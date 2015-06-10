
# 5.1 Expressions vs. Statements
从根本上来说，rust是基于expression的一门语言。它只有两种类型的statement，其它的全是expression。

那 Expressions和Statements有什么区别？ Expressions有返回值而Statements没有。

在大多数的语言里`if`是Statement，没有返回值。因此 let x = if ...这样的语句没有意义。但是在Rust里，`if`是Expression,可以有返回值，可以用它来初始化变量。

赋值语句（Rust术语叫bindings）是Rust的两种Statement里的一种，准确地说是`声明语句`。目前为止，let是我们见到的唯一的`声明语句`，那我们就再多说点。

在大多数的语言里，变量赋值是可以写成Expressions的，如：
```
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





# box unbox

rust 里的 box是从heap分配的内存的指针。



## 5.24 Closures 闭包


有一种是stack closure,是在栈上的closure。


``` rust
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


## Ownership
Rust ensures that there is exactly one binding to any given resource.


## move还是copy
When a local variable is used as an rvalue the variable will either be moved or copied, depending on its type. All values whose type implements Copy are copied, all others are moved.    
当一个局部变量用做右值时，它可能会被move或copy，取决于它的类型，如果它实现了`Copy`这个trait，那它就会被copied，否则就会被moved.    
move是从哪儿move到哪儿?  如果是copy是从哪儿copy到哪儿？

``` rust
let v = vec![1, 2, 3];

let v2 = v;
```
vector没有实现`Copy` trait，所以在赋值后`v`就不可以用了。

``` rust
let v = 1;

let v2 = v;

println!("v is: {}", v);
```
这个例子里v的类型是i32，它实现了`Copy` trait，所以`let v2 = v;`这行代码执行时，rust会把v的值深度copy一份，
然后给v2，所以v在赋值后可以用的。



http://doc.rust-lang.org/nightly/reference.html#moved-and-copied-types


试想一下，如果我们写了一个函数，以vector为参数，为了能让函数调用后原来的变量能正常使用，我们必须手动归还这个ownership。

``` rust
fn foo(v1: Vec<i32>, v2: Vec<i32>) -> (Vec<i32>, Vec<i32>, i32) {
    // do stuff with v1 and v2

    // hand back ownership, and the result of our function
    (v1, v2, 42)
}

let v1 = vec![1, 2, 3];
let v2 = vec![1, 2, 3];

let (v1, v2, answer) = foo(v1, v2);
```
这简直太变态，无法接受啊！所以rust引入了`borrowing` 来解决这个问题。

## 5.9 References and Borrowing

在Ownership一节，我们给出了一个手动hand back Ownership例子
``` rust
fn foo(v1: Vec<i32>, v2: Vec<i32>) -> (Vec<i32>, Vec<i32>, i32) {
    // do stuff with v1 and v2

    // hand back ownership, and the result of our function
    (v1, v2, 42)
}

let v1 = vec![1, 2, 3];
let v2 = vec![1, 2, 3];

let (v1, v2, answer) = foo(v1, v2);
```

Rust使用`reference` 来解决这个问题。这是reference版本的。
``` rust
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
reference是什么？官方文档是这个说的。
```
We call the &T type a ‘reference’, and rather than owning the resource, it borrows ownership.
```
borrow,借，也就是所有权是没变的。我借你的书看，书还是你的（所有权归你），但是我现在在用它。
引用也是这个意思。

默认的References are immutable.


Here’s the rules about borrowing in Rust:

First, any borrow must last for a smaller scope than the owner.     
Second, you may have one or the other of these two kinds of borrows, but not both at the same time:

* 0 to N references (&T) to a resource.
* exactly one mutable reference (&mut T)


# Lifetime


在上一节里我们讲了引用和借用
把资源的引用借给他人使用其结果可能会很复杂。想像一下假如：
1.   我有一个资源
2.   我把这个资源的引用借给你
3.   我释放这个资源(我不关心你那儿还有一个引用，因为我是这个资源的owner,我有权释放它)。然后
4.   你要使用这个引用。

第4步，当你使用引用时，它所指向的资源已经不在了！这将导致不可预知的问题。

如何避免上述情况的发生？

一种解决方案就是: 当还有一个指向资源的引用存在时，资源就不能被释放。 没有指向资源的引用时，才能释放它。

这个方案下第3步就不会释放资源,第4步就是安全的。

那资源怎么释放呢？也有两种方案，引用计数(ARC)和垃圾回收器GC. Objective-C和Swift使用的是ARC,java和.net使用的是GC.

rust没有使用ARC也没有使用GC.  onwer使用完了资源（通常是owner超出作用范围自动销毁）就会释放资源。

那第4步怎么办？

Rust使用某种机制来保证第4步不会发生！

What?不会发生，怎么不会发生，我代码就要这样写，那当然会发生啊，比如：

``` rust
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
owner的lifetime。它发现引用的生命周期比资源的owner的长时，它编译时就报错了，根本就不会到
运行这一步。所以第4步是不会发生的。

因此在Rust里，你必须在owner释放资源之前使用它(借出)的引用。就也是上述的第4步应该发生在第3步之前。

1  我有一个资源

2  我把这个资源的引用借给你

4  你使用这个引用。

3  我释放这个资源。



上述的代码如果用java或swift来实现肯定可以编译通过。 我们已经习惯写这样的代码了，我们理所当然
地认为这样的代码可以运行。但是在rust里，你不能这样写代码，因为rust不允许你这样写。

如何保证第4步发生在第3步之前呢？rust是通过**保证资源owner活得比它的任何一个引用更长来实现的。**


ownership系统通过叫`lifetime`的概念来实现的。


```
The ownership system in Rust does this through a concept called lifetimes, which describe the scope that a reference is valid for.
```


记住，有引用才有lifetime.


``` rust
struct Foo {
    f : Box<i32>,
}

struct Bar {
    foo : &Foo
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

上面的代码会在第2个struct处报错`error: missing lifetime specifier`。而第1个就不报错这个错误，因为没有用引用。

好，我们现在给它加上lifetime。

``` rust
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

OK,可以编译通过了。很多人会被`Bar<'a>`和`foo : &'a Foo`里面的`'a`搞懵了。

`'a` 是`Named lifetime`,中文可译为带名有效期。它实际上是告诉编译器，struct Bar有引用，这个引用的lifetime我们把它命名为：a.

做为开发人员我们不用关心`'a`是怎么生效的。因为我们不会直接用到它。开发人员要就做的就是给引用加上一个带名有效期,然后由编译器来使用它。

你也许会说，我们只加了个`'a`代码就能编译了，为什么rust不为我们自动加一个呢？或者在这种情况也可以省略掉`'a`.那是因为我们的struct太简单了了，
实际上我们的struct可能会包含多个field，有多个引用。rust没有办法为我们自动加一个lifetime。


再强调一遍，当我们的struct包含了一个引用，那我们**struct的实例不能比它包含的引用活得更长**。而lifetime是rust用来度量引用有效期的
一个辅助标识。

下面我们看一个struct包含多个引用时的情况,这时`带名有效期`的作用就更容易理解。

``` rust
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
``` rust
d = bar.doo;
```
就会无法编译.









## 一些参考资料 

[Rust Borrow and Lifetimes](http://arthurtw.github.io/2014/11/30/rust-borrow-lifetimes.html)






