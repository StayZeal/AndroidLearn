```java

public class SyncThread implements Runnable {
    public static String tag = "Sync";

    public synchronized void test1() {
        try {
            Log.i(tag, "test1 start");
            Thread.sleep(1000);
            Log.i(tag, "test1 end");
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public static synchronized void test2() {
        try {
            Log.i(tag, "test2 start");
            Thread.sleep(1000);
            Log.i(tag, "test2 end");
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public void test3() {
        Log.i(tag, "test3 start");
        synchronized (this) {
            try {
                Log.i(tag, "test3 start 1");
                Thread.sleep(1000);
                Log.i(tag, "test3 end 2");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        Log.i(tag, "test3 end");
    }

    public void test4() {
        Log.i(tag, "test4 start");
        synchronized (SyncThread.class) {
            try {
                Log.i(tag, "test4 start 1");
                Thread.sleep(1000);
                Log.i(tag, "test4 end 2");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        Log.i(tag, "test4 end");
    }

    public static void test() {
        SyncThread syncThread = new SyncThread();
        Thread A_thread1 = new Thread(syncThread, "A_thread1");
        Thread A_thread2 = new Thread(syncThread, "A_thread2");
        Thread B_thread1 = new Thread(syncThread, "B_thread1");
        Thread B_thread2 = new Thread(syncThread, "B_thread2");
        Thread C_thread1 = new Thread(syncThread, "C_thread1");
//        Thread C_thread2 = new Thread(syncThread, "C_thread2");
        Thread D_thread1 = new Thread(syncThread, "D_thread1");
//        Thread D_thread2 = new Thread(syncThread, "D_thread2");
        A_thread1.start();
        A_thread2.start();
        B_thread1.start();
        B_thread2.start();
        C_thread1.start();
//        C_thread2.start();
        D_thread1.start();
//        D_thread2.start();
    }

    @Override
    public void run() {

        String threadName = Thread.currentThread().getName();
        if (threadName.startsWith("A")) {
            test1();
        } else if (threadName.startsWith("B")) {
            test2();
        } else if (threadName.startsWith("C")) {
            test3();
        } else {
            test4();
        }
    }
    }
 ```
