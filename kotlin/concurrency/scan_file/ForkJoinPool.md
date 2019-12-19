#### 多线程遍历Android文件目录

使用Java 并发库中的`ForkJoinPool`，对每个文件夹的任务进行拆分：

1、超过`TASK_SIZE`则启动多线程；

2、是文件夹也启动多线程；
```kotlin

package com.webviewtest.thread

import android.os.Environment
import android.util.Log
import java.io.File
import java.util.concurrent.ForkJoinPool
import java.util.concurrent.RecursiveTask
import java.util.concurrent.atomic.AtomicLong

//TODO 增加任务结束判断
class ForkJPool {

    var fileCount: AtomicLong = AtomicLong()
    var num = 0

    companion object {
        const val TASK_SIZE = 100
        const val TAG = "ForkJPool"
    }

    public fun start() {
        ForkJoinPool().execute(Task(Environment.getExternalStorageDirectory().absoluteFile, 0))
    }

    inner class Task(private val file: File,
                     private val start: Int = 0) : RecursiveTask<String>() {

        override fun compute(): String? {
            if (!file.exists()) {
                return null
            }
            if (!file.isDirectory) {
                return file.absolutePath
            }
            val files = file.listFiles()
            if (files.size < TASK_SIZE) {
                for (f in files) {
                    if (f.isDirectory) {
                        val task1 = Task(f, 0)
                        task1.fork()
                    } else {
                        onGetFile(f)
                    }
                }
            } else {
                val count = (start + TASK_SIZE).coerceAtMost(files.size)
                for (i in start until count) {
                    val f = files[i]
                    if (f.isDirectory) {
                        val task1 = Task(f, 0)
                        task1.fork()
                    } else {
                        onGetFile(f)
                    }
                }
                if (count < files.size) {
                    val task1 = Task(file, count)
                    task1.fork()
                }
            }
            return null
        }

        private fun onGetFile(file: File) {
            fileCount.incrementAndGet()
            Log.i(TAG, "onGetFile: ${file.absolutePath}，fileCount: " + fileCount.get())
        }
    }
}
```
