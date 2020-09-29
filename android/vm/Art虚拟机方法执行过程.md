Art 9.0源码 

文件：vim art/runtime/jni_internal.cc

CallStaticVoidMethodV
调用：InvokeWithVarArgs

文件：vim art/runtime/reflection.cc +437

调用：InvokeWithArgArray
```c++

static void InvokeWithArgArray(const ScopedObjectAccessAlreadyRunnable& soa,
                               ArtMethod* method, ArgArray* arg_array, JValue* result,
                               const char* shorty)
    SHARED_LOCKS_REQUIRED(Locks::mutator_lock_) {
  uint32_t* args = arg_array->GetArray();
  if (UNLIKELY(soa.Env()->check_jni)) {
    CheckMethodArguments(soa.Vm(), method->GetInterfaceMethodIfProxy(sizeof(void*)), args);
  }
  method->Invoke(soa.Self(), args, arg_array->GetNumBytes(), result, shorty);
}
```
ArtMethod::Invoke()方法的实现
文件：vim art/runtime/art_method.cc +392