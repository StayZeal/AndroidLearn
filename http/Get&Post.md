#### GET和POST

一句话解释：GET请求是幂等的，即多次请求结果不变；POST请求不是幂等的，即多次请求结果不同。

如果客户端和服务端都是自己实现的话，两者可以实现的没有区别；两者的区别主要是针对浏览器的对两个协议实现的区别。
一般的GET请求参数在请求地址中，并且浏览器有长度限制。
PS:OkHTTP缓存只缓存GET请求，但是没有缓存POST请求

GET 和 POST 到底有什么区别？ - 大宽宽的回答 - 知乎
https://www.zhihu.com/question/28586791/answer/767316172