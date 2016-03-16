Swift编程语言学习心得备忘
----------------

Swfit不允许隐式转换，这一点要特别注意。我感觉这很好，隐匿转换会带来很多问题。

``` swift
let s = "hello";
let i = 10;
var ns = s + i;
```
