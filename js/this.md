### JavaScript中的this 不是固定不变的，它会随着执行环境的改变而改变。

#### 概括

在全局执行环境中（在任何函数体外部）this 都指向全局对象。

在函数内部，this 的值取决于函数被调用的方式。

当函数作为对象里的方法被调用时，它们的 this 是调用该函数的对象。

当一个函数用作构造函数时（使用 new 关键字），它的 this 被绑定到正在构造的新对象。

当函数被用作事件处理函数时，它的 this 指向触发事件的元素。

当代码被内联 on-event 处理函数调用时，它的 this 指向监听器所在的 DOM 元素

在箭头函数中，this 与**封闭词法环境**的 this 保持一致


#### 官方文档

看了那么多文章都不太理解，还是官网说的好（中文如果翻译的不行，看英文）。///为我自己添加的注释

在箭头函数出现之前，每一个新函数都重新定义了自己的 this 值（在构造函数中是一个新的对象；在严格模式下是未定义的；
在作为“对象方法”调用的函数中指向这个对象；等等）。以面向对象的编程风格，这样着实有点恼人。

function Person() {
  // 构造函数Person()将`this`定义为自身
  this.age = 0;
   ///按照Java的思维方式理解，一个function相当于Java中的一个对象。growUp()就像一个匿名内部类，
   ///在Java中直接使用this.age会编译报错，但是Js只会在运行时报错，符合我们的预期。
  setInterval(function growUp() {
    // 在非严格模式下，growUp()函数将`this`定义为“全局对象”，
    // 这与Person()定义的`this`不同，
    // 所以下面的语句不会起到预期的效果。
    this.age++;
  }, 1000);
}

var p = new Person();
在ECMAScript 3/5里，通过把this的值赋值给一个变量可以修复这个问题。

function Person() {
  var self = this; // 有的人习惯用`that`而不是`self`，
                   // 无论你选择哪一种方式，请保持前后代码的一致性
  self.age = 0;

  setInterval(function growUp() {
    // 以下语句可以实现预期的功能
    self.age++;
  }, 1000);
}
另外，创建一个约束函数可以使得 this值被正确传递给 growUp() 函数。

箭头函数捕捉闭包上下文的this值，所以下面的代码工作正常。

function Person(){
  this.age = 0;
  
  ///Java也可以通过lambda表达式实现这一功能，符合我们预期。
  setInterval(() => {
    this.age++; // 这里的`this`正确地指向person对象
  }, 1000);
}

var p = new Person();

=======================
### 例子
```javaScript
const obj1 = {
	a: 'a in obj1',
	// foo: () => { console.log(this.b) },
	foo:function(){
		console.log(this.a)
	}

}

const obj2 = {
	a: 'a in obj2',
	bar: obj1.foo
}

const obj3 = {
	a: 'a in obj3'
}

obj1.foo()  // 输出 ？？
obj2.bar()  // 输出 ？？
obj2.bar.call(obj3) 

如果是=》函数
undefined
undefined
undefined

如果是第二种
a in obj1
test.js:33
a in obj2
test.js:33
a in obj3
```