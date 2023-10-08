Linux Notes
------

# bash or dash

Ubuntu 6.10 开始用 dash 做为 /bin/sh，而不是bash.  所以，如果脚本是以`#! /bin/sh` 开头的要注意了。可能会出现有些命令不能用的情况。
所以还是以`#! /bin/bash` 

# Shell Programming Note

## initialize variable when not set

```bash
FOO=${VARIABLE:-default} 
```

`$#` 参数的个数.  

`${$#}`输出的就是最后一个参数。

`$*`是把参数当成一行来看的.

`$@` 是把参数当成数组来看的.  参考1，11章 Special Paramter Variables.

You may also see variables referenced using the format ${variable} . The extra braces
around the variable name are often used to help identify the variable name from the
dollar sign.

可以用$来引用一个变量，也可以用${}来引用变量，后一种方式是为了让变量名更明显。

`$[]` $加方括号是用来做算术计算的。

```bash
$[1 + 5]
```

## Bash Shell Find Out If a Variable Is Empty Or Not

Let us see syntax and examples in details. The syntax is as follows for if command:

```bash
`if [ -z "$var" ] then       echo "\$var is empty" else       echo "\$var is NOT empty" fi`
```

## Parameter Expansion

在阅读kubernetes的部署shell脚本时，看到一个expression,不明白是什么意思

```bash
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

### Trim whitespaces with parameter expansion

  我们可以用parameter expansion来trim whitespaces in a string.

```bash
var="    abc    "
# remove leading whitespace characters
var="${var#"${var%%[![:space:]]*}"}"
# remove trailing whitespace characters
var="${var%"${var##*[![:space:]]}"}"   
printf '%s' "===$var==="

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}
```

## Arrays

把数组转成逗号分隔的字符串

```bash
EXTRA_SANS=(
    IP:${MASTER_IP}
    IP:${SERVICE_CLUSTER_IP_RANGE%.*}.1
    DNS:kubernetes
    DNS:kubernetes.default
    DNS:kubernetes.default.svc
    DNS:kubernetes.default.svc.cluster.local
)

echo $(echo "${EXTRA_SANS[@]}" | tr ' ' ,)
```

根据bash manpage的说明，

```
 If the word is double-quoted, ${name[*]} expands to a single word with the value of each array member separated by the first character of the IFS special variable, and ${name[@]} expands each element of name to a separate word.
```

`${name[*]}`展开成一个word,`${name[@]}`把每个元素展开成一个word.

()　圆括号是用来生成数组的。

```bash
$ mytest=(one two three four five)
```

`$()` :`$`  + 圆括号用来redirect命令行的输出的。跟backtick的作用是一样的。因为ksh93 shell中不能用backtick。　　参考文档1，22章 The Korn Shell

`;;`  只用在`case`中，相当于`break`.

```bash
/bin/cat << EOF | /usr/bin/osascript
#!/usr/bin/osascrip
tell application "iTerm"
    set cmd to "/Users/harley/.pyenv/shims/python3 /Users/harley/Documents/Workspace/python/python-scripts/expect-ssh.py -s 10.218.128.38 -u ubuntu"
    tell current window
        create tab with default profile command cmd
    end tell
    activate
