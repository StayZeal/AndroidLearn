### JniEnv在多线程环境的使用

JniEnv的内存肯定是分配在堆上的，所以理论上是多线程都可以访问到这个结构体（对象）？但是Android的文档却说不能夸进程使用。
这是怎么回事呢？到底是哪里限制JniEnv的多线程使用呢？

### 报错

如果多线程使用同一个JniEnv，会报错：
```
Abort message: 'Java_vm_ext.cc:542] JNI DETECTED ERROR IN APPLICATION: a thread (tid 24680 is making JNI calls without being attached'
```

查看源码：
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

### 线程

在Android中有Java线程和Native线程，这两种线程都是系统线程，区别就是Java线程有Jni环境，而Native线程没有Jni环境（
不能直接调用Jni的方法，进而和Java对象进行互调）

### 猜想

不管是Java线程还是Native线程都有一个单独的栈，在程序执行的过程中如果涉及到Jni的调用，
那么同一个线程Java和Native是需要维护两个不同的栈的。Java线程通过Jni是可以执行Native代码的，也就是可以理解为通过Jni可以
维护好同一个线程的Java的栈和Native的栈。如果多个Native栈（多个线程）共用通过一个Java栈（一个线程），肯定是有问题的，
所以JniEnv不能被多线程共用，即每一个Native需要有自己的JniEnv。

PS：Native和Java的堆应该不是同一个堆，

### 验证

//TODO 翻阅源码


### 多线程JniEnv的使用方法

每一个使用Jni的线程都要Attach到Jvm（每个进程只有一个Jvm实例）上，然后获取到每个线程的JniEnv的指针。