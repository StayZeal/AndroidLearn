### Java泛型
Java泛型是Java很常用的语法，由于经常忘记泛型的一些细节，今天把这些细节记录下来。

#### 用途
类型参数化

#### 实现原理
是一种语法糖，编译器做的一种语法检查。（字节码也有相关信息，但仍然是伪泛型）

#### 泛型擦除
Java代码编译成字节码之后，泛型会被擦除。eg.在Jvm中List<Objetc>和List<String>是相同的类型。
```java
    public static class Student<T extends Object>{
        public void test(){
//            T t = new T();
            List<String> strs = new ArrayList<>();
            List<Object> objs = new ArrayList<>(); 
            System.out.println(strs.getClass().getSimpleName());
            System.out.println(objs.getClass().getSimpleName());
        }
    }
```
其实在jdk1.5之前Java中只有原始类型而没有泛型类型，而在JDK 1.5 之后引入泛型，但是这种泛型仅仅存在于编译阶段，
当在JVM运行的过程中，与泛型相关的信息将会被擦除，如List与List都将会在运行时被擦除成为List这个类型。
而类型擦除机制存在的原因正是因为如果在运行时存在泛型，那么将要修改JVM指令集，这是非常致命的。

gson获取泛型的方法：通过反射获取对应的Type.

链接：https://juejin.im/post/5adefaba518825670e5cb44d

#### 字节码

通过反射获取泛型的原理，test方法的字节码属性表局部代码：
```
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      39     0  this   Lcom/example/myapplication/T2$Student;
            8      31     1  strs   Ljava/util/List;
           16      23     2  objs   Ljava/util/List;
           38       1     3     s   Ljava/lang/String;
      LocalVariableTypeTable:
        Start  Length  Slot  Name   Signature
            0      39     0  this   Lcom/example/myapplication/T2$Student<TT;>;
            8      31     1  strs   Ljava/util/List<Ljava/lang/String;>;
           16      23     2  objs   Ljava/util/List<Ljava/lang/Object;>;

```
LocalVariableTypeTable是Java1.5中新增的属性，通过里面的Signature字段，我们可以知道泛型的真实类型。
而没有使用泛型的方法只有LocalVariableTable属性。

#### 通配符:T和?

T和?都可以这么用
```
T extends Object
?  extends Object
```
T可以用来声明对象，但是不能用来实例化对象：
```
//可以
T t ;
//不可以
T t = new T();
```
而?不能用来声明对象。

#### extends和super

PECS 代表生产者-Extends，消费者-Super（Producer-Extends, Consumer-Super）;
只能从中读取的对象为生产者，并称那些你只能写入的对象为消费者。

```
 List<String> strs = new ArrayList<String>();
 List<Object> objs = strs; // ！！！此处的编译器错误让我们避免了之后的运行时异常
 objs.add(1); // 这里我们把一个整数放入一个字符串列表
 String s = strs.get(0); // ！！！ ClassCastException：无法将整数转换为字符串
```

#### 缺点：

- 伪泛型

- 语法限制：由于编译器无法知道使用泛型的地方是生产者还是消费者。所以类似List<Object> objs = strs总是不允许的。



### Kotlin语法的改进

- **out**代表生产者

- **in**代表消费者

Java代码：
```
void demo(Source<String> strs) {
  Source<Object> objects = strs; // ！！！在 Java 中不允许
  // ……
}
```
Kotlin:
```
interface Source<out T> {
    fun nextT(): T
}

fun demo(strs: Source<String>) {
    val objects: Source<Any> = strs // 这个没问题，因为 T 是一个 out-参数
    // ……
}
```

#### 相关知识点 Type

链接：https://juejin.im/post/5adefaba518825670e5cb44d
