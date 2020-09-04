### Dex文件格式

Dex中文件的method和class是单独存放的。

Method：每一个method都有它的类信息。

Class：每一个class都有它的方法信息。

但是方法调用时，直接根据method信息进行查找，而不用先找到对应的类。