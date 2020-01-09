### sleep wait notify notifyAll

sleep：不会释放锁

wait：会释放锁

notify/notifyAll的线程（A）之后wait的线程（B）不一定立即返回，需要A释放锁之后才能返回；
必须等到synchronized方法或者语法块执行完才真正释放锁。

如果有多个线程wait,那么哪个线程获取锁不确定。

Thread的join()：在A中调用bThread.jion，A需要等待bThread线程执行完毕。
