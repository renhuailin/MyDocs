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

``` cpp
decltype(f()) sum = x; // sum has whatever type f returns
```
注意編譯器並不對表達式進行求值。它並不真的調用函數f，只是利用它的返回值。
``` cpp
// decltype of an expression can be a reference type
int i = 42, *p = &i, &r = i;
decltype(r + 0) b; // ok: addition yields an int; b is an (uninitialized) int
decltype(*p) c; // error: c is int& and must be initialized
```
這裏需要注意的是，如果dereference 一個指針，我們會得到指針所指向的對象，上面的例子裏，p是指向引用的
指針，所以decltype(*p)就是一個引用，必須被初始化。

**注意：**  與`auto`不同的是，括號`()`會影響`decltype`的結果。
``` cpp
// decltype of a parenthesized variable is always a reference
decltype((i)) d; // error: d is int& and must be initialized
decltype(i) e; // ok: e is an (uninitialized) int
```

__警告__
    記住decltype((variable))總是得出一個引用。


## 2.6. Defining Our Own Data Structures
這一節其實很好理解，因爲後面要講到class，所以這裏有很多東西沒講。


在這裏講了如何防止header文件被多次include.講了preprocessor,中文叫預處理。這也很簡單。



# Chapter 3. Strings, Vectors, and Arrays

## 3.1. Namespace using Declarations
因爲要講string，它在std名空間裏，所以本節講了`using`.它的使用方式是：
``` cpp
using namespace::name;
```
這樣我們就使用不帶Namespace前綴的name了。

**不要在header文件裏使用using聲明**  
通常不要在header文件裏使用using，因爲header文件會copy到include它的程序中，你在header裏using
可能會引起命名衝突。

## 3.2. Library string Type

### 3.2.1. Defining and Initializing strings

**Ways to initialize a string**
``` cpp
string s1; // default initialization; s1 is the empty string
string s2(s1)    //s2 is a copy of s1
string s2 = s1; // s2 is a copy of s1
string s3("hiya");  //  s3 is a copy of the string literal,not including the null.
string s3 = "hiya"; // s3 is a copy of the string literal
string s4(10, 'c'); // s4 is cccccccccc
```

**直接初始化和copy初始化**   
當我們用等號`=`來初始化時，我們是要求compiler做copy初始化，copy `=`右邊的對象來初始化左邊的對象。    
如果我們省略`=`,就是直接初始化了。

``` cpp
string s5 = "hiya"; // copy initialization
string s6("hiya"); // direct initialization
string s7(10, 'c'); // direct initialization; s7 is cccccccccc
```


**string::size_type類型**

string的`size()`方法返回的是`string::size_type`類型的值

``` cpp
string::size_type len = line.size();
```

每次都敲`string::size_type`也太累了。還好c++11引入`auto`，我們可以用auto來推導出`string::size_type`.
``` cpp
auto len = line.size();
```
儘管我們不知道`string::size_type`的具體類型，但它肯定是個無符號類型，所以在判斷大小時要特別注意。
因爲有符號數和無符號數有時會有很大的問題。假如n是有符號負數，那麼`s.size() < n`可以會永遠是真，因爲
負數會轉成一個巨大的無符號數！


**Tip**
爲了避免這種情況發生，在使用size()的表達式裏，不要使用ints.


**Adding Two strings**

需要注意的是一個literal的字符串在C++裏不是一個對象，這跟java是不同的。java裏`"Hello world!".length()`是可以的。
在C++裏，它就個字面字符，不是對象，所以在C++裏`s = "Hello" + " world!";`會編譯報錯的：
`invalid operands of types ‘const char [6]’ and ‘const char [8]’ to binary ‘operator+’`。

字面字符串爲什麼不像java那樣做爲string對象呢？書上說是因爲歷史原因，同時也是爲了兼容C。

### 3.2.3. Dealing with the Characters in a string

