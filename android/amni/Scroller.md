一个工具类用来帮助View计算X,Y的滚动位置

1、初始化 mScroller = Scroller(context, interpolator)

2、开始滚动 mScroller!!.startScroll(startX, startY, dy, dy, duration)

3、在你需要的时候获取计算出来的x,y
```
if (mScroller!!.computeScrollOffset()) {
            scrollTo(mScroller!!.currX, mScroller!!.currY)
            invalidate()
            return
}
```
一般在View的computeScroll()中调用，computeScroll()会在onDraw()方法中被调用。