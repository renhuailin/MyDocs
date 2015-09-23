OpenStack备注
----



http://niusmallnan.github.io/_build/html/index.html
包含如下文章：


巧用flavor metadata决定虚机的宿主机  
openstack中的协程  
openstack学习指南  
neutron SDN的实现
Nova中VIF的实现
Nova实现虚拟机冷迁移
openstack中的metadata server
虚拟机数据流  
ceilometer的数据采集机制
ceilometer的API使用
虚拟机的快照
实现虚拟机ROOT密码注入
KVM虚拟机IO性能调优  
提升虚机创建后的启动速度
健康检查与自动化测试


```
To enable the libvirt memory.usage supporting, you need libvirt version 1.1.1+, qemu version 1.5+, and you need to prepare suitable balloon driver in the image, particularly for Windows guests, most modern Linuxes have it built in. The memory.usage meters can’t be fetched without image balloon driver.
```


这里是Ceilometer的一些查询示例
http://docs.openstack.org/developer/ceilometer/webapi/v2.html#api-queries


获得auth id.
``` json
{
    "auth": {
        "tenantName": "demo",
        "passwordCredentials": {
            "username": "demo",
            "password": "secretsecret"
        }
    }
}

```


# 修改Ubuntu镜像的默认用户的密码
Ubuntu官方提供的[OpenStack镜像](http://docs.openstack.org/image-guide/content/ch_obtaining_images.html)是用Key来登录的，太麻烦，可以改成用密码来登录。

修改image的工具叫：`guestfish`。

Ubuntu 14.04下安装:

```
# apt-get install libguestfs-tools
```

用它来打开一个镜像

```
# guestfish --rw -a trusty-server-cloudimg-amd64-disk1.img
```
guestfish的命令行提示符是`><fs>`。


你需要先运行这个镜像
```
><fs> run
```

如果这一步报错：  
```
libguestfs: error: /usr/bin/supermin-helper exited with error status 1.
To see full error messages you may need to enable debugging.
See http://libguestfs.org/guestfs-faq.1.html#debugging-libguestfs
```

则请退出guestfish,然后运行下面的命令。
```
# update-guestfs-appliance
```

更新完后再重新进入镜像。


列出所有的文件系统
```
><fs> list-filesystems
/dev/sda1: ext4
```

挂载到根目录
```
><fs> mount /dev/sda1 /
```
编辑文件`/etc/cloud/cloud.cfg`，因为我们要修改默认用户ubuntu的密码，所以，很简单加入下面的内容就行了。

```
/#cloud-config
password: openstack
chpasswd: { expire: False }
ssh_pwauth: True
```

退出后，把这个镜像加到OpenStack里就行了。

参考：
[http://docs.openstack.org/image-guide/content/ch_modifying_images.html](http://docs.openstack.org/image-guide/content/ch_modifying_images.html)

[https://ask.openstack.org/en/question/5531/defining-default-user-password-for-ubuntu-cloud-image/](https://ask.openstack.org/en/question/5531/defining-default-user-password-for-ubuntu-cloud-image/)

For other options in cloud.cfg file: http://bazaar.launchpad.net/~cloud-init-dev/cloud-init/trunk/view/head:/doc/examples/cloud-config.txt
