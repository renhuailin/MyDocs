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

# Neutron
Neutron DVR实现multi-host特性打通东西南北流量提前看 http://blog.csdn.net/quqi99/article/details/20711303


Introducing Linux Network Namespaces   http://blog.scottlowe.org/2013/09/04/introducing-linux-network-namespaces/  帮助理解Linux的网络namespaces和veth等。讲了很多跟`ip`这个命令有关的。

```
 As a result, you can use veth interfaces to connect a network namespace to the outside world via the “default” or “global” namespace where physical interfaces exist.
```

这是说default或global namespace是给物理网卡用的，veth可以连接你创建的namespace和`default或global`,这样你的namespace里的数据就可通过物理网卡出去了。
是不是只能通过veth来连接两个namespace?

```
ip link add veth0 type veth peer name veth1
```
I found a few sites that repeated this command to create veth1 and link it to veth0, but my tests showed that both interfaces were created and linked automatically using this command listed above. Naturally, you could substitute other names for veth0 and veth1, if you wanted.
有些网站


CSDN上的这篇blog: [network namespace与veth pair](http://blog.csdn.net/tycoon1988/article/details/39055149) 引用了上面的blog，并添加了新内容，如bridge的部分，docker的部分。

[ Linux Foundation DokuWiki : bridge](https://wiki.linuxfoundation.org/networking/bridge)
Linux bridge是通过Ethernet address(MAC地址？)来转发包的。它实现了 ANSI/IEEE 802.1d standard[1](http://standards.ieee.org/about/get/802/802.1.html) 的一个子集.

spanning tree protocol算法

  
`ip` 这个命令太强大了,网上的教程都没有把它讲解的太详细。 下面我收集了一些教程的地址。

http://www.cyberciti.biz/faq/linux-ip-command-examples-usage-syntax/       
https://www.zybuluo.com/ghostfn1/note/120631

这个页面讲解的算是比较详细的了。https://sites.google.com/site/linuxxuexi/system/app/pages/subPages?path=/wang-luo-an-quan 


### Test  OpenStack API with firefox RestClient
preflight :
add headers in RestClient:
```
Content-Type = application/json
Accept = */*
```

首先要获得token
http://192.168.30.211:5000/v3/auth/tokens
发送请求：
``` json
{
    "auth": {
        "scope": {
            "project": {
                "domain": {
                    "id": "default"
                },
                "name": "p_wsy@qq.com_1467178668"
            }
        },
        "identity": {
            "password": {
                "user": {
                    "domain": {
                        "id": "default"
                    },
                    "password": "916aaa8c-3dbb-11e6-9586-842b2bfac9e8Ww111111",
                    "name": "wsy@qq.com"
                }
            },
            "methods": [
                "password"
            ]
        }
    }
}

```
获得的response:


``` json


    {
        "token":
        {
            "methods":
            [
                "password"
            ],
            "roles":
            [
                {
                    "id": "8a593316ea2948f3afab82f23837b46b",
                    "name": "admin"
                }
            ],
            "expires_at": "2016-09-07T10:04:46.497379Z",
            "project":
            {
                "domain":
                {
                    "id": "default",
                    "name": "Default"
                },
                "id": "bfb53f3794f94932a05376c598854a5e",
                "name": "p_wsy@qq.com_1467178668"
            },
            "catalog":
            [
                {
                    "endpoints":
                    [
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:9292",
                            "region": "RegionOne",
                            "interface": "internal",
                            "id": "3f5a5cecaffc4823908e9026634afb1f"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:9292",
                            "region": "RegionOne",
                            "interface": "public",
                            "id": "e3d1666529b941a2a03a59112b467347"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:9292",
                            "region": "RegionOne",
                            "interface": "admin",
                            "id": "fcbba0dbfd7f424aaf5f985ce4da795c"
                        }
                    ],
                    "type": "image",
                    "id": "29ab6378ceb14a76a5c0c8c7ce23252b",
                    "name": "glance"
                },
                {
                    "endpoints":
                    [
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:5000/v2.0",
                            "region": "RegionOne",
                            "interface": "internal",
                            "id": "2210356af57845e28201601acd0b47be"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:5000/v2.0",
                            "region": "RegionOne",
                            "interface": "public",
                            "id": "9253f34c805c4791af4836f039f147bc"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:35357/v2.0",
                            "region": "RegionOne",
                            "interface": "admin",
                            "id": "98024be472fd4dac8d893781d93ffec9"
                        }
                    ],
                    "type": "identity",
                    "id": "348ad69fb53144239600e3d3e040dfbc",
                    "name": "keystone"
                },
                {
                    "endpoints":
                    [
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:8774/v2/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "admin",
                            "id": "8477117d207e48a1805fd329e26bcfd1"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:8774/v2/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "public",
                            "id": "a62ae15279144e5a8b2cf5447ceef87d"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:8774/v2/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "internal",
                            "id": "b6c9fb6e132142e8a840ea25289709ea"
                        }
                    ],
                    "type": "compute",
                    "id": "482d08e234814737b06efcfe08bcaf75",
                    "name": "nova"
                },
                {
                    "endpoints":
                    [
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:8776/v2/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "admin",
                            "id": "434794fe9c79484293c5802ff0acf794"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:8776/v2/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "public",
                            "id": "533dfcec2d744efa9136918f442fb001"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:8776/v2/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "internal",
                            "id": "ad5dbdf7fc4349408ae24ac5fb246d07"
                        }
                    ],
                    "type": "volume",
                    "id": "4e7bf0f0ac0647668e5ffbaf6b4227b1",
                    "name": "cinder"
                },
                {
                    "endpoints":
                    [
                        {
                            "region_id": "RegionOne",
                            "url": "http://controller02:6385",
                            "region": "RegionOne",
                            "interface": "public",
                            "id": "0e6c544dd0ac4aaf94e7cb3db9fc644f"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://controller02:6385",
                            "region": "RegionOne",
                            "interface": "admin",
                            "id": "74c91000e6794ede927fa6cc43b59465"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://controller02:6385",
                            "region": "RegionOne",
                            "interface": "internal",
                            "id": "848636cb860c46a2983a710636f429d9"
                        }
                    ],
                    "type": "baremetal",
                    "id": "56986a33c17f40d6886f235d62d69924",
                    "name": "ironic"
                },
                {
                    "endpoints":
                    [
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:9696",
                            "region": "RegionOne",
                            "interface": "admin",
                            "id": "5d20c1912a684edf9962be54ad3ca78b"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:9696",
                            "region": "RegionOne",
                            "interface": "public",
                            "id": "8bee621f5fbe4327b76da62c79aee03d"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:9696",
                            "region": "RegionOne",
                            "interface": "internal",
                            "id": "f62e5b5f91024dc397f8cff208211819"
                        }
                    ],
                    "type": "network",
                    "id": "79adcb6faaa44dc6b7244b16c0281bd9",
                    "name": "neutron"
                },
                {
                    "endpoints":
                    [
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.228:8786/v1/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "internal",
                            "id": "021d568588784ace9a0c70e383b7f714"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.228:8786/v1/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "admin",
                            "id": "851835d2e59c4d72ae329c35702d50ba"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.228:8786/v1/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "public",
                            "id": "fe1df6a5af464935aa8187b2470f2255"
                        }
                    ],
                    "type": "share",
                    "id": "7b5d58c35dc84642803565f9a9338683",
                    "name": "manila"
                },
                {
                    "endpoints":
                    [
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:8776/v2/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "admin",
                            "id": "18ab6b5a0ddf4badba05a37961865950"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:8776/v2/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "internal",
                            "id": "482dd0fd3ebb41a19dbebe0c20a489d6"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.211:8776/v2/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "public",
                            "id": "be2f78be19224d8487160c4f97761b83"
                        }
                    ],
                    "type": "volumev2",
                    "id": "a1d93589349f4e26b8caaa55064a6165",
                    "name": "cinderv2"
                },
                {
                    "endpoints":
                    [
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.215:8779/v1.0/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "admin",
                            "id": "1c7f7d6d5c014d25adc37fde0286beca"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.215:8779/v1.0/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "public",
                            "id": "881f7c1c30324fbf9cadcb43b2469132"
                        },
                        {
                            "region_id": "RegionOne",
                            "url": "http://192.168.30.215:8779/v1.0/bfb53f3794f94932a05376c598854a5e",
                            "region": "RegionOne",
                            "interface": "internal",
                            "id": "c0c6dbbfce8649dd9cac59fdff029f6b"
                        }
                    ],
                    "type": "database",
                    "id": "ee0cb39a7d9941ebbab2f6de0cd98ef7",
                    "name": "trove"
                }
            ],
            "extras":
            {
            },
            "user":
            {
                "domain":
                {
                    "id": "default",
                    "name": "Default"
                },
                "id": "aad27d83745d4113baaca5fd1e7ae868",
                "name": "wsy@qq.com"
            },
            "audit_ids":
            [
                "Q-lg0Oi0RbqGlmtEqAUHWQ"
            ],
            "issued_at": "2016-09-07T09:04:46.497596Z"
        }
    }


```

v3的token是放在response的header里的。
接下的请求中请带上header `X-Auth-Token`,值为上面的response中的token.id:`16a9b7cb42c44489a59b191c915aec46`


``` python
from keystoneauth1.identity import v3
from keystoneauth1 import session
from novaclient import client
auth = v3.Password(auth_url='http://192.168.30.211:5000/v3',
                    username="wsy@qq.com",
                    password="916aaa8c-3dbb-11e6-9586-842b2bfac9e8Ww111111",
                    project_name='p_wsy@qq.com_1467178668',
                    user_domain_id='default',
                    project_domain_id='default')  
sess = session.Session(auth=auth)
nova = client.Client("2.1", session=sess)
nova.flavors.list()
```



参考：
[http://docs.openstack.org/image-guide/content/ch_modifying_images.html](http://docs.openstack.org/image-guide/content/ch_modifying_images.html)

[https://ask.openstack.org/en/question/5531/defining-default-user-password-for-ubuntu-cloud-image/](https://ask.openstack.org/en/question/5531/defining-default-user-password-for-ubuntu-cloud-image/)

For other options in cloud.cfg file: http://bazaar.launchpad.net/~cloud-init-dev/cloud-init/trunk/view/head:/doc/examples/cloud-config.txt
