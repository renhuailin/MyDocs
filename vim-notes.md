## 【光标控制命令 】
```
命令                     光标移动
h或^h                    向左移一个字符
j或^j或^n                向下移一行
k或^p                    向上移一行
l或空格                   向右移一个字符
G                        移到文件的最后一行
nG                       移到文件的第n行
w                        移到下一个字的开头
W                        移到下一个字的开头，忽略标点符号
b                        移到前一个字的开头
B                        移到前一个字的开头，忽略标点符号
L                        移到屏幕的最后一行
M                        移到屏幕的中间一行
H                        移到屏幕的第一行
e                        移到下一个字的结尾
E                        移到下一个字的结尾，忽略标点符号
(                        移到句子的开头
)                        移到句子的结尾
{                        移到段落的开头
}                        移到下一个段落的开头
0或|                     移到当前行的第一列
n|                       移到当前行的第n列
^                        移到当前行的第一个非空字符
$                        移到当前行的最后一个字符
+或return                移到下一行的第一个字符
-                        移到前一行的第一个非空字符
```

## 【在vi中添加文本】

```
命令                     插入动作
a                        在光标后插入文本
A                        在当前行插入文本
i                        在光标前插入文本
I                        在当前行前插入文本
o                        在当前行的下边插入新行
O                        在当前行的上边插入新行
:r file                  读入文件file内容，并插在当前行后
:nr file                 读入文件file内容，并插在第n行后
escape                   回到命令模式
^v char                  插入时忽略char的指定意义，这是为了插入特殊字符
```
區塊選擇的按鍵意義 v 字元選擇，會將游標經過的地方反白選擇！ V 行選擇，會將游標經過的行反白選擇！ [Ctrl]+v 區塊選擇，可以用長方形的方式選擇資料 y 將反白的地方複製起來 d 將反白的地方刪除掉 



【在vi中删除文本】
```
命令                     删除操作
x                        删除光标处的字符，可以在x前加上需要删除的字符数目
nx                       从当前光标处往后删除n个字符
X                        删除光标前的字符，可以在X前加上需要删除的字符数目
nX                       从当前光标处往前删除n个字符
dw                       删至下一个字的开头
ndw                      从当前光标处往后删除n个字
dG                       删除行，直到文件结束
dd                       删除整行
ndd                      从当前行开始往后删除
db                       删除光标前面的字
ndb                      从当前行开始往前删除n字
:n,md                    从第m行开始往前删除n行
d或d$                    从光标处删除到行尾
dcursor_command          删除至光标命令处，如dG将从当产胆行删除至文件的末尾
^h或backspace            插入时，删除前面的字符
^w                       插入时，删除前面的字
```
【修改vi文本】

每个命令前面的数字表示该命令重复的次数

```
命令                         替换操作
rchar                    用char替换当前字符
R text escape            用text替换当前字符直到换下Esc键
stext escape             用text代替当前字符
S或cctext escape         用text代替整行
cwtext escape            将当前字改为text
Ctext escape             将当前行余下的改为text
cG escape                修改至文件的末尾
ccursor_cmd text escape 从当前位置处到光标命令位置处都改为text
```

