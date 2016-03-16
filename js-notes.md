Javascript notes
--------

用`var`声明的变量和不用`var`声明的变量是不一样的
``` js
var truevar = 1;    // A properly declared global variable, nondeletable.
fakevar = 2;        // Creates a deletable property of the global object.
this.fakevar2 = 3;  // This does the same thing.
delete truevar      // => false: variable not deleted
delete fakevar      // => true: variable deleted
delete this.fakevar2 // => true: variable deleted
```


Ojbect.create() 这个函数用来创建用一个对象来创建一个新对象，这样做的好处是可以保护原来的对象，以防止非恶意的修改。


6.2 查询属性

可以用点，也可以用`[]`
``` js
var author = book.author;  // Get the "author" property of the book.
var name = author.surname  // Get the "surname" property of the author.
var title = book["main title"] // Get the "main title" property of the book.

book.edition = 6;  // Create an "edition" property of book.
book["main title"] = "ECMAScript";  // Set the "main title" property.

```
6.3 删除属性

可以通过`delete`来删除一个属性，它只能删除`own property`,不能删除继承的属性。 如果要删除一个继承的属性，当然要先找到`own`它的那个`prototype`，才能删除它。

`delete` does not remove properties that have a `configurable attribute` of `false` .

## 6.4 测试属性

可以使用函数`hasOwnProperty`和`propertyIsEnumerable()`来测试一个对象是否包含指定属性.但是更简单的方法是用`in`这个key来测试。

``` js
book = {author : "Google"};

"author" in book ;
"a" in book;
```

`hasOwnProperty` 用来判断对象是否包含一个own属性，注意是`own property`。

``` js
book = {author : "Google"};
book.hasOwnProperty("author"); //有author这个属性，并own它。
book.hasOwnProperty("isbn");   //false,没有这个属性。
"toString" in book             //有这个属性
book.hasOwnProperty("toString");    //有toString这个属性，但不own它。
```

在写代码时，可能用的比较多的是用 `!== undifined`来判断一个属性

``` js
var o = { x: 1 }
o.x !== undefined;                  // true: o has a property x
o.y !== undefined;                  // false: o doesn't have a property y
o.toString !== undefined;           // true: o inherits a toString property
```
这样做无法区别没有这个属性，还是有这个属性,但它的值是undefined.

## 6.5 Enumerating properties
property分爲可遍歷的和不可遍歷的，繼承來的屬性都是不可以遍歷的。

你在代碼裏添加的屬性默認是可遍歷的，

``` js
var o = {x:1, y:2, z:3};              // Three enumerable own properties
o.propertyIsEnumerable("toString");   // => false: not enumerable
for(p in o) {                         // Loop through the properties
    console.log(p);                   // Prints x, y, and z, but not toString
}
```

ECMAScript 5 定義了一個方法來遍歷屬性名`Object.keys()`;

``` js
var o = {x:1, y:2, z:3};              // Three enumerable own properties
Object.keys(0);
}
```

## 6.6 Property Getters and Setters

ECMAScript 5引入了類似C#語法的`accessor properties`，真的很好理解。

``` js
var p = {
    // x and y are regular read-write data properties.
    x: 1.0,
    y: 1.0,

    // r is a read-write accessor property with getter and setter.  
    // Don't forget to put a comma after accessor methods.
    get r() { return Math.sqrt(this.x*this.x + this.y*this.y); },
    set r(newvalue) {
        var oldvalue = Math.sqrt(this.x*this.x + this.y*this.y);
        var ratio = newvalue/oldvalue;
        this.x *= ratio;
        this.y *= ratio;
    },
    // theta is a read-only accessor property with getter only.
    get theta() { return Math.atan2(this.y, this.x); }
};
```
## 6.6 Property Attributes（屬性特徵）
ECMAScript 5 之前的版本js裏創建的屬性都是`writable, enumerable, and configurable`，也
就是可寫、可遍歷和可配置的。

ECMAScript 5加入了對屬性的控制，從此我們可以控制屬性是否可寫、可遍歷和可配置了。
這對庫的設計者來說是重要的，因爲可以:
* 可爲object添加方法，並配置爲不可遍歷的(nonenumerable),這樣就更像是內置的方法了。
* 可以鎖住object，定義不可改變、不可刪除的屬性。


屬性有4個特徵：value, writable, enumerable, and configurable。


要獲得指定對象的屬性描述符,需要調用`Object.getOwnPropertyDescriptor()`方法。

``` js

// Returns {value: 1, writable:true, enumerable:true, configurable:true}
Object.getOwnPropertyDescriptor({x:1}, "x");

// Now query the octet property of the random object defined above.
// Returns { get: /*func*/, set:undefined, enumerable:true, configurable:true}
Object.getOwnPropertyDescriptor(random, "octet");

```



如果用es6的语法，autobinding会问题，请看：https://facebook.github.io/react/blog/2015/01/27/react-v0.13.0-beta-1.html

























# React

react 强制我们以组件的方式去思考。
每个组件有自己的state，这个东西有点像跟UI关联的model，是一對象。


this.props和this.state的区别是什么 ？  
https://github.com/uberVU/react-guide/blob/master/props-vs-state.md


https://facebook.github.io/react/docs/thinking-in-react.html    这个链接讲了如何确定你的Component的state。











# 参考文档
[Mozilla Javascript reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference)
