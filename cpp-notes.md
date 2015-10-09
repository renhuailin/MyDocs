 C++ 备注 for Java Programmer
 -----

# 数据类型
 一定要注意，C++里有无符号型的整型，有可能会溢出。
 请关注下面的两个头文件：
 ```cpp
 #include <climits>
 #include <cfloat>
 ```
float 和double都是有符号的。They are always signed.

# 引用 References.

C++ 默认是Pass by value,Pass by copy.

引用可以理解为别名，所以，对引用所有的操作，会直接作用于它引用的对象。

* 引用必须被初始化。

# Array
C++的Array不是对象。
C++的Array做为函数的参数时，不是传值，而是做为指针传给函数。







### 2.4.2. Pointers and const

`const double *dp1`是一个指向常量double的指针，这个指针本身不是const的，也就是你可以给它赋一个新值。
但是这个指针指向的内容是不能修改的，也就是地址里的内容，那个double的值是不能 **通过指针** 来修改的。

指针的类型与它所指向的类型要一致这个规则，有一个例外，就是`const double *dp1`它指向的不一定非要是一个常量的double,
可以是一个普通的double，如下面例子里的dp2;
```cpp
#include <iostream>

using namespace std;

int main() {
    const double PI = 3.14;
    double pi = 3.1415;

    const double *dp1 = &PI;
    const double *dp2 = &pi; //它可以指向一个非常量的double.

    cout << "dp1 : " << dp1 << endl;

    double g = 9.8;
    dp2 = &g;               //指针是可以修改的
    dp1 = &g;               //指针是可以修改的

    cout << "dp1 after modification : " << dp1 << endl;

    *dp1 = 9.8;    //不能通过指针来修改指向的内容。
    *dp2 = 9.8;    //

    cout << "Hello World!" << endl;
    cout << &pi << endl;
    return 0;
}
```

与引用不用，指针本身也可以是常量的。常理指针必须被初始化，一旦初始化，它的值，也就是地址，不能被修改。也就是它不能指向其它的地址。

```cpp
int errNumb = 0;
int *const curErr = &errNumb; // curErr will always point to errNumb

int i = 1;
curErr = &i;                  //这会报错
```
这些声明确实比较难分辨，C++有个原则，从右往左读。

```cpp
const int * const curErr = &errorCode;
```
在这个例子里，const 紧跟在curErr左边，所以意味着curErr是const的，所以curErr的内容不能改变。
接下是`*`说明curErr是个指针，再接下来是`int`说明是指向`int`类型的指针,再接下来是const说明
这个int的值是不能修改的。

C++ 使用`top-level const`来indicate一个指针是const的。用term `low-level const`来indicate
一个指针指向一个const对象。

```cpp
int i = 0;
int *const p1 = &i; // we can't change the value of p1; const is top-level
const int ci = 42; // we cannot change ci; const is top-level
const int *p2 = &ci; // we can change p2; const is low-level
const int *const p3 = p2; // right-most const is top-level, left-most is not
const int &r = ci; // const in reference types is always low-level
```
从上面的例子里可以看出来，指针跟其它类型不同，既可以是`top-level const`,也可以是`low-level const`.


`top-level const`和`low-level const`的区别主要体现在copy的时候。`top-level const`在copy时可以被忽略，
但是`low-level const`不能被忽略，怎么理解呢，请看下边。

```cpp
int *p = p3; // error: p3 has a low-level const but p doesn't
p2 = p3; // ok: p2 has the same low-level const qualification as p3
p2 = &i; // ok: we can convert int* to const int*
int &r = ci; // error: can't bind an ordinary int& to a const int object
const int &r2 = i; // ok: can bind const int& to plain int
```


2.4.4  constexpr和常理表达式
C++11中引入`constexpr`,用来定义一个常量表达式的变量。


*Pointers and constexpr*
需要注意的是当用constexpr来修饰一个指针时，它作用在指针上，而不是指针所指向的内容。

```cpp
const int *p = nullptr; // p is a pointer to a const int
constexpr int *q = nullptr; // q is a const pointer to int  注意这是一个常量指针，它指向一个int.
```

## 2.5. Dealing with Types
### 2.5.1. Type Aliases

我们可以用`typedef`来做别名，C++11可以用`using`来做别名。

```cpp
using SI = Sales_item; // SI is a synonym for Sales_item
```

需要注意的是const如果修饰别名时，会出现意外的结果。

```cpp
typedef char *pstring;
const pstring cstr = 0; // cstr is a constant pointer to char
const pstring *ps; // ps is a pointer to a constant pointer to char
```

`const pstring cstr = 0; `如果直接展开别名的话变成了：`const char * cstr = 0;`这变成了指向常量字符的指针了。
但是这种展开是错的。 pstring是一个指向字符的指针，`const pstring`在C++里解释为指向Int的常量指针，也就是const是作用于指针上的。
这一点要特别注意。


### 2.5.2. The auto Type Specifier
C++11此入了`auto`key，用来推导类型。

**Compound Types, const , and auto**
auto推导复合类型时，需要注意：
1 当我们用引用来初始化一个auto变量时，它的类型是引用所对象的类型，它不会推导为一个引用类型。
```cpp
int i = 0, &r = i;
auto a = r; // a is an int (r is an alias for i, which has type int)
```
注意a的类型是int，而不是引用。


2 auto通常会忽略`top-level const`，`low-level const`会被保留。

如果想让推导出来的类型有`top-level const`，我们需要显示的告诉它。
```cpp
const auto f = ci; // deduced type of ci is int; f has type const int
```


### 2.5.3. The decltype Type Specifier

有时，我们要一个变量，它的类型是从表达式里deduces出来的，但是我们不想用这个表达式来初始化变量。
也就是我们只想用这个表达式的类型，不用它的值。
