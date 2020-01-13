### SharedPreferences

#### get操作
如果已经加载文件放入内存了，则直接从内存读取。否则等待文件加载。

#### edit()
每次返回一个新的Editor对象

#### commit操作

需要先写入内存缓存，然后写入到文件

#### apply操作

开启一个HandlerThread异步写入到文件


不支持多进程操作

SharedPreferences会造成ANR
```
"main" prio=5 tid=1 Waiting
  | group="main" sCount=1 dsCount=0 obj=0x743008a8 self=0xb7fe0ba0
  | sysTid=24444 nice=-6 cgrp=default sched=0/0 handle=0xb6f31c00
  | state=S schedstat=( 0 0 0 ) utm=17881 stm=900 core=3 HZ=100
  | stack=0xbe53d000-0xbe53f000 stackSize=8MB
  | held mutexes=
  at java.lang.Object.wait!(Native method)
  - waiting on <0x0da0597c> (a java.lang.Object)
  at java.lang.Thread.parkFor$(Thread.java:1220)
  - locked <0x0da0597c> (a java.lang.Object)
  at sun.misc.Unsafe.park(Unsafe.java:299)
  at java.util.concurrent.locks.LockSupport.park(LockSupport.java:158)
  at java.util.concurrent.locks.AbstractQueuedSynchronizer.parkAndCheckInterrupt(AbstractQueuedSynchronizer.java:810)
  at java.util.concurrent.locks.AbstractQueuedSynchronizer.doAcquireSharedInterruptibly(AbstractQueuedSynchronizer.java:971)
  at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquireSharedInterruptibly(AbstractQueuedSynchronizer.java:1278)
  at java.util.concurrent.CountDownLatch.await(CountDownLatch.java:203)
  at android.app.SharedPreferencesImpl$EditorImpl$1.run(SharedPreferencesImpl.java:366)
  at android.app.QueuedWork.waitToFinish(QueuedWork.java:88)
  at android.app.ActivityThread.handleServiceArgs(ActivityThread.java:3041)
  at android.app.ActivityThread.-wrap17(ActivityThread.java:-1)
  at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1455)
  at android.os.Handler.dispatchMessage(Handler.java:102)
  at android.os.Looper.loop(Looper.java:148)
  at android.app.ActivityThread.main(ActivityThread.java:5497)
  at java.lang.reflect.Method.invoke!(Native method)
  at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:799)
  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:689)
```