【在vi中查找与替换】
```
命令                         查找与替换操作
/text                    在文件中向前查找text
?text                    在文件中向后查找text
n                        在同一方向重复查找
N                        在相反方向重复查找
ftext                    在当前行向前查找text
Ftext                    在当前行向后查找text
ttext                    在当前行向前查找text，并将光标定位在text的第一个字符
Ttext                    在当前行向后查找text，并将光标定位在text的第一个字符
:set ic                  查找时忽略大小写
:set noic                查找时对大小写敏感
:s/oldtext/newtext       用newtext替换oldtext
:m,ns/oldtext/newtext    在m行通过n，用newtext替换oldtext
&                        重复最后的:s命令
:g/text1/s/text2/text3   查找包含text1的行，用text3替换text2
:g/text/command          在所有包含text的行运行command所表示的命令
:v/text/command          在所有不包含text的行运行command所表示的命令
vi替换的语法为 :[addr]s/源字符串/目的字符串/[option]

全局替换命令为：:%s/源字符串/目的字符串/g

[addr] 表示检索范围，省略时表示当前行。

如：“1，20” ：表示从第1行到20行；

“%” ：表示整个文件，同“1,$”；

“. ,$” ：从当前行到文件尾；

s : 表示替换操作

[option] : 表示操作类型

如：g 表示全局替换;

c 表示进行确认

p 表示替代结果逐行显示（Ctrl + L恢复屏幕）；

省略option时仅对每行第一个匹配串进行替换；

如果在源字符串和目的字符串中出现特殊字符，需要用”\”转义

下面是一些例子：

#将That or this 换成 This or that
:%s/ThatThat or thisthis/\u\2 or \l\1/
—- 
#将句尾的child换成children
:%s/child[,.;!:?][,.;!:?]/children\1/g
—-
#将mgi/r/abox换成mgi/r/asquare
:g/mg[ira][ira]box/s//mg//my\1square/g    <=> :g/mg[ira]box/s/box/square/g
—-
#将多个空格换成一个空格
:%s/ */ /g
—-
#使用空格替换句号或者冒号后面的一个或者多个空格
:%s/[:.][:.] */\1 /g
—-
#删除所有空行
:g/^$/d
—-
#删除所有的空白行和空行
:g/^[ ][ ]*$/d
—-
#在每行的开始插入两个空白
:%s/^/> /
—-
#在接下来的6行末尾加入.
:.,5/$/./
—-
#颠倒文件的行序
:g/.*/m0O <=> :g/^/m0O
—-
#寻找不是数字的开始行,并将其移到文件尾部
:g!/^[0-9]/m$ <=> g/^[^0-9]/m$
—-
#将文件的第12到17行内容复制10词放到当前文件的尾部
:1,10g/^/12,17t$
~~~~重复次数的作用
—-
#将chapter开始行下面的第二行的内容写道begin文件中
:g/^chapter/.+2w>>begin
—-
:/^part2/,/^part3/g/^chapter/.+2w>>begin
—-
:/^part2/,/^part3/g/^chapter/.+2w>>begin|+t$
```

【在vi中复制文本】

```
命令                         复制操作
yw                      复制到下一个字的开头
yy                       将当前行的内容放入临时缓冲区
nyy                      将n行的内容放入临时缓冲区
p                        将临时缓冲区中的文本放入光标后
P                        将临时缓冲区中的文本放入光标前
dsfsd "(a-z)nyy          复制n行放入名字为圆括号内的可命名缓冲区，省略n表示当前行
"(a-z)ndd                删除n行放入名字为圆括号内的可命名缓冲区，省略n表示当前行
"(a-z)p                  将名字为圆括号的可命名缓冲区的内容放入当前行后
"(a-z)P                  将名字为圆括号的可命名缓冲区的内容放入当前行前
```

【在vi中撤消与重复】

```
命令                         撤消操作
u                        撤消最后一次修改
U                        撤消当前行的所有修改
.                        重复最后一次修改
,                        以相反的方向重复前面的f、F、t或T查找命令
;                        重复前面的f、F、t或T查找命令
"np                      取回最后第n次的删除(缓冲区中存有一定次数的删除内容，一般为9)
n                        重复前面的/或?查找命令
N                        以相反方向重复前面的/或?命令
```

【保存文本和退出vi】

```
命令                         保存和/或退出操作
:w                       保存文件但不退出vi
:w file                  将修改保存在file中但不退出vi
:wq或ZZ或:x              保存文件并退出vi
:q!                      不保存文件，退出vi
:e!                      放弃所有修改，从上次保存文件开始再编辑
```
【vi中的选项】

```
选项                         作用
:set all                 打印所有选项
:set nooption            关闭option选项
:set nu                  每行前打印行号
:set nonu              关闭行号（在console里复制文本时,会把行号也复制了。）;
:set showmode            显示是输入模式还是替换模式
:set noic                查找时忽略大小写
:set list                显示制表符(^I)和行尾符号
:set ts=8                为文本输入设置tab stops
:set window=n            设置文本窗口显示n行
```

【vi的状态】

```
选项                         作用
:.=                      打印当前行的行号
:=                       打印文件中的行数
^g                       显示文件名、当前的行号、文件的总行数和文件位置的百分比
:l                       使用字母"l"来显示许多的特殊字符，如制表符和换行符
```
【在文本中定位段落和放置标记】

```
选项                         作用
{                        在第一列插入{来定义一个段落
[[                       回到段落的开头处
]]                       向前移到下一个段落的开头处
m(a-z)                   用一个字母来标记当前位置，如用mz表示标记z
'(a-z)                   将光标移动到指定的标记，如用'z表示移动到z

```

