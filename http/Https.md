
Https是在Http协议的底层增加一个SSL/TLS来实现。

原理：建立连接时，获取一个对称加密的秘钥A，用来在之后的通信过程中使用。而这个对称加密的秘钥A，是通过非对称加密的方式从服务端获取，
并且使用证书中的公钥进行解密。

#### 握手过程

![](img/https_handshake.webp)


步骤：
![](img/ssl_handshake.png)

1 Client Hello	
生成Client random

2 Server Hello

生成Server random

3 certificate

4 (server_key_exchange)
5 (certificate_request)
6 server_hello_done
7 (certificate)
8 client_key_exchange

生成pre-master secret.然后通过证书里面的公钥加密发送给Server。Server收到pre-master然后用私钥解密。
此时Client和Server都有三个随机数。

如果是DH算法，这里发送的就是客户端的DH参数，之后服务器和客户端根据DH算法，各自计算出相同的pre-master secret。

>PS:这里使用RSA算法还是DH算法是不一样的。

9 (certifiate_verify)
10 change_cypher_spec
11 change_cypher_spec

参考：https://blog.csdn.net/fw0124/article/details/40983787

实例:

![](img/tls抓包.png)

百度实例：

![](img/baidu_handshake.png)

session 复用

![](img/baidu_session复用.png)

WireShark抓包 ： https://www.cnblogs.com/linyfeng/p/9496126.html

[Https证书生成](自签名证书生成.md)

[Https证书校验](证书校验过程.md)
 
https://www.ssl.com/article/browsers-and-certificate-validation/#

Https证书过期

https://juejin.im/post/5e689e336fb9a07c9e1c3903



>Diffie-Hellman:一种确保共享KEY安全穿越不安全网络的方法，它是OAKLEY的一个组成部分。Whitefield与Martin Hellman
>在1976年提出了一个奇妙的密钥交换协议，称为Diffie-Hellman密钥交换协议/算法(Diffie-Hellman Key Exchange/Agreement Algorithm).
>这个机制的巧妙在于需要安全通信的双方可以用这个方法确定对称密钥。然后可以用这个密钥进行加密和解密。但是注意，这个密钥交换协议/算法只能用于密钥的交换，而不能进行消息的加密和解密。双方确定要用的密钥后，要使用其他对称密钥操作加密算法实际加密和解密消息。
 DH 算法的握手阶段 
 整个握手阶段都不加密（也没法加密），都是明文的。因此，如果有人窃听通信，他可以知道双方选择的加密方法，以及三个随机数中的两个。整个通话的安全，只取决于第三个随机数（Premaster secret）能不能被破解。 
 虽然理论上，只要服务器的公钥足够长（比如2048位），那么Premaster secret可以保证不被破解。但是为了足够安全，我们可以考虑把握手阶段的算法从默认的RSA算法，改为 Diffie-Hellman算法（简称DH算法）。 
 采用DH算法后，Premaster secret不需要传递，双方只要交换各自的参数，就可以算出这个随机数。
 DH算法的一个简单描述： 
> 1) A随机产生一个大整数a，然后计算Ka=ga mod n。（a需要保密） 
> 2) B随机产生一个大整数b，然后计算Kb=gb mod n。（b需要保密） 
> 3) A把Ka发送给B,B把Kb发送给A 
> 4) A计算K=Kba mod n 
> 5) B计算K=Kab mod n 
 由于Kba mod n= （gb mod n）a mod n= （ga mod n）b mod n，因此可以保证双方得到的K是相同的，K即是共享的密钥。 
 意思是说client与server端都有一个随机数是不会通过网络传输的。所以保证了安全。 




