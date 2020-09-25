
1、Android 10上 dex2oat没法调用了

针对Android10支付宝在apk放了libdex2oat10.so

2、参考了Tinker的dex2oat
```
                commandAndParams.add("dex2oat");
                // for 7.1.1, duplicate class fix
                if (Build.VERSION.SDK_INT >= 24) {
                    commandAndParams.add("--runtime-arg");
                    commandAndParams.add("-classpath");
                    commandAndParams.add("--runtime-arg");
                    commandAndParams.add("&");
                }
                commandAndParams.add("--dex-file=" + dexFilePath);
                commandAndParams.add("--oat-file=" + oatFilePath);
                commandAndParams.add("--instruction-set=" + targetISA);
                if (Build.VERSION.SDK_INT > 25) {
                    commandAndParams.add("--compiler-filter=quicken");
                } else {
                    commandAndParams.add("--compiler-filter=interpret-only");
                }
```

https://www.jianshu.com/p/8a0a05c34c43

### 继续

1、new PathClassLoader()会触发dex2oat,Tinker和支付宝中都有这些代码，原理参考PathClassLoader()源码。

使用Tinker(dex2oat)技术的有：微信，头条，支付宝


2、头条监听/data/misc/profiles/cur/0中的文件，直接触发dex2oat

cmd package compile -m speed-profile -f com.ss.android.article.lite

这样不但不用等待系统进入空闲模式才进行dex2oat，还能释放jit占用的内存，降低内存占用。

https://cloud.tencent.com/developer/article/1005485

找来找去发现跟热更新技术耦合越来越重，最后的构想是通过手动生成jit profile文件，来优化启动速度的！

3、data/app/存放oat的目录，app没有权限，所以只能放到有权限的目录。比如data/data目录，然后要解决让系统加载我们自定义路径的
oat文件


发现Google Play也有优化，
Google Play现在除了APK文件之外，还会交付一套基于云端的ART Profile配置文件Dex Metadata(.dm)。

这个dm文件是从大数据用户那里搜集整理的APK对应的"热代码"文件，在通过GP安装apk时，会跟据dm文件提前进行优化编译，
而不必等到用户使用一段时间生成热代码后再编译，可以显著提升首次启动速度。

链接：https://www.jianshu.com/p/734fa7fbbbc1

但是只在安装时有用。不过也提供了可以让app运行一段时间，生成prof文件。然后提供给app使用，不知道prof文件跟cpu架构有关么？
dex,art,vdex文件https://www.jianshu.com/p/065e358b9599

>methods 和 classes 后面的数据，表示他们在dex文件中的index。

所以应该没有关系，那是不是代表整个方案确实靠谱？

头条pulgin目录下发现apk.cur.prof文件不知何用？

