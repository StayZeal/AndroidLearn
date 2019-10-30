在编译期生成_ViewBinding类，通过ButterKnife.bind()方法获取Activity的实例，进而初始化View ID

只有bind()方法中找对应的_ViewBinding类使用了反射，因此效率较高。