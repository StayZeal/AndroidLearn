#### 思路

Jit 会生成Profile文件放到App目录来进行Aot

找了App的data/data和data/user目录没有

看Jit的源码？没找到

但是在Jit源码的目录下发现profile_saver.cc

在profile_saver.cc了解到需要启动线程来保存profile文件（猜测），并且尝试找profile文件的保存路径，最后定位到为dex的路径
感觉不太对。

ps -T |grep profile 没有

ps -T |grep Profile 有了，线程名为Profile Saver

说明：以上考虑到每个进程都需要jit，所以每个进程有应该有jit或者profile的相关线程

在源码中ag "Profile Saver",确实是在profile_saver.cc中

Jit里能找到的线索就这样了，那么我们从Aot入手，因为Profile是由Jit产生，Aot消耗。

查看dex2oat源码

搜索profile关键字

定位到profile路径是由main()参数传进来的，考录到定位main()方法的调用可能比较复杂，没有继续往下追。

继续看dex2oat源码 http://androidxref.com/9.0.0_r3/xref/art/dex2oat/dex2oat.cc

在LoadProfile()方法中发现ProfileCompilationInfo类的使用。而这个类在art/runtime/jit目录下
http://androidxref.com/9.0.0_r3/xref/art/runtime/jit/

猜想这个可能是profile文件内容的格式。

google 这个类

找到了博客：https://blog.csdn.net/hl09083253cy/article/details/78418809

直接在博客中搜索关键字ProfileCompilationInfo。

找到了！


#### /data/misc/profiles/cur/0/com.***.home # 



