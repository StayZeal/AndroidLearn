### Android Dex文件

1、dex文件中描述方法长度的method_ids_size字段是一个uint类型，为啥方法数限制是64K（2的16次方）？

PS:Java的class文件中描述方法数的字段长度为16.

https://source.android.google.cn/devices/tech/dalvik/dex-format?hl=zh-cn#method-id-item

2、multi dex

在Art虚拟机中加载的是oat文件。oat文件是通过dex预编译形成，这个过程会把多个dex文件合并成同一个oat文件。所以不需要在代码中
处理多个dex的情况。具体的流程就是，AndroidStudio生成多个dex，而dex2ota把多个dex合并成一个oat文件。

而5.0以下的版本，即Dalvik虚拟机需要通过MultiDexApplication或者MultiDex.install(this)来处理多个dex的情况。并且过程
很复杂可能会造成anr。

https://developer.android.com/studio/build/multidex?hl=zh-cn

3、dex,odex,oat,vdex文件

- dex：原始文件

- odex：经过dexopt优化过的dex

- oat：经过dex2oat预编译过的文件.其实还是odex文件后缀。
普通app在data/user/包名/oat目录下
查看系统自带应用，比如system/priv-app/，system/app/中的apk，最终oat文件存放在/data/dalvik-cache/ 中

- vdex:其中包含 APK 的未压缩 DEX 代码，以及一些旨在加快验证速度的元数据。Android8.0引入，降低dex2oat执行耗时。

1、当系统OTA后，对于安装在data分区下的app，因为它们的apk都没有任何变化，那么在首次开机时，
对于这部分app如果有vdex文件存在的话，执行dexopt时就可以直接跳过verify流程，进入compile dex的流程，从而加速首次开机速度；

2、当app的jit profile信息变化时，background dexopt会在后台重新做dex2oat，因为有了vdex，这个时候也可以直接跳过

https://wwm0609.github.io/2017/12/21/android-vdex/

https://source.android.com/devices/tech/dalvik/configure