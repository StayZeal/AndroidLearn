### Art虚拟机的Compacting GC

所谓Compacting GC，就是在进行GC的时候，同时对堆空间进行压缩，以消除碎片，因此它的堆空间利用率就更高。
但是也正因为要对堆空间进行压缩，导致Compacting GC的GC效率不如Mark-Sweep GC。不过，只要我们使用得到恰当，
是能够同时发挥Compacting GC和Mark-Sweep GC的长处的。例如，当Android应用程序被激活在前台运行时，
就使用Mark-Sweep GC，而当Android应用程序回退到后台运行时，就使用Compacting GC。    

压缩空间的GC，需要对对象进行移动。一个对象被移动了，要保持它的使用者的正确性，无非就是两种方案：

- 使用者不是直接引用对象，而是间接引用。

- 第二种对象移动技术，也就是修改对象使用者的引用，使得它无论何时何地，总是直接指向对象的真实地址。


对象移动技术，是根据Object的monitor的高2位为0x11即kForwardingAddress状态时，取monitor的低30作为对象的新值。

>存疑?
>此处我的理解仍然是类似于间接引用，这样的方式相当于把对象的引用方式分为两种，一种是直接，一种是间接，而区分标志就是
>monitor的高2位的值。并且这种间接引用只会在第一发现是间接引用之后，就会更新直接引用，这样间接引用只会使用一次。

参考：https://blog.csdn.net/luoshengyang/article/details/44513977