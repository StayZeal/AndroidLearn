```
 WindowManager manager = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
        Display display = manager.getDefaultDisplay();
        Point rect = new Point();
        display.getSize(rect);
```
获取的size为除去状态栏和虚拟键，在小米手机上全面屏模式获取的size没有变化。


获取View位置
https://blog.csdn.net/carson_ho/article/details/103342511