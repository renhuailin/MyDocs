
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
