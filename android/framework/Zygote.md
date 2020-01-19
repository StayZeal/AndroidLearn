#### system_server和zygote通信为什么使用Socket?

首先，Binder通信需要使用Binder线程池。

然后，Zygote 在fork进程之前，会把多余的线程（包括Binder线程）都杀掉只保留一个线程。所以此时就无法把结果通过Binder
把消息发送给system_server。fork()进程完成之后Zygote也会把其他线程重新启动，这时候也即使有了Binder线程，也无法重新建立连接。

由于fork进程（Zygote）出来的进程A只有一个线程，如果Zygote有多个进程，那么A会丢失其他进程。这时可能造成死锁。

http://www.doublersolutions.com/docs/dce/osfdocs/htmls/develop/appdev/Appde193.htm