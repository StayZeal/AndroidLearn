### Http优化

1、不是使用DNS，直接使用ip。可以在应用初始化的时候获取相应的ip。

2、减少连接服务器个数-统一域名，达到减少DNS次数的目的。

3、使用Http 2.0，需要服务端支持

4、CDN

https://tech.meituan.com/2017/03/17/shark-sdk.html



sessionid复用：https://juejin.im/post/5b305758e51d4558ce5ea0d9#heading-19



### https://imququ.com/post/optimize-tls-handshake.html