# The Rust Programming Language

--------

&String 和 &str 

&String 是 String的reference.

 &str 是 string slice 

他们是不同的类型，一定要注意。

关于static lifetime.

https://www.jianshu.com/p/500ed3635a41

https://users.rust-lang.org/t/why-does-thread-spawn-need-static-lifetime-for-generic-bounds/4541


## 4. Understanding Ownership
一定要先了解什么情况下会在堆里分配内存，什么情况下在栈里分配内存。只有在堆里分配的内存才需要手工释放。




Ownership Rules

First, let’s take a look at the ownership rules. Keep these rules in mind as we work through the examples that illustrate them:

- Each value in Rust has an owner.
- There can only be one owner at a time.
- When the owner goes out of scope, the value will be dropped.


**The String Type**

To illustrate the rules of ownership, we need a data type that is more complex than those we covered in the “Data Types” section of Chapter 3. The types covered previously are all a known size, can be stored on the stack and popped off the stack when their scope is over, and can be quickly and trivially copied to make a new, independent instance if another part of code needs to use the same value in a different scope. But we want to look at data that is stored on the heap and explore how Rust knows when to clean up that data, and the String type is a great example.

在第三章里提到的类型都是预知大小的，能被保存在栈上，并在超出范围后被弹出栈（也就是销毁），当其它范围的代码（比如其它函数）要用到这个值的时候，也可以非常快速地复制为一个新的、独立的实例。



我们一定时刻牢记下面三个规则：
- 每个值都有owner.
- 在某一时刻只能有一个owner.
- 当owner超出作用范围时，它own的值就会被drop，也就是释放掉。


那在什么情况下才在堆里分配内存呢？那就是在**编译时无法确定大小的变量**。


就来字符串来说吧，
```rust
let s1 = "hello";
let s2 = String::from("hello");
```
s1就是字符字面量（string literal），在编译时就知道大小了。会分配在栈上，而s2则会分配在堆上。

下面的例子是一个变量，没有发生owner转移，所以在作用域的最后就回收了。rust会自动调用`drop`这个方法来释放内存。
```rust
fn main() {
    {
        let s = String::from("hello"); // s is valid from this point forward

        // do stuff with s
    }                                  // this scope is now over, and s is no
                                       // longer valid
}
```
我们的代码当然不可能都像上面那么简单，当有多个变量要使用分配在堆上的内存时，情况就会复杂很多。

**Ways Variables and Data Interact: Move**

```rust
    let x = 5;
    let y = x;
```
因为integer是简单、已知固定大小的类型，所以`let y=x;`会简单地把x的值copy一份给y。 这时会有两个`5`被压进栈。

我们来看看`String`版本的。

```rust
{
    let s1 = String::from("hello");
    let s2 = s1;
    println!("{}",s1);
}
    
```
如果是其它语言，上面的代码可以编译并执行。因为`let s2 = s1;`会执行一个浅copy，也就是只copy指针，并没有copy它所指向的内存中的内容。
那种copy内存中的内容的操作叫deep copy，深度复制。
因为String是从堆上分配内存的，所以如果像其它语言一样，s1和s2都指向同一块内存，且同时超出scope，那被同时销毁的话，就会出现同一块内存被销毁两次的情况。
这是很多程序的bug，也是非常危险的操作。
在rust里当执行`let s2 = s1;`时，就发生了ownership的转移，这时s1就不再指向堆上的内存了。这时你再尝试打印它的值时就会编译报错，因为编译器知道这时s1已经是没有指向有效的内容了。


**Ways Variables and Data Interact: Clone**

那在rust里如果执行深copy呢？需要手工调用一个方法：`clone()`

```rust
{
    let s1 = String::from("hello");
    let s2 = s1.clone();

    println!("s1 = {}, s2 = {}", s1, s2);
}
    
```

**Stack-Only Data: Copy 栈上数据：复制**
这一节的意思是`stack-only`,也就是只存在于栈上的数据。比如同一个函数里的两个整数变量。

```rust
    let x = 5;
    let y = x;

    println!("x = {}, y = {}", x, y);
```
像integer这样的类型，编译期就知道它的大小，因为它是固定大小的嘛，是完全保存在栈上的。所以它的内容copy起来也非常的快。因此浅copy和deep copy也操作也基本没啥区别了，开销都非常小（甚至copy整数的开销更小）。

Rust有一个特别的annotation叫 `Copy trait`.我们可以把它放在可以在栈里保存的类型的前面，如果一个类型实现了`Copy` trait，当变量被赋给其它变量时，就会自动执行deep copy。

