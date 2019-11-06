RequestQueue queue = Volley.newRequestQueue(this);

后台会启动5个线程：

1.一个CacheDispatcher；用来缓存

2.四个NetworkDispatcher；用来处理网络请求；

加载图片有NetworkImageView，内部使用ImageLoader

这个框架太古老了;取而代之的是OkHttp+Glide