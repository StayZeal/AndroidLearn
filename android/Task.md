#### 任务和返回栈

Activity实例是否存在还要根据Context是否相同来进行判断。

官方文档：https://developer.android.com/guide/components/tasks-and-back-stack.html?hl=zh-CN

[解开Android应用程序组件Activity的"singleTask"之谜](https://blog.csdn.net/luoshengyang/article/details/6714543)

相关的重要的三部分：
- launchMode
- taskAffinity
- Intent的flag
```
通过使用 <activity> 清单文件元素中的属性和传递给 startActivity() 的 Intent 中的标志，您可以执行所有这些操作以及其他操作。
在这一方面，您可以使用的主要 <activity> 属性包括：
taskAffinity
launchMode
allowTaskReparenting
clearTaskOnLaunch
alwaysRetainTaskState
finishOnTaskLaunch
您可以使用的主要 Intent 标志包括：

FLAG_ACTIVITY_NEW_TASK
FLAG_ACTIVITY_CLEAR_TOP
FLAG_ACTIVITY_SINGLE_TOP
```

#### make sure to test the usability of the activity during launch