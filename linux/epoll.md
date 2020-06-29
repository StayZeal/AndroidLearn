### select、poll和epoll

select用法：
```c
int select (int n, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
```

doc: https://man7.org/linux/man-pages/man2/select.2.html

select 函数监视的文件描述符分3类，分别是writefds、readfds、和exceptfds。调用后select函数会阻塞，
直到有描述副就绪（有数据 可读、可写、或者有except），或者超时（timeout指定等待时间，如果立即返回设为null即可），
函数返回。当select函数返回后，可以 通过遍历writefds、readfds、和exceptfds，来找到就绪的描述符。

epoll比select/poll的优越之处：因为后者每次调用时都要传递你所要监控的所有socket给select/poll系统调用，
这意味着需要将用户态的socket列表copy到内核态，如果以万计的句柄会导致每次都要copy几十几百KB的内存到内核态，非常低效。
而我们调用epoll_wait时就相当于以往调用select/poll，但是这时却不用传递socket句柄给内核，因为内核已经在epoll_ctl中拿到了要监控的句柄列表。
 
**my ps: 在函数调用和返回是需要从用户空间copy到内核空间和从内核空间copy到用户空间（writefds、readfds、和exceptfds），
而且哪个fd可以操作，需要遍历所有的fd；而epoll返回的events全部都是可以操作的；当有大量的可不操作的fd时，epoll的效率要高很多**

select目前几乎在所有的平台上支持，其良好跨平台支持也是它的一个优点。select的一个缺点在于单个进程能够监视的文件描述符
的数量存在最大限制，在Linux上一般为1024，可以通过修改宏定义甚至重新编译内核的方式提升这一限制，但 是这样也会造成效率的降低。

**my ps：fd都在用户空间打开，所以有1024的限制（ulimit -n）。而下面的epoll的fd是在内核空间打开，
所以收到的限制为系统能够打开的fd数量的限制（/proc/sys/fs/file-max）ubuntu:1600366,android:348504。
epoll 文档上针对每个用户还有额外限制（ /proc/sys/fs/epoll/max_user_watches，ubuntn:3322265,android:746536）**

poll用法：
```
int poll (struct pollfd *fds, unsigned int nfds, int timeout);
不同与select使用三个位图来表示三个fdset的方式，poll使用一个 pollfd的指针实现。

struct pollfd {
    int fd; /* file descriptor */
    short events; /* requested events to watch */
    short revents; /* returned events witnessed */
};
```

doc: https://man7.org/linux/man-pages/man2/poll.2.html

从上面看，select和poll都需要在返回后，通过遍历文件描述符来获取已经就绪的socket。
事实上，同时连接的大量客户端在一时刻可能只有很少的处于就绪状态，因此随着监视的描述符数量的增长，其效率也会线性下降。

epoll用法：
```c
int epoll_create(int size)；//创建一个epoll的句柄，size用来告诉内核这个监听的数目一共有多大
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event)；
int epoll_wait(int epfd, struct epoll_event * events, int maxevents, int timeout);
```
doc: https://man7.org/linux/man-pages/man7/epoll.7.html

epoll采用空间换时间的方式提高I/O的效率。


在 select/poll中，进程只有在调用一定的方法后，内核才对所有监视的文件描述符进行扫描，
而epoll事先通过epoll_ctl()来注册一 个文件描述符，一旦基于某个文件描述符就绪时，内核会采用类似callback的回调机制，
迅速激活这个文件描述符，当进程调用epoll_wait() 时便得到通知。
(此处去掉了遍历文件描述符，而是通过监听回调的的机制。这正是epoll的魅力所在。)


链接：https://segmentfault.com/a/1190000003063859