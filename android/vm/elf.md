### Oat/Elf 文件格式

Art虚拟机可以运行dex文件，也可以运行oat文件，oat文件扩展名为odex，内部是elf文件格式。

#### 疑问

Android Oat文件为什么要套一个Elf文件的壳？

猜想：elf文件是Linux支持的可执行文件，Oat文件封装成elf，就可以方便使用so等共享库，
包括使用Linux的接口加载已经运行oat文件，以及动态链接其他so库。

![elf1](img/elf-all.png)

截图来自010 editor ，文件为Android的odex文件（dex经过dex2oat的文件，Android 9.0），也是一个elf文件。

#### 主要分四部分：

- elf header:主要用了描述文件版本号，格式等信息。从上图中的名字我们可以推断header包含的信息。
（Value列的值为10进制，e_phentsize的value代表字节数，start和size是16进制-可以理解为是bit）

![elf2](img/elf-header.png)

- program header:

- section header:

- dynamic symbol:

#### 罗升阳的图(Art 5.0?)

![luoshengyang](img/oat-luoshengyang.png)


>作为Android私有的一种ELF文件，OAT文件包含有两个特殊的段oatdata和oatexec，前者包含有用来生成本地机器指令的dex文件内容，
后者包含有生成的本地机器指令，它们之间的关系通过储存在oatdata段前面的oat头部描述。此外，在OAT文件的dynamic段，
导出了三个符号oatdata、oatexec和oatlastword，它们的值就是用来界定oatdata段和oatexec段的起止位置的。
其中，[oatdata, oatexec - 1]描述的是oatdata段的起止位置，而[oatexec, oatlastword + 3]描述的是oatexec的起止位置。

https://blog.csdn.net/Luoshengyang/article/details/39307813

罗老师的图是对应的老版本的oat文件，但是罗老师文章中的分析过程还是值得学习的。按照罗老师的思路就可以分析出新版的oat文件的变化

其他：https://blog.csdn.net/TaylorPotter/article/details/89855346

vdex反编译：https://www.freebuf.com/sectool/185881.html

#### 思考
不管是oat、art、vdex文件搞这么复杂主要是为了可以通过mmap快速把对象加载到内存中，提高了对象创建的速度。