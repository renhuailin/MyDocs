Linux Shell Tips and Tricks
------

# Shell Programming Note

`$#` 是把参数当成一行来看的.

`$@` 是把参数当成数组来看的.  参考1，11章 Special Paramter Variables.


You may also see variables referenced using the format ${variable} . The extra braces
around the variable name are often used to help identify the variable name from the
dollar sign.

可以用$来引用一个变量，也可以用${}来引用变量，后一种方式是为了让变量名更明显。


`$[]` $加方括号是用来做算术计算的。 

``` bash
$[1 + 5]
```

()　圆括号是用来生成数组的。

``` bash
$ mytest=(one two three four five)
```

`$()` :`$`  + 圆括号用来redirect命令行的输出的。跟backtick的作用是一样的。因为ksh93 shell中不能用backtick。　　参考文档1，22章 The Korn Shell


`;;`  只用在`case`中，相当于`break`.




## 生成随机密码

```
$ openssl rand -hex 10
```

## ubuntu 14.04下查看dns
```
$ nm-tool
```

## ubuntu 14.04禁用dnsmasq
```sh
$ sudo gedit /etc/NetworkManager/NetworkManager.conf
# Comment out the “dns=dnsmasq” line by putting a hash “#” in front it.

$ sudo service network-manager restart
```

## 让ls命令显示长日期
ls 默认是短日期格式，对中国人太不友好了。
```
$ ll
drwxr-xr-x  8 git  git  4096 Apr 22  2014 ./
drwxr-xr-x  5 root root 4096 Nov 15  2013 ../
-rw-------  1 git  git     4 Nov 14  2013 .bash_history
-rw-r--r--  1 git  git   220 Nov 12  2013 .bash_logout
-rw-r--r--  1 git  git  3486 Nov 12  2013 .bashrc
drwxr-xr-x  3 git  git  4096 Nov 12  2013 .gem/
-rw-r--r--  1 git  git    73 Nov 12  2013 .gitconfig
drwxr-xr-x 17 git  git  4096 Apr  9 11:44 gitlab/
drwxr-xr-x 13 git  git  4096 Jan 23 17:53 gitlab-satellites/
drwxr-xr-x  8 git  git  4096 Apr  9 06:52 gitlab-shell/
-rw-------  1 git  git     0 Nov 12  2013 .mysql_history
-rw-r--r--  1 git  git   675 Nov 12  2013 .profile
drwxrws--- 19 git  git  4096 Jan 29 16:42 repositories/
drwx------  2 git  git  4096 Nov 12  2013 .ssh/
-rw-------  1 git  git  3100 Apr 22  2014 .viminfo

```

方法一：   
```
alias ll='ls -lh --time-style long-iso'
```

方法二：   
``` bash
export TIME_STYLE=long-iso
```

# 参考文档
1. 《Linux command line and shell scripting bible》