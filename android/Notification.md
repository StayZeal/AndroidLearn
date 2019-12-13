#### 显示：System UI的StatusBar

#### 管理：NotificationManagerService

#### 权限：

1.应用通知管理

2.通知使用权

StatusBar通过实现NotificationListenerService来管理通知

https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/packages/SystemUI/src/com/android/systemui/statusbar/NotificationListener.java

https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/packages/SystemUI/src/com/android/systemui/statusbar/phone/NotificationListenerWithPlugins.java

#### 同一个App的通知栏被合并

```
.setGroup("test1")//8.0 9.0 需要设置这个属性，setGroupSummary(false)才能生效
.setGroupSummary(false)
```

pendingIntent request相同会导致Intent不变？


查看通知服务
adb shell dumpsys notification
```
  Notification listeners:
    All notification listeners (4) enabled for current profiles:
      ComponentInfo{team.ultraapp.cleaner.booster.master/com.ehawk.newcleaner.notifyclean.service.NotificationMonitor}
      ComponentInfo{com.qihoo.cleandroid_cn/com.qihoo360.mobilesafe.notifymanage.NotifyBlockerService}
      ComponentInfo{com.qiku.android.launcher3/com.qiku.android.launcher3.badge.NotificationListener}
      ComponentInfo{com.anyun.cleaner/com.anyun.cleaner.notify.NotifyService}
    Live notification listeners (5):
      ComponentInfo{com.android.systemui/com.android.systemui.statusbar.phone.PhoneStatusBar} (user -1): android.service.notification.INotificationListener$Stub$Proxy@c1d4d0f SYSTEM
      ComponentInfo{com.android.systemui/com.qiku.magazine.keyguard.NotificationStackScrollLayoutHelper} (user -1): android.service.notification.INotificationListener$Stub$Proxy@e8e919c SYSTEM
      ComponentInfo{android.ext.services/android.ext.services.notification.Ranker} (user 0): android.service.notification.INotificationListener$Stub$Proxy@db9b7a5 SYSTEM GUEST
      ComponentInfo{com.qiku.android.launcher3/com.qiku.android.launcher3.badge.NotificationListener} (user 0): android.service.notification.INotificationListener$Stub$Proxy@ca5a77a
      ComponentInfo{com.qihoo.cleandroid_cn/com.qihoo360.mobilesafe.notifymanage.NotifyBlockerService} (user 0): android.service.notification.INotificationListener$Stub$Proxy@debab2b
    Snoozed notification listeners (0):
    mListenerHints: 0
    mListenersDisablingEffects: ()
```