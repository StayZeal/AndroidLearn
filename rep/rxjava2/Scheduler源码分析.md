**IO线程池缓存的是ScheduledExecutorService线程池，而不是缓存的线程**(通过注释就可以看到这点，我还傻乎乎的下载了源码调试)

NewThreadWorker持有一个[ScheduledExecutorService](../../java/thread/线程池.md)；

IoScheduler：默认最多持有线程数不限。

ComputationScheduler：默认最多持有CPU核数的线程池，多余的任务放入ScheduledExecutorService的任务队列中。

NewThreadScheduler：每次都启动一个新的线程池，不会复用。

SingleScheduler：每次都使用同一个线程执行任务，单线程模型。