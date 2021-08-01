Activity setContentView
- PhoneWindow 初始DecorView，inflate setContentView
- ActivityThread handleReusueActivity,通过WindowManager调用addView()，生成ViewRootImpl
- ViewRoot setView()调用requestLayout开始View绘制