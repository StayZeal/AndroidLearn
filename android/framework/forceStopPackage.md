### Android杀进程- AMS forceStopPackage()源码分析

该方法需要权限android.permission.KILL_BACKGROUND_PROCESSES。


系统会强制停止与指定包关联的所有事情，将会杀死使用同一个uid的所有进程，停止所有服务，移除所有activity。所有注册的定时器和通知也会移除。

setPackageStoppedState()方法将包的状态设置为stopped，那么所有广播都无法接收，除非带有标记FLAG_INCLUDE_STOPPED_PACKAGES的广播，
系统默认的广播几乎都不带有该标记，也就意味着被force-stop的应用是无法通过建立手机网络状态或者亮灭屏广播来拉起进程的。

功能点归纳：

    1、force stop并不会杀死persistent进程；

    2、当app被force stop后，  无法接收到正常广播，那么也就无法通过监听手机网络状态的变化或亮灭屏来拉起进程；

    3、当app被force stop后，alarm闹钟一并被清理，无法实现定时响起的功能；

    4、当app被force stop后，四大组件以及相关进程被一一清理，即便多进程架构的app也无法拉起自己；

    5、级联诛杀：当app通过ClassLoader加载另一个app，则会在force stop的过程中会被级联诛杀；

    6、生死与共： 当app与另一个app使用了share uid，则会在force stop的过程，任意一方被杀则另一方也被杀，建立起生死与共的强关系。

```
public void forceStopPackage(final String packageName, int userId) {
        if (checkCallingPermission(android.Manifest.permission.FORCE_STOP_PACKAGES)
                != PackageManager.PERMISSION_GRANTED) {
            ...
        }
        final int callingPid = Binder.getCallingPid();
        userId = mUserController.handleIncomingUser(callingPid, Binder.getCallingUid(),
                userId, true, ALLOW_FULL_ONLY, "forceStopPackage", null);
        long callingId = Binder.clearCallingIdentity();
        try {
            IPackageManager pm = AppGlobals.getPackageManager();
            synchronized(this) {
                int[] users = userId == UserHandle.USER_ALL
                        ? mUserController.getUsers() : new int[] { userId };
                for (int user : users) {
                    int pkgUid = -1;
                    try {
                        pkgUid = pm.getPackageUid(packageName, MATCH_DEBUG_TRIAGED_MISSING,
                                user);
                    } catch (RemoteException e) {
                    }
                    if (pkgUid == -1) {
                        Slog.w(TAG, "Invalid packageName: " + packageName);
                        continue;
                    }
                    try {
                        pm.setPackageStoppedState(packageName, true, user);
                    } catch (RemoteException e) {
                    } catch (IllegalArgumentException e) {
                        Slog.w(TAG, "Failed trying to unstop package "
                                + packageName + ": " + e);
                    }
                    if (mUserController.isUserRunningLocked(user, 0)) {
                        forceStopPackageLocked(packageName, pkgUid, "from pid " + callingPid);//1
                        finishForceStopPackageLocked(packageName, pkgUid);//2
                    }
                }
            }
        } finally {
            Binder.restoreCallingIdentity(callingId);
        }
    }
```

