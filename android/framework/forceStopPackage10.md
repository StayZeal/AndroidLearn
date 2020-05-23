```objectivec
 public void forceStopPackage(final String packageName, int userId) {
        if (checkCallingPermission(android.Manifest.permission.FORCE_STOP_PACKAGES)
                != PackageManager.PERMISSION_GRANTED) {
            String msg = "Permission Denial: forceStopPackage() from pid="
                    + Binder.getCallingPid()
                    + ", uid=" + Binder.getCallingUid()
                    + " requires " + android.Manifest.permission.FORCE_STOP_PACKAGES;
            Slog.w(TAG, msg);
            throw new SecurityException(msg);
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
                    if (getPackageManagerInternalLocked().isPackageStateProtected(
                            packageName, user)) {
                        Slog.w(TAG, "Ignoring request to force stop protected package "
                                + packageName + " u" + user);
                        return;
                    }

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
                    if (mUserController.isUserRunning(user, 0)) {
                        forceStopPackageLocked(packageName, pkgUid, "from pid " + callingPid);
                        finishForceStopPackageLocked(packageName, pkgUid);
                    }
                }
            }
        } finally {
            Binder.restoreCallingIdentity(callingId);
        }
```

```objectivec
 @GuardedBy("this")
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

        boolean didSomething = mProcessList.killPackageProcessesLocked(packageName, appId, userId,
                ProcessList.INVALID_ADJ, callerWillRestart, true /* allowRestart */, doit,
                evenPersistent, true /* setRemoved */,
                packageName == null ? ("stop user " + userId) : ("stop " + packageName));

        didSomething |=
                mAtmInternal.onForceStopPackage(packageName, doit, evenPersistent, userId);

        if (mServices.bringDownDisabledPackageServicesLocked(
                packageName, null /* filterByClasses */, userId, evenPersistent, doit)) {
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
        mUgmInternal.removeUriPermissionsForPackage(packageName, userId, false, false);

        if (doit) {
            for (i = mBroadcastQueues.length - 1; i >= 0; i--) {
                didSomething |= mBroadcastQueues[i].cleanupDisabledPackageReceiversLocked(
                        packageName, null, userId, doit);
            }
        }

        if (packageName == null || uninstalling) {
            didSomething |= mPendingIntentController.removePendingIntentsForPackage(
                    packageName, userId, appId, doit);
        }

        if (doit) {
            if (purgeCache && packageName != null) {
                AttributeCache ac = AttributeCache.instance();
                if (ac != null) {
                    ac.removePackage(packageName);
                }
            }
            if (mBooted) {
                mAtmInternal.resumeTopActivities(true /* scheduleIdle */);
            }
        }

        return didSomething;
    }
```


 final boolean killPackageProcessesLocked(String packageName, int appId,
            int userId, int minOomAdj, boolean callerWillRestart, boolean allowRestart,
            boolean doit, boolean evenPersistent, boolean setRemoved, String reason) {
        ArrayList<ProcessRecord> procs = new ArrayList<>();

        // Remove all processes this package may have touched: all with the
        // same UID (except for the system or root user), and all whose name
        // matches the package name.
        final int NP = mProcessNames.getMap().size();
        for (int ip = 0; ip < NP; ip++) {
            SparseArray<ProcessRecord> apps = mProcessNames.getMap().valueAt(ip);
            final int NA = apps.size();
            for (int ia = 0; ia < NA; ia++) {
                ProcessRecord app = apps.valueAt(ia);
                if (app.isPersistent() && !evenPersistent) {
                    // we don't kill persistent processes
                    continue;
                }
                if (app.removed) {
                    if (doit) {
                        procs.add(app);
                    }
                    continue;
                }

                // Skip process if it doesn't meet our oom adj requirement.
                if (app.setAdj < minOomAdj) {
                    // Note it is still possible to have a process with oom adj 0 in the killed
                    // processes, but it does not mean misjudgment. E.g. a bound service process
                    // and its client activity process are both in the background, so they are
                    // collected to be killed. If the client activity is killed first, the service
                    // may be scheduled to unbind and become an executing service (oom adj 0).
                    continue;
                }

                // If no package is specified, we call all processes under the
                // give user id.
                if (packageName == null) {
                    if (userId != UserHandle.USER_ALL && app.userId != userId) {
                        continue;
                    }
                    if (appId >= 0 && UserHandle.getAppId(app.uid) != appId) {
                        continue;
                    }
                    // Package has been specified, we want to hit all processes
                    // that match it.  We need to qualify this by the processes
                    // that are running under the specified app and user ID.
                } else {
                    final boolean isDep = app.pkgDeps != null
                            && app.pkgDeps.contains(packageName);
                    if (!isDep && UserHandle.getAppId(app.uid) != appId) {
                        continue;
                    }
                    if (userId != UserHandle.USER_ALL && app.userId != userId) {
                        continue;
                    }
                    if (!app.pkgList.containsKey(packageName) && !isDep) {
                        continue;
                    }
                }

                // Process has passed all conditions, kill it!
                if (!doit) {
                    return true;
                }
                if (setRemoved) {
                    app.removed = true;
                }
                procs.add(app);
            }
        }

        int N = procs.size();
        for (int i=0; i<N; i++) {
            removeProcessLocked(procs.get(i), callerWillRestart, allowRestart, reason);
        }
        // See if there are any app zygotes running for this packageName / UID combination,
        // and kill it if so.
        final ArrayList<AppZygote> zygotesToKill = new ArrayList<>();
        for (SparseArray<AppZygote> appZygotes : mAppZygotes.getMap().values()) {
            for (int i = 0; i < appZygotes.size(); ++i) {
                final int appZygoteUid = appZygotes.keyAt(i);
                if (userId != UserHandle.USER_ALL && UserHandle.getUserId(appZygoteUid) != userId) {
                    continue;
                }
                if (appId >= 0 && UserHandle.getAppId(appZygoteUid) != appId) {
                    continue;
                }
                final AppZygote appZygote = appZygotes.valueAt(i);
                if (packageName != null
                        && !packageName.equals(appZygote.getAppInfo().packageName)) {
                    continue;
                }
                zygotesToKill.add(appZygote);
            }
        }
        for (AppZygote appZygote : zygotesToKill) {
            killAppZygoteIfNeededLocked(appZygote);
        }
        mService.updateOomAdjLocked(OomAdjuster.OOM_ADJ_REASON_PROCESS_END);
        return N > 0;
    }
    
  ProcessList
  ```objectivec
 @GuardedBy("mService")
    boolean removeProcessLocked(ProcessRecord app,
            boolean callerWillRestart, boolean allowRestart, String reason) {
        final String name = app.processName;
        final int uid = app.uid;
        if (DEBUG_PROCESSES) Slog.d(TAG_PROCESSES,
                "Force removing proc " + app.toShortString() + " (" + name + "/" + uid + ")");

        ProcessRecord old = mProcessNames.get(name, uid);
        if (old != app) {
            // This process is no longer active, so nothing to do.
            Slog.w(TAG, "Ignoring remove of inactive process: " + app);
            return false;
        }
        removeProcessNameLocked(name, uid);
        mService.mAtmInternal.clearHeavyWeightProcessIfEquals(app.getWindowProcessController());

        boolean needRestart = false;
        if ((app.pid > 0 && app.pid != ActivityManagerService.MY_PID) || (app.pid == 0 && app
                .pendingStart)) {
            int pid = app.pid;
            if (pid > 0) {
                mService.mPidsSelfLocked.remove(app);
                mService.mHandler.removeMessages(PROC_START_TIMEOUT_MSG, app);
                mService.mBatteryStatsService.noteProcessFinish(app.processName, app.info.uid);
                if (app.isolated) {
                    mService.mBatteryStatsService.removeIsolatedUid(app.uid, app.info.uid);
                    mService.getPackageManagerInternalLocked().removeIsolatedUid(app.uid);
                }
            }
            boolean willRestart = false;
            if (app.isPersistent() && !app.isolated) {
                if (!callerWillRestart) {
                    willRestart = true;
                } else {
                    needRestart = true;
                }
            }
            app.kill(reason, true);
            mService.handleAppDiedLocked(app, willRestart, allowRestart);
            if (willRestart) {
                removeLruProcessLocked(app);
                mService.addAppLocked(app.info, null, false, null /* ABI override */);
            }
        } else {
            mRemovedProcesses.add(app);
        }

        return needRestart;
    }

```
ProcessRecord
```objectivec
    void kill(String reason, boolean noisy) {
        if (!killedByAm) {
            Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "kill");
            if (mService != null && (noisy || info.uid == mService.mCurOomAdjUid)) {
                mService.reportUidInfoMessageLocked(TAG,
                        "Killing " + toShortString() + " (adj " + setAdj + "): " + reason,
                        info.uid);
            }
            if (pid > 0) {
                EventLog.writeEvent(EventLogTags.AM_KILL, userId, pid, processName, setAdj, reason);
                Process.killProcessQuiet(pid);
                ProcessList.killProcessGroup(uid, pid);
            } else {
                pendingStart = false;
            }
            if (!mPersistent) {
                killed = true;
                killedByAm = true;
            }
            Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
        }
    }
```
Process
```objectivec
    public static final void killProcessQuiet(int pid) {
        sendSignalQuiet(pid, SIGNAL_KILL);
    }

```

