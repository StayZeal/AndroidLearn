### fork

#### 多进程环境fork

多进程fork分两种情况:

1、子进程包含父进程的所有线程：可能导致多线程重复执行，比如：从你的银行账户扣款。

2、子进程只包含一个线程(POSIX )：由于子进程复制了父进程的地址空间，包括：锁。如果相应的线程毫无征兆的退出，会导致锁无法释放。

解决方案：

在fork进程的时候，主动杀掉父进程的其他线程，然后fork.


原文翻译：

当fork()这个系统调用被使用之后，子进程会复制父进程的地址空间，所以两个进程会执行相同的代码。因此在多线程环境中fork()进程可能会出现问题。

当多线程是库调用的结果时，线程不一定知道彼此的存在，目的，动作等。假设其他线程之一（除进行fork（）之外的任何线程）
都具有从您的支票帐户中扣除钱的任务。显然，您不希望由于其他线程决定调用fork（）而导致这种情况发生两次。


http://www.doublersolutions.com/docs/dce/osfdocs/htmls/develop/appdev/Appde193.htm