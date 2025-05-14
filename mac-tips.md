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

## 3.1 查看端口占用

1. 输入命令 `lsof -i :端口号`，其中“端口号”是需要查看的端口号，例如要查看端口号为8080的情况，可以输入 `lsof -i :8080`。
2. 如果没有占用则无输出结果。
3. 也可以用netstat，不过不支持`p`这个选项。
```
netstat -anv|grep 80 |grep LIST
```


## 3.2  创建带密码的压缩文件

```
zip -e archivename.zip filetoprotect.txt
```

# 4 Homebrew

```bash

# List all installed formulae.
brew list
```

### install
```
brew install mysql-client
```


### search formulae

```
brew search node@22
```


### 查看配置
```
brew config
```


### Display formula’s name and one-line description. The cache is created on the first search, making that search slower than subsequent ones.
```
brew desc node@20
```


### Display brief statistics for your Homebrew installation. If a _`formula`_ or _`cask`_ is provided, show summary of information about it.
```
brew info node@20
```

### `uninstall`, `remove`, `rm` [_`options`_] _`installed_formula`_|_`installed_cask`_ […]
Uninstall a _`formula`_ or _`cask`_.
```
brew uninstall
brew remove
brew rm
```


### `upgrade` [_options_]     [_installed_formula_|_installed_cask_ …]
Upgrade outdated casks and outdated, unpinned formulae using the same options they were originally installed with, plus any appended brew formula options. If _`cask`_ or _`formula`_ are specified, upgrade only the given _`cask`_ or _`formula`_ kegs (unless they are pinned; see `pin`, `unpin`).

Unless `$HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK` is set, `brew upgrade` or `brew reinstall` will be run for outdated dependents and dependents with broken linkage, respectively.

Unless `$HOMEBREW_NO_INSTALL_CLEANUP` is set, `brew cleanup` will then be run for the upgraded formulae or, every 30 days, for all formulae.

### `outdated` [_`options`_] [_`formula`_|_`cask`_ …]

List installed casks and formulae that have an updated version available. By default, version information is displayed in interactive shells and suppressed otherwise.


### `link`, `ln` [_`options`_] _`installed_formula`_ […]

Symlink all of _`formula`_’s installed files into Homebrew’s prefix. This is done automatically when you install formulae but can be useful for manual installations.

```
brew link node@22
```
