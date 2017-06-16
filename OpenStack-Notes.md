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

# Nova

```
$ nova service-list
```



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

 
作者归档：鲁, 媛媛   Neutron社区每周记 (这里面的东西都很好，喜欢)
https://www.ustack.com/author/luyuanyuan/

[Neutron社区每周记（10.24-10.28）| Neutron 终于不“浪费”公网 IP 了](http://mp.weixin.qq.com/s?__biz=MjM5NjUxNDIwNw==&mid=2654062576&idx=1&sn=f8f20a7d8770afe94648f1e7542d34f5&chksm=bd2d77008a5afe16d6a3e8ac6ab2f5d500003f028297748deb67cb4bf8e6906d9649b0a39203&mpshare=1&scene=2&srcid=1107mvc0vYLowJrmjADElouY&from=timeline#wechat_redirect)

##  关于router路由器
如果router绑定网关,就需要一个floating IP,可以用端口转发的方式访问云主机.
云主机也可以再绑定一个floating ip,外部可以直接用这个IP访问到主机.
如果router不设置网关也就是不绑定floatingIP,那它只能做连接内部网络用,被外网访问,这时内网的主机是不能绑定floating IP的.

## Linux bridge
https://wiki.linuxfoundation.org/networking/bridge

## OVS with DPDK

[OVS-DPDK installation guide](https://github.com/openvswitch/ovs/blob/v2.5.0/INSTALL.DPDK.md)



https://communities.cisco.com/community/developer/openstack/blog/2017/02/01/how-to-deploy-openstack-newton-with-opendaylight-boron-and-open-vswitch

## mininet.org

## 与OpenDayLight整合
https://wiki.opendaylight.org/view/OpenStack_and_OpenDaylight
http://www.sdnlab.com/18099.html
http://files.meetup.com/14446642/neutron.pdf
http://superuser.openstack.org/articles/open-daylight-integration-with-openstack-a-tutorial/

http://verticalindustriesblog.redhat.com/successful-integration-of-opendaylight-boron-release-with-mitaka-release-of-openstack/

OpenDayLight支持  hardware VXLAN tunnel endpoints(VTEPs) for hardware switches.   我们是不是将来可以把openstack的L3下放到hardware switches? 

# Kolla 
使用kolla快速部署openstack all-in-one环境
https://xiexianbin.cn/openstack/2016/10/23/use-kolla-to-deploy-openstack-all-in-one-env


九州云-生产环境中使用Docker自动化部署升级OpenStack的运维实践
http://doc.mbalib.com/view/b75d377a08dbe37ec0f42f5efbce5765.html

## Install OpenStack Newton with Kolla

openstack-controller1 172.16.69.226    ubuntu 16.04
openstack-network-node1 172.16.69.227  ubuntu 16.04
openstack-compute-node1 172.16.69.228  ubuntu 16.04
ansible-docker-registry 172.16.69.229  ubuntu 16.04  

### 安装pip
在ansible-docker-registry 172.16.69.229这台机器上安装pip

```
$ sudo apt-get install python-pip 
$ suod apt-get install python-dev libffi-dev gcc libssl-dev
```

### 安装ansible, kolla
On ansible-docker-registry 172.16.69.229

$ sudo apt install ansible

$ git clone https://github.com/openstack/kolla.git

运行一个私有registry服务。
$ tools/start-registry 


### Configure Docker on all nodes
在其它所有的节点上配置docker,让它可以使用这个私有的registry.
编辑`/etc/default/docker`

```
DOCKER_OPTS="--insecure-registry 172.16.69.229:5000"
```

16.04 使用systemd了，所以根据Docker官方文档[Control and configure Docker with systemd](https://docs.docker.com/engine/admin/systemd/)

```
$ sudo cp /lib/systemd/system/docker.service /etc/systemd/system/docker.service
```
接下来，我们修改文件`/etc/systemd/system/docker.service`的`Service`小节：
``` ini
[Service]
MountFlags=shared
EnvironmentFile=-/etc/default/docker
ExecStart=/usr/bin/docker daemon -H fd:// $DOCKER_OPTS
```

重启docker服务

```
# systemctl daemon-reload
# systemctl restart docker
```

确认修改成功

```
$ docker info

....
Registry: https://index.docker.io/v1/
WARNING: No swap limit support
Insecure Registries:
 172.16.69.229:5000
 127.0.0.0/8
```
可以看到` 172.16.69.229:5000`加入到`Insecure Registries`中了。

編輯`/etc/rc.local`檔案，加入以下內容：

```
mount --make-shared /run
```

因为我们用的是Ubuntu 16.04,请卸载`lxd lxc`，因为`cgroup mounts`问题，在启动容器时，mounts会指数级地增长。

```
# apt remove lxd lxc
```

安装`pip` ,然后通过 `pip` 安装 `docker-py`

```
# apt-get install -y python-pip python-dev
# pip install -U pip docker-py
```



上面的操作要在所有的节点都操作一遍。


### 配置计算节点 
在`openstack-compute-node1 172.16.69.228`上

編輯`/etc/rc.local`檔案，加入以下內容：
```
mount --make-shared /var/lib/nova/mnt
```
保存后，执行下面的命令：

```
# mkdir -p /var/lib/nova/mnt /var/lib/nova/mnt1
# mount --bind /var/lib/nova/mnt1 /var/lib/nova/mnt
# mount --make-shared /var/lib/nova/mnt
```



配置时间同步
我的这三台机器都能上外网，所以直接配置ntp同步就行了。如果你的机器不能访问外网，就在其中的一台上安装ntp服务，然后让其它的机器从它同步时间，保证所有的机器时间一致就OK。

16.04 使用timedatect同步时间了。
https://help.ubuntu.com/lts/serverguide/NTP.html

```
# timedatectl status
```
请确认状态是对的。

Libvirt is started by default on many operating systems. Please disable libvirt on any machines that will be deployment targets. Only one copy of libvirt may be running at a time.
在很多系统下Libvrit是默认自动启动的，
```
service libvirt-bin stop
update-rc.d libvirt-bin disable
```

16.04默认是没有启动的，所以这一步可以略过。

### 重启所有节点
重启所有节点,以使配置生效。


# 编辑 ansible的`Inventory`文件


下面开始安装kolla，我发现必须如果要通过源码安装，一定要clone kolla repository.不能下载压缩包安装，否则会报下面的错：
```
 Complete output from command python setup.py egg_info:
    ERROR:root:Error parsing
    Traceback (most recent call last):
      File "/usr/local/lib/python2.7/dist-packages/pbr/core.py", line 111, in pbr
        attrs = util.cfg_to_args(path, dist.script_args)
      File "/usr/local/lib/python2.7/dist-packages/pbr/util.py", line 246, in cfg_to_args
        pbr.hooks.setup_hook(config)
      File "/usr/local/lib/python2.7/dist-packages/pbr/hooks/__init__.py", line 25, in setup_hook
        metadata_config.run()
      File "/usr/local/lib/python2.7/dist-packages/pbr/hooks/base.py", line 27, in run
        self.hook()
      File "/usr/local/lib/python2.7/dist-packages/pbr/hooks/metadata.py", line 26, in hook
        self.config['name'], self.config.get('version', None))
      File "/usr/local/lib/python2.7/dist-packages/pbr/packaging.py", line 725, in get_version
        raise Exception("Versioning for this project requires either an sdist"
    Exception: Versioning for this project requires either an sdist tarball, or access to an upstream git repository. Are you sure that git is installed?
    error in setup command: Error parsing /tmp/pip-AV4mIk-build/setup.cfg: Exception: Versioning for this project requires either an sdist tarball, or access to an upstream git repository. Are you sure that git is installed?
```

Installing Kolla and dependencies for development

To clone the Kolla repo:

git clone https://git.openstack.org/openstack/kolla
To install Kolla’s Python dependencies use:

pip install -r kolla/requirements.txt -r kolla/test-requirements.txt
Note This does not actually install Kolla. Many commands in this documentation are named differently in the tools directory.
Kolla holds configurations files in etc/kolla. Copy the configuration files to /etc:

cd kolla
cp -r etc/kolla /etc/
Install Python Clients
On the system where the OpenStack CLI/Python code is run, the Kolla community recommends installing the OpenStack python clients if they are not installed. This could be a completely different machine then the deployment host or deployment targets. Install dependencies needed to build the code with pip package manager as explained earlier.

To install the clients use:

yum install python-openstackclient python-neutronclient
Or using pip to install:


```
pip install -U python-openstackclient python-neutronclient

pip install .
```

```
kolla-build --base ubuntu --type source --registry 172.16.69.229:5000 --push
```

编辑`/etc/kolla/globals.yml`
```
config_strategy: "COPY_ALWAYS"
kolla_base_distro: "ubuntu"
kolla_install_type: "source"
openstack_release: "4.0.0"
kolla_internal_vip_address: "10.0.0.10"
docker_registry: "172.16.69.229:5000"
network_interface: "eth0"
neutron_external_interface: "eth2"

# 这个IP绑定在网络节点的eth0上，要用ip addr这个命令才能看出来。
kolla_internal_vip_address: "172.16.69.230"  
network_interface: "eth0"
```



kolla-genpwd



```
# kolla-ansible prechecks -i ansible/inventory/multinode
```

```
172.16.69.226	control01
172.16.69.227	network01
172.16.69.228	compute01
```

control01 ansible_host=172.16.69.226 ansible_user=xcadmin ansible_ssh_pass="Xiangc10ud"
network01 ansible_host=172.16.69.227 ansible_user=xcadmin ansible_ssh_pass="Xiangc10ud"
compute01 ansible_host=172.16.69.228 ansible_user=xcadmin ansible_ssh_pass="Xiangc10ud"

```
TASK [prechecks : fail] ********************************************************
failed: [compute01] => (item={u'stdout': u'192.157.208.178 STREAM controller1\n192.157.208.178 DGRAM  \n192.157.208.178 RAW    ', u'cmd': [u'getent', u'ahostsv4', u'controller1'], u'end': u'2017-01-13 15:28:12.477273', '_ansible_no_log': False, u'warnings': [], u'changed': False, u'start': u'2017-01-13 15:28:12.447745', u'delta': u'0:00:00.029528', 'item': u'control01', u'rc': 0, 'invocation': {'module_name': u'command', u'module_args': {u'creates': None, u'executable': None, u'chdir': None, u'_raw_params': u'getent ahostsv4 controller1', u'removes': None, u'warn': True, u'_uses_shell': False}}, 'stdout_lines': [u'192.157.208.178 STREAM controller1', u'192.157.208.178 DGRAM  ', u'192.157.208.178 RAW    '], u'stderr': u''}) => {"failed": true, "item": {"_ansible_no_log": false, "changed": false, "cmd": ["getent", "ahostsv4", "controller1"], "delta": "0:00:00.029528", "end": "2017-01-13 15:28:12.477273", "invocation": {"module_args": {"_raw_params": "getent ahostsv4 controller1", "_uses_shell": false, "chdir": null, "creates": null, "executable": null, "removes": null, "warn": true}, "module_name": "command"}, "item": "control01", "rc": 0, "start": "2017-01-13 15:28:12.447745", "stderr": "", "stdout": "192.157.208.178 STREAM controller1\n192.157.208.178 DGRAM  \n192.157.208.178 RAW    ", "stdout_lines": ["192.157.208.178 STREAM controller1", "192.157.208.178 DGRAM  ", "192.157.208.178 RAW    "], "warnings": []}, "msg": "Hostname has to resolve to IP address of api_interface"}
failed: [control01] => (item={u'stdout': u'192.157.208.178 STREAM controller1\n192.157.208.178 DGRAM  \n192.157.208.178 RAW    ', u'cmd': [u'getent', u'ahostsv4', u'controller1'], u'end': u'2017-01-13 15:28:12.405884', '_ansible_no_log': False, u'warnings': [], u'changed': False, u'start': u'2017-01-13 15:28:12.366799', u'delta': u'0:00:00.039085', 'item': u'control01', u'rc': 0, 'invocation': {'module_name': u'command', u'module_args': {u'creates': None, u'executable': None, u'chdir': None, u'_raw_params': u'getent ahostsv4 controller1', u'removes': None, u'warn': True, u'_uses_shell': False}}, 'stdout_lines': [u'192.157.208.178 STREAM controller1', u'192.157.208.178 DGRAM  ', u'192.157.208.178 RAW    '], u'stderr': u''}) => {"failed": true, "item": {"_ansible_no_log": false, "changed": false, "cmd": ["getent", "ahostsv4", "controller1"], "delta": "0:00:00.039085", "end": "2017-01-13 15:28:12.405884", "invocation": {"module_args": {"_raw_params": "getent ahostsv4 controller1", "_uses_shell": false, "chdir": null, "creates": null, "executable": null, "removes": null, "warn": true}, "module_name": "command"}, "item": "control01", "rc": 0, "start": "2017-01-13 15:28:12.366799", "stderr": "", "stdout": "192.157.208.178 STREAM controller1\n192.157.208.178 DGRAM  \n192.157.208.178 RAW    ", "stdout_lines": ["192.157.208.178 STREAM controller1", "192.157.208.178 DGRAM  ", "192.157.208.178 RAW    "], "warnings": []}, "msg": "Hostname has to resolve to IP address of api_interface"}
failed: [network01] => (item={u'stdout': u'192.157.208.178 STREAM controller1\n192.157.208.178 DGRAM  \n192.157.208.178 RAW    ', u'cmd': [u'getent', u'ahostsv4', u'controller1'], u'end': u'2017-01-13 15:28:12.505458', '_ansible_no_log': False, u'warnings': [], u'changed': False, u'start': u'2017-01-13 15:28:12.475810', u'delta': u'0:00:00.029648', 'item': u'control01', u'rc': 0, 'invocation': {'module_name': u'command', u'module_args': {u'creates': None, u'executable': None, u'chdir': None, u'_raw_params': u'getent ahostsv4 controller1', u'removes': None, u'warn': True, u'_uses_shell': False}}, 'stdout_lines': [u'192.157.208.178 STREAM controller1', u'192.157.208.178 DGRAM  ', u'192.157.208.178 RAW    '], u'stderr': u''}) => {"failed": true, "item": {"_ansible_no_log": false, "changed": false, "cmd": ["getent", "ahostsv4", "controller1"], "delta": "0:00:00.029648", "end": "2017-01-13 15:28:12.505458", "invocation": {"module_args": {"_raw_params": "getent ahostsv4 controller1", "_uses_shell": false, "chdir": null, "creates": null, "executable": null, "removes": null, "warn": true}, "module_name": "command"}, "item": "control01", "rc": 0, "start": "2017-01-13 15:28:12.475810", "stderr": "", "stdout": "192.157.208.178 STREAM controller1\n192.157.208.178 DGRAM  \n192.157.208.178 RAW    ", "stdout_lines": ["192.157.208.178 STREAM controller1", "192.157.208.178 DGRAM  ", "192.157.208.178 RAW    "], "warnings": []}, "msg": "Hostname has to resolve to IP address of api_interface"}
```


# kolla-ansible deploy -i ansible/inventory/multinode

如果没有错误，就可以运行下面的处理。
# kolla-ansible post-deploy


参考：
http://docs.openstack.org/developer/kolla/quickstart.html






```
对于用户来说，尤其是国内用户，可以直接通过 http://tarballs.openstack.org/kolla/images/ 下载build好的kolla 的docker file，下载回来解压就可以。对于Stable的版本，如果有任何一个commit的更新，也会马上重新build 镜像上传。
```


### Test  OpenStack API with firefox RestClient
preflight :
add headers in RestClient:
```
Content-Type = application/json
Accept = */*
```

首先要获得token
http://172.16.68.68:5000/v3/auth/tokens
发送请求：

``` json
{
    "auth": {
        "scope": {
            "project": {
                "domain": {
                    "id": "default"
                },
                "name": "p_renhuailin@xiangcloud.com.cn_1478168088"
            }
        },
        "identity": {
            "password": {
                "user": {
                    "domain": {
                        "id": "default"
                    },
                    "password": "59cfe59a-a1ae-11e6-a7f3-0242ac1100051Q2w3e4r",
                    "name": "renhuailin@xiangcloud.com.cn"
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


```json


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





# 开发指南
https://www.ustack.com/blog/openstack_hacker/

参考：
[http://docs.openstack.org/image-guide/content/ch_modifying_images.html](http://docs.openstack.org/image-guide/content/ch_modifying_images.html)

[https://ask.openstack.org/en/question/5531/defining-default-user-password-for-ubuntu-cloud-image/](https://ask.openstack.org/en/question/5531/defining-default-user-password-for-ubuntu-cloud-image/)

For other options in cloud.cfg file: http://bazaar.launchpad.net/~cloud-init-dev/cloud-init/trunk/view/head:/doc/examples/cloud-config.txt


# VPN as a service.


# Kolla 安装 O版


```
git clone http://git.trystack.cn/openstack/kolla-ansible
```

修改hosts

```
172.16.69.226 controller1
172.16.69.227 network1
172.16.69.228 compute1
```

管理网段：192.168.56.0/24
This network requires a gateway to provide Internet access to all nodes for administrative purposes such as package installation, security updates, DNS, and NTP.

Provider network：172.16.69.0/24,This network requires a gateway to provide Internet access to instances in your OpenStack environment.



```
$ sudo echo "xcadmin ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/xcadmin sudo chmod 0440 /etc/sudoers.d/xcadmin
```

设置docker

```
$ sudo mkdir /etc/systemd/system/docker.service.d
$ sudo tee /etc/systemd/system/docker.service.d/kolla.conf << 'EOF'
[Service]
MountFlags=shared
EOF
```

访问私有的Docker仓库

在其它所有的节点上配置docker,让它可以使用这个私有的registry.
编辑`/etc/docker/daemon.json`

``` json
{
    "insecure-registries": ["172.16.69.229:5000"]
}
```

Restart Docker by executing the following commands:

```
# Run these commands to reload the daemon
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker

$ docker info
```

install 

```
$ apt install python-pip
$ pip install -U docker-py -i https://pypi.douban.com/simple
```


Install NTP service .

```
# apt-get install ntp
```


Libvirt is started by default on many operating systems. Please disable libvirt on any machines that will be deployment targets. Only one copy of libvirt may be running at a time.

```
$ service libvirt-bin stop
$ update-rc.d libvirt-bin disable
```


On Ubuntu, apparmor will sometimes prevent libvirt from working.

```
/usr/sbin/libvirtd: error while loading shared libraries:
libvirt-admin.so.0: cannot open shared object file: Permission denied
```

If you are seeing the libvirt container fail with the error above, disable the libvirt profile.

```
sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.libvirtd
```

Note On Ubuntu 16.04, please uninstall lxd and lxc packages. (An issue exists with cgroup mounts, mounts exponentially increasing when restarting container).

```
# apt autoremove lxd  lxc 
```

```
mkdir -p /etc/kolla/config/nova
cat << EOF > /etc/kolla/config/nova/nova-compute.conf
[libvirt]
virt_type=qemu
cpu_mode = none
EOF
```


```
# kolla-ansible prechecks -i ansible/inventory/multinode
# kolla-ansible deploy -i ansible/inventory/multinode
```

```
# pip install python-openstackclient
```

编辑 `/usr/local/share/kolla-ansible/init-runonce`，

网络需要根据实际情况修改

```
EXT_NET_CIDR='172.16.69.0/24'
EXT_NET_RANGE='start=172.16.69.245,end=172.16.69.253'
EXT_NET_GATEWAY='172.16.69.1'
```

```
# source /etc/kolla/admin-openrc.sh
# cd /usr/local/share/kolla-ansible
# ./init-runonce
```


```
# wget http://tarballs.openstack.org/kolla/images/ubuntu-source-registry-ocata.tar.gz
```

如何build images.
https://docs.openstack.org/developer/kolla/image-building.html


我们来看看registry的数据目录在哪儿。
# docker inspect registry|less
``` json 
"Mounts": [
            {
                "Name": "registry",
                "Source": "/var/lib/docker/volumes/registry/_data",
                "Destination": "/var/lib/registry",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],

```
数据目录是"/var/lib/docker/volumes/registry/_data"

```
# tar zxvf ubuntu-source-registry-ocata.tar.gz -C /var/lib/docker/volumes/registry/_data
```


报错排查：

```
fatal: [control01]: FAILED! => {"failed": true, "reason": "ERROR! The field 'until' is supposed to be a string type, however the incoming data structure is a <class 'ansible.parsing.yaml.objects.AnsibleSequence'>\n\nThe error appears to h
ave been in '/usr/local/share/kolla-ansible/ansible/roles/nova/tasks/simple_cell_setup.yml': line 2, column 3, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n---\n- name: W
aiting for nova-compute service up\n  ^ here\n"}
fatal: [compute01]: FAILED! => {"failed": true, "reason": "ERROR! The field 'until' is supposed to be a string type, however the incoming data structure is a <class 'ansible.parsing.yaml.objects.AnsibleSequence'>\n\nThe error appears to h
ave been in '/usr/local/share/kolla-ansible/ansible/roles/nova/tasks/simple_cell_setup.yml': line 2, column 3, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n---\n- name: W
aiting for nova-compute service up\n  ^ here\n"}
```

这个错误应该晚的ansible 版本太低的原因,我用的是`ansible 2.0.0.2`推荐的应该是 2.x版了。

升级ansible
pip install  ansible -U -i https://pypi.douban.com/simple

```

我报了个bug。
https://bugs.launchpad.net/kolla-ansible/+bug/1676790

后来用`pip freeze`来查看kolla和kolla-ansible发现两个的版本都是开发版，把它们都升级到4.0.0，重新部署了一遍，就没问题了。



默认镜像的登录账号： cirros/cubswin:)


要使用floating IP 必须 有外部网络。

参考： 
http://www.chenshake.com/kolla-installation/

[DRBD](https://zh.wikipedia.org/zh-hans/DRBD)