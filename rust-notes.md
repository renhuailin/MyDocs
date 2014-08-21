

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


## 一些参考资料 
[Rust for Rubyists](http://www.rustforrubyists.com/book/book.html)