end tell
EOF
```

### cat 多行文本到一个文件

```
$ cat > "$FILE" <<EOM
Line 1.
Line 2.
EOM
```

### iterate files in folder

```bash
for file in Data/*.txt; do
    [ -e "$file" ] || continue
    # ... rest of the loop body
done
```

```bash
for filename in $(find /Data/*.txt 2> /dev/null); do
    for ((i=0; i<=3; i++)); do
        ./MyProgram.exe "$filename" "Logs/$(basename "$filename" .txt)_Log$i.txt"
    done
done
```

### iterate lines in a file.

```bash
for id in $(cat ./unused-containers.txt);do
    docker rm $id
done
```

### 批量删除k8s jobs

```bash
for job in $(kubectl get job|grep gitlab-confluence-backup-cronjob|awk {'print $1'});do
    kubectl delete job $job
done
```

## sed

```
# 替换文件的内容
$ sed -i 's/deb.debian.org/mirrors.163.com/g' /etc/apt/sources.list 
```

## 用uniq去重

```
# You might want to look at the uniq and sort applications.

$ ./yourscript.ksh | sort | uniq
(FYI, yes, the sort is necessary in this command line, uniq only strips duplicate lines that are immediately after each other)
```

## print pid

```bash
pid=`aux|grep java|grep wechat|awk {'print $2'}`

if [ -z "$pid" ]
then
    echo "\$pid is empty"
else
    #echo "\$pid is NOT empty"
    kill $pid
    sleep 2
fi
```

## Script Path

Absolute path this script is in.

```bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
```

## 生成随机密码

```
$ openssl rand -hex 10
```

## Base64 encode and decode

encode 

```
$ echo -n 'admin' | base64
```

`-n`  means `Do not print the trailing newline character.`

decode 

```
echo 'MWYyZDFlMmU2N2Rm' | base64 --decode
```

## Cent OS监控网卡流量

```
$ sudo yum install iptraf
$ sudo iptraf-ng
```

## How to Install Iptables on CentOS 7

[https://linuxize.com/post/how-to-install-iptables-on-centos-7/](https://linuxize.com/post/how-to-install-iptables-on-centos-7/)

查看端口情况，除了`netstat -anpl` 还可以使用下面的命令

```
 ss -nlp | grep <port_number> 
```

### HPing3

在一些环境下是禁用ICMP协议的，这时可以使用`hping3`来代替`ping`。

```
$ sudo hping3 -S -p 22 10.224.40.240
```

其中的`-S`是TCP sync的选项。

请参考 ：   http://man.linuxde.net/hping3

## 安装指定版本的包

有时候我们不希望安装最近版的某个软件，如docker,我可能希望安装特定版本的。      
我需要先用下面的命令列出源里所有的docker版本

```
$ apt-cache policy docker-engine
$ apt-cache madison docker-ce
```

然后安装指定版本的docker.

```
$ apt-get install docker-engine=1.12.6-0~ubuntu-xenial
```

## dpkg -i安装无法自动安装依赖的问题

`dpkg -i` 安装的包有时会出现依赖没有安装上的问题，可以在运行完`dpkg -i` 后运行`apt-get -f install`来把相关的依赖安装上。

## IP地址反查

$ dig -x 8.8.8.8 +short
大多数的邮件服务器会查询 PTR record of an IP address it receives email from. 如果没有查询到 PTR record ，可能会把邮件当做垃圾邮件。

# ethtool 查看本地网卡情况

```
# ethtool bond0
Settings for bond0:
    Supported ports: [ ]
    Supported link modes:   Not reported
    Supported pause frame use: No
    Supports auto-negotiation: No
    Advertised link modes:  Not reported
    Advertised pause frame use: No
    Advertised auto-negotiation: No
    Speed: 2000Mb/s
    Duplex: Full
    Port: Other
    PHYAD: 0
    Transceiver: internal
    Auto-negotiation: off
    Link detected: yes
```

## 统计当目录下的所有目录的大小

```
$ du -d 1 -h
```

# 查看配置文件

有时我们想查看一个配置文件,但是想过滤掉注释,可以这样:

```
$ grep -v '^$\|^\s*\#'   pdns.conf
```

## grep命令

```
#显示搜索结果前后5行
$ cat test.txt|grep -C 5 hello

#显示搜索结果后5行
$ cat test.txt|grep -A 5 hello
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

```bash
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

# SSH


用密钥登录
```
$ ssh-copy-id -i key_file user@host
```


ssh client如果长时间不向服务器发数据，连接就会断开，如：

```
packet_write_wait: Connection to xxx.xxx.xx.xxx: Broken pipe
```

如果频繁的断开连接影响了你的工作，你可以client端设置`ServerAliveInterval 60`，这个值的意思是每隔60秒，向服务器发一个KeepAlive包，用以保持连接。

```
$ sudo vi /etc/ssh/ssh_config
```

Add this line.

```
ServerAliveInterval 60
```

echo "harley ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

## ssh x11 forward

加速它

```
$ ssh -XC -c blowfish-cbc,arcfour xmodulo@remote_host.com
```

请参考文献【3】

## 远程和本地端口的映射(转发)

### 把远程主机的某个端口映射到本地

`ssh -L <local port>:<remote host>:<remote port> <SSH hostname>`

```
ssh -L 1521:9.111.121.223:1521 root@9.111.121.223
```

### 把本地的某个端口映射到远程主机

`ssh -R <remote port>:<localhost or local IP>:<local port> <SSH hostname>`

```
ssh -i ~/.ssh/<your_ssh_key> -R 8000:127.0.0.1:8000 ubuntu@132.226.6.25
```

**Note:**

这样映射的端口只能listen在 127.0.0.1，所以需要通过nginx反向代理才能访问。

这样做会一直开着一个terminal，如果这个terminal挂了，这个连接就断了，根据[这篇blog](https://mpharrigan.com/2016/05/17/background-ssh.html) ,我们可以添加上参数 `-fNT`, 让这个ssh运行在后台，Now you can't ever close the connection!

# tmux

列出了tmux的几个基本模块之后，就要来点实实在在的干货了，和screen默认激活控制台的Ctrl+a不同，tmux默认的是Ctrl+b，使用快捷键之后就可以执行一些相应的指令了。当然如果你不习惯使用Ctrl+b，也可以在~/.tmux文件中加入以下内容把快捷键变为Ctrl+a：
```
`Set prefix key to Ctrl-a`
unbind-key C-b
set-option -g prefix C-a
以下所有的操作都是激活控制台之后，即键入Ctrl+b前提下才可以使用的命令【这里假设快捷键没改，改了的话则用Ctrl+b】。

基本操作：

?    列出所有快捷键；按q返回
d    脱离当前会话,可暂时返回Shell界面，输入tmux attach能够重新进入之前会话
s    选择并切换会话；在同时开启了多个会话时使用
D    选择要脱离的会话；在同时开启了多个会话时使用
:    进入命令行模式；此时可输入支持的命令，例如kill-server所有tmux会话
[    复制模式，光标移动到复制内容位置，空格键开始，方向键选择复制，回车确认，q/Esc退出
]    进入粘贴模式，粘贴之前复制的内容，按q/Esc退出
~    列出提示信息缓存；其中包含了之前tmux返回的各种提示信息
t    显示当前的时间
Ctrl+z    挂起当前会话
窗口操作:

c    创建新窗口
&    关闭当前窗口
数字键    切换到指定窗口
p    切换至上一窗口
n    切换至下一窗口
l    前后窗口间互相切换
w    通过窗口列表切换窗口
,    重命名当前窗口，便于识别
.    修改当前窗口编号，相当于重新排序
f    在所有窗口中查找关键词，便于窗口多了切换
面板操作:

“    将当前面板上下分屏
%    将当前面板左右分屏
x    关闭当前分屏
!    将当前面板置于新窗口,即新建一个窗口,其中仅包含当前面板
Ctrl+方向键    以1个单元格为单位移动边缘以调整当前面板大小
Alt+方向键    以5个单元格为单位移动边缘以调整当前面板大小
空格键    可以在默认面板布局中切换，试试就知道了
q    显示面板编号
o    选择当前窗口中下一个面板
方向键    移动光标选择对应面板
{    向前置换当前面板
}    向后置换当前面板
Alt+o    逆时针旋转当前窗口的面板
Ctrl+o    顺时针旋转当前窗口的面板
z    tmux 1.8新特性，最大化当前所在面板
```

tmux a 或 tmux attach.






```
$ tmux ls
```

## tmux 与 iTerm2 整合

```
$ tmux -CC
$ tmux -CC attach
```

# 生成自定义的证书

一条命令就行了。
$ openssl req \
​       -newkey rsa:2048 -nodes -keyout domain.key \
​       -x509 -days 365 -out domain.crt

请参考：
http://www.ruanyifeng.com/blog/2014/09/illustration-ssl.html
http://www.ruanyifeng.com/blog/2011/08/what_is_a_digital_signature.html

# 命令行下的多线程下载工具 aria2c

```
# aria2c -x5  http://23.106.147.145/ubuntu-source-registry-ocata.tar.gz
```

文档： https://aria2.github.io/

# IPMI

# 翻墙

shadowsocks + privoxy  
网上推荐的什么polipo 根本不好使！还是privoxy好使。

# Systemd

`systemctl list-unit-files | grep enabled` will list all enabled ones.

If you want which ones are currently running, you need `systemctl | grep running`

```
$ systemctl list-unit-files | grep enabled

$ sudo systemctl daemon-reload ; sudo systemctl start docker

$ systemctl show --property=FragmentPath docker

$ systemctl disable docker
```

FragmentPath=/usr/lib/systemd/system/docker.service

# letsencrypt.org

```
$ ./certbot-auto certonly -a webroot --webroot-path=/usr/share/nginx/html -d registry.xiangcloud.com.cn
```

我的域名用了reverse proxy,所以需要在nginx里配置特殊处理一下

```
upstream docker_private_registry {
    server 127.0.0.1:5000;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    listen 443 ssl;
    client_max_body_size 0;
    ssl_certificate /etc/letsencrypt/live/registry.xiangcloud.com.cn/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/registry.xiangcloud.com.cn/privkey.pem;

    root /usr/share/nginx/html;
    index index.html index.htm;

    # Make site accessible from http://localhost/
    server_name registry.xiangcloud.com.cn;
    location /.well-known {
        allow all;
        alias /usr/share/nginx/html/.well-known;
    }

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        #try_files $uri $uri/ =404;
        # Uncomment to enable naxsi on this location
        # include /etc/nginx/naxsi.rules
        proxy_pass  https://docker_private_registry;
         proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
         proxy_buffering off;
         proxy_set_header        Host            $host;
         proxy_set_header        X-Real-IP       $remote_addr;
         proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Only for nginx-naxsi used with nginx-naxsi-ui : process denied requests
    #location /RequestDenied {
    #    proxy_pass http://127.0.0.1:8080;
    #}

    #error_page 404 /404.html;

    # redirect server error pages to the static page /50x.html
    #
    #error_page 500 502 503 504 /50x.html;
    #location = /50x.html {
    #    root /usr/share/nginx/html;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    #    # NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
    #
    #    # With php5-cgi alone:
    #    fastcgi_pass 127.0.0.1:9000;
    #    # With php5-fpm:
    #    fastcgi_pass unix:/var/run/php5-fpm.sock;
    #    fastcgi_index index.php;
    #    include fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny all;
    #}
}
```

```
./certbot-auto certonly -a webroot --webroot-path=/usr/share/nginx/html -d registry.xiangcloud.com.cn
```

请见参考文档[2]

# iptables

显示规则

```
$ iptables -L -n -v --line-number
```

删除input的第3条规则  

```
[root@linux ~]# iptables -D INPUT 3  
```

-A默认是插入到尾部的，可以-I来插入到指定位置

下面的是打开20端口。

```bash
# iptables -I INPUT 3 -p tcp -m tcp --dport 20 -j ACCEPT


# 允许连接UDP 4000端口。
iptables -I INPUT 3 -p udp -m udp --dport 4000 -j ACCEPT
```

清除规则

```
$ sudo /sbin/iptables -P INPUT ACCEPT  #一定要先执行这个
$ sudo iptables -F
```

### iptables 端口映射

假设192.168.75.5是一个nginx，我们用它做网关，192.168.75.3是tomcat，运行着一个app.我们要把192.168.75.5:80的映射到192.168.75.3:8080上。

1. 需要先开启linux的数据转发功能

```
# vi /etc/sysctl.conf，将net.ipv4.ip_forward=0更改为net.ipv4.ip_forward=1
# sysctl -p  //使数据转发功能生效
```

2. 更改iptables，使之实现nat映射功能，请注意一定要是两条规则，一个请求包，一个是响应包。如果没有第二条规则，则会有问题的。

```bash
# 将外网访问nginx(192.168.75.5)的80端口转发到tomcat(192.168.75.3)的8000端口。
iptables -t nat -A PREROUTING -d 192.168.75.5 -p tcp --dport 80 -j DNAT --to-destination 192.168.75.3:8000
# 上面是根据包的目的IP，当然也可以根据网卡
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to 192.168.75.3:8080
# 要让包通过FORWARD链
iptables -A FORWARD -p tcp -d 192.168.75.3 --dport 8080 -j ACCEPT

# 在这一步只所以要做dnat,是因为，如果不做dnat,源IP将是一个外网的IP，不是一个合法连接了。所以这一步要将源ip改为nginx的192.168.75.5，让tomcat把包回到这儿。

iptables -t nat -A POSTROUTING -d 192.168.75.3 -p tcp --dport 8000 -j SNAT --to 192.168.75.5
```

我想我们只所以要打开ip forward，回包时，192.168.75.3:8080返回的包的在dest是请求的源IP，不是本机的IP，如果不打开ip forward，就无法实现转发。请见参考2和网卡的混杂模式。

我之前一直没想明白，当tomcat把回给nginx时，src=192.168.75.3,dest=192.168.75.5，这时的目的IP还不是client IP呢，我们为什么没在iptable加一条规则把dest改成client ip呢？后来研究了connect track，才明白。在我们第一条做nat时，kernel会再track table记录下来此连接的信息如client ip:31411 ->  192.168.75:8000,当收到tomcat的回包时，系统会根据track table的这条记录，做一次dnat,把nginx的IP换成client ip，这一步是系统做的，所以我们不用手工添加在iptable的规则里。

Iptables Tutorial 1.2.1  里讲到可以通过 cat  `/proc/net/ip_conntrack`  来查询connection track的信息，这已经是过时的做法，现在通过`conntrack`这个命令来跟踪连接。

参考: 

1. http://blog.51yip.com/linux/1404.html

2. https://www.systutorials.com/816/port-forwarding-using-iptables/ 

3. https://www.digitalocean.com/community/tutorials/how-to-forward-ports-through-a-linux-gateway-with-iptables

4. [网络地址转换NAT原理及应用-连接跟踪--端口转换](https://blog.csdn.net/tycoon1988/article/details/40782269)

# PowerDNS

用monitor mode启动.

```
# service pdns monitor
```

# 用wget来做压力测试

```shell
while true; do wget -q -O- http://9.112.190.95:32758/; done
```

# curl

```
-f, --fail
              (HTTP) Fail silently (no output at all) on server errors. This is mostly done to better enable scripts etc to better deal with failed attempts. In normal cases when an HTTP server fails to  deliver  a
              document, it returns an HTML document stating so (which often also describes why and more). This flag will prevent curl from outputting that and return error 22.

              This method is not fail-safe and there are occasions where non-successful response codes will slip through, especially when authentication is involved (response codes 401 and 407).

-S, --show-error
              When used with -s, --silent, it makes curl show an error message if it fails.

-s, --silent
              Silent or quiet mode. Don't show progress meter or error messages.  Makes Curl mute. It will still output the data you ask for, potentially even to the terminal/stdout unless you redirect it.

              Use -S, --show-error in addition to this option to disable progress meter but still show error messages.

              See also -v, --verbose and --stderr.
```

follow redirect.

```
$ curl -L http://www.google.com

```

通过-o/-O选项保存下载的文件到指定的文件中：
-o：将文件保存为命令行中指定的文件名的文件中
-O：使用URL中默认的文件名保存文件到本地

Add header 

```
$ curl -H "X-First-Name: Joe" http://example.com/

# Download a file.
$ curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar
```

`--create-dirs` 如果目录不存在就创建它。

```
$ curl -X GET \
'http://service-lv63z1gn-1256532032.ap-beijing.apigateway.myqcloud.com/release/internal/v1/violationQueryjh?appkey=2738501135&digitalSign=1&signTimestamp=1&nonce=1&plateNumber=%E5%90%89ALS105&vin=WAUACC8P0BA126688&engineNo=CDA195206' \
  -H 'Accept: */*' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Host: service-lv63z1gn-1256532032.ap-beijing.apigateway.myqcloud.com' \
  -H 'Postman-Token: d46789b5-ddec-4019-b801-140fa0611220,a0a2cab4-1cc0-4b7e-b7b8-21eb94445d1f' \
  -H 'User-Agent: PostmanRuntime/7.15.2' \
  -H 'cache-control: no-cache' \
  -H 'x-microservice-name: violation' \
  -H 'x-namespace-code: cdp-uat'
