Linux Shell Tips and Tricks
------

# Shell Programming Note

`$#` 参数的个数.  ${$#}输出的就是最后一个参数。

`$*`是把参数当成一行来看的.

`$@` 是把参数当成数组来看的.  参考1，11章 Special Paramter Variables.


You may also see variables referenced using the format ${variable} . The extra braces
around the variable name are often used to help identify the variable name from the
dollar sign.

可以用$来引用一个变量，也可以用${}来引用变量，后一种方式是为了让变量名更明显。


`$[]` $加方括号是用来做算术计算的。

``` bash
$[1 + 5]
```

## Parameter Expansion
在阅读kubernetes的部署shell脚本时，看到一个expression,不明白是什么意思
``` bash
${1#*@}
```
输入的参数是`ubuntu@192.168.56.102`。
后来自己写了个脚本试了一下，原来输出的是后面的那个IP.
```
192.168.56.102
```
也是在这个部署脚本里，又有一个expression,我没看明白：
```bash
export SERVICE_CLUSTER_IP_RANGE=${SERVICE_CLUSTER_IP_RANGE:-192.168.3.0/24}
...
EXTRA_SANS=(
    IP:${MASTER_IP}
    IP:${SERVICE_CLUSTER_IP_RANGE%.*}.1
    DNS:kubernetes
    DNS:kubernetes.default
    DNS:kubernetes.default.svc
    DNS:kubernetes.default.svc.cluster.local
  )
```
`${SERVICE_CLUSTER_IP_RANGE%.*}.1`这是什么意思？     
参考文献1里也没有讲解，最后发现bash的manpage有详细的说明。

```
${parameter#word}
${parameter##word}
Remove matching prefix pattern. The word is expanded to produce a pattern just as in pathname expansion. If the pattern matches the beginning of the value of parameter, then the result of the expansion is the expanded value of parameter with the shortest matching pattern (the ''#'' case) or the longest matching pattern (the ''##'' case) deleted. If parameter is @ or *, the pattern removal operation is applied to each positional parameter in turn, and the expansion is the resultant list. If parameter is an array variable subscripted with @ or *, the pattern removal operation is applied to each member of the array in turn, and the expansion is the resultant list.
${parameter%word}
${parameter%%word}
Remove matching suffix pattern. The word is expanded to produce a pattern just as in pathname expansion. If the pattern matches a trailing portion of the expanded value of parameter, then the result of the expansion is the expanded value of parameter with the shortest matching pattern (the ''%'' case) or the longest matching pattern (the ''%%'' case) deleted. If parameter is @ or *, the pattern removal operation is applied to each positional parameter in turn, and the expansion is the resultant list. If parameter is an array variable subscripted with @ or *, the pattern removal operation is applied to each member of the array in turn, and the expansion is the resultant list.
```
先说第一个expression: `${1#*@}`,我们先看`#`右边的部分，这是个pattern,我们的输入是`ubuntu@192.168.56.102`,那么这个pattern match的是`@`和它前面的部分：`ubuntu@`。`#`前面的部分就是我们要match的字符串或变量，在这里是变量，参数1的内容。
**请注意**  pattern match的部分要从源字符串里删除掉，this expression的evaluation的结果是剩下的部分：192.168.56.102。

第二个expression：`${SERVICE_CLUSTER_IP_RANGE%.*}`，根据文档这是一个"Remove matching suffix pattern"。我们先看`%`右边的部分:`.*`,match圆点及其后面的所有内容。`SERVICE_CLUSTER_IP_RANGE`的内容是`192.168.3.0/24`,expression evaluation的结果是`192.168.3`.与上一个expression明显的不同是它是从后往前开始match的，而且不是greedy match，所以`.*`match了`.0/24`，把它从源字符串中删除，然后把剩下的部分做为求值结果返回了。`%%`就是`greedy mode`的了，文档里叫`longest matching pattern`。`${SERVICE_CLUSTER_IP_RANGE%%.*}`的求值结果是:`192`.









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

## dpkg -i安装无法自动安装依赖的问题
`dpkg -i` 安装的包有时会出现依赖没有安装上的问题，可以在运行完`dpkg -i` 后运行`apt-get -f install`来把相关的依赖安装上。


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

# fc-match
```
$ fc-match "Noto Sans CJK JP:style=Thin:lang=zh-cn"
```



# CIDR IP
这里有个网站用来转换这CIDR notation到普通的notation.
http://www.ipaddressguide.com/cidr

https://www.digitalocean.com/community/tutorials/understanding-ip-addresses-subnets-and-cidr-notation-for-networking


[create a bootable USB stick on ubuntu]
http://www.ubuntu.org.cn/download/desktop/create-a-usb-stick-on-ubuntu

# 参考文档
1. 《Linux command line and shell scripting bible》
