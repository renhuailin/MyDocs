
[Go语言的一本电子书](http://www.golangbootcamp.com/)，主要参考了go tour.


这里面包含一些比较有趣的试验，作者很用心啊。
https://github.com/realint/labs


知乎上这个帖子讲了go 的GC , 值得参考。 http://www.zhihu.com/question/21615032


一篇老外的文章：），http://blog.cloudflare.com/recycling-memory-buffers-in-go


# 《Learning Go》 笔记     

:= 这符号dephi里有，在go里 我看它的意义是 定义并赋值 define and assign。

if和switch都可以包含 初始化语句 (initialization statement)
```go
if err := file.Chmod(0664); err != nil {   //nil is like C's NULL
   fmt.Printf(err)  //Scope of err is limited to if's body
   return err
}
```
请看if后面用来限定条件的括号不见了，分号前面的部分是初始化部分，分号后面的才是判断条件。
```go
if err != nil
{  	  ←Must be on the same line as the if
  return err
}
```
上面的代码是错误的，在Go里，左花括号必须与if、switch等在同行。


range关键字很强大，它能用在for循环里，It can loop over slices, arrays, strings, maps and channels。
遍历的对象不同，range返回的结果也不同，如果是slice, array,那第一个返回值是索引，第二个返回值是索引所在位置的数据。
```go
list := []string{"a", "b", "c", "d", "e", "f"}
for k, v := range list {
	//do what you want with k and v
}
```

switch要特别注意，请看下面的例子：
```go
switch i {
case 0: // empty case body
case 1:
	 f() //f is not called when i==0!
}
```
在C,java中，如果i为0，则会自动穿透而执行下面的语句，如果不想穿透则需要一个break关键字，而Go的思路是相反的！Go里默认是不穿透的，如果想穿透则必须使用关键字：fallthrough。

```go
switch i {
case 0: fallthrough
case 1:
	 f() //f is called when i==0!
}
```
case语句后面可以接逗号分隔的列表。
```go
func shouldEscape(c byte) bool {
	 switch c {
	 case ' ', '?', '&', '=', '#', '+':
	 	  return true
	 }
	 return false
}
```

## 数据类型
Go語言將數據類型分爲四類：基礎類型、複合類型、引用類型和接口類型。本章介紹基礎類型，包括：數字、字符串和布爾型。複合數據類型——數組（§4.1）和結構體（§4.2）——是通過組合簡單類型，來表達更加複雜的數據結構。引用類型包括指針（§2.3.2）、切片（§4.2)）字典（§4.3）、函數（§5）、通道（§8），雖然數據種類很多，但它們都是對程序中一個變量或狀態的間接引用。這意味着對任一引用類型數據的脩改都會影響所有該引用的拷貝。我們將在第7章介紹接口類型。

wizardforcel (2016-01-10T06:36:17.671085+00:00). Go 语言圣经 中文版 (Kindle Locations 2446-2449). GitBook. Kindle Edition. 



array是值类型，意味着如果把数组传给函数，实际上是传递了一个数组的copy。slice是引用类型，传给函数传了一个引用。

【函数 function】=========================================
在java里，如果函数没有返回值，要用void来修饰，而在Go里是不用的，感觉很自然。
```go
func subroutine( i int) {
	 return
}
```
Go的函数是可以返回多个返回值的，并且返回值可以是有名称的。当被命名后，在函数开始时，他们会被初始化为0值。 When named, they are initialized to the zero values for their types when the function begins.

下面的这样函数第二个返回值被命名为：nextPos。可以命名好处是参数自描述了。
```go
func nextInt(b []byte, pos int) (value, nextPos int) { /* ... */ }
```
因为命名了的返回值被初始化，并绑定到未加修饰的return上，所以它们很简洁。可以像内部变量一样在函数内部使用。
Because named results are initialized and tied to an unadorned return, they can simplify
as well as clarify. Here’s a version of io.ReadFull that uses them well:

