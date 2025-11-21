Javascript notes
--------

# 1. 语言基础
用`var`声明的变量和不用`var`声明的变量是不一样的

```js
var truevar = 1;    // A properly declared global variable, nondeletable.
fakevar = 2;        // Creates a deletable property of the global object.
this.fakevar2 = 3;  // This does the same thing.
delete truevar      // => false: variable not deleted
delete fakevar      // => true: variable deleted
delete this.fakevar2 // => true: variable deleted
```

### Object.create()
`Object.create()` 静态方法以一个现有对象作为原型，创建一个新对象。这样做的好处是可以保护原来的对象，以防止非恶意的修改。

## 4. Expressions and Operators

### 4.9 Relational Expressions

The strict equality operator === evaluates its operands, and then compares the two values as follows, performing no type conversion: 

* If the two values have different types, they are not equal.
  *If both values are null or both values are undefined, they are equal.
  *If both values are the boolean value true or both are the boolean value false, they are equal.
  *If one or both values is NaN, they are not equal. **The NaN value is never equal to any other value, including itself!**  To check whether a value x is NaN, use `x !== x`. **NaN is the only value of x for which this expression will be true**. 
  *If both values are numbers and have the same value, they are equal. If one value is 0 and the other is -0, they are also equal. 
  *If both values are strings and contain exactly the same 16-bit values (see the sidebar in §3.2) in the same positions, they are equal. If the strings differ in length or content, they are not equal. Two strings may have the same meaning and the same visual appearance, but still be encoded using different sequences of 16-bit values. JavaScript performs no Unicode normalization, and a pair of strings like this are not considered equal to the === or to the == operators. See String.localeCompare() in Part III for another way to compare strings. 
  *If both values refer to the same object, array, or function, they are equal. If they refer to different objects they are not equal, even if both objects have identical properties. 

The equality operator == is like the strict equality operator, but it is less strict. If the values of the two operands are not the same type, it attempts some type conversions 
and tries the comparison again: 

1. If the two values have the same type, test them for strict equality as described above. If they are strictly equal, they are equal. If they are not strictly equal, they are not equal. 
   2.If the two values do not have the same type, the == operator may still consider them equal. Use the following rules and type conversions to check for equality: 
   * If one value is null and the other is undefined, they are equal. 
   * If one value is a number and the other is a string, convert the string to a number and try the comparison again, using the converted value. 
   * If either value is true, convert it to 1 and try the comparison again. If either value is false, convert it to 0 and try the comparison again. 
   * If one value is an object and the other is a number or string, convert the object to a primitive using the algorithm described in §3.8.3 and try the comparison again. An object is converted to a primitive value by either its toString() method or its valueOf() method. The built-in classes of core JavaScript attempt valueOf() conversion before toString() conversion, except for the Date class, which performs toString() conversion. Objects that are not part of core Java- Script may convert themselves to primitive values in an implementation-defined way. 
   * Any other combinations of values are not equal.

## 6.2 查询属性

可以用点，也可以用`[]`

```js
var author = book.author;  // Get the "author" property of the book.
var name = author.surname  // Get the "surname" property of the author.
var title = book["main title"] // Get the "main title" property of the book.

book.edition = 6;  // Create an "edition" property of book.
book["main title"] = "ECMAScript";  // Set the "main title" property.
```

## 6.3 删除属性

可以通过`delete`来删除一个属性，它只能删除`own property`,不能删除继承的属性。 如果要删除一个继承的属性，当然要先找到`own`它的那个`prototype`，才能删除它。

`delete` does not remove properties that have a `configurable attribute` of `false` .

## 6.4 测试属性

可以使用函数`hasOwnProperty`和`propertyIsEnumerable()`来测试一个对象是否包含指定属性.但是更简单的方法是用`in`这个key来测试。

```js
book = {author : "Google"};

"author" in book ;
"a" in book;
```

`hasOwnProperty` 用来判断对象是否包含一个own属性，注意是`own property`。

```js
book = {author : "Google"};
book.hasOwnProperty("author"); //有author这个属性，并own它。
book.hasOwnProperty("isbn");   //false,没有这个属性。
"toString" in book             //有这个属性
book.hasOwnProperty("toString");    //有toString这个属性，但不own它。
```

在写代码时，可能用的比较多的是用 `!== undifined`来判断一个属性

```js
var o = { x: 1 }
o.x !== undefined;                  // true: o has a property x
o.y !== undefined;                  // false: o doesn't have a property y
o.toString !== undefined;           // true: o inherits a toString property
```

这样做无法区别没有这个属性，还是有这个属性,但它的值是undefined.

## 6.5 Enumerating properties

property分爲可遍歷的和不可遍歷的，繼承來的屬性都是不可以遍歷的。

你在代碼裏添加的屬性默認是可遍歷的，

```js
var o = {x:1, y:2, z:3};              // Three enumerable own properties
o.propertyIsEnumerable("toString");   // => false: not enumerable
for(p in o) {                         // Loop through the properties
    console.log(p);                   // Prints x, y, and z, but not toString
}
```

ECMAScript 5 定義了一個方法來遍歷屬性名`Object.keys()`;

```js
var o = {x:1, y:2, z:3};              // Three enumerable own properties
Object.keys(0);
}
```

## 6.6 Property Getters and Setters

ECMAScript 5引入了類似C#語法的`accessor properties`，真的很好理解。

```js
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

```js
// Returns {value: 1, writable:true, enumerable:true, configurable:true}
Object.getOwnPropertyDescriptor({x:1}, "x");

// Now query the octet property of the random object defined above.
// Returns { get: /*func*/, set:undefined, enumerable:true, configurable:true}
Object.getOwnPropertyDescriptor(random, "octet");
```

如果用es6的语法，autobinding会解决问题，请看：https://facebook.github.io/react/blog/2015/01/27/react-v0.13.0-beta-1.html

## Spread syntax (...)
The **spread (`...`)** syntax allows an iterable, such as an array or string, to be expanded in places where zero or more arguments (for function calls) or elements (for array literals) are expected. In an object literal, the spread syntax enumerates the properties of an object and adds the key-value pairs to the object being created.



需要注意的是，**对象的展开位置影响最后的展开结果**。
```js
const obj1 = { foo: "bar", x: 42 };
const obj2 = { foo: "baz", y: 13 };

