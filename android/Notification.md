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