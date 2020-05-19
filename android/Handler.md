### Handler机制
消息循环

底层使用epoll机制，没有消息时就睡眠，所以不会阻塞CPU

#### Idle执行时机
注释中明确的指出当消息队列空闲时会执行 IdelHandler 的 queueIdle() 方法，该方法返回一个 boolean 值，
 如果为 false 则执行完毕之后移除这条消息， 如果为 true 则保留，等到下次空闲时会再次执行
