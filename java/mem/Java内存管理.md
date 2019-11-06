#### Java内存区域分为：
- 方法区(Method Area):所有线程共有
- 虚拟机栈(VM Stack):每一个线程独有
- 本地方法栈(Native Method Stack):HotSpot虚拟机直接将本地方法栈和虚拟机栈合二为一。
- 堆（heap）：所有线程共有
- 程序计数器（Program Counter Register）：每个线程独有，只记录非native方法

```
/**
 * 运行时, jvm 把AppMain的信息都放入方法区
 */
public class AppMain {
    /**
     * main 方法放入栈区。
     */
    public static void main(String[] args) {
        Sample test1 ;
        System.out.println("Sample test1 statement");
        test1= new Sample(" 测试1 ");   //test1是引用，所以放到栈区里， Sample是自定义对象应该放到堆里面   
        Sample test2 = new Sample(" 测试2 ");

        test1.printName();
        test2.printName();
    }
}

/**
 * 运行时, jvm 把Sample的信息都放入方法区
 */
class Sample {
  
    static{
           System.out.println("Sample class loaded");
    }
   //new Sample实例后， name 引用放入堆里，  name 对象放入堆里
    private String name;      

    public Sample(String name) {
        this.name = name;
    }

    /**
     * print方法本身放入 方法区里。
     */
    public void printName() {
        System.out.println(name);
    }
}

```
#### 程序运行过程：
Jvm首先加载AppMain类进方法区，然后执行main()方法。test1是局部变量会加载到栈中，然后实例化Sample对象，此时需要加载Sample类到方法区，然后在堆中new出一个Sample的对象，地址交给test1在栈中保存。**然后调用printName()方法,Jvm将继续执行后续指令，在堆区里继续创建另一个Sample实例，然后依次执行它们的printName()方法。当JAVA虚拟机执行test1.printName()方法时，JAVA虚拟机根据局部变量test1持有的引用，定位到堆区中的Sample实例，再根据Sample实例持有的引用，定位到方法去中Sample类的类型信息，从而获得printName()方法的字节码，接着执行printName()方法包含的指令.
**(printName()会进去栈中吗？在栈中怎么存放？Sample的name属性是放在堆中还是栈中？)**
方法进入栈，形成一个栈帧，name属性放在堆中，只有方法中的变量进入栈中。

#### 问题1：到底是test1变量在声明时加载Sample还是在new的时候加载Sample到方法区?
经过打印log发现Sample是在new的时候加载，在声明的时候并不加载。

[深入理解JVM（1） : Java内存区域划分](http://www.jianshu.com/p/7ebbe102c1ae)

[Java里的堆(heap)栈(stack)和方法区(method)](http://lz12366.iteye.com/blog/639873)

http://www.cnblogs.com/gw811/archive/2012/10/18/2730117.html

http://www.cnblogs.com/vamei/archive/2013/04/28/3048353.html