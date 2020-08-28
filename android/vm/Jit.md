### Jit

#### Jit依据

在 JVM 中，编译是基于两个计数器的：一个是方法被调用的次数，另一个是方法中循环被回弹执行的次数。回弹可以有效的被认为是
循环被执行完成的次数，不仅因为它是循环的结尾，也可能是因为它执行到了一个分支语句，例如 continue。

#### Jit调优

- 优化代码缓存

- 编译阈值

- 调整编译线程个数

参考：https://developer.ibm.com/zh/technologies/java/articles/j-lo-just-in-time/