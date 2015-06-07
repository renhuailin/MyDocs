
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


## move还是copy
When a local variable is used as an rvalue the variable will either be moved or copied, depending on its type. All values whose type implements Copy are copied, all others are moved.    
当一个局部变量用做右值时，它可能会被move或copy，取决于它的类型，如果它实现了`Copy`这个trait，那它就会被copied，否则就会被moved.    
move是从哪儿move到哪儿?  如果是copy是从哪儿copy到哪儿？




http://doc.rust-lang.org/nightly/reference.html#moved-and-copied-types



## 一些参考资料 
[Rust for Rubyists](http://www.rustforrubyists.com/book/book.html)
[Pointers in Rust: a guide](http://words.steveklabnik.com/pointers-in-rust-a-guide)
[Managed & Owned Boxes in the Rust Programming Language](http://tomlee.co/2012/12/managed-and-owned-boxes-in-the-rust-programming-language/)


[Rust Borrow and Lifetimes](http://arthurtw.github.io/2014/11/30/rust-borrow-lifetimes.html)



