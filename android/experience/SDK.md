### 开发SDK需要注意的事件

1、implementation的库需要提供给调用者

2、代码混淆规则要提供给调用者，不要混淆包名（保留keep标签-待测）

3、提供需要的so库，arm、x86等

4、只能在AndroidManifest.xml中使用${applicationId}占位符

5、在SDK代码中保存版本号信息