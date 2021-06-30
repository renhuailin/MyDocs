IPtables Notes
-----

## 1. 可视化分析工具

http://www.iptables.info/en/iptables-gui.html

http://jekor.com/gressgraph/

`MASQUERADE`这个targe和`SNAT` 的区别在：`MASQUERADE`可以使用dhcp出来的IP， `SNAT`只能使用配置好的IP，`MASQUERADE`更灵活些。

## `Raw` table

这个表的主要作用是给包打个标识，让conntrack不能追踪它。

通过 `NOTRACK`这个target.

As we have already stated in this chapter, conntrack and the state machine is rather resource hungry. For this reason, it might sometimes be a good idea to turn off connection tracking and the state machine.

conntrack and the state machine 都相当消耗资源，所以有些时候关闭它能带来性能提升。

如果你的防火墙负载很大，你

# 显示规则

```
$ iptables -L -n -v --line-number
```

删除input的第3条规则  

```
[root@linux ~]# iptables -D INPUT 3  
```

-A默认是插入到尾部的，可以-I来插入到指定位置

```
[root@linux ~]# iptables -I INPUT 3 -p tcp -m tcp --dport 20 -j ACCEPT
```

## Restore rules

```
$ iptables-restore < /root/working.iptables.rules
```

## 端口映射

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

我之前一直没想明白，当tomcat把回给nginx时，src=192.168.75.3,dest=192.168.75.5，这时的目的IP还不是client IP呢，我们为什么没在iptable加一条规则把dest改成client ip呢？后来研究了connect track，才明白。在我们第一条做nat时，kernel会再track table记录下来此连接的信息如client ip:31411 -> 192.168.75:8000,当收到tomcat的回包时，系统会根据track table的这条记录，做一次dnat,把nginx的IP换成client ip，这一步是系统做的，所以我们不用手工添加在iptable的规则里。

Iptables Tutorial 1.2.1 里讲到可以通过 cat `/proc/net/ip_conntrack` 来查询connection track的信息，这已经是过时的做法，现在通过`conntrack`这个命令来跟踪连接。

参考:

1. [iptables 添加，删除，查看，修改&laquo;海底苍鹰(tank)博客](http://blog.51yip.com/linux/1404.html)

2. https://www.systutorials.com/816/port-forwarding-using-iptables/

3. [How To Forward Ports through a Linux Gateway with Iptables | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-forward-ports-through-a-linux-gateway-with-iptables)

4. [网络地址转换NAT原理及应用-连接跟踪--端口转换](https://blog.csdn.net/tycoon1988/article/details/40782269)
