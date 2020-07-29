启动服务

```bash
adb shell am startservice com.test./.MyService
```
```bash

adb shell pm list packages webview  //查看指定的包
adb shell pm path com.test//获取包路径
adb shell pm dump com.test > ~/aaaa.txt
adb shell pm dump com.test | grep test
adb shell pm clear  com.test 
adb shell dumpsys package com.test| grep version
adb shell getprop | grep heap

1.查看oat文件
oatdump --oat-file=boot-os-framework.oat | grep handleNormalView
2.查看dex文件
dexdump os-framework.jar |grep dele

adb remount preset
adb shell umount /system/etc
adb shell umount /system/etc
```
