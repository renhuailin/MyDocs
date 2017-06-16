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


# 4. Expressions and Operators
# 4.9 Relational Expressions

The strict equality operator === evaluates its operands, and then compares the two values as follows, performing no type conversion: 
*	If the two values have different types, they are not equal.
*	If both values are null or both values are undefined, they are equal.
*	If both values are the boolean value true or both are the boolean value false, they are equal.
*	If one or both values is NaN, they are not equal. **The NaN value is never equal to any other value, including itself!**  To check whether a value x is NaN, use `x !== x`. **NaN is the only value of x for which this expression will be true**. 
*	If both values are numbers and have the same value, they are equal. If one value is 0 and the other is -0, they are also equal. 
*	If both values are strings and contain exactly the same 16-bit values (see the sidebar in §3.2) in the same positions, they are equal. If the strings differ in length or content, they are not equal. Two strings may have the same meaning and the same visual appearance, but still be encoded using different sequences of 16-bit values. JavaScript performs no Unicode normalization, and a pair of strings like this are not considered equal to the === or to the == operators. See String.localeCompare() in Part III for another way to compare strings. 
*	If both values refer to the same object, array, or function, they are equal. If they refer to different objects they are not equal, even if both objects have identical properties. 


The equality operator == is like the strict equality operator, but it is less strict. If the values of the two operands are not the same type, it attempts some type conversions 
and tries the comparison again: 
1.	If the two values have the same type, test them for strict equality as described above. If they are strictly equal, they are equal. If they are not strictly equal, they are not equal. 
2.	If the two values do not have the same type, the == operator may still consider them equal. Use the following rules and type conversions to check for equality: 
    *  If one value is null and the other is undefined, they are equal. 
    *  If one value is a number and the other is a string, convert the string to a number and try the comparison again, using the converted value. 
    *  If either value is true, convert it to 1 and try the comparison again. If either value is false, convert it to 0 and try the comparison again. 
    *  If one value is an object and the other is a number or string, convert the object to a primitive using the algorithm described in §3.8.3 and try the comparison again. An object is converted to a primitive value by either its toString() method or its valueOf() method. The built-in classes of core JavaScript attempt valueOf() conversion before toString() conversion, except for the Date class, which performs toString() conversion. Objects that are not part of core Java- Script may convert themselves to primitive values in an implementation-defined way. 
    *  Any other combinations of values are not equal.




## 6.2 查询属性

可以用点，也可以用`[]`
``` js
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



如果用es6的语法，autobinding会解决问题，请看：https://facebook.github.io/react/blog/2015/01/27/react-v0.13.0-beta-1.html






# React

react 强制我们以组件的方式去思考。
每个组件有自己的state，这个东西有点像跟UI关联的model，是一對象。


this.props和this.state的区别是什么 ？  
https://github.com/uberVU/react-guide/blob/master/props-vs-state.md


https://facebook.github.io/react/docs/thinking-in-react.html    这个链接讲了如何确定你的Component的state。





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

# ES6

## Generator

``` js
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


## Promise

``` js
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

##  async await 关键字

The await expression causes async function execution to pause, to wait for the Promise's resolution, and to resume the async function execution when the value is resolved. It then returns the resolved value. If the value is not a Promise, it's converted to a resolved Promise.

If the Promise is rejected, the await expression throws the rejected value.

`await`会暂停async函数的调用,等待Promise resolution.当值被解析后继续执行async函数,如果await后面接不是Promise,await会反它转成一个`resolved Promise`.

``` js
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
``` js
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



# Webpack
多页面设置
https://webpack.github.io/docs/optimization.html#multi-page-app


# JQuery 

jQuery操作select总结：
1.添加option

``` js
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

``` js
jQuery('#trunkTags :selected').first().get(0).index //这个是把select的multiple属性设置为true的时候，需要用first().
```

获得index=4的option

``` js
jQuery("#trunkTags option[index=4]").get(0)
```

In jQuery, working with select box required some additional knowledge and interaction with jQuery. You may have some problem manipulating select box during your web development on jQuery. In this article we will discuss how you can solve this without any additional plugin to kill efficiency.

Create Selext Box In jQuery

Create a select box is very simple and straight forward. Just write a string with the normal select tag and a select box is created in jQuery


这下面的代码在IE8下无法正常运行：
``` js
$("#start_instance_dialog #lbxIPs option:selected").val();
```
为了兼容IE8，只能写成
``` js
$("#start_instance_dialog #lbxIPs option:selected").attr("value");
```

