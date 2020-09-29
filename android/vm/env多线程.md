### JniEnv在多线程环境的使用

#### 问题描述

JniEnv用来描述线程的Jni环境（从名字上来看就是不能跨进程使用的），但是在使用的过程存在如下疑问：

JniEnv的内存肯定是分配在堆上的，所以理论上是多线程都可以访问到这个结构体（对象）？但是Android的文档却说不能跨进程使用。
这是怎么回事呢？到底是哪里限制JniEnv的多线程使用呢？

#### 报错

如果多线程使用同一个JniEnv，会报错：
```
Abort message: 'Java_vm_ext.cc:542] JNI DETECTED ERROR IN APPLICATION: a thread (tid 24680 is making JNI calls without being attached'
```

找到报错的的源码：
```

  bool CheckThread(JNIEnv* env) SHARED_LOCKS_REQUIRED(Locks::mutator_lock_) {
    Thread* self = Thread::Current();
    if (self == nullptr) {
      AbortF("a thread (tid %d) is making JNI calls without being attached", GetTid());
      return false;
    }
    ...
  }
```
有点像Android的更新UI的主线程检查。所以我们找到了限制JniEnv多线程使用的地方。接下来我们研究为什么会有这种限制？

#### 线程

在Android中有Java线程和Native线程，这两种线程都是系统线程，区别就是Java线程有Jni环境，而Native线程没有Jni环境（
不能直接调用Jni的方法，进而和Java对象进行互调）。

#### 猜想

不管是Java线程还是Native线程都有一个单独的栈，在程序执行的过程中如果涉及到Jni的调用，
那么同一个线程Java和Native是需要维护两个不同的栈的。Java线程通过Jni是可以执行Native代码的，也就是可以理解为通过Jni可以
维护好同一个线程的Java的栈和Native的栈。如果多个Native栈（多个线程）共用通过一个Java栈（一个线程），肯定是有问题的，
所以JniEnv不能被多线程共用，即每一个Native线程（如果需要调用Java）需要有自己的JniEnv。

**PS：经过后面的验证这个猜想是正确的。**

#### 验证

我们以Dalvik的源码为例：

每一个能够调用Java代码的Native线程需要使用如下方式：
```
static int javaAttachThread(const char* threadName, JNIEnv** pEnv)
{
    JavaVMAttachArgs args;
    JavaVM* vm;
    jint result;
 
    vm = AndroidRuntime::getJavaVM();
    assert(vm != NULL);
 
    args.version = JNI_VERSION_1_4;
    args.name = (char*) threadName;
    args.group = NULL;
 
    result = vm->AttachCurrentThread(pEnv, (void*) &args);
    if (result != JNI_OK)
        LOGI("NOTE: attach of thread '%s' failed\n", threadName);
 
    return result;
}

```
AttachCurrentThread()中间会调用到dvmAttachCurrentThread():

```

bool dvmAttachCurrentThread(const JavaVMAttachArgs* pArgs, bool isDaemon)
{
    Thread* self = NULL;
    ......
    bool ok, ret;
 
    self = allocThread(gDvm.stackSize);
    ......
    setThreadSelf(self);
    ......
 
    ok = prepareThread(self);
    ......
    
    self->jniEnv = dvmCreateJNIEnv(self);
    ......
 
    self->next = gDvm.threadList->next;
    if (self->next != NULL)
        self->next->prev = self;
    self->prev = gDvm.threadList;
    gDvm.threadList->next = self;
    ......
 
    /* tell the debugger & DDM */
    if (gDvm.debuggerConnected)
        dvmDbgPostThreadStart(self);
 
    return ret;
 
    ......
}
```

