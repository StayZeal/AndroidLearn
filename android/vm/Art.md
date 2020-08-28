### Art虚拟机

#### Dalvik

使用JIT，每次应用启动JIT过程就会重新开始，不会复用。而且JIT是发生在运行时。JIT的代码占用内存，在内存不够时，
占用的内存会被回收。

#### Art

使用AOT，提前把字节码编译成本地机器码，但是不会所有的字节码全部编译成字节码，这样会导致APK安装速度太慢，因为编译过程是
在安装过程中进行的（记得每次开机或者系统OTA都会造成APK的重新安装）。

即使是Art虚拟机，也可以开启解释执行、JIT所有可以反推Art并不是把所有代码进行AOT，而是随着程序运行把部分代码进行AOT，这样
既兼容了运行速度（不用每次JIT），也提高了安装速度。

>Android 7.0上，采用AOT/JIT 混合编译的策略，特点是：
 应用在安装的时候dex不会再被编译
 App运行时,dex文件先通过解析器被直接执行，热点函数会被识别并被JIT编译后存储在 jit code cache 中并生成profile文件以记录热点函数的信息。
 手机进入 IDLE（空闲） 或者 Charging（充电） 状态的时候，系统会扫描 App 目录下的 profile 文件并执行 AOT 过程进行编译。
>https://zhuanlan.zhihu.com/p/53723652

#### Art执行JIT和AOT过程

![JIT](./img/jit-workflow.png)

如果同时存在 JIT 和 AOT 代码（例如，由于反复进行逆优化），经过 JIT 编译的代码将是首选代码。

https://source.android.com/devices/tech/dalvik/jit-compiler

#### vdex

为了进一步提到dex2aot的效率，Android O引入了[vdex](dex.md)。