const mergedObj = { x: 41, ...obj1, ...obj2, y: 9 }; // { x: 42, foo: "baz", y: 9 }
```

所以如果想通过一个对象来创建新对象时，通常在最前面展开老对象。如果放在后面展开，前面赋值的内容会被覆盖！

```js
const obj1 = {a: "bar", b: 42 ,c: "sss"}

const obj2 = {
	...obj1, //在最前面展开它，如果放在后面展开，前
	b: 43
}
```


## Destructuring assignment
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment


```js
const { a, ...others } = { a: 1, b: 2, c: 3 };
console.log(a); //1
console.log(others); //{ b: 2, c: 3 }

const [first, ...others2] = [1, 2, 3];
console.log(others2); // [2, 3]

```



### [Tagged templates](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals#tagged_templates)

我今天看到一行奇怪的typescript代码: const result = await prisma.$queryRaw<User[]>`SELECT * FROM User`; 为什么后面可以直接是一个字符串，没有用()包围的字符串，这是什么语法？

下面是Gemini给出的答案：

你看到的 `const result = await prisma.$queryRaw<User[]>`SELECT * FROM User`;` 这种写法是使用了 TypeScript 的 **标记模板字面量 (Tagged Template Literals)** 特性，结合 Prisma 的 `Prisma.sql` 模板标签函数，而不是普通的字符串字面量。

**普通模板字面量 (Template Literals)**

首先回顾一下普通的模板字面量，它使用反引号 (\`) 包围字符串，并且允许在字符串中嵌入表达式：


```ts
const name = 'Alice';
const greeting = `Hello, ${name}!`; // Hello, Alice!
```

**标记模板字面量 (Tagged Template Literals)**

标记模板字面量则更进一步，它允许你在模板字面量前面添加一个 _函数_ (称为“标签函数”)，这个函数会接收模板字面量的各个部分，并允许你自定义处理这些部分。

语法如下：

```ts
const result = tagFunction`string parts ${expression} string parts`;
```

在这个例子中：

- `tagFunction` 是一个函数。
- 反引号中的内容是模板字面量。

**标签函数接收的参数：**

标签函数接收的第一个参数是一个 _字符串数组_，包含模板字面量中所有静态的字符串部分。后面的参数是所有嵌入的表达式的值。

例如：

TypeScript

```
function tagFunction(strings, ...values) {
  console.log(strings); // ["SELECT * FROM User WHERE id = ", " AND name = ", "", raw: Array(3)]
  console.log(values); // [123, "Bob"]
  // ... 自定义处理 ...
  return 'result'
}

const id = 123;
const name = 'Bob';
const result = tagFunction`SELECT * FROM User WHERE id = ${id} AND name = ${name}`;
console.log(result) // result
```

**Prisma.sql 的作用**

在你的例子中，`Prisma.sql` 就是一个标签函数。Prisma 使用它来安全地构建 SQL 查询。`Prisma.sql` 会接收模板字面量中的 SQL 字符串部分和嵌入的变量，进行处理，以防止 SQL 注入等安全问题。它会将变量进行转义，并构建一个参数化的 SQL 查询。

**为什么可以省略括号？**

当标记模板字面量用于调用函数时，如果模板字面量 _没有嵌入任何表达式_，则可以省略括号。这就是你看到的 `Prisma.sql`SELECT * FROM User`;` 的原因。由于 `SELECT * FROM User` 中没有任何 `${}` 嵌入的表达式，所以可以省略括号。它等价于：

TypeScript

```
const result = await prisma.$queryRaw<User[]>(Prisma.sql`SELECT * FROM User`);
```

但是，如果查询中包含变量，就必须使用 `${}` 嵌入表达式：


```ts
const userId = 123;
const result = await prisma.$queryRaw<User[]>(Prisma.sql`SELECT * FROM User WHERE id = ${userId}`);
```

在这种情况下，不能省略括号。

**总结**

- `Prisma.sql` 是一个标签函数，用于安全地构建 SQL 查询。
- 当使用标记模板字面量且没有嵌入表达式时，可以省略调用函数的括号。
- 使用 `${}` 嵌入表达式可以将变量安全地传递到 SQL 查询中，防止 SQL 注入。

理解了标记模板字面量的概念，你就能明白为什么 `Prisma.sql` 后面可以直接跟字符串而不需要用括号包围。这是 TypeScript 提供的一种简洁而强大的语法特性，用于更灵活地处理字符串和构建 DSL（领域特定语言）。

下面是Claude-3.5-Sonnet给出的回答，可以看出来，这个更合理。

这是 JavaScript/TypeScript 中的标签模板字符串（Tagged Template Literals）语法。

这是 ES6 引入的特性，允许我们在模板字符串前面添加一个函数（称为"标签"），这个函数可以对模板字符串进行处理。

基本语法是：
```typescript
// 标签函数名`模板字符串`
tagFunction`template string`
```

举些例子帮助理解：

1. 最简单的例子：
```typescript
function myTag(strings: TemplateStringsArray, ...values: any[]) {
    console.log(strings);
    console.log(values);
}

const name = "Alice";
const age = 25;
myTag`Hello, ${name}! You are ${age} years old.`;

// 输出：
// ["Hello, ", "! You are ", " years old."]
// ["Alice", 25]
```

2. SQL查询的例子（类似你看到的Prisma代码）：
```typescript
const userId = 123;
const status = "active";

// 使用标签模板字符串
const query = sql`
    SELECT * FROM users 
    WHERE id = ${userId} 
    AND status = ${status}
`;

// 等价于普通函数调用
const sameThing = sql(["SELECT * FROM users WHERE id = ", " AND status = ", ""], userId, status);
```

3. 在Prisma中的实际应用：
```typescript
// Prisma的用法
const minAge = 18;
const result = await prisma.$queryRaw<User[]>`
    SELECT * FROM "User" 
    WHERE age >= ${minAge}
`;

