# 快捷键汇总

写在前面
  `C-'               Control-(即 Ctrl-)，按住 Ctrl 键再按其他键
  `M-'               Meta-(或 Alt-)，按住 Alt 键再按其他键；或按一下 ESC，再按其他键
  `C-M-'             Control-Alt-，按住 Ctrl 和 Alt 两个键再按其他键
  point              位点。文档中的一个位置，一般是光标的左下角
  mark               标记。由命令设置，用来定义/保存文档中的位置信息
  region             区域。在 mark 和 point 之间部分，称为一个 region

  RET                回车键
  TAB                制表符键
  ESC                ESC 键
  SPC                空格键
  Backspace, DEL       退格键
  Delete              删除键

如果不知道
  C-x C-c            退出并关闭 Emacs

  C-z                
  C-x C-z            退出并挂起 Emacs

  C-x C-f            打开文件/目录
  C-x i              插入文件内容
  C-x C-r            只读方式打开一个文件

  C-x u              Undo( 想要Redo，动一下光标或按一下 C-g 再Undo :)
  C-x C-s            保存文件
  C-x s              询问保存所有未存盘文件
  C-x C-w            文件另存为…

  C-l                刷新窗口，并将当前行移至窗口中心。给定参数，可以设置
                     当前行的位置，不妨试试 M-0 C-l 或 M-- C-l 或 M-4 C-l

  C-g                退出当前命令。如果你不知道Emacs正在干什么呢，多按几次
                     C-g，就会恢复到正常状态

在线帮助
  C-h t              TUTORIAL
  C-h i              Online Info

  C-h c              给出键序列（简称键）绑定的命令名字
  C-h w              由命令名字给出键的绑定

给命令传参数
  C-u                给定参数前缀

  M-0
  ...
  M-9                参数0...9

  M--                负参数

光标的移动
  C-a                行首
  C-e                行尾

  C-n                下一行
  C-p                上一行
  C-f                前进一个字符
  C-b                后退一个字符

  M-f                前进一个词
  M-b                后退一个词

搜索和替换
  C-s                增量搜索
  C-r                向后增量搜索

  M-x search-forward
                     搜索
  M-x search-backward
                     向后搜索

  C-M-s
  M-x isearch-forward-regexp
                     正则表达式增量搜索
  C-M-r
  M-x isearch-backward-regexp
                     正则表达式向后增量搜索

  M-x search-forward-regexp
                     正则表达式搜索
  M-x search-backward-regexp
                     正则表达式向后搜索

  ESC %              询问替换
  M-x query-replace-regexp
                     正则表达式询问替换

  M-x replace-string 替换
  M-x replace-regexp 正则表达式替换

区域的拷贝和粘贴
区域是Mark和Point之间的部分，Point就是光标的左下角，Mark由命令设置。 `Yanking ring'是一个存放文本的地方，从这里你可以拷贝删除(kill)的文本。 `Yanking'表示插入刚刚删除(kill)的文本。 

  C-SPC              
  C-@                
  M-x set-mark-command
                     设置 mark
  C-x C-x            交换 mark 和 point

  C-w                将区域的文本删除，并放入yanking ring中
  M-w                复制区域到yanking ring中

  C-y                将yanking ring中最后一个区域插入当前缓冲区

  M-y                按一次C-y后，多次按M-y，则用yanking ring中的其他区域替
                     换刚刚插入的区域

  C-o                在光标后面插入空行
  C-x C-o            将光标附近的空行去掉，多行的时候，第一次只剩一行，第二
                     次全部删除

  C-d                删除一个字符（不能yank）
  M-d                删除光标附近的一个词

  C-x h              将整个缓冲区设置为区域（缓冲区尾是mark，首是point）

  C-k                删除（kill）从光标处到行尾

基本编辑
  C-q                插入下一个的字符,比如插入字符`^X'用“C-q C-x”

  C-t                交换两个字符
  M-t                交换两个词
  C-x C-t            交换两行

  C-x =              显示光标所在字符的信息

  C-v                向下滚动窗口
  M-v                向上滚动窗口

多窗口和多缓冲区
  C-x b              转到另一个缓冲区
  C-x k              删除缓冲区

  C-x 2              水平分个窗口
  C-x 3              垂直分割窗口
  C-x 1              去掉其它窗口
  ESC ESC ESC        同上
  C-x 0              去掉当前窗口

  C-x o              光标到另一个窗口中

  C-M-v              向下滚动另一个窗口，给一个负的参数，则向上滚动

宏
  C-x (              开始一个宏的定义
  C-x )              结束一个宏的定义

  C-x e              执行宏

  M-x name-last-kbd-macro
                     给最后一个宏命名

  M-x insert-kbd-macro
                     在当前文件中插入一个已定义并命名过的宏

矩形区域操作

* 矩形区域的两端是由 Mark 和 Point 确定的。
  
  C-x r t            用串填充矩形区域
  C-x r o            插入空白的矩形区域
  C-x r y            插入之前删除的矩形区域
  C-x r k            删除矩形区域
  C-x r c            将当前矩形区域清空

#【移动】
`C-n`   向前移动一行
`C-p`   向后移动一行
C-v     向前移动一屏
M-v     向后移动一屏
C-l     重绘屏幕，并将光标所在行置于屏幕的中央 （注意是 CONTROL-L，不是 CONTROL-1）

用命令名扩展的命令通常并不常用，或只用在部分模式下。比如 replace-string （字符串替换）这个命令，它会在全文范围内把一个字符串替换成另一个。在输 入 M-x 之后，Emacs 会在屏幕底端向你询问并等待你输入命令名。如果你想输入 “replace-string”，其实只需要敲“repl s<TAB>”就行了，Emacs 会帮你自动 补齐。输入完之后按 <Return> 。
 【windows】
`C-x 2' (`split-window-below')  把当前的窗口分割成上下两个。
`C-x 3' (`split-window-right')   把当前窗口分割成左右两个。
`C-M-v'
     Scroll the next window (`scroll-other-window').