```
final boolean forceStopPackageLocked(String packageName, int appId,
            boolean callerWillRestart, boolean purgeCache, boolean doit,
            boolean evenPersistent, boolean uninstalling, int userId, String reason) {
        int i;

        if (userId == UserHandle.USER_ALL && packageName == null) {
            Slog.w(TAG, "Can't force stop all processes of all users, that is insane!");
        }

        if (appId < 0 && packageName != null) {
            try {
                appId = UserHandle.getAppId(AppGlobals.getPackageManager()
                        .getPackageUid(packageName, MATCH_DEBUG_TRIAGED_MISSING, 0));
            } catch (RemoteException e) {
            }
        }

        if (doit) {
            if (packageName != null) {
                Slog.i(TAG, "Force stopping " + packageName + " appid=" + appId
                        + " user=" + userId + ": " + reason);
            } else {
                Slog.i(TAG, "Force stopping u" + userId + ": " + reason);
            }

            mAppErrors.resetProcessCrashTimeLocked(packageName == null, appId, userId);
        }

        boolean didSomething = killPackageProcessesLocked(packageName, appId, userId,
                ProcessList.INVALID_ADJ, callerWillRestart, true, doit, evenPersistent,
                packageName == null ? ("stop user " + userId) : ("stop " + packageName));

        didSomething |= mActivityStartController.clearPendingActivityLaunches(packageName);

        if (mStackSupervisor.finishDisabledPackageActivitiesLocked(
                packageName, null, doit, evenPersistent, userId)) {
            if (!doit) {
                return true;
            }
            didSomething = true;
        }

        if (mServices.bringDownDisabledPackageServicesLocked(
                packageName, null, userId, evenPersistent, true, doit)) {
            if (!doit) {
                return true;
            }
            didSomething = true;
        }

        if (packageName == null) {
            // Remove all sticky broadcasts from this user.
            mStickyBroadcasts.remove(userId);
        }

        ArrayList<ContentProviderRecord> providers = new ArrayList<>();
        if (mProviderMap.collectPackageProvidersLocked(packageName, null, doit, evenPersistent,
                userId, providers)) {
            if (!doit) {
                return true;
            }
            didSomething = true;
        }
        for (i = providers.size() - 1; i >= 0; i--) {
            removeDyingProviderLocked(null, providers.get(i), true);
        }

        // Remove transient permissions granted from/to this package/user
        removeUriPermissionsForPackageLocked(packageName, userId, false, false);

        if (doit) {
            for (i = mBroadcastQueues.length - 1; i >= 0; i--) {
                didSomething |= mBroadcastQueues[i].cleanupDisabledPackageReceiversLocked(
                        packageName, null, userId, doit);
            }
        }

        if (packageName == null || uninstalling) {
            // Remove pending intents.  For now we only do this when force
            // stopping users, because we have some problems when doing this
            // for packages -- app widgets are not currently cleaned up for
            // such packages, so they can be left with bad pending intents.
            if (mIntentSenderRecords.size() > 0) {
                Iterator<WeakReference<PendingIntentRecord>> it
                        = mIntentSenderRecords.values().iterator();
                while (it.hasNext()) {
                    WeakReference<PendingIntentRecord> wpir = it.next();
                    if (wpir == null) {
                        it.remove();
                        continue;
                    }
                    PendingIntentRecord pir = wpir.get();
                    if (pir == null) {
                        it.remove();
                        continue;
                    }
                    if (packageName == null) {
                        // Stopping user, remove all objects for the user.
                        if (pir.key.userId != userId) {
                            // Not the same user, skip it.
                            continue;
                        }
                    } else {
                        if (UserHandle.getAppId(pir.uid) != appId) {
                            // Different app id, skip it.
                            continue;
                        }
                        if (userId != UserHandle.USER_ALL && pir.key.userId != userId) {
                            // Different user, skip it.
                            continue;
                        }
                        if (!pir.key.packageName.equals(packageName)) {
                            // Different package, skip it.
                            continue;
                        }
                    }
                    if (!doit) {
                        return true;
                    }
                    didSomething = true;
                    it.remove();
                    makeIntentSenderCanceledLocked(pir);
                    if (pir.key.activity != null && pir.key.activity.pendingResults != null) {
                        pir.key.activity.pendingResults.remove(pir.ref);
                    }
                }
            }
        }

        if (doit) {
            if (purgeCache && packageName != null) {
                AttributeCache ac = AttributeCache.instance();
                if (ac != null) {
                    ac.removePackage(packageName);
                }
            }
            if (mBooted) {
                mStackSupervisor.resumeFocusedStackTopActivityLocked();
                mStackSupervisor.scheduleIdleLocked();
            }
        }

        return didSomething;
    }

```

```
  static void killProcessGroup(int uid, int pid) {
        if (sKillHandler != null) {
            //最终也会调用Process.killProcessGroup(uid, pid);
            sKillHandler.sendMessage(
                    sKillHandler.obtainMessage(KillHandler.KILL_PROCESS_GROUP_MSG, uid, pid));
        } else {
            Slog.w(TAG, "Asked to kill process group before system bringup!");
            Process.killProcessGroup(uid, pid);
        }
    }
```
Process.killProcessGroup(uid, pid);是native方法。
实现再frameworks/base/core/jni/android_util_Process.cpp文件中。
调用到./system/core/libprocessgroup/processgroup.cpp文件中。
```objectivec
int killProcessGroup(uid_t uid, int initialPid, int signal) {
    return KillProcessGroup(uid, initialPid, signal, 40 /*retries*/);
}
```