``` js
jQuery('#some_element').append('<select></select>');
```

I bet everyone would have tried this and it work. However, manipulating might be a more challenging task.

Add Option In Select Box With jQuery

One easy way is to create a string with the whole element and create it straight away


``` js
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

``` js
function(id, obj) {

    jQuery('#some_element').append('<select id="' + id + '"></select>');

    jQuery.each(obj, function (val, text) {

        jQuery('#' + id).append(

            jQuery('<option></option').val(val).html(text)

        );
    })


```
You may not be familiar what i wrote above. Hence, a more javascript approach is shown below.

``` js
function(id, obj) {

    jQuery('#some_element').append('<select id="' + id + '"></select>');

    for (var i = 0; i < obj.length; i++) {
        jQuery('#' + id).append('<option value="' + obj[i] + '">' + obj[i] + '</option');
    }

}
```

Get Select Box Value/Text In jQuery

Sometimes we want to know what is the value of the selected option. This is how we do it. Please bear in mind that there shouldn’t be any spaces between the : and selected.

```
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
``` js
$("#id_province option").remove();
```

Select an option in the select box with jQuery

If you want to select an option in the select box, you can do this.

``` js
jQuery('#selectbox option[value="something"]').attr('selected', 'selected');
```
all option will be selected in this case.




**取消选中**
UnSelect an option in the select box with jQuery
If you want to unselect an option in the select box, you can do this.

``` js
jQuery('#selectbox option[value="something"]').attr('selected', false);
```
all option will be unselected n this case.




OnChange find selected option from the select box

onchange find select box selected item.

``` js
$('#selectbox').change(function(){
    var val = $(this).find('option:selected').text();
    alert('i selected: ' + val);
});
```

在select `onchange`事件里获取选中项的text.
onchange find select box selected items.

``` js
$('#selectbox').change(function(){
    $(this).find('option:selected').each(function () {
        alert('i selected: ' + $(this).text());
    }

});
```

SpringMVC, jQuery post  json object 报：415 (Unsupported Media Type)  这个错，
解决方法是在 jquery post中加入 contentType: "application/json; charset=utf-8",就行了，

``` js
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

jQuery('#some_element').append('<select></select>');
I bet everyone would have tried this and it work. However, manipulating might be a more challenging task.

Add Option In Select Box With jQuery

One easy way is to create a string with the whole element and create it straight away

1
//obj is the list of option values
2
function(obj)
3
{
4
    var create = '<select id="test">';
5
    for(var i = 0; i < obj.length;i++)
6
    {
7
        create += '<option value="'+obj[i]+'">'+obj[i]+'</option>';
8
    }
9
    create += '</select>';
10
    jQuery('#some_element').append(create);
11
}
Another way to create a list of elements is to create its option and append it in using pure jQuery.

1
function(id, obj)
2
{
3
    jQuery('#some_element').append('<select id="'+id+'"></select>');
4
    jQuery.each(obj, function(val, text) {
5
        jQuery('#'+id).append(
6
        jQuery('<option></option').val(val).html(text)
7
    );})
8
}
You may not be familiar what i wrote above. Hence, a more javascript approach is shown below.

1
function(id, obj)
2
{
3
    jQuery('#some_element').append('<select id="'+id+'"></select>');
4
    for(var i = 0; i < obj.length;i++)
5
    {
6
        jQuery('#'+id).append('<option value="'+obj[i]+'">'+obj[i]+'</option')
7
    }
8
}
Get Select Box Value/Text In jQuery

Sometimes we want to know what is the value of the selected option. This is how we do it. Please bear in mind that there shouldn’t be any spaces between the : and selected.

1
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
Select an option in the select box with jQuery

If you want to select an option in the select box, you can do this.

1
jQuery('#selectbox option[value="something"]').attr('selected', 'selected');
all option will be selected in this case.

UnSelect an option in the select box with jQuery

If you want to unselect an option in the select box, you can do this.

1
jQuery('#selectbox option[value="something"]').attr('selected', false);
all option will be unselected n this case.

OnChange find selected option from the select box

onchange find select box selected item.

1
$('#selectbox').change(function(){
2
    var val = $(this).find('option:selected').text();r
3
    alert('i selected: ' + val);
4
});
onchange find select box selected items.

1
$('#selectbox').change(function(){
2
    $(this).find('option:selected').each(function () {
3
        alert('i selected: ' + $(this).text());
4
    }
5
});

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


# 参考文档
[Mozilla Javascript reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference)
