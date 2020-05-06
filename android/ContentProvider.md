### ContentProvider

#### 提供方-Server

在App启动的时候，install ContentProvider

#### 调用方-Client

进程未启动，需要先启动Server的进程


Client和Server都需要调用
```java
    private ContentProviderHolder installProvider(Context context,
            ContentProviderHolder holder, ProviderInfo info,
            boolean noisy, boolean noReleaseNeeded, boolean stable) {}
```
区别：Client在调用该方法时，holder不为null

ContentResolver的query()在Server进程死掉的时候，可能会引起Client进程抛出异常，进而死掉。
```kotlin
 // Force query execution.  Might fail and throw a runtime exception here.
            qCursor.getCount();
```