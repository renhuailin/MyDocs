Kotlin notes
--------



# delegation 跟继承有什么区别呀?

# delegated properties 有什么用? 这个语法糖没看懂.

lazy(), 这个内置函数可以让一个属性变成lazy的,lazy的属性是只初始化一次.然后再读的时候就都是计算后的值了


Observable  

Delegates.observable() ,可以监控属性的变化,其实就是就是setter.



## Providing a delegate (since 1.1)
One of the possible use cases of provideDelegate is to check property consistency when the property is created, not only in its getter or setter.


# Function 


## Infix notation
把一个函数变成操作符了!

``` kotlin
// Define extension to Int
infix fun Int.shl(x: Int): Int { ...
}
// call extension function using infix notation
1 shl 2
// is the same as 1.shl(2)
```


in Kotlin, there is a convention that if the last parameter to a function is a function, and you're passing a lambda expression as the corresponding argument, you can specify it outside of parentheses:

``` kotlin
fun <T> lock(lock: Lock, body: () -> T): T {
    lock.lock()
    try {
        return body()
    } finally {
        lock.unlock()
    }
}

lock (lock) {
    sharedResource.operation()
}
```

** it: implicit name of a single parameter **
``` kotlin
ints.map { it * 2 }
```

Underscore for unused variables (since 1.1)

``` kotlin
map.forEach { _, value -> println("$value!") }
```



### Closures
A lambda expression or anonymous function (as well as a local function and an object expression) can access its closure, i.e. the variables declared in the outer scope. **Unlike Java, the variables captured in the closure can be modified**:

``` kotlin
var sum = 0
ints.filter { it > 0 }.forEach {
    sum += it 
}
print(sum)
```


### Function Literals with Receiver
這章要好好看看,沒看太懂


Kotlin provides the ability to call a function literal with a specified receiver object. Inside the body of the function literal, you can call methods on that receiver object without any additional qualifiers. 

可以给函数指定一个接收者:


``` kotlin
//不带接收者的是这样:
sum : (other: Int) -> Int

//这是带的
sum : Int.(other: Int) -> Int
```
也就是说这个函数只能通过接收者来调用.

``` kotlin
1.sum(2)
```


Lambda expressions can be used as function literals with receiver when the receiver type can be inferred from context.


``` kotlin
class HTML {
    fun body() { ... }
}

fun html(init: HTML.() -> Unit): HTML {
    val html = HTML() // create the receiver object
    html.init() // pass the receiver object to the lambda return html
}

html { // lambda with receiver begins here
    body() // calling a method on the receiver object
}

```



## Inline Functions
c++的内链函数也来了!!

**inline**函数很好理解,不多说.

*** noinline ***

In case you want only some of the lambdas passed to an inline function to be inlined, you can mark some of your function parameters with the `noinline` modifier:

``` kotlin
inline fun foo(inlined: () -> Unit, noinline notInlined: () -> Unit) { 
    // ...
}
```


**Non-local returns**
In Kotlin, we can only use a normal, unqualified return to exit a named function or an anonymous function. This means that to exit a lambda, we have to use a label, and a bare return is forbidden inside a lambda, because a lambda can not make the enclosing function return:

普通的`return`只能用在有名字和匿名函数里,不能用在lambda函数里.在lambda函数里只能使用 `qualified return`,带label的.

``` kotlin
fun foo() { 
    ordinaryFunction {
        return // ERROR: can not make `foo` return here 
    }
}
```


But if the function the lambda is passed to is inlined, the return can be inlined as well, so it is allowed:    
但是如果传的lambda是inlined的,那就可以使用普通的return了.

``` kotlin
fun foo() { 
    inlineFunction {
        return // OK: the lambda is inlined
    }
}
```


**crossinline**
Note that some inline functions may call the lambdas passed to them as parameters not directly from the function body, but from another execution context, such as a local object or a nested function. In such cases, non-local control flow is also not allowed in the lambdas. To indicate that, the lambda parameter needs to be marked with the crossinline modifier:

``` kotlin
inline fun f(crossinline body: () -> Unit) { 
    val f = object: Runnable {
        override fun run() = body() 
    }
    // ...
}
```
这个真没看懂


**Reified type parameters**

这个真心没看懂,我感觉跟IDE的整合有关,没想到什么情况下能用到这个.


# Coroutines


##  @RestrictsSuspension annotation

More information on how actual async/await functions work in kotlinx.coroutines can be found [here](https://github.com/Kotlin/kotlinx.coroutines/blob/master/coroutines-guide.md#composing-suspending-functions).

In some cases the library author needs to prevent the user from adding **new ways** of suspending a coroutine.   
To achieve this, the @RestrictsSuspension annotation may be used. 

在某些情况下库的作者需要阻止用户添加新的挂起一个coroutine的方式,这可以通过@RestrictsSuspension annotation来实现.






# Other

## Destructuring Declarations


``` kotlin
 val name = person.component1()
 val age = person.component2()
```
componentN是怎么回事?好好再看看.


The component1() and component2() functions are another example of the principle of conventions widely used in Kotlin (see operators like + and * , for-loops etc.)


Note the difference between declaring two parameters and declaring a destructuring pair instead of a parameter:    
``` kotlin
{ a -> ... } // one parameter
{ a, b -> ... } // two parameters
{ (a, b) -> ... } // a destructured pair
{ (a, b), c -> ... } // a destructured pair and another parameter

```


## Operator overloading
这很好理解


## Type-Safe Builders
这章有意思,要仔细看看,DSL


### Type aliases
Kotlin支持类型别名了.







































