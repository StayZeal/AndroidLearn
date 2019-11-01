每一个Thread有一个ThreadLocalMap：

ThreadLocalMap里面维护一个Entry的数组，Entry的key(弱引用)为变量ThreadLocal，value(强引用)就是set(T t)的参数T

使用不当会导致内存泄漏，不使用时最好调用remove()方法

说一句废话：源码中的set和get操作没有加锁，是因为所有的操作都是单线程的。