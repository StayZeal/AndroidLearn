### SurfaceView

#### 首先知道View显示在屏幕的过程

[Android图形界面](Android图形界面.md)

#### 其次，为什么需要SurfaceView？

1、Android的UI只能主线程更新，这是为了保证View只能单进程更新，以免多线程导致错误显示（因为性能要求，没有使用锁）。
很多系统的更新原则都是这样，eg.js;为了保证这一点，Android在ViewRootImpl进行了线程判断，如果不是主线程
则会抛CalledFromWrongThreadException。

2、但是主线程要做的事情太多，当UI更新任务太重的时候会导致主线程卡死，无法响应其他事件。在游戏，或者视频时，可能会导致这种情况。
所以提供一个SurfaceView来提供一种多线程更新UI的能力。SurfaceView单独持有Surface，和主进程持有的Surface不是同一个。
其实更新SurfaceView的线程也是只有一个。从这个意义上来说，更新UI（Surface）还是单线程的。

#### 然后，SurfaceView怎么使用

#### 最后SurfaceView的原理