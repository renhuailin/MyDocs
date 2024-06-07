Mac的一些使用技巧

# 1. 使用技巧

## 1.1 快捷键 shortcuts

### 1.1.1 切换窗口
[apple + `]  在同一应用的不同windows

### 1.1.2录屏

`command + shift + 5`

# 2. 常用软件
## 2.1 iTerm2

有时候选中一些文本,不小心拖了一下,把这些文本当命令运行了,烦人. 禁用它

Turn on "Prefs > Advanced > To drag images or selected text, you must hold ⌘. This prevents accidental drags."

发现了一种在keychain中保存密码的方法。思路是用sshpass + SSH_ASKPASS ，可以用它来做一个类似xshell的东西了。：）。

https://superuser.com/a/394826

access keychain from command line: 

https://macromates.com/blog/2006/keychain-access-from-shell/

iTerm2 apple scripts.

https://www.iterm2.com/documentation-scripting.html

 NSOutlineView(TreeView) tutorial

https://www.raywenderlich.com/1201-nsoutlineview-on-macos-tutorial

如何直接下载xcode，app store里下载实在是太慢了。

[https://dev.to/jahirfiquitiva/direct-download-any-xcode-385o](https://dev.to/jahirfiquitiva/direct-download-any-xcode-385o)

## 2.2 TextMate

Build and install [Typescript Bundle for Textmate](https://www.chrisjmendez.com/2018/03/09/typescript-bundle-for-textmate/)

# 3 常用命令

## 3.1 查看商品占用

1. 输入命令 `lsof -i :端口号`，其中“端口号”是需要查看的端口号，例如要查看端口号为8080的情况，可以输入 `lsof -i :8080`。
2. 如果没有占用则无输出结果。
3. 也可以用netstat，不过不支持`p`这个选项。
```
netstat -anv|grep 80 |grep LIST
```