```

查询本地IP

```
$ curl cip.cc
```

# yum

```
$ yum list installed
```

[yum cheatsheet](https://access.redhat.com/sites/default/files/attachments/rh_yum_cheatsheet_1214_jcs_print-1.pdf)

看看哪个包包含ab

```
$ yum provides /usr/bin/ab
```

然后下载它：

```
$ yum install httpd-tools
```

查看某包安装了哪些文件，比如我经常忘记docker在centos下的配置文件在哪里，于是我先查看一下docker是由哪个rpm安装的。

```
$ rpm -qa|grep docker 
docker-ce-18.09.1-2.1.rc1.el7.x86_64
docker-ce-cli-18.09.1-2.1.rc1.el7.x86_64
```

然后看一下这个包安装哪些文件：

```
$ rpm -ql docker-ce-18.09.1-2.1.rc1.el7.x86_64
```

# Ubuntu

## Ubuntu 14.04

### 打开crontab日志

ubuntu 14.04默认是没有打开crontab的日志的，需要手动打开：

```
cd /etc/rsyslog.d/
sudo nano 50-default.conf
```

Uncoment line:

```
#cron.*                         /var/log/cron.log
```

Save file and restart rsyslog

```
sudo service rsyslog restart 
```

Restart your cron daemon for get it's messages from new file

```
sudo service cron restart
```

参考：[http://askubuntu.com/a/624785](http://askubuntu.com/a/624785)

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

# command-not-found包

debian 安装这个包，可以实现Ubuntu那样的，命令不存在时提示可以哪个包里找到这个命令的功能。

```
$ sudo apt-get install command-not-found
```

## 通用

### 设置timezone

```bash
$ timedatectl list-timezones
$ sudo timedatectl set-timezone Asia/Shanghai