```objectivec
static int KillProcessGroup(uid_t uid, int initialPid, int signal, int retries) {
    std::chrono::steady_clock::time_point start = std::chrono::steady_clock::now();

    int retry = retries;
    int processes;
    while ((processes = DoKillProcessGroupOnce(uid, initialPid, signal)) > 0) {
        LOG(VERBOSE) << "Killed " << processes << " processes for processgroup " << initialPid;
        if (retry > 0) {
            std::this_thread::sleep_for(5ms);
            --retry;
        } else {
            break;
        }
    }

    if (processes < 0) {
        PLOG(ERROR) << "Error encountered killing process cgroup uid " << uid << " pid "
                    << initialPid;
        return -1;
    }

    std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();

    // We only calculate the number of 'processes' when killing the processes.
    // In the retries == 0 case, we only kill the processes once and therefore
    // will not have waited then recalculated how many processes are remaining
    // after the first signals have been sent.
    // Logging anything regarding the number of 'processes' here does not make sense.

    if (processes == 0) {
        if (retries > 0) {
            LOG(INFO) << "Successfully killed process cgroup uid " << uid << " pid " << initialPid
                      << " in " << static_cast<int>(ms) << "ms";
        }
        return RemoveProcessGroup(uid, initialPid);
    } else {
        if (retries > 0) {
            LOG(ERROR) << "Failed to kill process cgroup uid " << uid << " pid " << initialPid
                       << " in " << static_cast<int>(ms) << "ms, " << processes
                       << " processes remain";
        }
        return -1;
    }
}

```
```objectivec


// Returns number of processes killed on success
// Returns 0 if there are no processes in the process cgroup left to kill
// Returns -1 on error
static int DoKillProcessGroupOnce(uid_t uid, int initialPid, int signal) {
    auto path = ConvertUidPidToPath(uid, initialPid) + PROCESSGROUP_CGROUP_PROCS_FILE;
    std::unique_ptr<FILE, decltype(&fclose)> fd(fopen(path.c_str(), "re"), fclose);
    if (!fd) {
        PLOG(WARNING) << "Failed to open process cgroup uid " << uid << " pid " << initialPid;
        return -1;
    }

    // We separate all of the pids in the cgroup into those pids that are also the leaders of
    // process groups (stored in the pgids set) and those that are not (stored in the pids set).
    std::set<pid_t> pgids;
    pgids.emplace(initialPid);
    std::set<pid_t> pids;

    pid_t pid;
    int processes = 0;
    while (fscanf(fd.get(), "%d\n", &pid) == 1 && pid >= 0) {
        processes++;
        if (pid == 0) {
            // Should never happen...  but if it does, trying to kill this
            // will boomerang right back and kill us!  Let's not let that happen.
            LOG(WARNING) << "Yikes, we've been told to kill pid 0!  How about we don't do that?";
            continue;
        }
        pid_t pgid = getpgid(pid);
        if (pgid == -1) PLOG(ERROR) << "getpgid(" << pid << ") failed";
        if (pgid == pid) {
            pgids.emplace(pid);
        } else {
            pids.emplace(pid);
        }
    }

    // Erase all pids that will be killed when we kill the process groups.
    for (auto it = pids.begin(); it != pids.end();) {
        pid_t pgid = getpgid(pid);
        if (pgids.count(pgid) == 1) {
            it = pids.erase(it);
        } else {
            ++it;
        }
    }

    // Kill all process groups.
    for (const auto pgid : pgids) {
        LOG(VERBOSE) << "Killing process group " << -pgid << " in uid " << uid
                     << " as part of process cgroup " << initialPid;


        if (kill(-pgid, signal) == -1) {
            PLOG(WARNING) << "kill(" << -pgid << ", " << signal << ") failed";
        }
    }

    // Kill remaining pids.
    for (const auto pid : pids) {
        LOG(VERBOSE) << "Killing pid " << pid << " in uid " << uid << " as part of process cgroup "
                     << initialPid;

        if (kill(pid, signal) == -1) {
            PLOG(WARNING) << "kill(" << pid << ", " << signal << ") failed";
        }
    }

    return feof(fd.get()) ? processes : -1;
}
```

kill()的实现在./kernel/msm-3.18/kernel/signal.c文件中

看第二部分：finishForceStopPackageLocked(packageName, pkgUid);
```
    @GuardedBy("this")
    private void finishForceStopPackageLocked(final String packageName, int uid) {
        Intent intent = new Intent(Intent.ACTION_PACKAGE_RESTARTED,
                Uri.fromParts("package", packageName, null));
        if (!mProcessesReady) {
            intent.addFlags(Intent.FLAG_RECEIVER_REGISTERED_ONLY
                    | Intent.FLAG_RECEIVER_FOREGROUND);
        }
        intent.putExtra(Intent.EXTRA_UID, uid);
        intent.putExtra(Intent.EXTRA_USER_HANDLE, UserHandle.getUserId(uid));
        broadcastIntentLocked(null, null, intent,
                null, null, 0, null, null, null, OP_NONE,
                null, false, false, MY_PID, SYSTEM_UID, UserHandle.getUserId(uid));
    }
```
接下来就是发送广播的流程了。