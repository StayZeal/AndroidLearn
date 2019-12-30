### Binder机制

#### 重要性
Binder是用来进行跨进程通信的，Android的四大组件都是由ActivityManagerService进行管理，包括Activity生命周期，Service的启动等。
而ActivityManagerService运行在system_server进程，App都运行在自己的进程中，所以Android系统基本时时刻刻都在进行跨进程通信。

#### 为什么选择Binder
跨进程通信的方式有很多种，比如：Socket (Android系统中也有使用Socket进程的通信)、Pipe等。之所以使用Binder，
是因为只需要一次内存拷贝，主要是通过Linux内核提供的mmap功能了来实现的。

#### 跨进程通信要点

不同的进程有不同的地址空间，进程中对象使用的都是相对地址，而不知道在内存中的绝对地址，所以进程A不可能直接拿到进程B中的对象，
这时就需要通过内核辅助完成这个功能。

#### 一些实现细节

#### 匿名共享内存


ActivityManagerService就是通socket来和zygote进程通信,eg.请求fork一个应用程序进程。