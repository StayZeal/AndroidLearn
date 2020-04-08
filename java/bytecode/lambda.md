### Lambda实现原理

通过invokedynamic指令生成中间类。`invokestatic java/lang/invoke/LambdaMetafactory.metafactory`

编译：javac LambdaTest.java

生成中间类：`java -Djdk.internal.lambda.dumpProxyClasses LambdaTest`，需要包含main方法
