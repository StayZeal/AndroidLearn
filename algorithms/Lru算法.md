Glide的LRU Cache使用的是[LinkedHashMap](../java/hashmap/LinkeHashMap.md)实现；按照访问顺序来控制LinkedHashMap的顺序；

然后增加Size的判断，当超过Size时从Map中移除。

[LinkedHashMap](../java/hashmap/LinkeHashMap.md)使用的双向链表，每次增加/更新会把节点发到tail的位置，所以header就是最旧的数据


https://github.com/StayZeal/AndroidLearn/blob/master/algorithms/java/hashmap/LinkeHashMap.md
https://github.com/StayZeal/AndroidLearn/blob/master/java/hashmap/LinkeHashMap.md