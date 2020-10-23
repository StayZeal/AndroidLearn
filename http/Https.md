### HTTPS协议

Https是在Http协议的底层增加一个SSL/TLS来实现。

原理：建立连接时，获取一个对称加密的秘钥A，用来在之后的通信过程中使用。而这个对称加密的秘钥A，是通过非对称加密的方式从服务端获取，
并且使用证书中的公钥进行解密。

#### 握手过程

[详细过程](Https握手.md)

请求百度实例，使用了DH算法产生密钥:

![](img/tls抓包.png)


#### 优化
百度Http优化实例，Session复用：

![](img/baidu_handshake.png)

Session复用:

![](img/baidu_session复用.png)


[优化方案](Http优化.md)

#### 抓包教程

WireShark抓包 ： https://www.cnblogs.com/linyfeng/p/9496126.html

#### 证书

[Https证书生成](自签名证书生成.md)

[Https证书校验](证书校验过程.md)
 
https://www.ssl.com/article/browsers-and-certificate-validation/#

Https证书过期

https://juejin.im/post/5e689e336fb9a07c9e1c3903
