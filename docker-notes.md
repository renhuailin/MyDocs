Docker notes
-------------

docker在使用中，网络问题是比较大的，提供的几种网络模型各有优缺，
bridge 方式： 有mac地址变更，ip地址等问题。

 -p -P来映射port, 在container内部是用iptables来实现的，最多只能处理65535个连接。在大网站里这是不可能接受的。



host:方式，会有端口冲突。但是可以通过上层的编排系统来解决。是新浪目前使用的方式。



InfoQ的视频[Docker与OpenStack](http://www.infoq.com/cn/presentations/docker-and-openstack?utm_campaign=infoq_content&utm_source=infoq&utm_medium=feed&utm_term=global)


docker可以与openstack结合，分别是以Nova的driver和heat的plugin方式。

Magnum是OpenStack的新项目，也就是Container as a Service.


进入容器的bash

可以用docker attach,但是docker attach是共享窗口的。
docker version > 1.3，我们还可以使用
```
# docker exec -it <container id or name> bash
```

左耳说vlan能真正解决docker的网络问题。还说已经有了IPVLAN的驱动。   
[Docker基础技术：Linux Namespace（下）](http://coolshell.cn/articles/17029.html)


# Docker性能问题
IO性能不是很好是因为AUFS,网络模式最好是host．
可以通过Volume来挂载的方式来绕过AUFS.


# Mesos VS Kubernates
根据sof这篇文章　[http://stackoverflow.com/a/28725899](http://stackoverflow.com/a/28725899)　来看mesos更成熟．