```go
func ReadFull(r Reader, buf []byte) (n int, err error) {
	for len(buf) > 0 && err == nil {
		var nr int
		nr, err = r.Read(buf)
		n += nr
		buf = buf[nr:len(buf)]
	}
	return
}
```

【Deferred code 延迟执行的代码 】=========================================
假设你写了一个函数，打开了一个文件，执行写操作，并且在这个函数中有多个return，那么你要在每个return前写上关闭文件的代码。像下面的代码一样。
```go
func ReadWrite() bool {
	file.Open("file")
	// Do your thing
	if failureX {
		file.Close()
		return false
	}
	if failureY {
		file.Close()
		return false
	}
	file.Close()
	return true
}
```
写了好几个file.Close() ，麻烦吧？为了解决这个问题，Go语言引入了defer这个语句。在defer后面接一个函数，这个函数将在函数返回前执行。
```go
func ReadWrite() bool {
	file.Open("file")
	defer file.Close()
	// Do your thing
	if failureX {
		return false
	}
	if failureY {
		return false
	}
	return true
}
```
这样的代码清爽多了吧？

* 你可以在函数里写多个defer，它们以FILO的顺序执行。
defer后面的函数甚至可以修改函数的返回值。

```go
func f() (ret int) { //← ret is initialized with zero
	defer func() {
		ret++        //← Increment ret with 1
	}()
	return 0         //← 1 not 0 will be returned!
}
```
【 变长参数 Variadic parameters 】
```go
func myfunc(arg ...int) {}
```
这个很好理解，要注意的是，如果你不指定变参的类型，那它默认的类型是empty inteface: interface{}

【 以函数为值 】
在go里函数跟其它东西是一样的，可以做为值传给变量。
```go
func main() {
	a := func() { 					//← define a nemeless function and assign to a
		println("Hello world!")
	}								//← 注意这里没有括号()
	a()								//← 调用这个函数

}
```

【 Callback 回调 】
函数可以做为值，那么回调就简单了。
```go
func callback(y int, f func(int)) { ← f will hold the function
	f(y) ← Call the callback f with y
}
```

【Panic and recovering】
Go里没有像java一样的exception的处理机制，你无法抛出一个异常。代替它的是panic-recover这种机制。需要注意的是，你要把这做为最后的手段。

Panic panic 是一个内置的函数，它停止正常的执行流程，开始panicing.当函数F调用了panic，那么F的执行就会被停止，任何deferred的函数都会被执行，接着F就返回到它的调用者。对F的调用者来说，F这时就相当于是panic函数了，请仔细理解这句话，也就是对于F的调用者来说，当F中调用了panic,那么调用F就相当于调用了panic.然后这个处理过程就沿着堆栈一直往上走，直到当前goroutine中的函数都返回，这时程序会崩溃。

Recover  也是一个内置函数，它会重新获得一个已经panic的goroutine的控制权。有点像java中的try catch。
注意: recover只在deferred 函数中才有用。
在正常的流程中（非panic）调用recover是没用的，它会返回一个nil。


chapter 4  Package

一个包是一系列的函数和数值。一个包里可以包含多个文件。按惯例包名一般是小写的。

@是否要像java一样，把一个包入在包里的目录里？

我们来定义一个包：
``` go
package even

func Even(i int) bool { //← Exported function
	return i % 2 == 0
}

func odd(i int) bool { //← Private function
	return i % 2 == 1
}
```
以大写字母开头的函数是exported的，相当于public的。小写函数也就是private的了。

* build一个包
% mkdir $GOPATH/src/even 		← Create top-level directory
% cp even.go $GOPATH/src/even 	← Copy the package file
% go build						← Build it
% go install					← Install it to ../pkg

这样我们就可以在程序里使用even这个包了。
```go
package main

import (
	"even"
	"fmt"
)

func main() {
	i := 5
	fmt.Printf("Is %d even?",i,even.Even(i))
}
```

