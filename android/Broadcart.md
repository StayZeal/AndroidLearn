### Broadcast&BroadcastReceiver

- 无须广播：sendBroadcast(Intent)

- 有序广播：sendOrderedBroadcast(Intent, String)，当接收器逐个顺序执行时，接收器可以向下传递结果，也可以完全中止广播，
使其不再传递给其他接收器。接收器的运行顺序可以通过匹配的 intent-filter 的 android:priority 属性来控制；具有相同优
先级的接收器将按随机顺序运行

- 本地广播：LocalBroadcastManager.sendBroadcast

- Sticky广播：Context.sendStickyBroadcast()，用此函数发送的广播会一直滞留，当有匹配此广播的广播接收器被注册后，
该广播接收器就会收到此条信息。

使用此函数需要发送广播时，需要获得BROADCAST_STICKY权限
```xml
<uses-permission android:name="android.permission.BROADCAST_STICKY"/>
```
sendStickyBroadcast只保留最后一条广播，并且一直保留下去，这样即使已经有广播接收器处理了该广播，当再有匹配的广播
接收器被注册时，此广播仍会被接收。如果你只想处理一遍该广播，可以通过removeStickyBroadcast()函数来实现。



#### 指定广播发送权限： 

`sendBroadcast(new Intent("com.example.NOTIFY"),Manifest.permission.SEND_SMS);`

#### 对进程状态的影响

BroadcastReceiver 的状态（无论它是否在运行）会影响其所在进程的状态，而其所在进程的状态又会影响它被系统终结的可能性。
例如，当进程执行接收器（即当前在运行其 onReceive() 方法中的代码）时，它被认为是前台进程。除非遇到极大的内存压力，
否则系统会保持该进程运行。
但是，一旦从 onReceive() 返回代码，BroadcastReceiver 就不再活跃。

#### 恶意广播

1、可以在注册广播接收器时指定权限。
2、对于清单声明的接收器，您可以在清单中将 android:exported 属性设置为“false”。
3、可以使用 LocalBroadcastManager 限制您的应用只接收本地广播。

动态广播注册：

AMS的mRegisteredReceivers
mReceiverResolver