講了一下<cctype>和"ctype.h",一個C++版，一個C版的。建議使用C++版的。


在這裏講到了C++11的`range for`，跟其它語言裏基本沒什麼區別，只是C++才引入而已。


## 3.3. Library vector Type

vector裏**不能**放引用;


有一些編譯器可能還是需要在`vector<vector<int> >`這樣的聲明中保留那個額外的空格。

初始化vector講了一下`list initialize`.
``` cpp
vector<string> articles = {"a", "an", "the"};
```
`list initialize`用的是大括號，不是圓括號。

使用direct initialization時，請注意`()`和`{}`的區別。

``` cpp
vector<int> v1(10); // v1 has ten elements with value 0
vector<int> v2{10}; // v2 has one element with value 10.  list initialize
vector<int> v3(10, 1); // v3 has ten elements with value 1
vector<int> v4{10, 1}; // v4 has two elements with values 10 and 1   list initialize
```



## 3.4 Introducing Iterator.





## 3.5 Arrays

數組的大小在定義時必須是可知的，不能是變量 ，可以是constexpr. 我們必須顯示的指定數組的類型，
不能通過auto來推導出來。 跟vector一樣，數組裏不能放引用。


### 3.5.1. Defining and Initializing Built-in Arrays

數組的大小要由`size_t`來定義。


**Character Arrays Are Special**
字符數組有額外的初始化方式，它可以通過字面字符串(string literal)來初始化。

``` cpp
char a1[] = {'C', '+', '+'}; // list initialization, no null
char a2[] = {'C', '+', '+', '\0'}; // list initialization, explicit null
char a3[] = "C++"; // null terminator added
automatically
const char a4[6] = "Daniel"; // error: no space for the null!
```

**理解複雜的數組聲明**
數組的聲明可能比指針的還複雜。。。
``` cpp
int *ptrs[10]; // ptrs is an array of ten pointers to int
int &refs[10] = /* ? */; // error: no arrays of references
int (*Parray)[10] = &arr; // Parray points to an array of ten ints
int (&arrRef)[10] = arr; // arrRef refers to an array of ten ints
int *(&arry)[10] = ptrs; // arry is a reference to an array of ten pointers
```
從右往左來讀已經不好使了，書上說要從數組的名字開始，從裏往外讀。

C++沒有邊界檢查，所以邊界檢查由程序員負責了， 一定要防止數組或vector越界.數組越界會成爲安全漏洞，
成爲黑客攻擊的主要方式。

### 3.5.3. Pointers and Arrays

在C++裏，數組和指針是交織在一起的。

``` cpp
int ia[] = {0,1,2,3,4,5,6,7,8,9}; // ia is an array of ten ints
auto ia2(ia); // ia2 is an int* that points to the first element in ia
ia2 = 42; // error: ia2 is a pointer, and we can't assign an int to a pointer
```

請注意`auto ia2(ia)`這行，`auto`推導出來的類型是`int*`。

但是如果我們`decltype`就不會發生這種轉換`decltype(ia)`推導的結果一個包含10 int的數據組。

```cpp
// ia3 is an array of ten ints
decltype(ia) ia3 = {0,1,2,3,4,5,6,7,8,9};
ia3 = p; // error: can't assign an int* to an array
ia3[4] = i; // ok: assigns the value of i to an element in ia3
```

**Pointers Are Iterators**
指針是迭代器。
```cpp
int arr[] = {0,1,2,3,4,5,6,7,8,9};
int *p = arr; // p points to the first element in arr
++p; // p points to arr[1]
```
`int *p = arr;`這個是begin,如何獲得end呢？做法很野蠻:

```cpp
int *e = &arr[10]; // pointer just past the last element in arr
```

arr有10個元素，下標10就越界，所以可以代表end(one past the last),因爲這個元素並不存在，所以只能取它的地址.

``` cpp
for (int *b = arr; b != e; ++b)
    cout << *b << endl; // print the elements in arr
```