// 这种写法可以帮助防止SQL注入，因为参数会被正确转义
```

标签模板字符串的主要优点：
1. 更清晰的语法
2. 自动处理参数转义
3. 可以进行自定义的字符串处理
4. 支持多行字符串
5. 在SQL查询场景下特别有用，可以防止SQL注入

需要我提供更多示例或详细解释吗？

可见Gemini的回答是有误的，即使有嵌入的变量，也可以省略小括号的。 这个语法确实特别适合防止SQL注入，之前我还一直纳闷直接在SQL中嵌入了变量，如何防止SQL注入的，原来是通过这个机制来实现的。

## Regex 正则表达式
特别好用的一个测试正则表达式的网站： https://regex101.com/



Selector

## xpath selector

在chrome中测试

**chrome console**

F12->

```
$x(“//title”)
```

## document.querySelector()

## ES6

### Generator

```js
function* gen1() {
    console.log(" run into generate ...");
    for (var i = 0; true; i++) {
        console.log(" run into for ...");
        var reset = yield i;
        console.log(`reset : ${reset}`)
        if (reset) i = -1;
    }
}
```

在node的REPL里粘贴上面的代码。

```
> var g = gen1();
undefined
```

我们引用这个generator时，generator里的代码并没有执行。

```
> g.next();
 run into generate ...
 run into for ...
{ value: 0, done: false }
```

接下来我们调用`next`,代码开始执行并在 `var reset = yield i;`这一行停下来。 把`yield`后面的表达式求值，做为`next`方法的返回值。

接下来我们调用再`next`。

```
> g.next();
reset : undefined
 run into for ...
{ value: 1, done: false }
```

我们可以看到`reset`的值为`undefined`。
这里大家一定注意`var reset = yield i;`这条语句，要区分`yield`的返回值和`next`方法的返回值。`yield`关键字把它后面的表达式求值后做为`next`方法的返回值。而本身的返回值为`undefined`;

下面为`yield`操作符的语法：

```
[rv] = yield [expression];
```

* expression      
    Defines the value to return from the generator function via the iterator protocol. If omitted, undefined is returned instead.
* rv     
    Returns the optional value passed to the generator's next() method to resume its execution.

如果我们没有给`next`传递参数，那`yield`返回值就是`undefined`,如果传了一个值给`next`方法，这个值就会做为`yield`的返回值，注意不是`next`的返回值！

关于`yield`更多信息请参见[这里](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/yield)

### Promise

```js
var getJSON = function(url) {
    var promise = new Promise(function(resolve, reject) {
        var client = new XMLHttpRequest();
        client.open("GET", url);
        client.onreadystatechange = handler;
        client.responseType = "json";
        client.setRequestHeader("Accept", "application/json");
        client.send();

        function handler() {
            if (this.status === 200) {
                resolve(this.response);
            } else {
                reject(new Error(this.statusText));
            }
        };
    });
    return promise;
};

getJSON("/posts.json").then(function(json) {
    console.log('Contents: ' + json);
}, function(error) {
    console.error('出错了', error);
});
```

### async await 关键字

The await expression causes async function execution to pause, to wait for the Promise's resolution, and to resume the async function execution when the value is resolved. It then returns the resolved value. If the value is not a Promise, it's converted to a resolved Promise.

If the Promise is rejected, the await expression throws the rejected value.

`await`会暂停async函数的调用,等待Promise resolution.当值被解析后继续执行async函数,如果await后面接不是Promise,await会反它转成一个`resolved Promise`.

```js
var fetchDoubanApi = function() {  
  return new Promise((resolve, reject) => {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        if (xhr.status >= 200 && xhr.status < 300) {
          var response;
          try {
            response = JSON.parse(xhr.responseText);
          } catch (e) {
            reject(e);
          }
          if (response) {
            resolve(response, xhr.status, xhr);
          }
        } else {
          reject(xhr);
        }
      }
    };
    xhr.open('GET', 'https://api.douban.com/v2/user/aisk', true);
    xhr.setRequestHeader("Content-Type", "text/plain");
    xhr.send(data);
  });
};

(async function() {
  try {
    let result = await fetchDoubanApi();
    console.log(result);
  } catch (e) {
    console.log(e);
  }
})();
```

注意async 方法返回是Promise,不能直接返回一个value,

```js
function resolveAfter2Seconds(x) {
  return new Promise(resolve => {
    setTimeout(() => {
      resolve(x);
    }, 2000);
  });
}

async function add1(x) {
  var a = resolveAfter2Seconds(20);
  var b = resolveAfter2Seconds(30);
  return x + await a + await b;
}

//我们不能这样使用async
let result = add1(10);
//这时result就是Promise.正确的使用方法是调用Promise的then方法.

