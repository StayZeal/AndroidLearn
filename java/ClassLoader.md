### ClassLoader

#### 双亲委托机制

ClassLoader需要加载一个类时，首先会请求父加载器去加载，如果父加载器无法加载，自己才去加载。

优点：避免类重复加载

#### Class.forName vs ClassLoader.loadClass

Class.forName() 方法可以获取原生类型(int,float等)的 Class，而 ClassLoader.loadClass() 则会报错。

https://juejin.im/post/5c04892351882516e70dcc9b