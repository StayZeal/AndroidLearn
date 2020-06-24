
ZygoteProcess
```objectivec
 public static ProcessStartResult start(@NonNull final String processClass,
                                           @Nullable final String niceName,
                                           int uid, int gid, @Nullable int[] gids,
                                           int runtimeFlags,
                                           int mountExternal,
                                           int targetSdkVersion,
                                           @Nullable String seInfo,
                                           @NonNull String abi,
                                           @Nullable String instructionSet,
                                           @Nullable String appDataDir,
                                           @Nullable String invokeWith,
                                           @Nullable String packageName,
                                           @Nullable String[] zygoteArgs) {
        return ZYGOTE_PROCESS.start(processClass, niceName, uid, gid, gids,
                    runtimeFlags, mountExternal, targetSdkVersion, seInfo,
                    abi, instructionSet, appDataDir, invokeWith, packageName,
                    /*useUsapPool=*/ true, zygoteArgs);
    }
```

```objectivec
  private Process.ProcessStartResult startViaZygote(@NonNull final String processClass,
                                                      @Nullable final String niceName,
                                                      final int uid, final int gid,
                                                      @Nullable final int[] gids,
                                                      int runtimeFlags, int mountExternal,
                                                      int targetSdkVersion,
                                                      @Nullable String seInfo,
                                                      @NonNull String abi,
                                                      @Nullable String instructionSet,
                                                      @Nullable String appDataDir,
                                                      @Nullable String invokeWith,
                                                      boolean startChildZygote,
                                                      @Nullable String packageName,
                                                      boolean useUsapPool,
                                                      @Nullable String[] extraArgs)
                                                      throws ZygoteStartFailedEx {
        ArrayList<String> argsForZygote = new ArrayList<>();

        // --runtime-args, --setuid=, --setgid=,
        // and --setgroups= must go first
        argsForZygote.add("--runtime-args");
        argsForZygote.add("--setuid=" + uid);
        argsForZygote.add("--setgid=" + gid);
        argsForZygote.add("--runtime-flags=" + runtimeFlags);
        if (mountExternal == Zygote.MOUNT_EXTERNAL_DEFAULT) {
            argsForZygote.add("--mount-external-default");
        } else if (mountExternal == Zygote.MOUNT_EXTERNAL_READ) {
            argsForZygote.add("--mount-external-read");
        } else if (mountExternal == Zygote.MOUNT_EXTERNAL_WRITE) {
            argsForZygote.add("--mount-external-write");
        } else if (mountExternal == Zygote.MOUNT_EXTERNAL_FULL) {
            argsForZygote.add("--mount-external-full");
        } else if (mountExternal == Zygote.MOUNT_EXTERNAL_INSTALLER) {
            argsForZygote.add("--mount-external-installer");
        } else if (mountExternal == Zygote.MOUNT_EXTERNAL_LEGACY) {
            argsForZygote.add("--mount-external-legacy");
        }

        argsForZygote.add("--target-sdk-version=" + targetSdkVersion);

        // --setgroups is a comma-separated list
        if (gids != null && gids.length > 0) {
            StringBuilder sb = new StringBuilder();
            sb.append("--setgroups=");

            int sz = gids.length;
            for (int i = 0; i < sz; i++) {
                if (i != 0) {
                    sb.append(',');
                }
                sb.append(gids[i]);
            }

            argsForZygote.add(sb.toString());
        }

        if (niceName != null) {
            argsForZygote.add("--nice-name=" + niceName);
        }

        if (seInfo != null) {
            argsForZygote.add("--seinfo=" + seInfo);
        }

        if (instructionSet != null) {
            argsForZygote.add("--instruction-set=" + instructionSet);
        }

        if (appDataDir != null) {
            argsForZygote.add("--app-data-dir=" + appDataDir);
        }

        if (invokeWith != null) {
            argsForZygote.add("--invoke-with");
            argsForZygote.add(invokeWith);
        }

        if (startChildZygote) {
            argsForZygote.add("--start-child-zygote");
        }

        if (packageName != null) {
            argsForZygote.add("--package-name=" + packageName);
        }

        argsForZygote.add(processClass);

        if (extraArgs != null) {
            Collections.addAll(argsForZygote, extraArgs);
        }

        synchronized(mLock) {
            // The USAP pool can not be used if the application will not use the systems graphics
            // driver.  If that driver is requested use the Zygote application start path.
            return zygoteSendArgsAndGetResult(openZygoteSocketIfNeeded(abi),
                                              useUsapPool,
                                              argsForZygote);
        }
    }
```