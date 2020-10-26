### Android GC的发展过程

#### Dalvik

算法：Mark-Sweep

内存区域：Zygote Heap，Active Heap

是否支持并发：是

缺点：无法整理内存碎片

触发垃圾回收的时机：

- GC_FOR_MALLOC: 表示是在堆上分配对象时内存不足触发的GC。

- GC_CONCURRENT: 表示是在已分配内存达到一定量之后触发的GC。

- GC_EXPLICIT: 表示是应用程序调用System.gc、VMRuntime.gc接口或者收到SIGUSR1信号时触发的GC。

- GC_BEFORE_OOM: 表示是在准备抛OOM异常之前进行的最后努力而触发的GC。

-----------------------------------------参考-----------------------------------------------------

- Dalvik虚拟机在Java堆上分配对象的时候，在碰到分配失败的情况，会尝试调用函数gcForMalloc进行垃圾回收

- 当Dalvik虚拟机成功地在堆上分配一个对象之后，会检查一下当前分配的内存是否超出一个阈值。触发GC_CONCURRENT类型的GC。

- 显示调用

#### Art

算法：

- Compacting GC，就是在进行GC的时候，同时对堆空间进行压缩，以消除碎片，因此它的堆空间利用率就更高。
但是也正因为要对堆空间进行压缩，导致Compacting GC的GC效率不如Mark-Sweep GC。（Android 5.0添加）

- Mark-Sweep GC

内存区域：Image Space、Zygote Space、Allocation Space和Large Object Space

是否支持并发：是

使用方式：Mark-Sweep GC适合作为Foreground GC，而Compacting GC适合作为Background GC。

