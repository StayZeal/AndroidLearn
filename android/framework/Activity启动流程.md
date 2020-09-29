#### Activity的启动流程

#### AMS流程

PMS解析Intent拿到ResolveInfo,通过ResolveInfo拿到ActivityInfo

创建一个ActivityRecord对象

创建TaskRecord taskToAffiliate对象

setTaskFromReuseOrCreateNewTask创建TaskRecord（Task）并放入ActivityStack mTargetStack中，把Activity放入Task

mTargetStack.startActivityLocked移到栈顶

在这里创建window和显示startingWindow

pause 上一个Activity

realStartActivityLocked()

#### 进程启动流程

Process启动进程，然后执行ActivityThread中的main()

ActivityThread的attach()

AMS的attachApplication()，参数有ApplicationThread

AMS的attachApplicationLocked()方法，调用ApplicationThread的bindApplication()和mStackSupervisor.attachApplicationLocked(app)

- ApplicationThread的bindApplication()调用ActivityThrea的handleBindApplication()方法。

- ActivityStackSupervisor mStackSupervisor.attachApplicationLocked(app)调用realStartActivityLocked()
