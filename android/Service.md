### Service

https://developer.android.com/guide/components/services?hl=zh-cn


如果组件通过调用 startService() 启动服务（这会引起对 onStartCommand() 的调用），则服务会一直运行，
直到其使用 stopSelf() 自行停止运行，或由其他组件通过调用 stopService() 将其停止为止。

如果组件通过调用 bindService() 来创建服务，且未调用 onStartCommand()，则服务只会在该组件与其绑定时运行。
当该服务与其所有组件取消绑定后，系统便会将其销毁。

只有在内存过低且必须回收系统资源以供拥有用户焦点的 Activity 使用时，Android 系统才会停止服务。
如果将服务绑定到拥有用户焦点的 Activity，则它其不太可能会终止；如果将服务声明为在前台运行，则其几乎永远不会终止。