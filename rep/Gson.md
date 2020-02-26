利用反射

默认不会序列化值为null的字段。可以通过如下方式：
 new GsonBuilder().serializeNulls().create();