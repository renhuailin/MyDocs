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