## 在vi中连接行

```
选项                         作用
J                        将下一行连接到当前行的末尾
nJ                       连接后面n行
```
【光标放置与屏幕调整】

```
选项                         作用
H                        将光标移动到屏幕的顶行
nH                       将光标移动到屏幕顶行下的第n行
M                        将光标移动到屏幕的中间
L                        将光标移动到屏幕的底行
nL                       将光标移动到屏幕底行上的第n行
^e(ctrl+e)               将屏幕上滚一行
^y                       将屏幕下滚一行
^u                       将屏幕上滚半页
^d                       将屏幕下滚半页
^b                       将屏幕上滚一页
^f                       将屏幕下滚一页
^l                       重绘屏幕
z-return                 将当前行置为屏幕的顶行
nz-return                将当前行下的第n行置为屏幕的顶行
z.                       将当前行置为屏幕的中央
nz.                      将当前行上的第n行置为屏幕的中央
z-                       将当前行置为屏幕的底行
nz-                      将当前行上的第n行置为屏幕的底行
```
【vi中的shell转义命令】

```
选项                         作用
:!command                执行shell的command命令，如:!ls
:!!                      执行前一个shell命令
:r!command               读取command命令的输入并插入，如:r!ls会先执行ls，然后读入内容
:w!command               将当前已编辑文件作为command命令的标准输入并执行command命令，如:w!grep all
:cd directory            将当前工作目录更改为directory所表示的目录
:sh                      将启动一个子shell，使用^d(ctrl+d)返回vi
:so file                 在shell程序file中读入和执行命令

```
【vi中的宏与缩写】


(避免使用控制键和符号，不要使用字符K、V、g、q、v、*、=和功能键)

```
选项                         作用
:map key command_seq     定义一个键来运行command_seq，如:map e ea，无论什么时候都可以e移到一个字的末尾来追加文本
:map                     在状态行显示所有已定义的宏
:umap key                删除该键的宏
:ab string1 string2      定义一个缩写，使得当插入string1时，用string2替换string1。当要插入文本时，键入string1然后按Esc键，系统就插入了string2
:ab                      显示所有缩写
:una string              取消string的缩写
```
【在vi中缩进文本】

```
选项                         作用
^i(ctrl+i)或tab          插入文本时，插入移动的宽度，移动宽度是事先定义好的
:set ai                  打开自动缩进
:set sw=n                将移动宽度设置为n个字符
n<<                      使n行都向左移动一个宽度
n>>                      使n行都向右移动一个宽度，例如3>>就将接下来的三行每行都向右移动一个移动宽度

>                        缩进选中的行。
<                        反缩进选中的行。
```

## 【用户配置文件】

.vimrc

```vimrc
" Don't try to be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below
filetype off

" TODO: Load plugins here (pathogen or vundle)

" Turn on syntax highlighting
syntax on

" For plugins to load correctly
filetype plugin indent on

" TODO: Pick a leader key
" let mapleader = ","

" Security
set modelines=0

" Show line numbers
set number

" Show file stats
set ruler

" Blink cursor on error instead of beeping (grr)
set visualbell

" Encoding
set encoding=utf-8

" Whitespace
set wrap
"set textwidth=79
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround
```



【显示^M】

当从Windows传来一个文件时，文件可能包含特殊的字符^M，会导致某些文件无法正常工作，可以使用vim -d 命令来打开该文件，这样就能看到行尾的^M符号了。
如果还是不能显示，且导致程序运行出错，则可以用dos2unix把它转成Unix格式的换行。


【多行注释】

```
1. 进入命令行模式，按ctrl + v进入 visual block模式（可视快模式），然后上下移动光标选中多行。

2. 按大写字母I，再插入注释符，例如#。

3. 按esc键,这一步很重要！
```

【进入和退出recording模式】

了解什么是recording.
```
:h recording或q  
```
在文档中的正式名称是Complex repeats。
首先在非编辑模式上，按`q`进入宏的录制模式。
```
esc q
```
然后做你想做的操作，然后按`q`退出recording.
```
esc q
```
这篇文章讲了它有什么用[Vi and Vim Macro Tutorial: How To Record and Play](https://www.thegeekstuff.com/2009/01/vi-and-vim-macro-tutorial-how-to-record-and-play/)
