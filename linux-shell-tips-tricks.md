Linux Shell Tips and Tricks
------

## 生成随机密码

```
$ openssl rand -hex 10
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