#### 问题描述

两个aar项目分别在连个git仓库，现在要把两个aar合并，已方便打成一个aar.

#### 处理方案

1、通过sourcesSet指定代码路径：包括AndroidManifest,Java,res等。

AndroidManifest中的package要使用一个，不然无法找到R.java文件

2、cmake也可以自定义路径，但是无法通过sourceSet指定，可以在cmake脚本中做flavor的判断（未作）

3、aar版本号，如果要保留两个aar的版本号，可以通过自定义BuildConfig的属性实现。

