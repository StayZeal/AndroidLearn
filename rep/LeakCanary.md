### LeakCanary

之所以能有检测内存泄漏，主要是以Activity和Fragment的生命周期作为参考。在Activity的onDestroy()调用时，判断应该被回收的对象是否被回收。

在onDestroy()持有一个弱引用并保存到ReferenceQueue中，如果被回收，就能在ReferenceQueue中找到该对象。

在判断Activity是否被回首时，判断了两次；第一次直接判断，虽然此时Activity应该被回收了，但是由于Jvm的垃圾回收机制并不是
立即回首，所以需要手动触发gc，再次判断才能确定是否无法回首。