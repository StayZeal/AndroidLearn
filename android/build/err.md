
1、Missing Android platform(s) detected: 'android-29'

明明安装了29版本的sdk。后来发现时NDK没有配置。

2、 aar中应用的资源id，报了 android.content.res.Resources$NotFoundException

release版本中，R.string.name等资源id会被替换为具体的数值。在Apk重新打包的过程，会重新生成替换这个值。
可能是AS的bug，一直报异常。，更新了classpath 'com.android.tools.build:gradle:4.0.1'解决了（更新到最新版本）