# 直接 timedatectl可以查看是否配置了时间同步。
$ timedatectl
```

# Simple HTTP Server

```
$ python -m SimpleHTTPServer


$ python3 -m http.server 8080
```

# 什么是公钥、私钥和证书

请看[数字签名是什么](http://www.ruanyifeng.com/blog/2011/08/what_is_a_digital_signature.html)

http://www.youdzone.com/signature.html

几种证书的格式有什么区别？http://www.metsky.com/archives/598.html

采用的标准不同，生成的数字证书，包含内容也可能不同。

下面就证书包含/可能包含的内容做个汇总，一般证书特性有：

- 存储格式：二进制还是ASCII
- 是否包含公钥、私钥
- 包含一个还是多个证书
- 是否支持密码保护（针对当前证书）

其中：

- *.der/*.cer/*.crt 以**二进制形式存放证书，只有公钥，不包含私钥。**
- *.csr 证书请求
- *.pem 以Base64编码形式存放证书，以"-----BEGIN CERTIFICATE-----" and "-----END CERTIFICATE-----"封装，只有公钥。
- *.pfx/*.p12也是以二进制形式存放证书，包含公钥、私钥，包含保护密码。pfx和p12存储格式完全相同只是扩展名不同。
- *.p10 证书请求
- *.p7r CA对证书请求回复，一般做数字信封
- *.p7b/*.p7c 证书链，可包含一个或多个证书。

**理解关键点：**

- 凡是包含私钥的，一律必须添加密码保护（加密私钥），因为按照习惯，公钥是可以公开的，私钥必须保护，所以明码证书以及未加保护的证书都不可能包含私钥，只有公钥，不用加密。
- 上文描述中，*.der均表示证书且有签名，实际使用中，还有DER编码的私钥不用签名，实际上只是个“中间件”。

**另外：**

证书请求一般采用.csr扩展名，但是其格式有可能是PEM也可能是DER格式，但都代表证书请求，只有经过CA签发后才能得到真正的证书。

# Crontab

实例1：每1分钟执行一次myCommand

```
* * * * * myCommand
```

实例2：每小时的第3和第15分钟执行

```
3,15 * * * * myCommand
```

实例3：在上午8点到11点的第3和第15分钟执行

```
3,15 8-11 * * * myCommand
```

实例4：每隔两天的上午8点到11点的第3和第15分钟执行

```
3,15 8-11 */2  *  * myCommand
```

实例5：每周一上午8点到11点的第3和第15分钟执行

```
3,15 8-11 * * 1 myCommand
```

实例6：每晚的21:30重启smb

```
30 21 * * * /etc/init.d/smb restart
```

实例7：每月1、10、22日的4 : 45重启smb

```
45 4 1,10,22 * * /etc/init.d/smb restart
```

实例8：每周六、周日的1 : 10重启smb

```
10 1 * * 6,0 /etc/init.d/smb restart
```

实例9：每天18 : 00至23 : 00之间每隔30分钟重启smb

```
0,30 18-23 * * * /etc/init.d/smb restart
```

实例10：每星期六的晚上11 : 00 pm重启smb

```
0 23 * * 6 /etc/init.d/smb restart
```

实例11：每一小时重启smb

```
* */1 * * * /etc/init.d/smb restart
```

实例12：晚上11点到早上7点之间，每隔一小时重启smb

```
0 23-7 * * * /etc/init.d/smb restart
```

certbot现在用systemd timer做定时刷新证书

```
$ systemctl list-timers
```

# SSL 证书

openssl生成自签名的证书，网友在这篇文章里(<http://www.liaoxuefeng.com/article/0014189023237367e8d42829de24b6eaf893ca47df4fb5e000>)[[http://www.liaoxuefeng.com/article/0014189023237367e8d42829de24b6eaf893ca47df4fb5e000\]提供了一个sh](http://www.liaoxuefeng.com/article/0014189023237367e8d42829de24b6eaf893ca47df4fb5e000%5D%E6%8F%90%E4%BE%9B%E4%BA%86%E4%B8%80%E4%B8%AAsh)，可以自动生成一个自签名的证书

用keytool来查看证书的信息

```
$ keytool -list -v -alias server -keystore keystore_1.jks -storepass password | less
```

```
$ openssl x509 -text -noout -in trtjk.com.cer
```

https://docs.aws.amazon.com/zh_cn/elasticbeanstalk/latest/dg/configuring-https-ssl.html

## 导出PKCS12的格式证书

```
$ openssl pkcs12 -inkey trtjkserver.key -in trtjk.com.1.cer -export -out certificate.p12  -CAfile CA.cer -chain
```

报错：

```
Error unable to get issuer certificate getting chain.
```

参考这个URL: https://superuser.com/a/1143743

找台linux来做这件事。

```
$ openssl verify  allcacerts.crt
```

#用户管理

```
usermod -a -G sudo geek
usermod geek -G sudo
```

### Alpine

目前Docker镜像越来越倾向于使用Alpine系统作为基础的系统镜像，Docker Hub 官方制作的镜像都在逐步支持Alpine系统。

**下面的修改以 Alpine 3.4 为例：**

```
# 备份原始文件
cp /etc/apk/repositories /etc/apk/repositories.bak

# 修改为国内镜像源
echo "http://mirrors.aliyun.com/alpine/v3.7/main/" > /etc/apk/repositories


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

# Source 执行另外一个命令的输出bash

```
$ source <(kubectl completion zsh)
```

# 参考文档

1. 《Linux command line and shell scripting bible》

2. [How To Secure Nginx with Let's Encrypt on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-14-04)

3. [How to speed up X11 forwarding in SSH](http://xmodulo.com/how-to-speed-up-x11-forwarding-in-ssh.html)

4. [CURL常用命令](http://www.cnblogs.com/gbyukg/p/3326825.html)