這種獲得end的方法太危險了，所以C++11引用了兩個函數：`begin`,`end`.

```cpp
int ia[] = {0,1,2,3,4,5,6,7,8,9}; // ia is an array of ten ints
int *beg = begin(ia); // pointer to the first element in ia
int *last = end(ia); // pointer one past the last element in ia
```

**Subscripts and Pointers**

NOTE:  與`vector`和`string`的下標不同，內置的下標操作符的索引不是`unsigned`類型。


接下來講C string,簡單略過。


**Using an Array to Initialize a vector**
我們不能用數組來初始化數組，也不能用vector來初始化數組，但是可以用數組來初始化vector
```cpp
int int_arr[] = {0, 1, 2, 3, 4, 5};
// ivec has six elements; each is a copy of the corresponding element in int_arr
vector<int> ivec(begin(int_arr), end(int_arr));
```

建議Modern C++程序儘量來使用vector來代替數組。

## 3.6 Multidimensional Arrays
嚴格來說C++沒有多維數組。通常指的多維數組其實是數組的數組。


# Chapter 4. Expressions

lvalue和rvalue那段沒怎麼看明白，以後有時間好好研究下。


# Chapter 5. Statements

###　5.4.3 Range for Statement

第５章沒有什麼好記的，除了C++11引入的`Range for`.


# Chapter 6. Functions

## 6.1. Function Basics

**Parameters and Arguments**

Parameters是形參，Arguments是實參，明白了吧。

### 6.2.6. Functions with Varying Parameters

C++的變長參數是通過`initializer_list`來實現的。

```cpp
void error_msg(initializer_list<string> il)
{
    for (auto beg = il.begin(); beg != il.end(); ++beg)
        cout << *beg << " " ;
    cout << endl;
}
```

調用：
```cpp0
// expected, actual are strings
if (expected != actual)
    error_msg({"functionX", expected, actual});
else
    error_msg({"functionX", "okay"});
 ```
另外一種方式就是兼容C的`...`省略號參數。它利用了Ｃ的`varargs`.具體的可以參考`varargs`.


## 6.5. Features for Specialized Uses
## 6.5.1. Default Arguments
C++支持默認參數！


### 6.5.2. Inline and constexpr Functions
Inline很好理解

constexpr函數需要多多注意。限制比較多。

constexpr函數隱式的全是inline函數。

**constexpr函數允許返回非常量值**!
```cpp
// scale(arg) is a constant expression if arg is a constant expression
constexpr size_t scale(size_t cnt) { return new_sz() * cnt; }
```
當傳入的實參是常量時，這個函數返回的才是常量。
```cpp
int arr[scale(2)]; // ok: scale(2) is a constant expression
int i = 2; // i is not a constant expression
int a2[scale(i)]; // error: scale(i) is not a constant expression
```


**Put inline and constexpr Functions in Header Files**
因爲編譯器要知道這些函數的實現細節，所以不能簡單把signature放在header裏，要把函數完整的放在
header裏。

# Chapter 7. Classes
類的成員函數必須在類(class body)裏聲明(declare) ,但是可以在定義(define)在類內部也可以定義在類體(class body)外.



```cpp
struct Sales_data {
    // new members: operations on Sales_data objects
    std::string isbn() const { return bookNo; }
    Sales_data& combine(const Sales_data&);
    double avg_price() const;
    // data members are unchanged from § 2.6.1 (p. 72)
    std::string bookNo;
    unsigned units_sold = 0;
    double revenue = 0.0;
};
```

**定義class body內的成員函數默認是`inline`的** ,所以這些函數通常要簡潔. 如上面的`isbn()`.

請注意`isbn`這個函數在參數列表的圓括號後面的`const`.爲什麼會有這個const,這叫`常量成員函數`.
要理解這個首先要講一下`this`指針,By default, the type of this is a const pointer to the nonconst version of the
class type. 也就是this是一個指向非常量class的常量指針,它一旦指向這個類,就不能再指向其他的類,但是可以通過this來修改類的成員.