add1(10).then(v => {
  console.log(v);  // prints 60 after 2 seconds.
});
```

https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function

[TypeScript 1.7](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-1-7.html) 就已经支持async await了.


# 2. React

## jsx tsx 
我在tsx里使用forEach，结果发现不输出任何东西，我改成map就行了。

```tsx
{

	pageSettings.agreements.forEach(value =>
	
	// <span><a onClick={() => showAgreement(index)} className="text-white"> {value.title}</a></span>
	
	<h1>{value.title}</h1>
	
	)

}
```
原来forEach是不返回任何东西的，而map是返回的。
https://stackoverflow.com/a/47616385/3012163


## nextjs


Create a new app 
```
npx create-next-app@latest
#or
pnpm dlx create-next-app@latest
```

### App router & Page router
In version 13, Next.js introduced a new **App Router** built on [React Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components), which supports shared layouts, nested routing, loading states, error handling, and more.

The App Router works in a new directory named `app`. The `app` directory works alongside the `pages` directory to allow for incremental adoption.

Page Router https://nextjs.org/docs/pages/building-your-application/routing
The `Pages Router` has a file-system based router built on concepts of pages. When a file is added to the `pages` directory it's automatically available as a route. Learn more about routing in the Pages Router:

使用Link来实现局部刷新

用`usePathname() ` 来显示active links.

#### Dynamic Routes

A Dynamic Segment can be created by wrapping a folder's name in square brackets: `[folderName]`. For example, `[id]` or `[slug]`.  
可以通过将文件夹名称括在方括号中来创建动态分段： `[folderName]` 。例如， `[id]`或`[slug]` 。

Dynamic Segments are passed as the `params` prop to [`layout`](https://nextjs.org/docs/app/api-reference/file-conventions/layout), [`page`](https://nextjs.org/docs/app/api-reference/file-conventions/page), [`route`](https://nextjs.org/docs/app/building-your-application/routing/route-handlers), and [`generateMetadata`](https://nextjs.org/docs/app/api-reference/functions/generate-metadata#generatemetadata-function) functions.  

动态段作为`params`属性传递给[`layout`](https://nextjs.org/docs/app/api-reference/file-conventions/layout) 、 [`page`](https://nextjs.org/docs/app/api-reference/file-conventions/page) 、 [`route`](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)和[`generateMetadata`](https://nextjs.org/docs/app/api-reference/functions/generate-metadata#generatemetadata-function)函数。


#### [Catch-all Segments](https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes#catch-all-segments)

Dynamic Segments can be extended to **catch-all** subsequent segments by adding an ellipsis inside the brackets `[...folderName]`.  
通过在括号`[...folderName]`内添加省略号，可以将动态段扩展为**捕获所有**后续段。

For example, `app/shop/[...slug]/page.js` will match `/shop/clothes`, but also `/shop/clothes/tops`, `/shop/clothes/tops/t-shirts`, and so on.  
例如， `app/shop/[...slug]/page.js`将匹配`/shop/clothes` ，但也会匹配`/shop/clothes/tops` 、 `/shop/clothes/tops/t-shirts` ，等等。

| Route 路线                     | Example URL 示例网址 | `params`                    |
| ---------------------------- | ---------------- | --------------------------- |
| `app/shop/[...slug]/page.js` | `/shop/a`        | `{ slug: ['a'] }`           |
| `app/shop/[...slug]/page.js` | `/shop/a/b`      | `{ slug: ['a', 'b'] }`      |
| `app/shop/[...slug]/page.js` | `/shop/a/b/c`    | `{ slug: ['a', 'b', 'c'] }` |

#### [Optional Catch-all Segments  ](https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes#optional-catch-all-segments)

Catch-all Segments can be made **optional** by including the parameter in double square brackets: `[[...folderName]]`.  
通过将参数包含在双方括号中，可以使 Catch-all Segments 成为**可选**： `[[...folderName]]` 。

For example, `app/shop/[[...slug]]/page.js` will **also** match `/shop`, in addition to `/shop/clothes`, `/shop/clothes/tops`, `/shop/clothes/tops/t-shirts`.  
例如， `app/shop/[[...slug]]/page.js`除了`/shop/clothes` 、 `/shop/clothes/tops` 、 `/shop/clothes/tops/t-shirts`之外，**还将**匹配`/shop` 。

The difference between **catch-all** and **optional catch-all** segments is that with optional, the route without the parameter is also matched (`/shop` in the example above).  
**catch-all**和**可选的 catch-all**段之间的区别在于，如果是可选的，则不带参数的路由也会匹配（上例中的`/shop` ）。

| Route 路线                       | Example URL 示例网址 | `params`                    |
| ------------------------------ | ---------------- | --------------------------- |
| `app/shop/[[...slug]]/page.js` | `/shop`          | `{ slug: undefined }`       |
| `app/shop/[[...slug]]/page.js` | `/shop/a`        | `{ slug: ['a'] }`           |
| `app/shop/[[...slug]]/page.js` | `/shop/a/b`      | `{ slug: ['a', 'b'] }`      |
| `app/shop/[[...slug]]/page.js` | `/shop/a/b/c`    | `{ slug: ['a', 'b', 'c'] }` |




```
npx create-next-app@latest
# or use pnpm
pnpm create next-app
```


### 添加Authentication

https://nextjs.org/learn/dashboard-app/adding-authentication


### Middleware 中间件

Middleware allows you to run code before a request is completed. Then, based on the incoming request, you can modify the response by rewriting, redirecting, modifying the request or response headers, or responding directly.  
中间件允许您在请求完成之前运行代码。然后，根据传入的请求，您可以通过重写、重定向、修改请求或响应标头或直接响应来修改响应。

Middleware runs before cached content and routes are matched. See [Matching Paths](https://nextjs.org/docs/app/building-your-application/routing/middleware#matching-paths) for more details.  
中间件在**缓存内容和路由**匹配之前运行。有关更多详细信息，请参阅[匹配路径](https://nextjs.org/docs/app/building-your-application/routing/middleware#matching-paths)。


Use the file `middleware.ts` (or `.js`) in the root of your project to define Middleware. For example, at the same level as `pages` or `app`, or inside `src` if applicable.  
使用项目根目录中的文件`middleware.ts` （或`.js` ）来定义中间件。例如，与`pages`或`app`处于同一级别，或者在`src`内部（如果适用）。





## React & Redux


1. react-redux里的`connect`方法是干什么用的？它的参数具体有什么用?

2. 是不是每个component都要调用`connect`方法?

3. 用什么方法能简单地保证representational components都能使用`store` ?    
   用Provider这个组件。

[深入浅出 - Redux](http://www.w3ctech.com/topic/1561) 这篇文章对于`connect`方法的讲解还是具有参考价值的。

connect把Dispatch做为子组件的props了。

* 参数前面带...是什么意思？
  
  ```js
  return (
      <TodoList todos={todos}
                {...boundActionCreators} />
    )
  ```
  
  上面代码里的`...`是什么意思?

答：  这是ES6里的新feature，叫spread operators,  简单地说就是把数组拆分成用`,`分隔的参数序列。

```js
// ES5
Math.max.apply(null, [14, 3, 77])

// ES6
Math.max(...[14, 3, 77])

// 等同于
Math.max(14, 3, 77);
```

请参考 https://wohugb.gitbooks.io/ecmascript-6/content/docs/function.html

另外使用...的方法叫 Rest Parameter.  通过rest parameter，我们通过数组的方式向函数提供变长的参数。 在这以前代码里要用`arguments`来判断是否还有额外的参数。

```js
// Before rest parameters, the following could be found:
function f(a, b){
  var args = Array.prototype.slice.call(arguments, f.length);

  // …
}

// to be equivalent of

function f(a, b, ...args) {

}
```

注意，rest参数之后不能再有其他参数，否则会报错。

每个reducer都应该改变state,因为这是change state的唯一方法，而且每个reducer应该会关心或是关注一个或几个state的属性,某些component可能会因为这些属性的change而重新render.

**NOTE**

```js
//in reducers/todos.js
export default function todos1(state = initialState, action) {
}

