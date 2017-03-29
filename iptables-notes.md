IPtables Notes
-----


`MASQUERADE`这个targe和`SNAT` 的区别在：`MASQUERADE`可以使用dhcp出来的IP， `SNAT`只能使用配置好的IP，`MASQUERADE`更灵活些。


## `Raw` table
这个表的主要作用是给包打个标识，让conntrack不能追踪它。

通过 `NOTRACK`这个target.


As we have already stated in this chapter, conntrack and the state machine is rather resource hungry. For this reason, it might sometimes be a good idea to turn off connection tracking and the state machine.

conntrack and the state machine 都相当消耗资源，所以有些时候关闭它能带来性能提升。

如果你的防火墙负载很大，你