this的定義大概應該是這樣的:`Sales_data * const this` ,因爲這一聲明是隱式的,我們無法讓this指向一個const的Sales_data.
因爲this指針是隱式傳遞的,不在參數列表裏,所以無法把它聲明爲指向常量class type的指針,那怎麼辦?

C++通過在參數列表後面添加const來實現這個功能. 有了這個const,成員函數就變成了`常量成員函數`.

上面的isbn這個函數相當於這樣寫的:
```cpp
// pseudo-code illustration of how the implicit this pointer is used
// this code is illegal: we may not explicitly define the this pointer ourselves
// note that this is a pointer to const because isbn is a const member
std::string Sales_data::isbn(const Sales_data *const this)
{ return this->isbn; }
```
爲什麼要有常量成員函數呢?    
試想,你有一個常量的對象,比如 const Sales_data sd;如果我們在sd上調用了可以修改sd的內容的函數那會發生什麼?  
這其實是違反了const這個聲明,C++肯定不能允許這樣的調用發生.怎麼阻止?通過常量成員函數來阻止.

**NOTE:  常量對象,指向常量對象的指針或引用,只能調用常量成員函數.**     
那些能修改對象內容的成員函數是不允許調用的.這樣就行了吧?

### 7.1.4. Constructors
構造函數是相當複雜的東西。

它不能是const的，這是當然的，因爲它就是修改this指針的，你聲明爲const怎麼修改？

```cpp
struct Sales_data {
    // constructors added
    Sales_data() = default;
    Sales_data(const std::string &s): bookNo(s) { }
    Sales_data(const std::string &s, unsigned n, double p):
    bookNo(s), units_sold(n), revenue(p*n) { }
    Sales_data(std::istream &);
    // other members as before
    std::string isbn() const { return bookNo; }
    Sales_data& combine(const Sales_data&);
    double avg_price() const;
    std::string bookNo;
    unsigned units_sold = 0;
    double revenue = 0.0;
};
```
上面的`Sales_data() = default;`是什麼鬼東西？

在新標準下，如果我們的behavior,我們要以要求編譯器生成一個默認構造函數，方式就是通過上面的語句.
`Sales_data() = default;`

`= default`可以寫在class body裏，這時它是inline的;也可以寫在definition outside the class,那它就是非inline的。

## 7.2. Access Control and Encapsulation

**Using the class or struct Keyword**

用class还是用struct？
用class和struct定义类有什么区别？
区别是默认访问级别的区别。



## 7.5. Constructors Revisited

**Constructor Initializers Are Sometimes Required**
有时构造器初始化是必须的

如果你的類裏有常量的成員、有引用類的成員，那Constructor Initializers就是必須的了。爲什麼呢？

```cpp
class ConstRef {
public:
    ConstRef(int ii);
private:
    int i;
    const int ci;
    int &ri;
};
```
跟其它的常量對象和引用對象一樣，必須被初始化。

```cpp
// error: ci and ri must be initialized
ConstRef::ConstRef(int ii)
{ // assignments:
    i = ii; // ok
    ci = ii; // error: cannot assign to a const
    ri = i; // error: ri was never initialized
}
```

當開始執行構造函數體時，初始化工作就完成了。所以上面的代碼報錯，因爲不能給常量賦值，引用必須被初始化。唯一能初始化常量和引用的方法就是constructor
initializer了，我想這也是爲什麼C++會引入constructor　initializer的原因吧。

好，正確做法是：　　　　

```cpp
// ok: explicitly initialize reference and const members
ConstRef::ConstRef(int ii): i(ii), ci(ii), ri(i) {}
```

**注意**
```
在C/C++里变量的定义位置是很重要的,这一点跟Java不一样,要注意.

```
### 7.5.2. Delegating Constructors