输入 C-x o（“o”指的是“其它（other）”），
   将光标转移到下方的窗格。

(add-to-list 'auto-mode-alist '()) 用来关联某种特定的文件和mode.  如rails中的scss

【auto completion】
auto-complete和yasnippet是Emacs下两款非常强悍的补全插件，那么auto-complete和yasnippet是否就是一对竞争者呢？有你没我，有我没你？
请看 http://emacser.com/auto-complete_yasnippet.htm

auto complete demo 
http://cx4a.org/software/auto-complete/demo.html

学会看文档
Emacs的文档非常丰富, 有Elisp自己的自文档, 还有更详细的info. Elisp中的变量, 函数都有文档. 对于大多数情况都够用了.

查看变量的值和文档
C-h v (describe-variable)

C-h f (describe-function)  查看函数的文档

查看face的文档
M-x describe-face

C-h m (describe-mode) 查看某个mode的文档。从我看来是“查看当前的mode信息”
刚开始学习某个mode的时候, 可以用C-h m看看当前buffer对应的主mode和副mode的文档, 这个文档一般都会包括mode中的命令和快捷键列表.

C-h k (describe-key) 查看某个快捷键对应的命令

C-h w (where-is)  查看某个命令对应的快捷键

C-h b (describe-bindings)  查看当前buffer所有的快捷键列表
查看当前buffer中以某个快捷键序列开头的快捷键列表

<待查看的快捷键序列> C-h，比如你想查看当前buffer中所有以C-c开头的快捷键列表，按C-c C-h就可以了。

find-function 查看函数的代码

find-variable 查看变量的代码

find-face-definition 查看face的代码
M-x apropos  查看包含某个关键词的函数,变量,face

会些简单的配置
执行Elisp代码
在某条语句后面按C-x C-e (eval-last-sexp)可以执行那条语句
M-x eval-buffer 可以执行当前buffer内的Elisp代
选中一个region后, M-x eval-region可以执行这个region内的代码

C-x k   kill current buffer
M-x ispell      use ispell to do spell check.

M-x cedet-version   查看cedet的版本
M-m   (back-to-indentation)   move cursor to the first word in the line.

;; Replace every occurrence of STRING with NEWSTRING.
`M-x replace-string <RET> STRING <RET> NEWSTRING <RET>'

Show current load path:
‘C-h v load-path RET’ 
First, check the value of your ‘load-path’ by asking for help on the variable: ‘C-h v load-path RET’ should give you the documentation for the variable and its current value. If your directory is not listed, you must add it (see above).

M-x shell      Open a interactive inferior shell.

M-g-g   Go to line.
C-h r  Read the emacs manual.

;;Edit remote file
/USER@HOST:FILENAME

【让Speedbar支持Go语言】
To enable Go in the Speedbar:
Go to: Options → Customize Emacs → Specific Option...
Choose: speedbar-supported-extension-expressions
Add extension: .go
Click on: State → Save for Future Sessions
To start the Speedbar:
Alt-X speedbar Enter
The following makes outline mode easy to use generally, not just when editing Go. You may have to install outline-magic separately.

;; Show/hide parts by repeated pressing f10
(add-hook 'outline-minor-mode-hook
           (lambda ()
             (require 'outline-magic)
             (define-key outline-minor-mode-map [(f10)] 'outline-cycle)))

## Set default font

Chose the menu 〖Options ▸ Set Default Font…〗, then 〖Options ▸ Save Options〗.

Or:

```lisp
;; set a default font
(when (member "DejaVu Sans Mono" (font-family-list))
  (set-face-attribute 'default nil :font "DejaVu Sans Mono"))
```

## Access menu in terminal mode

press F10

# BackupDirectory

https://www.emacswiki.org/emacs/BackupDirectory

## emacs lisp 学习

Alternatively, you can call ielm. It will start a interactive elisp command line interface.

http://ergoemacs.org/emacs/elisp.html
