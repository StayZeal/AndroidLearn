### View的绘制
Measure
onMeasure：

LinearLayout,parent会调用child的onMeasure()

RelativeLayout:会调用两次onMeasure();


Layout
onLayout:用来layout child view。所有View的onLayout()实现为空。

#### Draw
1、绘制背景

2、如果有必要，绘制fading

3、onDraw(canvas)

4、绘制Children,dispatchDraw(canvas);

5、如果有必要，绘制fading edges and restore layers

6、绘制装饰eg.ScrollBar

public final int getWidth() {
        return mRight - mLeft;
}