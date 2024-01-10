Rust编程语言学习心得备忘
----------------
## What's new?

Rust 1.65.0 稳定版发布，泛型关联类型 ([GATs](https://github.com/rust-lang/rust/pull/96709/)) 正式稳定

[The Rust Programming Language - The Rust Programming Language](https://doc.rust-lang.org/book/index.html)


## 一些教程
[Comprehensive Rust ](https://github.com/google/comprehensive-rust) google推出的rust教程。



## 类型的大小

我感觉要理解Rust，一定要理解**类型的大小**也就是size，对rust来说是非常重要的。为了让类型的大小在编译期可知，rust做了好多工作。

## 5.1 Expressions vs. Statements

从根本上来说，rust是基于expression的一门语言。它只有两种类型的statement，其它的全是expression。

那 Expressions和Statements有什么区别？ Expressions有返回值而Statements没有。

在大多数的语言里`if`是Statement，没有返回值。因此 let x = if ...这样的语句没有意义。但是在Rust里，`if`是Expression,可以有返回值，可以用它来初始化变量。

赋值语句（Rust术语叫bindings）是Rust的两种Statement里的一种，准确地说是`声明语句`。目前为止，let是我们见到的唯一的`声明语句`，那我们就再多说点。

在大多数的语言里，变量赋值是可以写成Expressions的，如：

```js
x = y = 5;
```

在Rust语言里，用let赋值的语句是Statement，下面的代码会产生一个编译错误：

```rust
let x = (let y = 5i); // expected identifier, found keyword `let`
```

编译器告诉我们，它需要一个Expression，但发现了一个let开头的Statement.

注意：给已经初始化过的变量赋值（如：y = 5i），仍然是Expression，尽管它的返回值不是那么常用。不像C语言，在C语言里赋值语句返回的是被赋的值，y = 5i，返回值是5i。在Rust里，它的返回值是unit type()，这个我们接下来会详细解释。

Rust里的另外一种的Statement叫`expression statement`(真头大;))。它的作用是把任何的expression转成statement。实际上，Rust的语法是一个接一个的statement的。这意味着你要用分号`;`来分隔一个个的Expression。这也意味着你要像写其它语言的代码一样，在每行的后面跟一个分号`;`，在接下来的你看到Rust代码里，几乎每一行都以分号`;`结尾。

为什么我们要说*几乎每一行*？

```rust
let x = 5i;

let y: int = if x == 5i { 10i } else { 15i };
```

我声明y为int类型，我期望它会被赋个int。

这样写结果就不一样了，无法编译了：

```rust
let x = 5i;

let y: int = if x == 5i { 10i; } else { 15i; };
```

请注意，我们在10和15后面加了一个分号`;`，Rust会给我们报下面的错误：

```
error: mismatched types: expected `int` but found `()` (expected int but found ())
```

我们想要一个Int，却发现一个`()`,`()`读做`unit`，是Rust的一种特殊类型。因为是不同的类型，所以上面的代码会报错。
还记得我们是怎么说的吗？Statement不能返回值？`unit`就是用来处理这种情况的。分号`;`把Expression的求值的结果抛弃掉，返回`unit类型，这样就实现了把任何的Expression转成了Statement。

# 5.2 Function

需要注意的是rust有一种叫`Diverging functions`的函数，它不返回值。

```rust
fn diverges() -> ! {
    panic!("This function never returns!");
}
```

因为这个函数会引发一个crash，所以它永远不会返回，所以它的返回值只是摆设了，Rust给它一个标识`!`。`Diverging functions`可以用于任何类型，这个设计真奇怪。

```rust
let x: i32 = diverges();
let x: String = diverges();
```

## 5.12 Struct

跟其它语言的没有什么太大区别，有两个地方要注意`Tuple structs`和`Unit-like structs`

**Tuple structs**

一种混杂了tuple和struct的数据结构。先看看定义吧

```rust
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

struct Point1 { x:i32, y:i32};
```

跟tuple比，它是有名字的。跟struct比，它没有field,而且是用圆括号()不是用花括号{}来定义body。

有种情况下它非常有用，那tuple struct只有一个field的时候。我们管它叫`新类型`模式。
效果相当于C语言里的typedef或宏,其它语言里的type alias.

```rust
struct Inches(i32);

let length = Inches(10);

let Inches(integer_length) = length;
println!("length is {} inches", integer_length);
```

还有一种特殊的struct叫`Unit-like structs`,它就是只有名字，没有任何field的struct.

```rust
struct Electron;
```

它定义了一个新类型。什么情况下会用到它呢？
有些library会要求创建一个struct，然后实现xxx,yyy等trait。如果你的struct里没有什么数据可存的，就可以定义一个这样的struct.

## 5.13 enum

Rust的enum跟其它语言不太一样。它的每一个变体都可以关联数据，它的变体的定义语法非常像struct的定义语法。

```rust
enum Message {
    Quit,                            // 像unit-like struct
    ChangeColor(i32, i32, i32),      // 像tuple struct
    Move { x: i32, y: i32 },         // 这就是一个struct
    Write(String),                   // 另一个tuple struct.
}
```

跟C语言enum太不一样了，跟java的enum也差别很大。它更像是一个小的namespace,里面有着几个类（struct等）。

主要用在match语句中比较多。

其它没什么了。

## 5.14 Match

Rust没有switch，它用了match来代替switch。当然match的功能要比switch强大多了。

```rust
let x = 5;

match x {
    1 => println!("one"),
    2 => println!("two"),
    3 => println!("three"),
    4 => println!("four"),
    5 => println!("five"),
    _ => println!("something else"),
}
```

`match` enforces ‘exhaustiveness checking’.强制进行全面检查，要求所有的可能性都要考虑到。

如果我们把上面代码里的`_`这个分支去掉，就会报错，Rust会认为你没有考虑所有的可能性。

## 5.23 Trait Objects

Rust里区分`static dispatch`和`dynamic dispatch`.

`static dispatch` 相当于用类来调用方法，而`dynamic dispatch`相当于通过接口来调用方法。

```rust
trait Foo {
    fn method(&self) -> String;
}
//We’ll also implement this trait for u8 and String:

impl Foo for u8 {
    fn method(&self) -> String { format!("u8: {}", *self) }
}

impl Foo for String {
    fn method(&self) -> String { format!("string: {}", *self) }
}
```

Foo是一个trait，u8和String 相当于是实现了这个trait的类。

先来看`static dispatch` 。

```rust
//注意参数不是&或Box<T>
fn do_something<T: Foo>(x: T) {
    x.method();
}

fn main() {
    let x = 5u8;
    let y = "Hello".to_string();

    do_something(x);
    do_something(y);
}
```

**dynamic dispatch**

```rust
fn do_something(x: &Foo) {
    x.method();
}

fn main() {
    let x = 5u8;
    do_something(&x as &Foo);
}
```

or by coercing:

```rust
fn do_something(x: &Foo) {
    x.method();
}

fn main() {
    let x = "Hello".to_string();
    do_something(&x);
}
```

上面函数do_something的参数是&Foo,是一个引用。这很关键，这就会使用dynamic dispatch。

具体实现区别涉及到指针和vtable等,请看官方文档。（有时间补充上）

## 5.24 Closures 闭包

有一种是stack closure,是在栈上的closure。

```rust
fn factory() -> (Fn(i32) -> Vec<i32>) {
    let vec = vec![1, 2, 3];

    |n| vec.push(n)
}

let f = factory();

let answer = f(4);
assert_eq!(vec![1, 2, 3, 4], answer);
```

## Borrow 和 AsRef

Choose Borrow when you want to abstract over different kinds of borrowing, or when you’re building a datastructure that treats owned and borrowed values in equivalent ways, such as hashing and comparison.
当你想`owned`和`borrowed`的值同样对待时，比如在设计你的函数参数时，你就要用Borrow.

Choose AsRef when you want to convert something to a reference directly, and you’re writing generic code.

## 5.8 Ownership

rust的ownership系统是它区别与其它语言的最主要的特征。只有理解了ownership系统，才能真正算是入门。

Variable bindings have a property in Rust: they ‘have ownership’ of what they’re bound to. This means that when a binding goes out of scope, the resource that they’re bound to are freed. For 

Rust的绑定变量有一个属性：获得它所绑定资源的所有权。这意味着当绑定变量超出作用域时，它所绑定资源的资源就会释放。

```rust
fn foo() {
    let v = vec![1, 2, 3];
}
```

绑定变量v的作用域是函数foo的函数体，创建v时，先会在栈上分配空间来保存v这个变量 ，然后会在堆上分配空间以保存它的3个元素。当v超出作用域时，Rust会清除栈和堆上这些资源。

有一点要注意：**Rust确保有且只有一个变量绑定到给定的资源**。

```rust
let v = vec![1, 2, 3];  //创建一个vector,并绑定到一个变量

let v2 = v;   //把它赋给另一个变量。

println!("v[0] is: {}", v[0]);   //使用原来的那个绑定变量。
```

运行上面的代码会报错。

```
error: use of moved value: `v`
println!("v[0] is: {}", v[0]);
```

```
let v2= v;
```

这行代码是把v赋给v2,它们都指向同一个vector，这违反了Rust安全承诺。所以在这个赋值后Rust不允许再使用变量v。在编译器优化时，可以会把它释放掉。看起来就像v的所有都转移(move)到v2了。

下面我们再看一个例子，这回我们把类型从vector换成i32.

```rust
let v  = 1;

let v2 = v;

println!("v is: {}", v);
```

 这个代码就可以运行，为什么？因为这个例子里v的类型是i32，它实现了`Copy` trait，所以`let v2 = v;`这行代码执行时，rust会把v的值深度copy一份，然后给v2，所以v在赋值后可以用的。
 v2和v拥有不同的资源，分别是各自资源的owner。

**move还是copy ?**

当一个局部变量用做右值时，它可能会被move或copy，取决于它的类型，如果它实现了`Copy`这个trait，那它就会被copied，否则就会被moved. 

```rust
let v = vec![1, 2, 3];

let v2 = v;
```

vector没有实现`Copy` trait，所以在赋值后`v`就不可以用了。

如果我们写了一个函数，以vector为参数，为了能让函数调用后原来的变量能正常使用，我们必须手动归还这个ownership。

```rust
fn foo(v1: Vec<i32>, v2: Vec<i32>) -> (Vec<i32>, Vec<i32>, i32) {
    // do stuff with v1 and v2

    // hand back ownership, and the result of our function
    (v1, v2, 42)
}

let v1 = vec![1, 2, 3];
let v2 = vec![1, 2, 3];

let (v1, v2, answer) = foo(v1, v2); //调用并归还
```

这简直太变态，无法接受啊！     

所以rust引入了`borrowing` 来解决这个问题。

## 5.9 References and Borrowing

在Ownership一节，我们给出了一个手动归还Ownership例子，手动归还实在太不方便。

Rust使用`reference` 来解决这个问题。这是reference版本的。

```rust
fn foo(v1: &Vec<i32>, v2: &Vec<i32>) -> i32 {
    // do stuff with v1 and v2

    // return the answer
    42
}

let v1 = vec![1, 2, 3];
let v2 = vec![1, 2, 3];

let answer = foo(&v1, &v2);

// we can use v1 and v2 here!
```

reference是什么？官方文档是这样解释的。

```
We call the &T type a ‘reference’, and rather than owning the resource, it borrows ownership.
```

borrow,借，也就是所有权是没变的。我借你的书看，书还是你的（所有权归你），但是我现在在用它。
引用也是这个意思,引用可以使用资源，但是不拥有所有权。

默认的References不可变的，跟绑定一样.

```rust
fn foo(v: &Vec<i32>) {
     v.push(5);
}

let v = vec![];

foo(&v);
```

会报错：

```
error: cannot borrow immutable borrowed content `*v` as mutable
v.push(5);
^
```

不可变的引用，不能修改资源的内容。如果要修改资源的内容，我们先取得`可变引用`。

```rust
let mut x = 5;
{
    let y = &mut x;
    *y += 1;
}
println!("{}", x);
```

x的值被修改了。你会奇怪，我们为什么要把修改的代码放在{}块里。如果我们把这两个花括号去掉会报错。

```
error: cannot borrow `x` as immutable because it is also borrowed as mutable
    println!("{}", x);
                   ^
note: previous borrow of `x` occurs here; the mutable borrow prevents
subsequent moves, borrows, or modification of `x` until the borrow ends
        let y = &mut x;
                     ^
note: previous borrow ends here
fn main() {

}
```

为什么？
我们先来说说Rust对references规定吧。

1. 所有的引用的作用域必须小于所有者(owner)的作用域。
2. 你可以有多个不可变的引用(&T)，但
3. 同时只能有一个可变的引用(&mut T)

Here’s the rules about borrowing in Rust:

First, any borrow must last for a smaller scope than the owner.     

Second, you may have one or the other of these two kinds of borrows, but not both at the same time:

* 0 to N references (&T) to a resource.
* exactly one mutable reference (&mut T)

我们还是举例子来说明吧。

第一种情况，两个 immutable reference.

```rust
fn main() {
    let x = 5;


    let z = & x;
    let y = & x;
    println!("y: {},z:{}",y,z);

}
```

这种情况是OK的。

一个 immutable reference和mutable reference的情况。

```rust
fn main() {
    let mut x = 5;


    let z = & x;
    let y = &mut x;
    println!("y: {},z:{}",y,z);

}
```

会报错：

```
cannot borrow `x` as mutable because it is also borrowed as immutable,the immutable borrow prevents subsequent moves or mutable borrows of `x` until the borrow ends.
```

我们先borrow一个mutable reference然后再borrow一个immutable的可以吗？

```rust
fn main() {
    let mut x = 5;

    let y = &mut x;
    let z = & x;
    println!("y: {},z:{}",y,z);

}
```

你会发现结果是一样的。

在一个scope里，可能多个immutable borrow，但是一旦有mutable borrow就不一样了。immutable borrow和mutable borrow在同一个scope里不能同时存在。也就是官方文档里说的：`but not both at the same time`。

我们再来看上边的例子:

```rust
let mut x = 5;

let y = &mut x;    // -+ 可变引用 y 开始生效
                   //  |
*y += 1;           //  |
                   //  |
println!("{}", x); // -+ - 试图使用原来的可变绑定
                   // -+ 可变引用 y 离开作用域
```

我们无法在可变引用y的作用域里使用x. 因为它违反了同时只能有一个可变引用的这条规则。

了解了引用我们下面再来学习Liftetime.

# Lifetime

Lifetime是刚接触rust时特别容易产生迷惑的一个概念，所以我在这里花了比较大的篇章来说明它，基于我自己的理解，希望能给大家讲明白。

在上一节里我们讲了引用和借用
把资源的引用借给他人使用其结果可能会很复杂。假如：

1. 我有一个资源
2. 我把这个资源的引用借给你
3. 我释放这个资源(我不关心你那儿还有一个引用，因为我是这个资源的owner,我有权释放它)。然后
4. 你要使用这个引用。

第4步，当你使用引用时，它所指向的资源已经不在了！这将导致不可预知的问题。

如何避免上述情况的发生？

一种解决方案就是: 当还有一个指向资源的引用存在时，资源就不能被释放。 没有指向资源的引用时，才能释放它。

这个方案下第3步就不会释放资源,第4步就是安全的。

在这种情况下资源怎么释放呢？有两种方案，引用计数(ARC)和垃圾回收器GC. Objective-C和Swift使用的是ARC,java和.net使用的是GC.

rust没有使用ARC也没有使用GC.  onwer使用完了资源（通常是owner超出作用范围自动销毁）就会释放资源。

那第4步怎么办？

Rust使用某种机制来保证第4步不会发生！

你会说怎么不会发生？ 我代码就要这样写，那当然会发生啊，比如：

```rust
struct Foo {
    f:Box<i32>,
}

fn main() {
    let y : &Foo;

    {
        let mut x = Foo{f : Box::new(18)};   // 这相当于第1步,获得资源。

        y = &x;                              // 这相当于第2步， 借出 reference.
    }                                        // 这相当于第3步 onwer超出作用范围，释放资源

    println!("{}",y.f);                      // 这相当于第4步。 通过reference来使用资源。

}
```

好像第4步发生了呀。 不好意思，这段代码无法成功编译。Rust compiler会检查引用的lifetime和
owner的lifetime。它发现引用的生命期比资源的owner的长时，它编译时就报错了，根本就不会到
运行这一步。所以第4步是不会发生的。

因此在Rust里，你必须在owner释放资源之前使用它(借出)的引用。就也是上述的第4步应该发生在第3步之前。

1  我有一个资源

2  我把这个资源的引用借给你

4  你使用这个引用。

3  我释放这个资源。

上述的代码如果用java或swift来实现肯定可以编译通过。 我们已经习惯写这样的代码了，我们理所当然
地认为这样的代码可以运行。但是在rust里，你不能这样写代码，因为rust不允许你这样写。

如何保证第4步发生在第3步之前呢？rust是通过**保证资源owner活得比它的任何一个引用更长来实现的。**

Rust的ownership系统通过叫`lifetime`的概念来实现。

```
The ownership system in Rust does this through a concept called lifetimes, which describe the scope that a reference is valid for.
```

下面我们举些例子来说明lifetime,在这之前，请记住：**有引用才有lifetime,lifetime是跟引用关联的**.

```rust
struct Foo {
    f : Box<i32>,
}

struct Bar {
    foo : &Foo,  //struct包含引用，就必须明确指定lifetime.
}

fn main() {
    let mut a = Foo {f: Box::new(14)};

    let y : &Foo;

    {
        let x = &a;
        y = x;
    }
    a.f = Box::new(1);
    println!("{}" ,  a.f);
}
```

上面的代码会在第2个struct: Bar 处报错`error: missing lifetime specifier`。而第1个struct  Foo就不报错这个错误，因为它没有用包含引用。

好，我们现在给它加上lifetime。

```rust
struct Foo {
    f : Box<i32>,
}

struct Bar<'a> {
    foo : &'a Foo
}

fn main() {
    let mut a = Foo {f: Box::new(14)};

    let y : &Foo;

    {
        let x = &a;
        y = x;
    }
    a.f = Box::new(1);
    println!("{}" ,  a.f);
}
```

OK,可以编译通过了。

很多人会被`Bar<'a>`和`foo : &'a Foo`里面的`'a`搞懵了，不明白它是干什么的，它如何起作用．

`'a` 是`Named lifetime`,中文可译为`带名生命期`。它实际上是告诉编译器，struct Bar有引用，这个引用的lifetime我们把它命名为：a.

做为开发人员我们不用关心`'a`是怎么生效的。因为我们不会直接用到它。开发人员要就做的就是给引用加上一个带名生命期。然后由编译器来使用它。

当我们的struct包含了一个引用，那我们**struct的实例不能比它包含的引用活得更长**。

如果不能理解这句话，请翻到前面看开头的那个４步的说明．

那什么是lifetime ? lifetime是rust用来度量引用生命期的一个辅助标识。编译器用它来计算引用的寿命有多长。  很多人认为`lifetime`这个词选择不太好，容易产生误解[1]。

`'a`这种东西只是用来计算生命期的标识，好理解了吧？

下面我们看一个struct包含多个引用时的情况,这时`带名生命期`的作用就更容易理解。

```rust
struct Foo {
    f : Box<i32>,
}

struct Bar<'a,'b> {
    foo : &'a Foo,
    doo : &'b Foo
}

fn main() {
    let mut a = Foo {f: Box::new(14)};

    let d : &Foo;

    { // block1
        let mut b = Foo {f: Box::new(13)};

        let bar = Bar{ foo : &a,doo : &b};
        println!("{}" ,  bar.foo.f);

        d = bar.foo;
    } // end of block1

    //a.f = Box::new(1);
    println!("{}" ,  d.f);
}
```

首先如果一个struct有多个引用，那它的实例的寿命只能和最短命的那个引用一样长。 a的寿命是整个main函数，而b的寿命是block1,
所以bar的寿命只能是block1。

如果我们把block1的最后一行改成:

```rust
d = bar.doo;
```

就会无法编译:

```rust
struct Foo {
    f : Box<i32>,
}

struct Bar<'a,'b> {
    foo : &'a Foo,
    doo : &'b Foo
}

fn main() {
    let mut a = Foo {f: Box::new(14)};

    let d : &Foo;

    { // block1
        let mut b = Foo {f: Box::new(13)};

        let bar = Bar{ foo : &a,doo : &b};
        println!("{}" ,  bar.foo.f);

        d = bar.doo;
    } // end of block1

    //a.f = Box::new(1);
    println!("{}" ,  d.f);
}
```

好，接下来我们看看lifetime和函数的关系。

```rust
struct Foo {
    f : Box<i32>,
}

fn test(a : &Foo,b : &Foo) -> &Foo {
    println!("a : {} - b : {}",a.f,b.f);
    b;
}

fn main() {
    let  a = Foo {f: Box::new(14)};


    let  b = Foo {f: Box::new(13)};
    //println!("{}" ,  bar.foo.f);
    test(&a,&b);
}
```

函数test有两个类型为&Foo，无需为这个函数显式指定lifetime。如果函数返回一个引用，则必须为函数显式指定lifetime。

我们修改代码，让函数返回一个引用，我们先不给它加lifetime，看看编译器提示什么．

```rust
struct Foo {
    f : Box<i32>,
}

fn test(a : &Foo,b : &Foo) -> &Foo {
    println!("a : {} - b : {}",a.f,b.f);
    b;
}

fn main() {
    let  a = Foo {f: Box::new(14)};


    let  b = Foo {f: Box::new(13)};
    //println!("{}" ,  bar.foo.f);
    test(&a,&b);
}
```

```
<anon>:5:31: 5:35 error: missing lifetime specifier [E0106]
<anon>:5 fn test(a : &Foo,b : &Foo) -> &Foo {
                                       ^~~~
<anon>:5:31: 5:35 help: this function's return type contains a borrowed value, but the signature does not say whether it is borrowed from `a` or `b`
error: aborting due to previous error
playpen: application terminated with error code 101
```

我们的函数返回了一个引用，px 有两引用类参数，编译器不知道返回的引用是从哪个参数借来的．所以时我们必须显式指定lifetime．

```rust
fn test<'a> (a : &Foo,b : &'a Foo) -> &'a Foo {
    println!("a : {} - b : {}",a.f,b.f);
    b
}
```

可不可以返回值的lifetime与参数的不相关呢？

```rust
fn test<'a,'b> (a : &Foo,b : &'a Foo) -> &'b Foo ;
```

上面的函数可能实现吗？如何从函数里面返回一个带新的lifetime的引用？在函数里新创建一个Foo?这样它就有了一个新的lifetime？
问题是函数体内创建的实例会在函数返回时销毁，引用就会失效．

```rust
fn test<'a,'b> (a : &Foo,b : &'a Foo) -> &'b Foo {
    println!("a : {} - b : {}",a.f,b.f);
    &Foo{f : Box::new(12)}
}
```

可以看出来**函数返回值的lifetime一定是跟某个参数的一致的**．

函数返回一个引用时必须显示指定lifetime，因为这个返回的引用__延长了引用生命期__.

没有返回值的函数也能延长引用的生命期．

```rust
struct Foo {
    f : Box<i32>,
}

struct Link<'a> {
    link: &'a Foo,
}

fn store_foo<'a> (x: &mut Link<'a>, y: &'a Foo) {
    x.link = y;
}

fn main() {
    let a = Foo{f : Box::new(1)};

    let x = &mut Link{ link : &a };

    if false {
        let b = Foo { f: Box::new(2) };

        store_foo(x, &b);  //在这里试图延长b的引用的生命期，但是b会在if块后销毁，&b就会成为野引用，所以这行代码无法编译．
    }
}
```

Rust的Borrow和Lifetime虽然有一点难理解，但请相信，一旦弄懂并开始coding,你会爱上它，：D。

# 5.23 Trait Object

Trait Object其实是Trait指针。  有了多态就要动态dispatch,所以有了Trait Object.

Trait objects, like &Foo or Box<Foo>.

```
A trait object can be obtained from a pointer to a concrete type that implements the trait by casting it (e.g. &x as &Foo) or coercing it (e.g. using &x as an argument to a function that takes &Foo).
```

其实它就是Trait指针嘛

## 一些参考资料

[1] [RFC: rename `lifetime` to `scope` ](https://github.com/rust-lang/rfcs/pull/431)

[Rust Borrow and Lifetimes](http://arthurtw.github.io/2014/11/30/rust-borrow-lifetimes.html)

[Rust by example](http://rustbyexample.com/)

[Move and Copied Types](http://doc.rust-lang.org/nightly/reference.html#moved-and-copied-types)

[Error Handling in Rust](http://blog.burntsushi.net/rust-error-handling/) 对rust错误处理讲得比较详细

# Rust 宏

Kleene star 克林星号

unwrap
Rc<T> and Arc<T>

# unsafe

Code using unsafe has less restrictions than normal code does.

有两种应用场景

**1 标识函数为unsafe**

```rust
unsafe fn danger_will_robinson() {
    // scary stuff 
}
```

All functions called from FFI must be marked as unsafe, for example.

**2 unsafe块**   

```rust
unsafe {
    // scary stuff
}
```

In both unsafe functions and unsafe blocks, Rust will let you do three things that you normally can not do. Just three. Here they are:

1. Access or update a static mutable variable.
2. Dereference a raw pointer.
3. Call unsafe functions. This is the most powerful ability.

# 错误处理

Option,Result,Some,None.这些是要了解的

# Attributes

很奇怪，在The Rust programming language这本书中没有介绍Attributes，不过语言的reference里是有的。

[Attributes - The Rust Reference](https://doc.rust-lang.org/reference/attributes.html#attributes)
## String 和 str的区别
    主要是因为内存管理方式的不同。
[疯狂字符串](https://course.rs/difficulties/string.html)
[Exploring Strings in Rust](https://betterprogramming.pub/strings-in-rust-28c08a2d3130) 把string讲解得非常清楚