然后会调用dvmCreateJNIEnv()，**参数self为当前线程**：
```

JNIEnv* dvmCreateJNIEnv(Thread* self)
{
    JavaVMExt* vm = (JavaVMExt*) gDvm.vmList;
    JNIEnvExt* newEnv;
 
    ......
 
    newEnv = (JNIEnvExt*) calloc(1, sizeof(JNIEnvExt));
    newEnv->funcTable = &gNativeInterface;
    newEnv->vm = vm;
 
    ......
 
    if (self != NULL) {
        dvmSetJniEnvThreadId((JNIEnv*) newEnv, self);
        assert(newEnv->envThreadId != 0);
    } else {
        /* make it obvious if we fail to initialize these later */
        newEnv->envThreadId = 0x77777775;
        newEnv->self = (Thread*) 0x77777779;
    }
 
    ......
 
    /* insert at head of list */
    newEnv->next = vm->envList;
    assert(newEnv->prev == NULL);
    if (vm->envList == NULL)            // rare, but possible
        vm->envList = newEnv;
    else
        vm->envList->prev = newEnv;
    vm->envList = newEnv;
 
    ......
 
    return (JNIEnv*) newEnv;
}
```
创建一个JNIEnvExt对象，用来描述一个JNI环境，并且设置这个JNIEnvExt对象的宿主Dalvik虚拟机，以及所使用的本地接口表，
即设置这个JNIEnvExt对象的成员变量funcTable和vm。这里的宿主Dalvik虚拟机即为当前进程的Dalvik虚拟机，
它保存在全局变量gDvm的成员变量vmList中。本地接口表由全局变量gNativeInterface来描述。

通过本地接口表gNativeInterface，我们就可以在Native线程中调用Java代码。比如：

```
env->CallStaticVoidMethod(startClass, startMeth, strArray)
```
CallStaticVoidMethod就在本地接口表gNativeInterface中。这个方法最终会调用到：

```

void dvmCallMethodV(Thread* self, const Method* method, Object* obj,
    bool fromJni, JValue* pResult, va_list args)
{
    ......
 
    if (dvmIsNativeMethod(method)) {
        TRACE_METHOD_ENTER(self, method);
        /*
         * Because we leave no space for local variables, "curFrame" points
         * directly at the method arguments.
         */
        (*method->nativeFunc)(self->curFrame, pResult, method, self);
        TRACE_METHOD_EXIT(self, method);
    } else {
        dvmInterpret(self, method, pResult);
    }
 
    ......
}
```

函数dvmCallMethodV首先检查参数method描述的函数是否是一个JNI方法。如果是的话，那么它所指向的一个Method对象的成员变
量nativeFunc就指向该JNI方法的地址，因此就可以直接对它进行调用。否则的话，就说明参数method描述的是一个Java函数，
这时候就需要继续调用函数dvmInterpret来执行它的代码。

```

void dvmInterpret(Thread* self, const Method* method, JValue* pResult)
{
    InterpState interpState;
    ......
 
    /*
     * Initialize working state.
     *
     * No need to initialize "retval".
     */
    interpState.method = method;
    interpState.fp = (u4*) self->curFrame;
    interpState.pc = method->insns;
    ......
 
    typedef bool (*Interpreter)(Thread*, InterpState*);
    Interpreter stdInterp;
    if (gDvm.executionMode == kExecutionModeInterpFast)
        stdInterp = dvmMterpStd;
#if defined(WITH_JIT)
    else if (gDvm.executionMode == kExecutionModeJit)
/* If profiling overhead can be kept low enough, we can use a profiling
 * mterp fast for both Jit and "fast" modes.  If overhead is too high,
 * create a specialized profiling interpreter.
 */
        stdInterp = dvmMterpStd;
#endif
    else
        stdInterp = dvmInterpretStd;
 
    change = true;
    while (change) {
        switch (interpState.nextMode) {
        case INTERP_STD:
            LOGVV("threadid=%d: interp STD\n", self->threadId);
            change = (*stdInterp)(self, &interpState);
            break;
        case INTERP_DBG:
            LOGVV("threadid=%d: interp DBG\n", self->threadId);
            change = dvmInterpretDbg(self, &interpState);
            break;
        default:
            dvmAbort();
        }
    }
 
    *pResult = interpState.retval;
 
    ......
}
```
在这个方法中我们可以看到执行Java代码时，会根据线程不同而使用不同的栈。所以我们看一下Thread* self指向的是哪个线程就能
判断JniEnv能否跨进程使用。  

#### 验证结果

通过前面的分析，每个线程调用dvmCreateJNIEnv()生成的JniEnv的self指向当前进程。
而在主线程中调用 pEnv = (JNIEnvExt*) dvmCreateJNIEnv(NULL)，参数为null，之后会设为主线程。

所以每一个JniEnv关联一个线程的栈，所以JniEnv不能夸线程使用。

#### 参考

罗升阳博客：https://blog.csdn.net/Luoshengyang/article/details/8852432