从[Copy trait](https://doc.rust-lang.org/std/marker/trait.Copy.html)的文档里，可以总结出来它有以下特点：
- it is always a simple bit-wise copy.它一直执行的简单的按位复制。根据我的理解，它复制的是变量保存在栈里的内容。比如integer变量，它在栈里保存的内容就是整数的值；如果是`String`那保存就是一个指针，这个指针包含三个部分，如下图，包含一个指向堆上的指针、字符串的len和capacity.如果是按位复制就会把指向堆上的指针也复制了。会导致二次释放的问题。
![字符串指针](https://doc.rust-lang.org/book/img/trpl04-01.svg)

- 它是隐式执行的，而且无法被重载,is not overloadable.查看它的源代码，会发现它只是一个空的trait，也就是它只起标识的作用。所以当然是无法重载的啦。

```rust
pub trait Copy: Clone { }
```
更详细的内容，请看[Copy和Cloe的区别](https://doc.rust-lang.org/std/marker/trait.Copy.html#whats-the-difference-between-copy-and-clone)

### 4.2 References and Borrowing

首先要理解，**引用** 就是一个指针，还是以字符串为例：

```rust
fn main() {
    let s1 = String::from("hello");

    let len = calculate_length(&s1);

    println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize {
    s.len()
}
```
上面的例子里s是s1的引用，如下图，s保存就是s1在内存中的地址。
![图解引用](https://doc.rust-lang.org/book/img/trpl04-05.svg)

We call the action of creating a reference *borrowing*. 创建引用的动作叫*borrowing*. rust为什么用借呢？我理解是这样：
- 对于你借的东西，你不拥有*所有权*，没有所有权的意思是你无权销毁它。在上面的函数calculate_length里，如果s不是引用，是普通变量，那它就会在函数结束后就销毁了。引用则不会，引用的东西是借的，最后要还的，不能销毁。

**The Rules of References 引用定律**
Let’s recap what we’ve discussed about references:

- At any given time, you can have either one mutable reference or any number of immutable references.
在任何给定的时间，你只能有一个可变引用或是多个不可变引用。
如果你借的是可变引用，那就只能你借，别人无法再借了。
- References must always be valid.  引用必须一直是有效的，这是强制的。你不可能为一个空值创建一个引用。


### 4.3 The Slice Type

这一章非常好理解没啥讲的。
下面这段话对初学者有点指导价值。
A more experienced Rustacean would write the signature shown in Listing 4-9 instead because it allows us to use the same function on both &String values and &str values.

```rust
fn first_word(s: &str) -> &str {
```
If we have a string slice, we can pass that directly. If we have a String, we can pass a slice of the String or a reference to the String. This flexibility takes advantage of deref coercions, a feature we will cover in the “Implicit Deref Coercions with Functions and Methods” section of Chapter 15. Defining a function to take a string slice instead of a reference to a String makes our API more general and useful without losing any functionality。


## 6. Enums and Pattern Matching

**6.1 Defining an Enum**

```rust
enum Message {
	Quit,
	Move { x: i32, y: i32 },
	Write(String),
	ChangeColor(i32, i32, i32),
}
```

Rust的enum有点像Java的，但又不太一样，又有些像C里面的union。

**6.3 Concise Control Flow with if let**

```rust
let some_u8_value = Some(0u8);

if let Some(3) = some_u8_value {

	println!("three");

}
```

这个跟swift的语法有些相似。

## 7. Managing Growing Projects with Packages, Crates, and Modules

先理解一些概念

- **Packages:** A Cargo feature that lets you build, test, and share crates 包
- **Crates:** A tree of modules that produces a library or executable 箱，是包的树，最后编译为library或可执行文件。
- **Modules** and **use:** Let you control the organization, scope, and privacy of paths 用来控制paths的组织、范围和隐私。
- **Paths:** A way of naming an item, such as a struct, function, or module 是struct、function或module的命名方式。

**7.1 Packages and Crates**

A crate is a binary or library. The *crate root* is a source file that the Rust compiler starts from and makes up the root module of your crate (we’ll explain modules in depth in the “Defining Modules to Control Scope and Privacy” section). A *package* is one or more crates that provide a set of functionality. A package contains a *Cargo.toml* file that describes how to build those crates.

箱是library或可执行文件。  *crate root* 是一个源文件，Rust编译器从它开始编译。

一个`package`是一个或多个crates，提供一组功能。 一个package包含一个`Cargo.toml`,这个文件描述了要如何构建这个crates.

一个`package `里包含的内容是有规定的：

- 0或1个library crate, 不能再多了。
- 可以包含多个binary crates。
- 至少要包含一个crate(library or binary都行)

创建一个package,用`cargo new`。

```
$ cargo new my-project
 Created binary (application) `my-project` package

$ ls my-project
Cargo.toml
src

$ ls my-project/src
main.rs
```

Cargo帮我们生成了一个binary的crate。

By convention ：

src/[main.rs](http://main.rs)是binary crate的crate root。

*src/*[*lib.rs*](http://lib.rs) 是library crate的crate root。

 一个package可以包含多个binary crates， 只需要把文件放在` *src/bin*`下，每个文件会被编译为独立的可执行文件。

A crate will group related functionality together in a scope so the functionality is easy to share between multiple projects.

一个箱(crate)会把一个scope里的一组功能组合起来以方便在多个项目之间共享。

**7.2 Defining Modules to Control Scope and Privacy**

*Modules* let us organize code within a crate into groups for readability and easy reuse. Modules also control the *privacy* of items, which is whether an item can be used by outside code (*public*) or is an internal implementation detail and not available for outside use (*private*).

`Modules`允许我们把crate里的代码分组，方便复用。同时它可以控制crate里的items的*privacy*，也就是谁能访问它。

以一个饭店*module*为例，可以分为前端和后端，前端主要是接待的，后端主要是做菜的。

```rust
mod front_of_house {

	mod hosting {
	
		fn add_to_waitlist() {}
		
		fn seat_at_table() {}
	
	}

	mod serving {
	
		fn take_order() {}
		
		fn serve_order() {}
		
		fn take_payment() {}
	
	}

}
```

`*module tree*`  显示了module之间的关系。

```
crate
 └── front_of_house
 ├── hosting
 │ ├── add_to_waitlist
 │ └── seat_at_table
 └── serving
 ├── take_order
 ├── serve_order
 └── take_payment
```

Notice that the entire module tree is rooted under the implicit module named crate. 注意整个module tree的根是一个隐式的module叫`crate`。

这跟java的package是非常相似的。

**7.3 Paths for Referring to an Item in the Module Tree**

这个path跟文件系统里的path很像，上节我们也看到了，module tree跟文件系统的目录也是非常像的。

访问一个crate里的item有两种方式：

- 用绝对路径，文件系统是”/”开头的，rust的module的根是`crate`。
- 用相对路径，是从当前module开始，用self,super或是当前module里一个标识符。

跟文件系统用`/`分隔目录不同的是，rust使用`::`来分隔module。

```
mod front_of_house {
 pub mod hosting {
     pub fn add_to_waitlist() {}
 }
}

pub fn eat_at_restaurant() {

 // Absolute path

 crate::front_of_house::hosting::add_to_waitlist();

 // Relative path

 front_of_house::hosting::add_to_waitlist();

}
```

为了让module里的item能让其它module访问，需要用`pub`关键字把它发布出来。类似于java中的public关键字。

用**super**以相对路径方式访问**module.**

```rust
fn serve_order() {}
mod back_of_house {
 fn fix_incorrect_order() {

 cook_order();

 super::serve_order();

 }

 fn cook_order() {}
}
```

**Making Structs and Enums Public** 公开**Structs and Enums** 

如果 pub放在struct的定义前，那么这个struct是public的，但是它的fields不是Public, 还需要把pub放field定义前才可以。

但enum不一样，只要把pub放在enum的定义前，它的所有的variants就都是public的了。

**7.4 Bringing Paths into Scope with the use Keyword**

在上面的例子中，我们使用`crate::front_of_house::hosting::add_to_waitlist();`这种方式来调用module里的对象，这也太啰嗦了。

可以用`use`关键字来简化，在java里被称为import。

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
 hosting::add_to_waitlist();

 hosting::add_to_waitlist();

 hosting::add_to_waitlist();

}
```

跟python的import类似，可以在use时给导入的item提供一个新的名字。

```rust
use std::fmt::Result;

use std::io::Result as IoResult;
```

```rust
mod front_of_house {

 pub mod hosting {

 pub fn add_to_waitlist() {

 println!(" add to wait list.")

 }
 }
}
```


**Re-exporting Names with pub use** 用 **pub use**实现重新导出。

请看下面的例子，hosting是前台的一个module，在后台用pub use导出后，backend这个module也有了一个hosting。

```rust

mod front_of_house {

    pub mod hosting {

        pub fn add_to_waitlist() {
            println!(" add to wait list.")
        }
    }
}

mod backend {

    pub use crate::front_of_house::hosting;

    pub fn eat_at_restaurant() {
        hosting::add_to_waitlist();

        hosting::add_to_waitlist();

        hosting::add_to_waitlist();
    }
}

fn main() {
    let string1 = String::from("abcd");

    let string2 = "xyz";

    let result = longest(string1.as_str(), string2);

    println!("The longest string is {}", result);

    use crate::backend::hosting;

    backend::eat_at_restaurant();

    hosting::add_to_waitlist();
}
```

**Using Nested Paths to Clean Up Large use Lists** 

这在脚本语言里很常见。

```rust
// --snip--

use std::cmp::Ordering;

use std::io;

// --snip--

// --snip--

// 可以替换成这样：

use std::{cmp::Ordering, io};

// --snip--
use std::io;

use std::io::Write;

use std::io::{self, Write};
```

### 7.5 Separating Modules into Different Files**

前面的例子里，我们把module放在一个文件里，在现实中的项目中module可能很大，需要把它分散到多个文件中去。

注意： 这种分散跟Java的非常不同，要注意理解。

我们试着把上文中的例子分散到文件中。

先把`front_of_house`独立到文件中去。 上面提到过，module root文件 是src/[lib.rs](http://lib.rs)或是src/[main.rs](http://main.rs)。

所以如果我们希望以`crate::front_of_house`方式访问front_of_house module内的内容。需要在src/[lib.rs](http://lib.rs)或是src/[main.rs](http://main.rs)内定义front_of_house module.

src/[lib.rs](http://lib.rs)

```rust
mod front_of_house;

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {

 hosting::add_to_waitlist();

 hosting::add_to_waitlist();

 hosting::add_to_waitlist();

}
```

问题是front_of_house的子module `hosting`应该放在哪个文件中呢？

应该放在src/[front_of_house.rs](http://front_of_house.rs)中

[src/[front_of_house.rs](http://front_of_house.rs)]内容：

```rust
pub mod hosting {

 pub fn add_to_waitlist() {}

}
```

我们还可以再的接着拆，把hosting这个module也拆到多个文件里。

这时`src/[front_of_house.rs](http://front_of_house.rs)`的内容改成：

```rust
pub mod hosting;
```

`hosting`这个module里面的内容要放在一个单独文件中，这个文件是： *src/front_of_house/*[*hosting.rs*](http://hosting.rs)。所以我们需要创建一个叫*front_of_house*的目录。

然后再在这个目录下创建[*hosting.rs*](http://hosting.rs)这个文件。 注意这时*src*目录下有个名为[front_of_house.rs](http://front_of_house.rs)的文件和一个名为*front_of_house*的目录。

[*src/front_of_house/*[*hosting.rs*](http://hosting.rs)]内容：

```rust
pub fn add_to_waitlist() {}
```

The `mod` keyword declares modules, and Rust looks in a file with the same name as the module for the code that goes into that module.

`mod`用来定义module，Rust会查询在相同名字的rs文件里找这个module的代码。


### 7.6 extern crate
我们经常会在代码中看到这样的语法。
``` rust
extern crate pcre;

```
根据rust language [reference](https://doc.rust-lang.org/reference/items/extern-crates.html),这样的声明主要是为了`extern prelude`.

    An extern crate declaration specifies a dependency on an external crate. The external crate is then bound into the declaring scope as the identifier provided in the extern crate declaration. Additionally, if the extern crate appears in the crate root, then the crate name is also added to the extern prelude, making it automatically in scope in all modules. The as clause can be used to bind the imported crate to a different name.

也就是会把这个crate绑定到当前的（declaring scope）scope中。也就是不用`use`这个关键字，就可以访问crate里的内容了。
如果这个外部声明出现在crate root,那么这个crate的名字也会被加到`extern prelude`中，这个scope下的所有Modules都自动可以引用它了。

### 7.7 Prelude

    A prelude is a collection of names that are automatically brought into scope of every module in a crate.

    These prelude names are not part of the module itself: they are implicitly queried during name resolution. For example, even though something like Box is in scope in every module, you cannot refer to it as self::Box because it is not a member of the current module.


标准库的[prelude](https://doc.rust-lang.org/std/prelude/index.html)模块讲得非常详细了。 

Rust comes with a variety of things in its standard library. However, if you had to manually import every single thing that you used, it would be very verbose. But importing a lot of things that a program never uses isn’t good either. A balance needs to be struck.
意思是标准库里有好多东西，如果我们手动导入的话，就太繁琐了。但是如果导入了很多没用的东西也不是好的选择，rust需要平衡这些需求，于是有了prelude。


**The prelude is the list of things that Rust automatically imports into every Rust program.** It’s kept as small as possible, and is focused on things, particularly traits, which are used in almost every single Rust program.
Other preludes

prelude是Rust自动导入到每个程序的一系列东西。它尽可能的小，它聚焦在那些每个Rust程序都会用到的东西上，尤其是`traits`.

Preludes can be seen as a pattern to make using multiple types more convenient. As such, you’ll find other preludes in the standard library, such as std::io::prelude. Various libraries in the Rust ecosystem may also define their own preludes.

Prelude可经被视为一种更方便地使用多个types的范式。你可在标准库中找到其它的Preludes，如`std::io::prelude`。Rust生态圈中的库也可能包含它们自己的preludes.

The difference between ‘the prelude’ and these other preludes is that they are not automatically use’d, and must be imported manually. This is still easier than importing all of their constituent components.

`the prelude`跟其它preludes的区别是，后者不是自动导入的，必须被手动导入。即使这样也比手动导入它们里面的components要方便很多。

通过查看[标准库中的preludes](https://doc.rust-lang.org/reference/names/preludes.html#standard-library-prelude)，我明白了，为什么我常在代码中看到`#[derive(PartialEq)]`这样的代码，但是我没见代码里有导入`derive`和`PartialEq`.

注意，可以通过`no_std`这个attribute来禁用标准库的preludes.

#### Language Prelude
除了标准库中的prelude外，Rust也有语言级的prelude。

    Type namespace
        Boolean type — bool
        Textual types — char and str
        Integer types — i8, i16, i32, i64, i128, u8, u16, u32, u64, u128
        Machine-dependent integer types — usize and isize
        floating-point types — f32 and f64
    Macro namespace
        Built-in attributes

这也是为什么可以在代码中使用这些类型而没有看到相关use的原因。

## 8. Common Collections

**8.3 Storing Keys with Associated Values in Hash Maps**

For types that implement the Copy trait, like i32, the values are copied into the hash map. For owned values like String, the values will be moved and the hash map will be the owner of those values, 

实现了Copy trait的类型，他们的值会被copy到hash map里。 像String这样的 owned values，他们的值会移到hash map里，hash map接管它们的ownership。

If we insert references to values into the hash map, the values won’t be moved into the hash map. The values that the references point to must be valid for at least as long as the hash map is valid. We’ll talk more about these issues in the “Validating References with Lifetimes” section in Chapter 10.

如果我们把一个引用放在hash map里，你必须保证这个引用指向的值在这个hash map存在的时候一直有效，也就是在hash map的生命周期里它必须是有效的。会在第10章讲Lifetimes时详细介绍。

## 9. Error Handling

Rust的错误处理跟Go和Java都不一样，它主要依赖Result这个enum。

```rust
enum Result<T, E> {

 Ok(T),

 Err(E),

}
```

这里给出一个错误处理的例子

```rust
use std::fs::File;

use std::io::ErrorKind;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,

        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => fc,

                Err(e) => panic!("Problem creating the file: {:?}", e),
            },

            other_error => {
                panic!("Problem opening the file: {:?}", other_error)
            }
        },
    };
}

```

**Shortcuts for Panic on Error: unwrap and expect**

```rust
use std::fs::File;



fn main() {

 let f = File::open("hello.txt").unwrap();

}
```

If the Result value is the Ok variant, unwrap will return the value inside the Ok. If the Result is the Err variant, unwrap will call the panic! macro for us.

**如果Result是Ok,那么`unwrap`就会返回Ok里的值，如果Result是`Err`,那就直接调用panic!的了。**

可以使用expect方法来提供一个自定义的错误消息。

```rust
use std::fs::File;

fn main() {
	let f = File::open("hello.txt").expect("Failed to open hello.txt");
}
```

**Propagating Errors** 传播错误

在函数中，大部分情况下我们是不希望在出错时就panic的，我们会希望把错误的处理权交给调用方。

如：

```rust
use std::fs::File;

use std::io;

use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hello.txt");

    let mut f = match f {
        Ok(file) => file,

        Err(e) => return Err(e),
    };

    let mut s = String::new();

    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),

        Err(e) => Err(e),
    }
}

```

这样写是不是太啰嗦了？rust提供了`?`操作符，以简化代码。

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
```

要注意main()函数是特殊的，它的返回值是有限制的。 

1. 返回 `()`
2. 返回 Result<T, E>，其中T就只能是()。

```rust
use std::error::Error;
use std::fs::File;

fn main() -> Result<(), Box<dyn Error>> {
    let f = File::open("hello.txt")?;
    Ok(())
}
```

## 10. Generic Types, Traits, and Lifetimes

### 10.2 Traits: Defining Shared Behavior

Traits are similar to a feature often called *interfaces* in other languages, although with some differences.

Traits很像java里的interface，虽然有一些不同。

```rust
pub trait Summary {
    fn summarize(&self) -> String;
}

pub struct Tweet {
    pub username: String,

    pub content: String,

    pub reply: bool,

    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

One restriction to note with trait implementations is that we can implement a trait on a type only if either the trait or the type is local to our crate. 

This restriction is part of a property of programs called *coherence*, and more specifically the *orphan rule*, so named because the parent type is not present. This rule ensures that other people’s code can’t break your code and vice versa. Without the rule, two crates could implement the same trait for the same type, and Rust wouldn’t know which implementation to use.

一个约束，那就是trait和类型两都之一必须是crate本地的。不能同时都是crate外面的。如果没有这条规则，两个crate就可以为同一个类实现同一个trait，Rust就不知道该用哪个了。

跟Java的interface一样，traits也是可以有默认方法的。

```rust
pub trait Summary {
    fn summarize_author(&self) -> String;

    fn summarize(&self) -> String {
        format!("(Read more from {}...)", self.summarize_author())
    }
}
```

### 10.3 Validating References with Lifetimes

```rust
&i32 // a reference

&'a i32 // a reference with an explicit lifetime

&'a mut i32 // a mutable reference with an explicit lifetime
```
One lifetime annotation by itself doesn’t have much meaning, because the annotations are meant to tell Rust how generic lifetime parameters of multiple references relate to each other. For example, let’s say we have a function with the parameter first that is a reference to an i32 with lifetime 'a. The function also has another parameter named second that is another reference to an i32 that also has the lifetime 'a. **The lifetime annotations indicate that the references first and second must both live as long as that generic lifetime.**


注意最后一句话，参数first和second必须存活跟**generic lifetime**一样长才行。

例如：

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

The function signature now tells Rust that for some lifetime 'a, the function takes two parameters, both of which are string slices that live at least as long as lifetime 'a. The function signature also tells Rust that the string slice returned from the function will live at least as long as lifetime 'a. **In practice, it means that the lifetime of the reference returned by the longest function is the same as the smaller of the lifetimes of the references passed in.** These constraints are what we want Rust to enforce. Remember, when we specify the lifetime parameters in this function signature, we’re not changing the lifetimes of any values passed in or returned. Rather, we’re specifying that the borrow checker should reject any values that don’t adhere to these constraints. Note that the longest function doesn’t need to know exactly how long x and y will live, only that some scope can be substituted for 'a that will satisfy this signature.

这个函数的signature告诉我们，有某个lifetime，这个两个参数要跟lifetime存活的时间一样长。同时，返回的string slice的生命也是跟这个lifetime一样长。 实际上，**lifetime a**是跟传进来的参数里**lifetime**最短的那是一致的。记住，函数声明里的**lifetime**并不改变任何传入的参数或返回值的**lifetime**的。

为什么要给函数加上这个lifetime annotation呢？非常好理解，函数内部的lifetime，rust能自动分析出来，但是函数外部传进来的reference，rust就无法分析了，因为每次传进来的参数的lifetime可能都是不一样的。 必须借助这个lifetime的annotation才行。

**Lifetime Annotations in Struct Definitions**

结构体里的Lifetime

struct ImportantExcerpt<'a> {

 part: &'a str,

}

fn main() {

 let novel = String::from("Call me Ishmael. Some years ago...");

 let first_sentence = novel.split('.').next().expect("Could not find a '.'");

 let i = ImportantExcerpt {

 part: first_sentence,

 };

}

这个struct里有一个field叫part, 它hold保持一个a string slice which is a reference. 在结构体的定义部分加上了lifetime annotation,所以这个struct和它的part是同一寿命的。

**Lifetime Elision** 省略Lifetime

在第4章的时候定义过一个函数，返回的也是引用，为什么没有用到lifetime annotation呢？

Filename: src/lib.rs
```rust
fn first_word(s: &str) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }

    &s[..]
}

```


这个函数没有用Lifetime但是也正常编译了。是什么原因呢？

在早期版本中，pre rust 1.0, 这个代码是不能编译的，那时编译器要求所有的引用必须要有lifetime.

在编写了大量 Rust 代码后，Rust 团队发现 Rust 程序员在特定情况下一遍又一遍地输入相同的Lifetime annotation。 这些情况是可预测的，并遵循一些确定性模式。

The developers programmed these patterns into the compiler’s code so the borrow checker could infer the lifetimes in these situations and wouldn’t need explicit annotations.

rust的开发人员把这些patterns写到compiler的代码里，以便borrow checker可推算这些场景下的lifetime，programmer就不用显示地加上lifetime annotation了。 随便着rust的推广和广泛使用，相信以后会有更多的这种Pattern会加入到compiler中，会大大减少需要显式添加lifetime annotation的情况。

Lifetimes on function or method parameters are called *input lifetimes*, and lifetimes on return values are called *output lifetimes*.

方法或函数的参数上的Lifetime叫输入*lifetimes,* 返回值上的*Lifetime*叫输出*lifetimes*。

当有没显式指定Lifetime annotation时，Rust compiler用三个规则来推算reference的lifetime.

The first rule is that each parameter that is a reference gets its own lifetime parameter. In other words, a function with one parameter gets one lifetime parameter: fn foo<'a>(x: &'a i32); a function with two parameters gets two separate lifetime parameters: fn foo<'a, 'b>(x: &'a i32, y: &'b i32); and so on.

The second rule is if there is exactly one input lifetime parameter, that lifetime is assigned to all output lifetime parameters: fn foo<'a>(x: &'a i32) -> &'a i32.

The third rule is if there are multiple input lifetime parameters, but one of them is &self or &mut self because this is a method, the lifetime of self is assigned to all output lifetime parameters. This third rule makes methods much nicer to read and write because fewer symbols are necessary.

规则1： 如果有没显式指定Lifetime annotation，每个参数默认分配一个lifetime。有几个参数compiler就为它生成几个lifetime。

规则2： 如果只有一个输入的lifetime，那么这个Lifetime会分配给所有的输出lifetime。

规则3： 如果有多个输入的lifetime，但其中有一个是&self or &mut self，那么lifetime of self 会分配给所有的输出lifetime.这个规则让方法看起来读或写起来更好些。

```rust
fn first_word(s: &str) -> &str 
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str 
```

现在我们可以解释为什么first_word这个函数不用加Lifetime annotation而longest需要加了。

我们先看first_word。

先应用规则1， 因为没有lifetime，且有一个输入reference,所以自动生成一个。

```rust
fn first_word<'a> (s: &’a str) -> &str
```

接下来应用规则2： 这时会发现只有一个输入lifetime，于是就把它分配给output lifetime. 这时所有reference的lifetime就都确定了。

```rust
fn first_word<'a> (s: &’a str) -> &’a str
```

也就是说compiler可以执照规则把所有的lifetime补上。这时程序员就不用自己加了。

我们先看longest。

先应用规则1， 因为没有lifetime，所以为每个reference自动生成一个。

```rust
fn longest<‘a,’b >(x: &'a str, y: &’b str) -> &str
```

接下来应用规则2：发现不符合规则2，因为它有多个输入lifetime，且其中没有&self or &mut self所以规则无法应用。这时compiler就抛出error，要求开发人员显式地添加Lifetime annotation。

**The Static Lifetime** 静态**lifetime**

One special lifetime we need to discuss is 'static, which means that this reference *can* live for the entire duration of the program. All string literals have the 'static lifetime, which we can annotate as follows:

```rust
let s: &'static str = "I have a static lifetime.";
```

The text of this string is stored directly in the program’s binary, which is always available. Therefore, the lifetime of all string literals is 'static.

You might see suggestions to use the 'static lifetime in error messages. But before specifying 'static as the lifetime for a reference, think about whether the reference you have actually lives the entire lifetime of your program or not. You might consider whether you want it to live that long, even if it could. Most of the time, the problem results from attempting to create a dangling reference or a mismatch of the available lifetimes. In such cases, the solution is fixing those problems, not specifying the 'static lifetime.

静态的lifetime意味着这个reference可以跟整个program的生命一样长。

[**Generic Type Parameters, Trait Bounds, and Lifetimes Together**](https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html#generic-type-parameters-trait-bounds-and-lifetimes-together)

```rust
fn main() {
    let string1 = String::from("abcd");
    let string2 = "xyz";

    let result = longest_with_an_announcement(
        string1.as_str(),
        string2,
        "Today is someone's birthday!",
    );
    println!("The longest string is {}", result);
}

use std::fmt::Display;

fn longest_with_an_announcement<'a, T>(
    x: &'a str,
    y: &'a str,
    ann: T,
) -> &'a str
where
    T: Display,
{
    println!("Announcement! {}", ann);
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

## 13. Functional Language Features: Iterators and Closures

### 13.1 Closures: Anonymous Functions that Can Capture Their Environment

**My Note**: Rust的Closure跟其实语言的差不多,但是因为rust是有ownership的，所以在capture enviromment的时候有一些差别的。

Closures can capture values from their environment in three ways, which directly map to the three ways a function can take a parameter: taking ownership, borrowing mutably, and borrowing immutably. These are encoded in the three `Fn` traits as follows:

- `FnOnce` consumes the variables it captures from its enclosing scope, known as the closure’s *environment*. To consume the captured variables, the closure must take ownership of these variables and move them into the closure when it is defined. The `Once` part of the name represents the fact that the closure can’t take ownership of the same variables more than once, so it can be called only once.
- `FnMut` can change the environment because it mutably borrows values.
- `Fn` borrows values from the environment immutably.

When you create a closure, Rust infers which trait to use based on how the closure uses the values from the environment. All closures implement `FnOnce` because they can all be called at least once. Closures that don’t move the captured variables also implement `FnMut`, and closures that don’t need mutable access to the captured variables also implement `Fn`. 

Closure 捕捉capture环境变量的方式有三种：

* FnOnce  这种方式的closure会take环境变量的ownership到closure里，Once的意思是，take环境变量的ownership这种事只能发生一次，因此也只能被调用一次。

* FnMut 以 mutably 的方式借用

* Fn 以immutably的方式借用。

```rust
fn main() {
    let x = vec![1, 2, 3];

    let equal_to_x = move |z| z == x;

    println!("can't use x here: {:?}", x);

    let y = vec![1, 2, 3];

    assert!(equal_to_x(y));
}
```

编译这段代码会报错：

```
$ cargo run
   Compiling equal-to-x v0.1.0 (file:///projects/equal-to-x)
error[E0382]: borrow of moved value: `x`
 --> src/main.rs:6:40
  |
2 |     let x = vec![1, 2, 3];
  |         - move occurs because `x` has type `Vec<i32>`, which does not implement the `Copy` trait
3 | 
4 |     let equal_to_x = move |z| z == x;
  |                      --------      - variable moved due to use in closure
  |                      |
  |                      value moved into closure here
5 | 
6 |     println!("can't use x here: {:?}", x);
  |                                        ^ value borrowed here after move

error: aborting due to previous error

For more information about this error, try `rustc --explain E0382`.
error: could not compile `equal-to-x`

To learn more, run the command again with --verbose.
```

这是因为，在closure**定义**的那一行，x的ownership就属于closure了。

### 13.2 Processing a Series of Items with Iterators

迭代器这个概念其它语言也有，不过rust里要考虑ownership的问题。

```rust
#[test]
    fn iterator_demonstration() {
        let v1 = vec![1, 2, 3];

        let mut v1_iter = v1.iter();

        assert_eq!(v1_iter.next(), Some(&1));
        assert_eq!(v1_iter.next(), Some(&2));
        assert_eq!(v1_iter.next(), Some(&3));
        assert_eq!(v1_iter.next(), None);
    }
```

Note that we needed to make `v1_iter` mutable: calling the `next` method on an iterator changes internal state that the iterator uses to keep track of where it is in the sequence. In other words, this code *consumes*, or uses up, the iterator. Each call to `next` eats up an item from the iterator. We didn’t need to make `v1_iter` mutable when we used a `for` loop because the loop took ownership of `v1_iter` and made it mutable behind the scenes.

Also note that the values we get from the calls to `next` are immutable references to the values in the vector. The `iter` method produces an iterator over immutable references. If we want to create an iterator that takes ownership of `v1` and returns owned values, we can call `into_iter` instead of `iter`. Similarly, if we want to iterate over mutable references, we can call `iter_mut` instead of `iter`.

需要注意：

我们创建iterator时，用了`mut`,因为每次调用next时，实际上是修改了v1的。

另外： `iter`方法是通过v1的immutable references产生的。

如果用`into_iter`，产生的iterator就会takes ownership of `v1`。

如果相通过iterator来修改v1时，需要用`iter_mut`   instead of   `iter`.

这是需要特别注意的。

### 13.3 Improving Our I/O Project

这一小节，把上面讲一个例子用iterator重构了一下。

原来的代码：

```rust
impl Config {
    pub fn new(args: &[String]) -> Result<Config, &str> {
        if args.len() < 3 {
            return Err("not enough arguments");
        }

        let query = args[1].clone();
        let filename = args[2].clone();

        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();

        Ok(Config {
            query,
            filename,
            case_sensitive,
        })
    }
}
```

这个代码的参数是slice,返回结果是`Result<Config, &str>`,要注意Config前面没有&，所以是发生了ownership转移的。也就是new方法在创建完Config后，把ownership转移给了caller。

所以，在声明`query`和`filename`时，都用了clone()这个方法。

而且这个函数里没有显式地指定lifetime，因为它符合省略lifetime的规则。

重构后的代码：

```rust
impl Config {
    pub fn new(mut args: env::Args) -> Result<Config, &'static str> {
        args.next();

        let query = match args.next() {
            Some(arg) => arg,
            None => return Err("Didn't get a query string"),
        };

        let filename = match args.next() {
            Some(arg) => arg,
            None => return Err("Didn't get a file name"),
        };

        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();

        Ok(Config {
            query,
            filename,
            case_sensitive,
        })
    }
}
```

由于new的参数不是reference了，所以不符合省略lifetime的规则了，返回值中的&str的lifetime必须明确地声明，这里只能声明为`static`。

### 13.4 Comparing Performance: Loops vs. Iterators

这一章，对比了for loop和iterator的性能，我之前觉得，iterator那么花哨，性能肯定好不了，结果是iterator的性能反而会稍稍好一点！

```
test bench_search_for  ... bench:  19,620,300 ns/iter (+/- 915,700)
test bench_search_iter ... bench:  19,234,900 ns/iter (+/- 657,200)
```


## 15. Smart Pointers

本章会主要介绍以下几种pointers:

- `Box<T>` for allocating values on the heap
- `Rc<T>`, a reference counting type that enables multiple ownership
- `Ref<T>` and `RefMut<T>`, accessed through `RefCell<T>`, a type that enforces the borrowing rules at runtime instead of compile time

### 15.1 Using `Box<T>` to Point to Data on the Heap

Boxes allow you to store data on the heap rather than the stack.

 You’ll use them most often in these situations:

- When you have a type whose size can’t be known at compile time and you want to use a value of that type in a context that requires an exact size
  
  当你有一个数据，它的大小在编译期是不确定的，但是你的使用场景却需要明确地需要它的大小。

- When you have a large amount of data and you want to transfer ownership but ensure the data won’t be copied when you do so
  
  当你有一大块的数据要转移所有权，但确保这些数据是不会被复制时。

- When you want to own a value and you care only that it’s a type that implements a particular trait rather than being of a specific type
  
  当你想要拥有一个值 ，你只在意它的类型实现了特定trait，但你不关心它具体是什么类型时。

#### Enabling Recursive Types with Boxes

这就是一个比较典型的使用场景。

假设有个枚举，它保存了自己的一个引用。

```rust
enum List {
    Cons(i32, List),
    Nil,
}
use crate::List::{Cons, Nil};

fn main() {
    let list = Cons(1, Cons(2, Cons(3, Nil)));
}
```

上面的代码在编译时会报错。

```rust
$ cargo run
   Compiling cons-list v0.1.0 (file:///projects/cons-list)
error[E0072]: recursive type `List` has infinite size
 --> src/main.rs:1:1
  |
1 | enum List {
  | ^^^^^^^^^ recursive type has infinite size
2 |     Cons(i32, List),
  |               ---- recursive without indirection
  |
help: insert some indirection (e.g., a `Box`, `Rc`, or `&`) to make `List` representable
  |
2 |     Cons(i32, Box<List>),
  |               ^^^^    ^

error[E0391]: cycle detected when computing drop-check constraints for `List`
 --> src/main.rs:1:1
  |
1 | enum List {
  | ^^^^^^^^^
  |
  = note: ...which again requires computing drop-check constraints for `List`, completing the cycle
  = note: cycle used when computing dropck types for `Canonical { max_universe: U0, variables: [], value: ParamEnvAnd { param_env: ParamEnv { caller_bounds: [], reveal: UserFacing }, value: List } }`

error: aborting due to 2 previous errors

Some errors have detailed explanations: E0072, E0391.
For more information about an error, try `rustc --explain E0072`.
error: could not compile `cons-list`

To learn more, run the command again with --verbose.
```

rust无法计算List size了，也就无法给它分配内存。

In this suggestion, “indirection” means that instead of storing a value directly, we’ll change the data structure to store the value indirectly by storing a pointer to the value instead.

在rustc给出的建议里，“indirection”的意思是，不要直接保存值，我们修改数据结构，通过存储指向这个值的指针来保存值。

```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let list = Cons(1, Box::new(Cons(2, Box::new(Cons(3, Box::new(Nil))))));
}
```

### 15.2 Treating Smart Pointers Like Regular References with the `Deref` Trait

Implementing the `Deref` trait allows you to customize the behavior of the *dereference operator*, `*` (as opposed to the multiplication or glob operator). By implementing `Deref` in such a way that a smart pointer can be treated like a regular reference, you can write code that operates on references and use that code with smart pointers too.

实现了Deref trait后，就可以用星号`*`来解引用指针了。这跟c语言里是一个操作符。

正常引用的解引用是这样的，假设y是x的引用，那么`*`y就和x是一样的。

```rust
fn main() {
    let x = 5;
    let y = &x;

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

用Box也是一样的。

```rust
fn main() {
    let x = 5;
    let y = Box::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

为什么`*y`还是可以引用到x呢，因为Box实现了`Deref` trait。

我们自己来创建一个智能指针，体会一下。

```rust
struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}
```

首先第一行`struct MyBox(T);`定义了一个tuple struct。关于什么是tuple struct请看[这里](https://doc.rust-lang.org/reference/expressions/struct-expr.html#tuple-struct-expression)。

这时如果直接使用`MyBox<T>`是有问题的。

```rust
fn main() {
    let x = 5;
    let y = MyBox::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

编译器会报无法解引用的错误

```
$ cargo run
   Compiling deref-example v0.1.0 (file:///projects/deref-example)
error[E0614]: type `MyBox<{integer}>` cannot be dereferenced
  --> src/main.rs:14:19
   |
14 |     assert_eq!(5, *y);
   |                   ^^

error: aborting due to previous error

For more information about this error, try `rustc --explain E0614`.
error: could not compile `deref-example`

To learn more, run the command again with --verbose.
```

实现`Deref` trait:

```rust
use std::ops::Deref;

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}
```

`type Target = T;`这一行定义了`associated type`。这会在19章详解介绍。

这样修改后，就可以使用`*y`了。

Deref coercion is a convenience that Rust performs on arguments to functions and methods. Deref coercion works only on types that implement the Deref trait. 

`Deref coercion`这个词没有官方准确的中文翻译，从字面就可以理解为`强制解引用`，只适用于实现了Deref trait的类型。

For example, deref coercion can convert `&String` to `&str` because `String` implements the `Deref` trait such that it returns `&str`.

这种转换发生在函数参数的传递过程中，如果我们转递的实参与形参的类型并不一致，但是可以通过转换实现一致，那么自动转换就会发生。比如形参是`&str`，但实参是`&String`,你会发现rust并不报错，因为String实现了`Deref` trait，可以转成`&str`。

BTW:  为什么有两个字符类型str和String?

Deref coercion 如何处理可变性呢？

Rust does deref coercion when it finds types and trait implementations in three cases:

- From `&T` to `&U` when `T: Deref<Target=U>`
- From `&mut T` to `&mut U` when `T: DerefMut<Target=U>`
- From `&mut T` to `&U` when `T: Deref<Target=U>`


## 19 Advanced Features

### 19.2 Advanced Traits

**在Trait的定义里通过Associated Types指定一个占位符类型**    
Specifying Placeholder Types in Trait Definitions with Associated Types
这是一个很高级的特性，我经常在代码中看到，但是我不明白。 终于在看了这小节后，有了些理解。

这是在trait的定义里包含一个类型占位符，所谓类型占位符就是这是个类型，但又不是具体的类型，只是个占位用的类型，trait的实现者会指定具体的类型。

下面是一个例子：
```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;
}
```
`Iterator`是标准库里的一个trait,里面包含了一个叫Item的类型。这个trait定义了一个方法它的返回值是`Option<Self::Item>`,要注意的是：
1. Self是首字母大写的Self，不是self，这个Self代表是trait的类型。self代表的是trait的实例。
2. 它返回的类型不是具体的类型，是Item这个类型。


下面我们来看看它的一个实现

```rust
impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
```
在Counter里，我们实现添加Iterator的实现时，为Item这个占位类型指定了具体的类型：u32. 于是next实际的返回类型就是Option\<u32>了。

有人会说，这跟泛型好像没有区别呀，泛型好像也可以实现类似的功能呀。比如：

```rust
pub trait Iterator<T> {
    fn next(&mut self) -> Option<T>;
}
```
但是如果这样的定义一个Iterator，那么我们在实现它的时候必须指定具体的类型，因为使用了泛型，所以我们可以为一个类型，多次实现`Iterator` trait。
比如我们可以实现一个Iterator\<u32> for Counter,也可以再实现一个Iterator\<String> for Counter.这样在调用Counter的next方法时，就要指定类型了，因为Counter有两个next方法。  使用Associated Types，我们不用在使用时标注类型。


下面就是例子，这是用泛型来实现的，所以在调用next的时候必须指定类型。

``` rust
trait Test<T> {
    fn next(&mut self) -> Option<T>;
}

struct Hua;

impl Test<u32> for Hua {
    fn next(&mut self) -> Option<u32> {
        Some(666)
    }
}

impl Test<String> for Hua {
    fn next(&mut self) -> Option<String> {
        Some("Hello world!".to_string())
    }
}


fn main() {
    let mut hua = Hua{};
    
    let i:Option<u32> = hua.next(); // 在调用next时，必须为返回值指定类型。
    
    println!("i = {:?}",i);
    
    let s:Option<String> = hua.next();// 在调用next时，必须为返回值指定类型。
    
    println!("s = {:?}",s);
}
```




## Appendix C: Derivable Traits



``` rust
#[derive(Deserialize, Debug, PartialEq, Clone, Copy, Visit, Eq)]
pub enum SamplerFallback {
    /// A 1x1px white texture.
    White,
    /// A 1x1px texture with (0, 1, 0) vector.
    Normal,
    /// A 1x1px black texture.
    Black,
}
```
我在代码里经常可以看到derive这个宏。一直不明白它的含义，这个附录C里讲的就是这个宏。

The derive attribute generates code that will implement a trait with its own default implementation on the type you’ve annotated with the derive syntax.
这个derive宏，会生成代码 ，这些代码会为宏所标注的类型(如struct)以它自己默认的实现来实现一个trait，
这么说可能不好理解，有点像java里只有个方法的接口（interface）的效果。
就以上面的代码为例，它实现了`Debug`这个trait,这个trait启用了调试信息中字符串格式化的能力，你可以在代码中使用`:?`占位符。

The Debug trait enables debug formatting in format strings, which you indicate by adding :? within {} placeholders.

在5.2这一节，我们看到Debug trait的能力。

Let’s try it! The println! macro call will now look like println!("rect1 is {:?}", rect1);. Putting the specifier :? inside the curly brackets tells println! we want to use an output format called Debug. The Debug trait enables us to print our struct in a way that is useful for developers so we can see its value while we’re debugging our code.

`:?`占位符告诉`println!`我们要使用叫Debug的输出格式。看来`println`这个宏里有多个输出格式呀。


这里是rust里内置的一些attributes,当有不理解的attributes时，可以到这里查查看：
[Built-in attributes index](https://doc.rust-lang.org/reference/attributes.html#built-in-attributes-index)