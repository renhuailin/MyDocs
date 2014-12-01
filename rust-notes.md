
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




## 11.1 Freezing
Lending an &-pointer to an object freezes the pointed-to object and prevents mutation—even if the object was declared as mut.  Freeze objects have freezing enforced statically at compile-time. An example of a non-Freeze type is RefCell<T>.


## 11.1 冻结
把&指针传给一个对象，会冻结这个指针所指向的对象，使其不可变-即使这个对象被声明为mut。
Lending an &-pointer to an object freezes the pointed-to object and prevents mutation—even if the object was declared as mut.  Freeze objects have freezing enforced statically at compile-time. An example of a non-Freeze type is RefCell<T>.



```rust
let mut x = 5;
{
    let y = &x; // `x` is now frozen. It cannot be modified or re-assigned.
}
// `x` is now unfrozen again
```



## 15 Closures 闭包


有一种是stack closure,是在栈上的closure。






## 一些参考资料 
[Rust for Rubyists](http://www.rustforrubyists.com/book/book.html)
[Pointers in Rust: a guide](http://words.steveklabnik.com/pointers-in-rust-a-guide)
[Managed & Owned Boxes in the Rust Programming Language](http://tomlee.co/2012/12/managed-and-owned-boxes-in-the-rust-programming-language/)
