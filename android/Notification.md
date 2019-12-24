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
而有些国产手机使用的是Custom的SystemUI，样式无法控制。

//todo
pendingIntent requestCode相同会导致Intent不变？


查看通知服务
adb shell dumpsys notification
```
  Notification listeners:
    All notification listeners (4) enabled for current profiles:
      ComponentInfo{team.ultraapp.cleaner.booster.master/com.ehawk.newcleaner.notifyclean.service.NotificationMonitor}
    Live notification listeners (5):
      ComponentInfo{com.android.systemui/com.android.systemui.statusbar.phone.PhoneStatusBar} (user -1): android.service.notification.INotificationListener$Stub$Proxy@c1d4d0f SYSTEM
    Snoozed notification listeners (0):
    mListenerHints: 0
    mListenersDisablingEffects: ()
```