ProcessList
```
    static void killProcessGroup(int uid, int pid) {
        /* static; one-time init here */
        if (sKillHandler != null) {
            sKillHandler.sendMessage(
                    sKillHandler.obtainMessage(KillHandler.KILL_PROCESS_GROUP_MSG, uid, pid));
        } else {
            Slog.w(TAG, "Asked to kill process group before system bringup!");
            Process.killProcessGroup(uid, pid);
        }
    }
```
最终会调用到Process：
```objectivec
    public static final native int killProcessGroup(int uid, int pid);
```

10增加的部分：
```objectivec
 final ArrayList<AppZygote> zygotesToKill = new ArrayList<>();
        for (SparseArray<AppZygote> appZygotes : mAppZygotes.getMap().values()) {
            for (int i = 0; i < appZygotes.size(); ++i) {
                final int appZygoteUid = appZygotes.keyAt(i);
                if (userId != UserHandle.USER_ALL && UserHandle.getUserId(appZygoteUid) != userId) {
                    continue;
                }
                if (appId >= 0 && UserHandle.getAppId(appZygoteUid) != appId) {
                    continue;
                }
                final AppZygote appZygote = appZygotes.valueAt(i);
                if (packageName != null
                        && !packageName.equals(appZygote.getAppInfo().packageName)) {
                    continue;
                }
                zygotesToKill.add(appZygote);
            }
        }
        for (AppZygote appZygote : zygotesToKill) {
            killAppZygoteIfNeededLocked(appZygote);
        }
```
mAppZygotes为AMS在启动进程的时候设置([通过分析Activity的启动流程可知](Activity启动流程10.md))。**这里相当于比10之前的版本，又增加了一次查杀。**

