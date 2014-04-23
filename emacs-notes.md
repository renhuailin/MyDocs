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
## emacs lisp 学习
Alternatively, you can call ielm. It will start a interactive elisp command line interface.

http://ergoemacs.org/emacs/elisp.html
