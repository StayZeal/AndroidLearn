### View的绘制
Measure
onMeasure
Layout
onLayout
#### Draw
1、绘制背景

2、如果有必要，绘制fading

3、onDraw(canvas)

4、绘制Children,dispatchDraw(canvas);

5、如果有必要，绘制fading edges and restore layers

6、绘制装饰eg.ScrollBar