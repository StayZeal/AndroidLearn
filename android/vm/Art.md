### Art虚拟机

Dalvik使用Jit，每次应用启动Jit过程就会重新开始，不会复用。而且Jit是发生在运行时。

Art使用AOT，提前把字节码编译成本地机器码，但是不会所有的字节码全部编译成字节码，这样会导致APK安装速度太慢，因为编译过程是
在安装过程中进行的（记得每次开机或者系统OTA都会造成APK的重新安装）。

即使是Art虚拟机，也可以开启解释执行、Jit所有可以反推Art并不是把所有代码进行AOT，而是随着程序运行把部分代码进行AOT，这样
既兼容了运行速度（不用每次Jit），也提高了安装速度。

Art执行Jit和Aot过程：

![](img/jit-workflow.png)

https://source.android.com/devices/tech/dalvik/jit-compiler

为了进一步提到dex2aot的效率，Android O引入了[vdex](dex.md)。