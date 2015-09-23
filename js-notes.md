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


















































# 参考文档
[Mozilla Javascript reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference)


