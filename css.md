# css備忘

position这个属性很有用。

## Flex

Flex box已经获得了所有主流brower的支持,可以安全地使用它了.

http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html  可以看一下他在文章里参考的两篇blog

[A Complete Guide to Flexbox](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)  这篇文章非常好，图解的非常清楚。再配合上这个在线的demo，就更好了：[CodePen - Flexbox Properties Demonstration](https://codepen.io/justd/full/yydezN/)



[A Visual Guide to CSS3 Flexbox Properties](https://scotch.io/tutorials/a-visual-guide-to-css3-flexbox-properties)

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



## CSS Units

CSS里常用单位有px,pt,em,vh

W3School的[CSS Units](https://www.w3schools.com/cssref/css_units.asp)这篇文章非常好。



### Absolute Lengths

绝对长度这个很容易理解，我们常用，如px,pt。

| Unit | Description                                                                                              |
| ---- | -------------------------------------------------------------------------------------------------------- |
| cm   | centimeters[Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_cm)                  |
| mm   | millimeters[Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_mm)                  |
| in   | inches (1in = 96px = 2.54cm)[Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_in) |
| px * | pixels (1px = 1/96th of 1in)[Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_px) |
| pt   | points (1pt = 1/72 of 1in)[Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_pt)   |
| pc   | picas (1pc = 12 pt)[Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_pc)          |

## Relative Lengths

相对长度在某些场景下，使用的更多，也能很方便地实现一些布局效果。其中vh,vw很实用。

em是相对于当前元素的字体大小来计算的。

| Unit | Description                                                                               |                                                                                |
| ---- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| em   | Relative to the font-size of the element (2em means 2 times the size of the current font) | [Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_em)   |
| ex   | Relative to the x-height of the current font (rarely used)                                | [Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_ex)   |
| ch   | Relative to the width of the "0" (zero)                                                   | [Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_ch)   |
| rem  | Relative to font-size of the root element                                                 | [Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_rem)  |
| vw   | Relative to 1% of the width of the viewport*                                              | [Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_vw)   |
| vh   | Relative to 1% of the height of the viewport*                                             | [Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_vh)   |
| vmin | Relative to 1% of viewport's* smaller dimension                                           | [Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_vmin) |
| vmax | Relative to 1% of viewport's* larger dimension                                            | [Try it](https://www.w3schools.com/cssref/tryit.asp?filename=trycss_unit_vmax) |
| %    | Relative to the parent element                                                            |                                                                                |

min-height: calc(100vh - 86px);







## CSS Grid

据说这东西要替代Flex

https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout

2.使用 vue-cli3.0+vuejs+bootstrap 作为前端架构 

3.使用 axios 进行数据交互，使用 vuex 进行页面间的数据传递; 

* http://cephnotes.ksperis.com/
