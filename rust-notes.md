
# 5.1 Expressions vs. Statements
从根本上来说，rust是基于expression的一门语言。它只有两种类型的statement，其它的全是expression。

那 Expressions和Statements有什么区别？ Expressions有返回值而Statements没有。

在大多数的语言里`if`是Statement，没有返回值。因此 let x = if ...这样的语句没有意义。但是在Rust里，if是Expression,可以有返回值，可以用它来初始化变量。

赋值语句（Rust术语叫bindings）是Rust的两种Statement里的一种，也就是赋值语句是没有返回值的。


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
