css備忘
-----------------

position这个属性很有用。

# Flex box已经获得了所有主流brower的支持,可以安全地使用它了.

http://zh.learnlayout.com/flexbox.html

http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html  可以看一下他在文章里参考的两篇blog

[A Complete Guide to Flexbox](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)

[A Visual Guide to CSS3 Flexbox Properties](https://scotch.io/tutorials/a-visual-guide-to-css3-flexbox-properties)

这里有个在线的demo也非常好:
https://demos.scotch.io/visual-guide-to-css3-flexbox-flexbox-playground/demos/

注意如果 

* `flex-direction`设置为row,如果想让内容vertical居中,需要设置`align-items`:center.
* `flex-direction`设置为column,如果想让内容水平居中,需要设置`align-items`:center.
  这个理解一下.

实现vertical middle:

```css
.vertical-center {
  min-height: 100%;  /* Fallback for browsers do NOT support vh unit */
  min-height: 100vh; /* These two lines are counted as one :-)       */

  display: flex;
  align-items: center;
}
```

`flex-grow` 这个属性如果设置为1,则会填满父元素.

用flexbox来实现sticky header and footer 

https://codepen.io/anthonyLukes/pen/DLBeE

```css

.page {
  display: flex;
  flex-direction: column;
}

.page-header {
  flex: 0 0 auto;
  background-color: #dcdcdc;
}

.page-content {
  flex: 1 1 auto;
  position: relative;/* need this to position inner content */
  overflow-y: auto;
}

.page-footer {
  flex: 0 0 auto;
  background-color: #dcdcdc;
}
```

首行缩进2空格.

```css
text-indent: 2em;
```

```css
white-space: nowrap;
overflow: hidden;    
```

## CSS Grid

据说这东西要替代Flex

https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout

2.使用 vue-cli3.0+vuejs+bootstrap 作为前端架构 

3.使用 axios 进行数据交互，使用 vuex 进行页面间的数据传递; 

* http://cephnotes.ksperis.com/