包名是默认的访问符，你可以在import时指定一个新的访问符。
```go
import bar "bytes"
bar.Buffer
```
另外一个convention是，包名是它的源代码目录名。如 src/pkg/compress/gzip,你可这样来导入它
import "compress/gzip"
这时，它的访问符是gzip,不是compress_gzip,也不是compressGzip.

Finally, the convention in Go is to use MixedCaps or mixedCaps rather than underscores to write multi-word names.

最后，Go一般使用混合大小写，而不是下划线的方式来表示一个多词的名字。

- 给包添加文档
每个包应该有一个包文档，一个注释块，放在package这个语句的前面。如果包里有多个文件，只要在一个文件加上这个注释就可以，任何一个包里的文件都可以。
```go
/*
The regexp package implements a simple library for regular expressions.
The syntax of the regular expressions accepted is:
regexp:
	concatenation '|' concatenation
*/
package regexp
```
每个包里的函数前面的注释被当作它的文档。
```go
// Printf formats according to a format specifier and writes to standard // output. It returns the number of bytes written and any write error
// encountered.
func Printf(format string, a ...interface) (n int, err error)
```
- 为包写单元测试 TODO......

## Chapter 5	Beyond the basics 基础之外
-指针
go 是有指针的，但是它没有C语言的指针那么复杂的用法。在Go里，当你在调用函数时，参数是传值的方式传递的。如果为了效率，或者，你有可能在函数内修改参数的值，我们有指针。Go里的指针定义和使用起来跟C差不多。
一个新创建的指针或是未指向任何东西的指针被赋以nil。

-内存分配
go有垃圾收集器，你不用担心内存的回收。

go里有两个关键字用来分配内存，new 和 make。它们做不同的工作，应用到不同的类型，这可能会让你迷惑，不过其实规则挺简单的。
Allocation with new 用new来分配
内置的指令new非常必要的，new(T)，为T分配了一个0大小的内存，并返回地址。用go的术语来说是：它返回了一个指向零值T的一个指针。返回值是`指针`，这一点很重要，要记住。

这意味着你可以通过new创建一个用户的数据结构，并马上开始使用它。例如bytes.Buffer的文档是这样说的，“零值的Buffer是一个即时可用空的Buffer” ready to use.
The zero-value-is-useful property works transitively. 零值可用这个属性是可传递的。

```go
type SyncedBuffer struct {
	lock sync.Mutex
	buffer bytes.Buffer
}
```
在分配完或声明完以后，SyncedBuffer的值即时可用。下面的例子里p和v，不做任何处理就可以直接用了。
In this snippet, both p and v will work correctly without further arrangement.
```go
p := new(SyncedBuffer) 	//← Type *SyncedBuffer, ready to use
var v SyncedBuffer 		//← Type SyncedBuffer, idem
```

- 用make来分配
内置函数make(T,args)与new(T)服务目的不一样。它只能创建一个slice,maps和channel.它返回一个已初始化（非零值）的T，而不是*T。这样区分的主要原因是用户的数据结构必须初始化才能用。
例如，make([]int,10,100)分配了一个100 int的数组，并创建了一个长度为10，容量为100，指向这个数组前10个元素的slice。作为对比，new([]int) 返回一个指向新分配的、零值的slice结构，也就是一个指向nilslice值的指针。


- Constructors and composite literals 构造函数和组合语义
有时零值是不够的，需要一个初始化的构造函器。下面的例子是从os这个包里摘出来的。
```go
func NewFile(fd int, name string) *File {
	if fd < 0 {
		return nil
	}
	f := new(File)
	f.fd = fd
	f.name = name
	f.dirinfo = nil
	f.nepipe = 0
	return f
}
```
有许多模板可用，我们可以用复合语法来简化上面的例子。复合语法在每次求值时生成一个新的实例。
```go
func NewFile(fd int, name string) *File {
	if fd < 0 {
		return nil
	}

	f = File{fd,name,nil,0}		 	//← Create a new File

	return &f						//← Return the address of f
}
```
返回函数内的变量的地址是OK的，变量存储的内容在函数返回后依然有效。

