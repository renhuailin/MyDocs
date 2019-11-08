Alpine-Notes
------------

包管理工具

https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management

libgmp-dev

使用国内的源

https://mirrors.ustc.edu.cn/alpine/



目前Docker镜像越来越倾向于使用Alpine系统作为基础的系统镜像，Docker Hub 官方制作的镜像都在逐步支持Alpine系统。

**下面的修改以 Alpine 3.4 为例：**

```
# 备份原始文件cp /etc/apk/repositories /etc/apk/repositories.bak
# 修改为国内镜像源
$ echo "http://mirrors.aliyun.com/alpine/v3.7/main/" > /etc/apk/repositories
$ apk update
```

####Setup timezone

```
# echo "http://mirrors.aliyun.com/alpine/v3.7/main/" > /etc/apk/repositories
# apk update
# apk add tzdata
# cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# echo "Asia/Shangha" >  /etc/timezone
```

删除一个包

```
$ apk del openssh
```

Install `telnet`

```
$ apk add busybox-extras
```