// in configureStore.dev.js
const store = createStore(rootReducer, initialState, enhancer);
```

这时生成的state里有个属性就叫todos1。这是非常诡异的，我是调试了好久才发现的，要好好看看createStore的源代码。


### useEffect

**What does `useEffect` do?** By using this Hook, you tell React that your component needs to do something after render. React will remember the function you passed (we’ll refer to it as our “effect”), and call it later after performing the DOM updates. In this effect, we set the document title, but we could also perform data fetching or call some other imperative API.  
 `useEffect`都做了什么 ？通过使用这个 Hook，你可以告诉 React 你的组件在渲染后需要做一些事情。React 会记住你传递的函数（我们称之为“effect”），并在执行 DOM 更新后稍后调用它。在这种效果下，我们设置了文档标题，但我们也可以执行数据获取或调用其他一些命令式 API。

**Why is `useEffect` called inside a component?** Placing `useEffect` inside the component lets us access the `count` state variable (or any props) right from the effect. We don’t need a special API to read it — it’s already in the function scope. Hooks embrace JavaScript closures and avoid introducing React-specific APIs where JavaScript already provides a solution.  
为什么在组件内部 `useEffect` 调用？放置 `useEffect` 在组件中，我们可以直接从效果中访问 `count` 状态变量（或任何道具）。我们不需要特殊的 API 来读取它——它已经在函数范围内了。Hook 采用 JavaScript 闭包，避免在 JavaScript 已经提供解决方案的情况下引入特定于 React 的 API。

**Does `useEffect` run after every render?** Yes! By default, it runs both after the first render _and_ after every update. (We will later talk about [how to customize this](https://legacy.reactjs.org/docs/hooks-effect.html#tip-optimizing-performance-by-skipping-effects).) Instead of thinking in terms of “mounting” and “updating”, you might find it easier to think that effects happen “after render”. React guarantees the DOM has been updated by the time it runs the effects.  
是否在每次渲染后 `useEffect` 运行？是的！默认情况下，它在第一次渲染后和每次更新后都运行。（我们稍后将讨论如何自定义它。与其从“挂载”和“更新”的角度来思考，不如认为效果发生在“渲染之后”更容易。React 保证 DOM 在运行效果时已更新。

https://react.dev/learn/synchronizing-with-effects

The behaviors without the dependency array and with an _empty_ `[]` dependency array are different:

```js
useEffect(() => {  // This runs after every render
});
useEffect(() => {  // This runs only on mount (when the component appears)
}, []);
useEffect(() => {  // This runs on mount *and also* if either a or b have changed since the last render
}, [a, b]);
```


When you choose whether to put some logic into an event handler or an Effect, the main question you need to answer is _what kind of logic_ it is from the user’s perspective. If this logic is caused by a particular interaction, keep it in the event handler. If it’s caused by the user _seeing_ the component on the screen, keep it in the Effect.


在开发时，useEffect会触发两次的问题的官方建议，从原理上来说这是没办法的，但是在生产环境，绝对不会触发两次。
https://react.dev/learn/synchronizing-with-effects#how-to-handle-the-effect-firing-twice-in-development


#### Ref and State

##### Differences between refs and state

Perhaps you’re thinking refs seem less “strict” than state—you can mutate them instead of always having to use a state setting function, for instance. But in most cases, you’ll want to use state. Refs are an “escape hatch” you won’t need often. Here’s how state and refs compare:

| refs                                                                                  | state                                                                                                                                                    |
| ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `useRef(initialValue)` returns `{ current: initialValue }`                            | `useState(initialValue)` returns the current value of a state variable and a state setter function ( `[value, setValue]`)                                |
| Doesn’t trigger re-render when you change it.                                         | Triggers re-render when you change it.                                                                                                                   |
| Mutable—you can modify and update `current`’s value outside of the rendering process. | ”Immutable”—you must use the state setting function to modify state variables to queue a re-render.                                                      |
| You shouldn’t read (or write) the `current` value during rendering.                   | You can read state at any time. However, each render has its own [snapshot](https://react.dev/learn/state-as-a-snapshot) of state which does not change. |



### Display HTML Content 

```tsx
<div dangerouslySetInnerHTML={{ __html: descHTML }} />
```



# 3. NodeJS

## @符号的含义

[https://docs.npmjs.com/using-npm/scope.html](https://docs.npmjs.com/using-npm/scope.html)

## 使用淘宝源

```
$ yarn config set registry 'https://registry.npmmirror.com'

# use taobao registry
$ npm install --registry=https://registry.npmmirror.com
```

## CLI

A simple HTTP Server

```shell
$ npm install -g http-server
# To run:
$ http-server & 
```



## npm 命令

```
# 使用国内的源
$ npm install -g cnpm --registry=https://registry.npmmirror.com

# 安全并保存到package.json的dependencies
$ npm install --save hbs

# 安全并保存到package.json的devDependencies
$ npm i -D @types/express-session
或使用--save-dev
$ npm i ---save-dev @types/express-session



# 列出全局安装的包
$ npm list -g --depth=0

#查看当前项目已经安装的依赖包的版本号
$ npm list --depth=0

# 查看某个包的所有versions.
$ npm view webpack versions --json
```

## 3.5 pnpm 命令

| command     | npm             | yarn                 | yarn (berry)         | pnpm                 | bun              |
| ----------- | --------------- | -------------------- | -------------------- | -------------------- | ---------------- |
| run package | `npx <package>` | `yarn dlx <package>` | `yarn dlx <package>` | `pnpm dlx <package>` | `bunx <package>` |

###  3.5.1 workspace

在根目录为子项目添加依赖
```
pnpm --filter @my-monorepo/common add -D barrelsby
```



```bash
# 先进入 admin-backend 目录
cd packages/admin-backend

# 再运行 add 命令
# --workspace 标志告诉 pnpm 这是一个工作区内部的依赖
pnpm add @my-monorepo/common --workspace
```






## Node Packages

[Zod](https://www.npmjs.com/package/zod) 是常用的校验 validation framework

# 4. JQuery

## jQuery操作select总结

1.添加option

```js
jQuery('#listCity').append( jQuery('<option></option').val(city.id).html(city.name) );