我们也可以合并上面的两行，
```go
return &File{fd,name,nil,0}
```
复合语法的项（或称字段）必须按顺序排列，并且要全部出现，一个也不能少。如果我们使用 字段:值 这样的方式来赋值，则字段可以以任意顺序出现。那些未赋值字段就会赋以零值。所以我们可以这样：
```go
return &File{fd:fd,name:name}  		← 这个跟ruby好像啊。
```
如果复合语法没有任何的字段，那么所有的字段会被赋以零值。这时&File{}和new(File)是一样的。

- Defining your own types 定义你自己的类型
你可以通过关键字 type 定义自己的类型
``` go
type foo int
```
这个感觉跟C的typedef效果是一样的。
go里也有struct，用它来定义结构。
```go
type Person struct {
	name string
	age int
}

func main() {
	a := new(Person)
	a.name = "Harley";a.age = 35
	fmt.Printf("%v\n",a)
}
```
运行的结果：
&{Pete 42}

真棒！go知道如何打印你的结构。

与C的struct不同的是，go里的struck可以包含函数，有点像class了吧。因为在go里函数也是值嘛。
```go
struct {
	x, y int
	A *[]int
	F func()
}
```

如果你省略了字段的名称，你就创建了一个匿名字段。

```go
struct {
	T1			← Field name is T1
	*T2 		← Field name is T2
	P.T3		← Field name is T3
	x, y int	← Field names are x and y
}
```
首字母大写的字段是exported的，也就是其它的包能读写它，结构里的函数也是如此。

- method
如果你创建一个使用刚建的struct的函数，你有两种方式：
1. 创建一个用struct做为参数的函数。
```go
func doSomething(in1 *Person, in2 int) { /* ... */ }
```
2.把struct做为函数的receiver。在第三章中说过，带receiver的函数被称为“方法”
```go
func (in1 *NameAge) doSomething(in2 int) { /* ... */ }
var n *NameAge
n.doSomething(2)
```
到底使用哪种方式，完全取决于你，但是如果你要满足接口interface,你就必须使用method.
同时，要牢记下面的规则：
如果x是可取址的， 同时&x的方法中包含m,那么x.m(),是(&x).m()的缩写。

这可能很巧妙，也是下面的类型声明的主要区别
```go
// A Mutex is a data type with two methods, Lock and Unlock. type Mutex struct { /* Mutex fields */ }
func (m *Mutex) Lock() { /* Lock implementation */ }
func (m *Mutex) Unlock() { /* Unlock implementation */ }
```
现在我们用两种不同的方式来创建两个类型。
```go
type NewMutex Mutex
type PrintableMutex struct {Mutex}
```
NewMutex 等同于 Mutex，但是它不包含Mutex的任何方法。也就说它的方法集是空的。
但是 PrintableMutex 继承了Mutex的方法集。也就是说：
	PrintableMutex的方法集包含了方法 Lock 和 Unlock，这两个方法绑定到PrintableMutex的匿名字段Mutex上。

`struct`的匿名成员有点像Mixin吧？
问题来了，如果两个匿名成员类型里都包含x,那我访问的是哪个x?这个书没有给出例子。

# chapter 6 Interface

在Go里，interface被重载成表示几个不同的东西。每种类型都有一个interface,即它定义的方法集。请看下面的例子。
Listing 6.1. Defining a struct and methods on it
```go
type S struct { i int }
func (p *S) Get() int { return p.i }
func (p *S) Put(v int) { p.i = v }
```
你也可以定义一个接口，它就简单的方法集。
```go
type I interface {
	Get() int
	Put(int)
}
```
类型S是接口I的一个合法实现，因为它定义了接口I所需的两个方法。尽管它没有显式地实现这个接口。
译注：在java里，要实现一个接口必须使用implements关键字。而在go里，你的类型只要满足接口所需的方法集，go就认为你实现了接口。真不错。：）
```go
func f(p I) {
	fmt.Println(p.Get())
	p.Put(1)
}
```
上面的函数使用了接口I
因为S实现接口I，所以我们可以调用f,把S的指针传过去。
var s S; f(&s)  译注：这里是指针哟，是不是当type做为参数时，调用时都要传指针呢？
我们要传指针，而不是S的值，因为我们定义的方法是用S的指针做为receiver的，
```go
func (p *S) Put(v int) { p.i = v }
```
当然我们也可以用S的值做为receiver,把方法改为像下面的一样：
```go
func (p S) Put(v int) { p.i = v }
```
但是因为p是传值的，所以p.i = v 这行代码就没有效果了。赋值不会成功的。所以一般方法声明的receiver都是指针了。如果你不希望传过来的S的值被修改，那你就以传值的方式定义一个方法就好了。