C++11引用了代理构造函数,不是什么新概念，java里早就有了。
```cpp
class Sales_data {
public:
    // nondelegating constructor initializes members from corresponding arguments
    Sales_data(std::string s, unsigned cnt, double price):
        bookNo(s), units_sold(cnt), revenue(cnt*price) {
    }
    // remaining constructors all delegate to another constructor
    Sales_data(): Sales_data("", 0, 0) {}
    Sales_data(std::string s): Sales_data(s, 0,0) {}
    Sales_data(std::istream &is): Sales_data()
    { read(is, *this); }
    // other members as before
};

```

### 7.5.4 Implicit Class-Type Conversions

隐式的类类型转换。

注意：单个参数的构造函数，实际上是一个隐式的类型转换器。

```cpp
string null_book = "9-999-99999-9";
// constructs a temporary Sales_data object
// with units_sold and revenue equal to 0 and bookNo equal to null_book
item.combine(null_book);
```
这个转换是编译器帮我们执行的，编译器自动创建了一个Sales_data对象，并把它传给combine这个方法。

注意：compiler只能执行一步的自动转换，下面的例子就不行了。

```cpp
// error: requires two user-defined conversions:
// (1) convert "9-999-99999-9" to string
// (2) convert that (temporary) string to Sales_data
item.combine("9-999-99999-9");
```
上面的代码需要先把"9-999-99999-9"转成string，然后再把string转成Sales_data,这是两步的转换，compiler执行不了。

```cpp
// ok: explicit conversion to string, implicit conversion to Sales_data
item.combine(string("9-999-99999-9"));
// ok: implicit conversion to string, explicit conversion to Sales_data
item.combine(Sales_data("9-999-99999-9"));
```


**Suppressing Implicit Conversions Defined by Constructors**

有时候我们不希望上述的以自动转换的方式来调用某些constructor，可以在constructor前面加explicit来阻止
constructor以隐式转换的方式来调用。

```cpp
class Sales_data {
public:
    Sales_data() = default;
    Sales_data(const std::string &s, unsigned n, double p):
    bookNo(s), units_sold(n), revenue(p*n) { }
    explicit Sales_data(const std::string &s): bookNo(s) { }
    explicit Sales_data(std::istream&);
    // remaining members as before
};
```

另一个使用自动转换的context时copy初始化。

```cpp
Sales_data item1 (null_book); // ok: direct initialization
// error: cannot use the copy form of initialization with an explicit constructor
Sales_data item2 = null_book;
```


### 7.5.6. Literal Classes

字面类？

constexpr　function 的参数和返回值都必须是Literal 类型的。除了算术类型，引用和指针外，有些类也是Literal Type的。

一个aggregate class聚合类，如果它的成员都是Literal Type的，那它就是Literal Type的。

一个非聚合类，它符合下面的条件，也是Literal Type的。
* 所有的成员必须是Literal Type
* 必须有至少一个`constexpr`构造函数
* 如果成员有in-class initializer,如果这个成员是内置类型的（非class）,那给它初始的值必须是`constexpr`的；如果是class类型的，
必须用那class的`constexpr`构造函数来初始化
* 必须使用默认的析构函数

```cpp
class Debug {
public:
    constexpr Debug(bool b = true): hw(b), io(b), other(b) {
    }
    constexpr Debug(bool h, bool i, bool o):
        hw(h), io(i), other(o) {
    }
    constexpr bool any() { return hw || io || other; }
    void set_io(bool b) { io = b; }
    void set_hw(bool b) { hw = b; }
    void set_other(bool b) { hw = b; }
private:
    bool hw; // hardware errors other than IO errors
    bool io; // IO errors
    bool other; // other errors
};
```

## 7.6. static Class Members

静态成员可以使用incompleted type,一个例子是单例模式里的`instance`,可以声明为跟它的类型一样.




# Chapter 12 Dynamic Memory
















EOF
