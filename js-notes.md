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



























# 参考文档
[Mozilla Javascript reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference)