Which is what? 这是什么？
让我们定义另外一个类型，它也实现接口I：
```go
type R struct { i int }
func (p *R) Get() int { return p.i }
func (p *R) Put(v int) { p.i = v }
```
现在函数f就可以接受R和S类型的参数了。假如你想知道传过来的参数的具体类型，你可以使用type switch.
```go
func f(p I) {
	switch t := p.(type) {
		case *S :   // 1
		case *R :	// 2
		case S:		// 3
		case R:		// 4
		default:	// 5
	}
}
```
在switch外使用(type)是非法的。type switch不是运行时检测类型的唯一方法。你可以使用“comma,ok”这样的方式来检测一个类型是否实现了一个指定的接口。
```go
if t,ok = something.(I); ok {
	// something implements the interface I
	// t is the type it has
}
```
- 空接口
因为所有的类型都实现了空接口：interface{}.我们可以创建一个以空接口为参数的通用方法：
```go
func g(something interface{}) int {
	return something.(I).Get()
}
```

这是方法的返回值有点小技巧。something的类型是空接口interface{},也就是它不保证有任何的方法：它可以包含任何类型。
`.(I)`是类型的断言，把`something`转成I类型。
```go
s = new(S)
fmt.Println(g(s));
```
这个调用工作得很好，会打印出0.如果我们用一个没有实现I接口的值来调用g，就会出问题。
```go
i := 5 //←Make i a ``lousy'' int
fmt.Println(g(i))
```
能编译，但是运行时会报错：
```
panic: interface conversion: int is not main.I: missing method Get
```
- Methods 方法
方法就是有receiver的函数。你可以为任何类型定义方法，除了非本地的类型（non-local type）包括内置类型：int不能有任何方法。但你可以建一个有自己方法的新integer类型。例如：
```go
type Foo int
func (self Foo) Emit() {
	fmt.Printf("%v\n",self)
}

type Emitter interface {
	Emit()
}
```
- Methods on interface types 接口里的方法
接口定义了一系列方法。方法包含真正的代码。换句话说，接口是定义原型，方法实现。所以一个method的receiver不能是接口。如果这样做了，会导致invalid receiver type的编译错误。

- Pointers to interfaces 指向接口的指针
在go里创建一个指向接口的指针是没用的，实际上创建一个接口的指针是非法的。

- Introspection and reflection 自省和反射
下面的例子我们想要查找Person类里的“tag”(这里叫"namestr")。我们需要使用“反射”包来实现（没有其它的途径）。
```go
type Person struct {
	name string "namestr"
	age int
}

p1 := make(Person)
ShowTag(p1)

func ShowTag(i interface{}) {
	switch t := reflect.TypeOf(i); t.Kind() { ← Get type, switch on Kind()
	case reflect.Ptr: ← Its a pointer, hence a reflect.Ptr
		tag := t.Elem().Field(0).Tag
}
```

下面的文字摘自godoc reflect
```go
// Elem returns a type’s element type.
// It panics if the type’s Kind is not Array, Chan, Map, Ptr, or Slice.
Elem() Type
```
所以在上面的代码里我们用Elem来获得指针所指向的值。然后用Field(0)来获得zeroth的字段。它返回一个StructField,它有Tag属性，它返回字符串tag-name


【Chapter 7 Concurrency 并发】


【Chapter 8 Communication 通信】