native(9.0)代码，由于没有10的源码
```objectivec
system/core/libprocessgroup/processgroup.cpp
284:static int killProcessGroup(uid_t uid, int initialPid, int signal, int retry) {
313:int killProcessGroup(uid_t uid, int initialPid, int signal) {
314:    return killProcessGroup(uid, initialPid, signal, 40 /*maxRetry*/);
317:int killProcessGroupOnce(uid_t uid, int initialPid, int signal) {
318:    return killProcessGroup(uid, initialPid, signal, 0 /*maxRetry*/);

```

```objectivec
int killProcessGroup(uid_t uid, int initialPid, int signal) {
    return killProcessGroup(uid, initialPid, signal, 40 /*maxRetry*/);
}

```
```objectivec
static int killProcessGroup(uid_t uid, int initialPid, int signal, int retry) {
    std::chrono::steady_clock::time_point start = std::chrono::steady_clock::now();

    int processes;
    while ((processes = doKillProcessGroupOnce(uid, initialPid, signal)) > 0) {
        LOG(VERBOSE) << "killed " << processes << " processes for processgroup " << initialPid;
        if (retry > 0) {
            std::this_thread::sleep_for(5ms);
            --retry;
        } else {
            LOG(ERROR) << "failed to kill " << processes << " processes for processgroup "
                       << initialPid;
            break;
        }
    }

    std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();

    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    LOG(VERBOSE) << "Killed process group uid " << uid << " pid " << initialPid << " in "
                 << static_cast<int>(ms) << "ms, " << processes << " procs remain";

    if (processes == 0) {
        return removeProcessGroup(uid, initialPid);
    } else {
        return -1;
    }
}

```
```objectivec
static int doKillProcessGroupOnce(uid_t uid, int initialPid, int signal) {
    int processes = 0;
    struct ctx ctx;
    pid_t pid;

    ctx.initialized = false;

    while ((pid = getOneAppProcess(uid, initialPid, &ctx)) >= 0) {
        processes++;
        if (pid == 0) {
            // Should never happen...  but if it does, trying to kill this
            // will boomerang right back and kill us!  Let's not let that happen.
            LOG(WARNING) << "Yikes, we've been told to kill pid 0!  How about we don't do that?";
            continue;
        }
        LOG(VERBOSE) << "Killing pid " << pid << " in uid " << uid
                     << " as part of process group " << initialPid;
        if (kill(pid, signal) == -1) {
            PLOG(WARNING) << "kill(" << pid << ", " << signal << ") failed";
        }
    }

    if (ctx.initialized) {
        close(ctx.fd);
    }

    return processes;
}
```
kill(pid, signal)为Linux系统调用。