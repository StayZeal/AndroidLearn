Android并不支持Java8的所有特性，只是支持一个语法糖。完全支持Java8语法糖，需要开启D8（进行脱糖处理）：

```groovy
android.enableD8.desugaring = true
android.enableD8=true
```