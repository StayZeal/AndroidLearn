#### 使用：
implementation 'com.android.volley:volley:1.1.1'

RequestQueue queue = Volley.newRequestQueue(this);

后台会启动5个线程：

1.一个CacheDispatcher；用来缓存

2.四个NetworkDispatcher；用来处理网络请求；

加载图片有NetworkImageView，内部使用ImageLoader

这个框架太古老了，好像还有[内存泄漏](../java/mem/MemoryLeak.md)的bug;取而代之的是OkHttp+Glide