$("#select_id").change(function(){//code...});   //为Select添加事件，当选择其中一项时触发
var checkText=$("#select_id").find("option:selected").text();  //获取Select选择的Text
var checkValue=$("#select_id").val();  //获取Select选择的Value
var checkIndex=$("#select_id ").get(0).selectedIndex;  //获取Select选择的索引值
var maxIndex=$("#select_id option:last").attr("index");  //获取Select最大的索引值 

$("#select_id ").get(0).selectedIndex=1;  //设置Select索引值为1的项选中
$("#select_id ").val(4);   //设置Select的Value值为4的项选中
$("#select_id option[text='jQuery']").attr("selected", true);   //设置Select的Text值为jQuery的项选中

$("#select_id").append("<option value='Value'>Text</option>");  //为Select追加一个Option(下拉项)
$("#select_id").prepend("<option value='0'>请选择</option>");  //为Select插入一个Option(第一个位置)
$("#select_id option:last").remove();  //删除Select中索引值最大Option(最后一个)
$("#select_id option[index='0']").remove();  //删除Select中索引值为0的Option(第一个)
$("#select_id option[value='3']").remove();  //删除Select中Value='3'的Option
$("#select_id option[text='4']").remove();  //删除Select中Text='4'的Option
```

获得选中的项的index

```js
jQuery('#trunkTags :selected').first().get(0).index //这个是把select的multiple属性设置为true的时候，需要用first().
```

获得index=4的option

```js
jQuery("#trunkTags option[index=4]").get(0)
```

In jQuery, working with select box required some additional knowledge and interaction with jQuery. You may have some problem manipulating select box during your web development on jQuery. In this article we will discuss how you can solve this without any additional plugin to kill efficiency.

Create Selext Box In jQuery

Create a select box is very simple and straight forward. Just write a string with the normal select tag and a select box is created in jQuery

这下面的代码在IE8下无法正常运行：

```js
$("#start_instance_dialog #lbxIPs option:selected").val();
```

为了兼容IE8，只能写成

```js
$("#start_instance_dialog #lbxIPs option:selected").attr("value");
```

```js
jQuery('#some_element').append('<select></select>');
```

I bet everyone would have tried this and it work. However, manipulating might be a more challenging task.

Add Option In Select Box With jQuery

One easy way is to create a string with the whole element and create it straight away

```js
//obj is the list of option values

function(obj) {

    var create = '<select id="test">';

    for (var i = 0; i < obj.length; i++) {

        create += '<option value="' + obj[i] + '">' + obj[i] + '</option>';

    }

    create += '</select>';

    jQuery('#some_element').append(create);

}}
```

Another way to create a list of elements is to create its option and append it in using pure jQuery.

```js
function(id, obj) {

    jQuery('#some_element').append('<select id="' + id + '"></select>');

    jQuery.each(obj, function (val, text) {

        jQuery('#' + id).append(

            jQuery('<option></option').val(val).html(text)

        );
    })
```

You may not be familiar what i wrote above. Hence, a more javascript approach is shown below.

```js
function(id, obj) {

    jQuery('#some_element').append('<select id="' + id + '"></select>');

    for (var i = 0; i < obj.length; i++) {
        jQuery('#' + id).append('<option value="' + obj[i] + '">' + obj[i] + '</option');
    }

}
```

Get Select Box Value/Text In jQuery

Sometimes we want to know what is the value of the selected option. This is how we do it. Please bear in mind that there shouldn’t be any spaces between the : and selected.

```js
//#selectbox is the id of the select box
2
jQuery('#selectbox option:selected').val();
On the other hand, we can get the text of the option by doing this.

1
//#selectbox is the id of the select box
2
jQuery('#selectbox option:selected').text();
What if you know the value of the options you want to get instead of the one selected?

1
//#selectbox is the id of the select box
2
$("#selectList option[value='thisistheone']").text();
How about the first element on the select box?

1
//#selectbox is the id of the select box
2
$("#selectList option:first").text()
How about the n element on the select box?

1
//#selectbox is the id of the select box
2
$("#selectList option:eq(3)").text()
How about getting all elements but the first and last one in a select box?

1
//#selectbox is the id of the select box
2
$("#selectList option:not(option:first, option:last)").each(function(){
3
$(this).text();
4
});

Get Multiple Selected Value/Text In jQuery Select Box

Now we want to try to retrieve multiple selected values, we can do it easily with the following code.

1
jQuery('#some_element:selected').each(function(){
2
    alert(jQuery(this).text());
3
    alert(jQuery(this).val());
4
});
How about storing these values?

1
var current = [];
2
jQuery('#some_element:selected').each(function(index, selectedObj){
3
    current[index] = $(selectedObj).text();
4
});
This way we eliminate the additional index needed to follow through the loop! How about shorten the cold a bit?

1
var foo = jQuery('#multiple :selected').map(function(){return jQuery(this).val();}).get();
This way we eliminate the need to create an array.

Remove Element In Select Box With jQuery

So we can get and add element into the select box. How about remove them? Basically, you will need to use one of the get element method describe above before applying the remove instruction.

1
jQuery('#selectbox: selected').remove();
Here we will remove all elements except the first and last one.

1
//#selectbox is the id of the select box
2
$("#selectbox option:not(option:first, option:last)").remove();
```

删除所有的options

```js
$("#id_province option").remove();
```

Select an option in the select box with jQuery

If you want to select an option in the select box, you can do this.

```js
jQuery('#selectbox option[value="something"]').attr('selected', 'selected');
```

all option will be selected in this case.

**取消选中**
UnSelect an option in the select box with jQuery
If you want to unselect an option in the select box, you can do this.

```js
jQuery('#selectbox option[value="something"]').attr('selected', false);
```

all option will be unselected n this case.

OnChange find selected option from the select box

onchange find select box selected item.

```js
$('#selectbox').change(function(){
    var val = $(this).find('option:selected').text();
    alert('i selected: ' + val);
});
```

在select `onchange`事件里获取选中项的text.
onchange find select box selected items.

```js
$('#selectbox').change(function(){
    $(this).find('option:selected').each(function () {
        alert('i selected: ' + $(this).text());
    }

});
```

## Show ,hide element

```js
// https://www.w3schools.com/jquery/jquery_hide_show.asp
$("#hide").click(function(){
  $("p").hide();
});

$("#show").click(function(){
  $("p").show();
});
```

SpringMVC, jQuery post  json object 报：415 (Unsupported Media Type)  这个错，
解决方法是在 jquery post中加入 contentType: "application/json; charset=utf-8",就行了，

```js
$.ajax({
    type: "POST",
    contentType: "application/json; charset=utf-8",//加入这行就行了，奇怪的是默认浏览器是会加的呀。
    url: contextPath + "/securitygroups/create.do",
    data: JSON.stringify(securityGroup),
    success: function (ajaxResponse) {
        if (ajaxResponse.success) {
            $("#step-4.wizard-step #security_groups_error").text("OK!");
        } else {
            $("#step-4.wizard-step #security_groups_error").text(ajaxResponse.message);
        }
    },
    error: function (XMLHttpRequest, textStatus, errorThrown) {
        alert(textStatus.error + " " + errorThrown);
    },
    dataType: "json"
});
```

```js
jQuery('#some_element').append('<select></select>');
```

I bet everyone would have tried this and it work. However, manipulating might be a more challenging task.

jQuery post  json object 报：415 (Unsupported Media Type)  这个错，
解决方法是在 jquery post中加入 contentType: "application/json; charset=utf-8",就行了，

```
$.ajax({
type: "POST",
contentType: "application/json; charset=utf-8",//加入这行就行了，奇怪的是默认浏览器是会加的呀。
url: contextPath  + "/securitygroups/create.do",
data: JSON.stringify(securityGroup),
success: function(ajaxResponse) {
if(ajaxResponse.success) {
$("#step-4.wizard-step #security_groups_error").text("OK!");
} else {
$("#step-4.wizard-step #security_groups_error").text( ajaxResponse.message );
}
},
error : function(XMLHttpRequest, textStatus, errorThrown) {
alert(textStatus.error + " " + errorThrown);
},
dataType : "json"
});
```

# 5. Vue

Vscode debugging 

[在 VS Code 中调试 — Vue.js](https://cn.vuejs.org/v2/cookbook/debugging-in-vscode.html)


## 模式和环境变量
[https://cn.vitejs.dev/guide/env-and-mode.html](https://cn.vitejs.dev/guide/env-and-mode.html)

为了防止意外地将一些环境变量泄漏到客户端，只有以 VITE_ 为前缀的变量才会暴露给经过 vite 处理的代码。例如下面这些环境变量：

```
VITE_SOME_KEY=123
DB_PASSWORD=foobar
```
只有 `VITE_SOME_KEY` 会被暴露为 `import.meta.env.VITE_SOME_KEY` 提供给客户端源码，而 `DB_PASSWORD` 则不会。

```js
console.log(import.meta.env.VITE_SOME_KEY) // "123"
console.log(import.meta.env.DB_PASSWORD) // undefined
```
环境变量解析

如上所示，`VITE_SOME_KEY` 是一个数字，但在解析时会返回一个字符串。布尔类型的环境变量也会发生同样的情况。在代码中使用时，请确保转换为所需的类型。


## Vue Router

v4.0是为支持vue3.0开始的，主要有以下改动。

## new Router 变成 createRouter
Vue Router 不再是一个类，而是一组函数。现在你不用再写 new Router()，而是要调用 createRouter:

// 以前是
```js
// import Router from 'vue-router'
import { createRouter } from 'vue-router'

const router = createRouter({
  // ...
})
```

## 新的 history 配置取代 mode
mode: 'history' 配置已经被一个更灵活的 history 配置所取代。根据你使用的模式，你必须用适当的函数替换它：

* "history": createWebHistory()
* "hash": createWebHashHistory()
* "abstract": createMemoryHistory()


下面是一个完整的代码段：

```js
import { createRouter, createWebHistory } from 'vue-router'
// 还有 createWebHashHistory 和 createMemoryHistory

createRouter({
  history: createWebHistory(),
  routes: [],
})
```

在 SSR 上使用时，你需要手动传递相应的 history：

```js
// router.js
let history = isServer ? createMemoryHistory() : createWebHistory()
let router = createRouter({ routes, history })
// 在你的 server-entry.js 中的某个地方
router.push(req.url) // 请求 url
router.isReady().then(() => {
  // 处理请求
})
```
原因：为未使用的 history 启用摇树，以及为高级用例（如原生解决方案）实现自定义 history。


## Layout 
Vue3 目前我认为是最好的实现。

[Vue 3 layout system: smart layouts for VueJS | by Saken | Medium](https://medium.com/@sakensaten1409/vue-3-layout-system-smart-layouts-for-vuejs-80ae700e48a6)


# 6. Prisma
默认安装的Prisma，会在nuxt启动的setup阶段提示你要不要运行migration,要不要安装 Prisma Studio,你必须选择Y/N，这会打断nuxt项目的启动过程，非常烦人，你只要在`nuxt.config.tx`里加上配置，就能跳过这一过程。
```ts
export default defineNuxtConfig({

	prisma: {	
		// Options		
		autoSetupPrisma: false	
	}
})
```

[Prevent hot reloading from creating new instances of `PrismaClient`](https://www.prisma.io/docs/orm/prisma-client/setup-and-configuration/databases-connections#prevent-hot-reloading-from-creating-new-instances-of-prismaclient)

nextjs的hot reload会导致too many clients的错误，Prisma官方也给出了解决方案，真是太贴心了。

```js
// client.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient }

export const prisma =
  globalForPrisma.prisma || new PrismaClient()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```


如何使用Prisma生成的类型，我查看了官方的文档，没有看到，最后还是在sof上找到了答案
https://stackoverflow.com/questions/73656963/how-to-access-prisma-generated-types

```javascript
import type { User } from '@prisma/client'
```
简直是太方便，太简单了。



虽然prisma的官方文档里说prisma提供了泛型参数可以把queryRaw的结果转成prisma generated types，但是我在试过后发现还是不对。
https://www.prisma.io/docs/orm/prisma-client/using-raw-sql/raw-queries#typing-queryraw-results
之所以有转换，是因为我在设计数据库表时，字段名使用的snake case的。prisma generated type
类型使用Camel case的field的。
可是虽然我加上了泛型参数，返回的结果仍然是数据库中的snake case的，并不是转成prisma generated type。

`PrismaPromise<T>` uses a [generic type parameter`T`](https://www.typescriptlang.org/docs/handbook/generics.html). You can determine the type of `T` when you invoke the `$queryRaw` method. In the following example, `$queryRaw` returns `User[]`:

```ts
// import the generated `User` type from the `@prisma/client` module
import { User } from "@prisma/client";

const result = await prisma.$queryRaw<User[]>`SELECT * FROM User`;
// result is of type: `User[]`
```


来看还是要写个转换器，于是我让Claude 3.5给我写了一个。
让我用一个具体的例子来展示如何使用这个转换器：

```typescript
import { Prisma, SimcardOrders } from '@prisma/client';

// 定义转换器类型和选项
interface ConverterOptions {
    dateFields?: string[];
    numberFields?: string[];
    booleanFields?: string[];
    customConverters?: {
        [key: string]: (value: any) => any
    }
}

// 创建转换器函数
function createPrismaConverter<T>(
    modelFields: Record<string, string>,
    options: ConverterOptions = {}
) {
    const {
        dateFields = [], //这些字段是在Generated type里的字段 ，比如数据库中的字段是user_id，在生成的type里是userId,在这里要填上userId。
        numberFields = [],
        booleanFields = [],
        customConverters = {}
    } = options;

    return function convertRawResult(rawResults: any[]): T[] {
        return rawResults.map(rawItem => {
            const convertedItem: any = {};
            
            for (const [originalField, mappedField] of Object.entries(modelFields)) {
                const dbField = originalField.toLowerCase();
                let value = rawItem[dbField];
                
                if (value !== undefined) {
                    if (customConverters[mappedField]) {
                        value = customConverters[mappedField](value);
                    }
                    else if (dateFields.includes(mappedField)) {
                        value = value ? new Date(value) : null;
                    }
                    else if (numberFields.includes(mappedField)) {
                        value = value !== null ? Number(value) : null;
                    }
                    else if (booleanFields.includes(mappedField)) {
                        value = Boolean(value);
                    }
                    
                    convertedItem[mappedField] = value;
                }
            }
            
            return convertedItem as T;
        });
    };
}

// 使用示例
async function getSimcardOrders(timezone: string) {
    // 创建转换器实例
    const converter = createPrismaConverter<SimcardOrders>(
        Prisma.SimcardOrdersScalarFieldEnum,
        {
            dateFields: ['createdAt', 'updatedAt', 'activatedAt'],
            numberFields: ['amount', 'quantity'],
            booleanFields: ['isActive'],
            customConverters: {
                // 示例：自定义转换某些字段
                orderStatus: (value) => value.toUpperCase(),
                metadata: (value) => value ? JSON.parse(value) : null
            }
        }
    );

    // 执行原始查询
    const rawResults = await prisma.$queryRaw`
        SELECT * FROM "simcard_orders"
        WHERE created_at AT TIME ZONE ${timezone} >= date_trunc('day', now() AT TIME ZONE ${timezone})
        AND created_at AT TIME ZONE ${timezone} < date_trunc('day', now() AT TIME ZONE ${timezone}) + interval '30 day'
    `;
    
    // 转换结果
    return converter(rawResults);
}

// 使用方法
async function main() {
    try {
        const orders = await getSimcardOrders('Asia/Shanghai');
        console.log('转换后的订单数据:', orders);
        
        // 类型安全：可以直接访问 SimcardOrders 的属性
        orders.forEach(order => {
            console.log(`订单 ${order.orderId}:`, {
                createdAt: order.createdAt, // 这是 Date 类型
                amount: order.amount,    // 这是 number 类型
                isActive: order.isActive // 这是 boolean 类型
            });
        });
    } catch (error) {
        console.error('查询错误:', error);
    }
}
```

使用这个转换器的主要优点：

1. 类型安全：
   - 使用 Prisma 生成的类型定义
   - TypeScript 可以正确推断转换后的类型

2. 自动类型转换：
   - 日期字符串自动转换为 Date 对象
   - 数字字符串自动转换为 number 类型
   - 布尔值的自动转换

3. 灵活性：
   - 可以自定义字段转换逻辑
   - 可以处理特殊的数据格式（如 JSON 字符串）

4. 可重用性：
   - 可以为不同的模型创建转换器
   - 转换逻辑可以在整个应用中复用

需要我解释某个具体部分，或者针对特定场景进行调整吗？

## 常用命令

```
pnpm i --save-dev prisma@latest
pnpm i @prisma/client@latest
```

如果你在项目中安装了`prisma`和`@prisma/client`，就可以使用exec来执行prisma命令。如果用`pnpm dlx prisma`需要每次都下载它然后再执行，速度会非常慢。

```bash
# 从数据库生成prisma models，并生成相关typescript代码。
pnpm exec prisma db pull && pnpm exec prisma generate
```

在开发环境我们修改了数据库后，比如添加了新列，并执行了`prisma db pull`生成了`schema.prisma`后，在生产环境只需要执行`prisma db push`就可以把修改同步到生产环境的数据库中。

```
pnpm exec prisma db push
```

# 7. ECharts

默认并不是显示所有的x轴的标签的，如果要显示，需要设置`axisLabel`下的`interval`为0。

```typescript
xAxis: {
        type: "category",
        axisTick: {
          alignWithLabel: true,
        },
        data: statData.horizontal,
        axisLabel: {
          interval: 0,
        }
      },
```

### 让单series的柱状图，每个柱显示不同的颜色

```typescript
series: [
        {
          name: "A",
          type: "bar",
          data: dataA,
          itemStyle: {
            // color: "#0c84c6",
            color: function (parms: any) {
              let colours = [
                "#002c53",
                "#ffa510",
                "#0c84c6",
                "#ffbd66",
                "#f74d4d",
                "#2455a4",
                "#41b7ac",
              ];
              return colours[parms.dataIndex % colours.length];
            },
          },
          markLine: {
            // data: statData.vertical[3]["BaseLine"]["A"],
            data: [
              {
                name: "Y 轴值为 100 的水平线",
                yAxis: statData.vertical[3]["BaseLine"]["A"],
              },
            ],
            lineStyle: {
              color: "#fdc746",
              width: 2,
            },
          },
        },
      ],
```

# 8 微信小程序

数据双向绑定
https://developers.weixin.qq.com/miniprogram/dev/framework/view/two-way-bindings.html




React的组件库
https://zhuanlan.zhihu.com/p/546697951
# 

# 参考文档

[Mozilla Javascript reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference)
