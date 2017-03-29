Linux Shell Tips and Tricks
------


# bash or dash 
Ubuntu 6.10 开始用 dash 做为 /bin/sh，而不是bash.  所以，如果脚本是以`#! /bin/sh` 开头的要注意了。可能会出现有些命令不能用的情况。
所以还是以`#! /bin/bash`


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

``` bash
$ mytest=(one two three four five)
```

`$()` :`$`  + 圆括号用来redirect命令行的输出的。跟backtick的作用是一样的。因为ksh93 shell中不能用backtick。　　参考文档1，22章 The Korn Shell


`;;`  只用在`case`中，相当于`break`.

## 
Absolute path this script is in.
``` bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
```

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


# SSH
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

# tmux

列出了tmux的几个基本模块之后，就要来点实实在在的干货了，和screen默认激活控制台的Ctrl+a不同，tmux默认的是Ctrl+b，使用快捷键之后就可以执行一些相应的指令了。当然如果你不习惯使用Ctrl+b，也可以在~/.tmux文件中加入以下内容把快捷键变为Ctrl+a：

`Set prefix key to Ctrl-a`
unbind-key C-b
set-option -g prefix C-a
以下所有的操作都是激活控制台之后，即键入Ctrl+b前提下才可以使用的命令【这里假设快捷键没改，改了的话则用Ctrl+b】。

基本操作：

?	列出所有快捷键；按q返回
d	脱离当前会话,可暂时返回Shell界面，输入tmux attach能够重新进入之前会话
s	选择并切换会话；在同时开启了多个会话时使用
D	选择要脱离的会话；在同时开启了多个会话时使用
:	进入命令行模式；此时可输入支持的命令，例如kill-server所有tmux会话
[	复制模式，光标移动到复制内容位置，空格键开始，方向键选择复制，回车确认，q/Esc退出
]	进入粘贴模式，粘贴之前复制的内容，按q/Esc退出
~	列出提示信息缓存；其中包含了之前tmux返回的各种提示信息
t	显示当前的时间
Ctrl+z	挂起当前会话
窗口操作:

c	创建新窗口
&	关闭当前窗口
数字键	切换到指定窗口
p	切换至上一窗口
n	切换至下一窗口
l	前后窗口间互相切换
w	通过窗口列表切换窗口
,	重命名当前窗口，便于识别
.	修改当前窗口编号，相当于重新排序
f	在所有窗口中查找关键词，便于窗口多了切换
面板操作:

“	将当前面板上下分屏
%	将当前面板左右分屏
x	关闭当前分屏
!	将当前面板置于新窗口,即新建一个窗口,其中仅包含当前面板
Ctrl+方向键	以1个单元格为单位移动边缘以调整当前面板大小
Alt+方向键	以5个单元格为单位移动边缘以调整当前面板大小
空格键	可以在默认面板布局中切换，试试就知道了
q	显示面板编号
o	选择当前窗口中下一个面板
方向键	移动光标选择对应面板
{	向前置换当前面板
}	向后置换当前面板
Alt+o	逆时针旋转当前窗口的面板
Ctrl+o	顺时针旋转当前窗口的面板
z	tmux 1.8新特性，最大化当前所在面板

tmux a 或 tmux attach.

# 生成自定义的证书
一条命令就行了。
$ openssl req \
       -newkey rsa:2048 -nodes -keyout domain.key \
       -x509 -days 365 -out domain.crt

请参考：
http://www.ruanyifeng.com/blog/2014/09/illustration-ssl.html
http://www.ruanyifeng.com/blog/2011/08/what_is_a_digital_signature.html


# command-not-found包
debian 安装这个包，可以实现Ubuntu那样的，命令不存在时提示可以哪个包里找到这个命令的功能。
$ sudo apt-get install command-not-found

# Ubuntu 14.04打开crontab日志

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



# 命令行下的多线程下载工具 aria2c
```
# aria2c -x5  http://23.106.147.145/ubuntu-source-registry-ocata.tar.gz
```
文档： https://aria2.github.io/

# IPMI

# 翻墙
shadowsocks + privoxy  
网上推荐的什么polipo 根本不好使！还是privoxy好使。

# systemd 
systemctl list-unit-files | grep enabled will list all enabled ones.

If you want which ones are currently running, you need systemctl | grep running


# letsencrypt.org
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
	#	proxy_pass http://127.0.0.1:8080;
	#}

	#error_page 404 /404.html;

	# redirect server error pages to the static page /50x.html
	#
	#error_page 500 502 503 504 /50x.html;
	#location = /50x.html {
	#	root /usr/share/nginx/html;
	#}

	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	#location ~ \.php$ {
	#	fastcgi_split_path_info ^(.+\.php)(/.+)$;
	#	# NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
	#
	#	# With php5-cgi alone:
	#	fastcgi_pass 127.0.0.1:9000;
	#	# With php5-fpm:
	#	fastcgi_pass unix:/var/run/php5-fpm.sock;
	#	fastcgi_index index.php;
	#	include fastcgi_params;
	#}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
}
```

```
./certbot-auto certonly -a webroot --webroot-path=/usr/share/nginx/html -d registry.xiangcloud.com.cn
```

请见参考文档[2]




# 参考文档
1. 《Linux command line and shell scripting bible》
2. [How To Secure Nginx with Let's Encrypt on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-14-04)
3. [How to speed up X11 forwarding in SSH](http://xmodulo.com/how-to-speed-up-x11-forwarding-in-ssh.html)