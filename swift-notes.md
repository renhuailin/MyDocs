Swift编程语言学习心得备忘
----------------

Swfit不允许隐式转换，这一点要特别注意。我感觉这很好，隐匿转换会带来很多问题。

``` swift
let s = "hello";
let i = 10;
var ns = s + i;
```

#### The differences between API and ABI
http://stackoverflow.com/questions/2171177/what-is-application-binary-interface-abi

environment 





# Structure

structure和enumeration都是value Types.也是就是赋值时是执行copy的操作的。而class是reference Types。



# Methods

因为structures and enumerations are value type,所以默认的instance method是不能修改它们自身属性的值的。如果要修改需要在方法前添加`mutating` keyword.  

**注意：** 在mutating method里甚至可以修改`self`，也就是给`self`赋一个新值，这个真的有点变态强大了。



## Type Methods

定义type method可以通过两个keyword，`static` and `class`。 class定义的method,子类可以override，`static`定义的不可以。





# Subscript 下标







# Subclassing

“You can present an inherited read-only property as a read-write property by providing both a getter and a setter in your subclass property override. You cannot, however, present an inherited read-write property as a read-only property.”

简单地说就是你能放大一个属性的权限，但是不能缩小。因为你缩小了这个权限，如果通过___父接口来调用___时，不就报错了嘛。



# Initialization

**NOTE**

When you assign a default value to a stored property, or set its initial value within an initializer, the value of that property is set directly, without calling any property observers.

当你为stored property设置值，或是在initializer里为它设置初始值时，都不会触发任何的observers。

