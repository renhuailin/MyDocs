Docker notes
-------------

# Install

```
$ curl -fsSL get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
```

# 1 docker run

为了让非root用户使用docker，需要把她加到docker这个组里

```
$ sudo usermod -aG docker your-user
```

```
$ sudo docker run  -d --name registry  -p 5000:5000 registry:2.0
```

docker在使用中，网络问题是比较大的，提供的几种网络模型各有优缺，
bridge 方式： 有mac地址变更，ip地址等问题。

 -p -P来映射port, 在container内部是用iptables来实现的，最多只能处理65535个连接。在大网站里这是不可能接受的。
IP:host_port:container_port

**注意**
docker映射的格式是:   宿主机的资源[端口或目录]:container的资源。

**指定容器的hostname**
-h --hostname 可以指定容器的hostname

**指定容器的hosts**
--add-host=[]              Add a custom host-to-IP mapping (host:ip)

**容器重启策略(--restart)**

这个策略控制容器退出后是否自动重启。有些时候我们会发现容器会因为我们的应用或tomcat,apache等进程退出了而退出。
这通常不是我们想要的，docker允许你指定一个策略在容器退出时，自动重启容器。

| Policy                   | Result                         |
| ------------------------ | ------------------------------ |
| no                       | 不自动重启                          |
| on-failure[:max-retries] | 当容器以非0的返回值退出时，重启，这时可以指定最大重启次数。 |
| always                   | 一直重启，没有次数限制                    |

为了防止宿主机被容器的频繁重启淹没，所以容器每次重启的时间间隔会自动递增，100ms,200ms、400ms、800ms。

host:方式，会有端口冲突。但是可以通过上层的编排系统来解决。是新浪目前使用的方式。

InfoQ的视频[Docker与OpenStack](http://www.infoq.com/cn/presentations/docker-and-openstack?utm_campaign=infoq_content&utm_source=infoq&utm_medium=feed&utm_term=global)

docker可以与openstack结合，分别是以Nova的driver和heat的plugin方式。

Magnum是OpenStack的新项目，也就是Container as a Service.

`--privileged` 
https://blog.docker.com/2013/09/docker-can-now-run-within-docker/

# 2 进入容器的bash

可以用docker attach,但是docker attach是共享窗口的。
docker version > 1.3，我们还可以使用

```
# 3 docker exec -it <container id or name> bash
```

# 4 storage driver

`--storage-driver=devicemapper`

https://docs.docker.com/reference/commandline/cli/#daemon-storage-driver-option
下面的[性能测试的文章](http://redhat.slides.com/jeremyeder/performance-analysis-of-docker#/9)里用的storage driver用的就是devicemapper

Tune-D  性能调优工具．

# 一些性能相关的文章

http://developerblog.redhat.com/2014/08/19/performance-analysis-docker-red-hat-enterprise-linux-7/　　

[http://redhat.slides.com/jeremyeder/performance-analysis-of-docke](http://redhat.slides.com/jeremyeder/performance-analysis-of-docke)　,相关Github Repository: [https://github.com/jeremyeder/docker-performance](https://github.com/jeremyeder/docker-performance)

http://www.slideshare.net/jpetazzo/shipping-applications-to-production-in-containers-with-docker

左耳说vlan能真正解决docker的网络问题。还说已经有了IPVLAN的驱动。
[Docker基础技术：Linux Namespace（下）](http://coolshell.cn/articles/17029.html)

# 5 Docker性能问题

IO性能不是很好是因为AUFS,网络模式最好是host．
可以通过Volume来挂载的方式来绕过AUFS.

# 6 Mesos VS Kubernates

# 7 registry

$ sudo docker run -p 5000:5000 registry:2.0  -e ICESCRUM_EMAIL_DEV=dev@icescrum.org

docker run \
​         -e SETTINGS_FLAVOR=s3 \
​         -e AWS_BUCKET=acme-docker \
​         -e STORAGE_PATH=/registry \
​         -e AWS_KEY=AKIAHSHB43HS3J92MXZ \
​         -e AWS_SECRET=xdDowwlK7TJajV1Y7EoOZrmuPEJlHYcNP2k4j49T \
​         -e SEARCH_BACKEND=sqlalchemy \
​         -p 5000:5000 \
​         registry

当你访问一个非localhost的registry时，docker要求你必须用https加密。否则报下面的错误。

```
FATA[0000] Error response from daemon: v1 ping attempt failed with error:
Get https://myregistrydomain.com:5000/v1/_ping: tls: oversized record received with length 20527.
If this private registry supports only HTTP or HTTPS with an unknown CA certificate,please add
`--insecure-registry myregistrydomain.com:5000` to the daemon's arguments.
In the case of HTTPS, if you have access to the registry's CA certificate, no need for the flag;
simply place the CA certificate at /etc/docker/certs.d/myregistrydomain.com:5000/ca.crt
```

 $ docker run -d -p 5000:5000 \
​    -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry \
​    -v /myregistrydata:/var/lib/registry \
​    --restart=always --name registry registry:2

mkdir -p certs && openssl req \
​    -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
​    -x509 -days 365 -out certs/domain.crt

```
$ openssl req  -newkey rsa:4096 -nodes -sha256 -keyout certs/registry_ecloud_com_cn.key -x509 -days 365 -out certs/registry_ecloud_com_cn.crt
```

Then you have to instruct every docker daemon to trust that certificate. This is done by copying the registry_ecloud_com_cn.crt file to /etc/docker/certs.d/registry.ecloud.com.cn:5000/registry_ecloud_com_cn.crt (don't forget to restart docker after doing so).

restart your Docker daemon: on ubuntu, this is usually service docker stop && service docker start

```yaml
registry:
  restart: always
  image: registry:2
  ports:
    - 5000:5000
  environment:
    REGISTRY_HTTP_TLS_CERTIFICATE: /certs/registry_ecloud_com_cn.crt
    REGISTRY_HTTP_TLS_KEY: /certs/registry_ecloud_com_cn.key
    REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /var/lib/registry
  volumes:
    - /opt/china_ops_docker_registry/data:/var/lib/registry
    - /opt/china_ops_docker_registry/certs:/certs
```

如何把自己的镜像push到private registry上呢？ 首先把你的image打一个tag. 这个tag以 <private registry domain>：<port>/开头．

```
$ docker tag hello-world:latest localhost:5000/hello-mine:latest
```

打完tag了，直接push这个镜像就行了．

```
$ docker push localhost:5000/hello-mine:latest
```

如果nginx报下面的错，请在配置里添加：`client_max_body_size 0;`

```
error parsing HTTP 413 response body: invalid character '<' looking for beginning of value: "<html>\r\n<head><title>413 Request Entity Too Large</title></head>\r\n<body bgcolor=\"white\">\r\n<center><h1>413 Request Entity Too Large</h1></center>\r\n<hr><center>nginx/1.4.6 (Ubuntu)</center>\r\n</body>\r\n</html>\r\n"
```

## 7.1 查看 private registry．

**From registry 2.1** 终于可以查询这个registry里有哪些镜像了,2.1添加了一`_catalog`api,可以list出所有的镜像，而且支持分页。

```
curl -v -X GET http://localhost:5000/v2/_catalog
```

```
curl -v -X GET http://localhost:5000/v2/hello-mine/tags/list
```

如果你的registry用的自签名的证书，你还需要给curl加上`-k`这个选项．

```
$ docker login localhost:5000
```

试着从private registry pull a image.

```
$ docker pull localhost:5000/hello-mine:latest
```

```
AUTH=$(echo -ne "$BASIC_AUTH_USER:$BASIC_AUTH_PASSWORD" | base64 --wrap 0)

curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Basic $AUTH" \
  --request POST \
  --data  '{"key1":"value1", "key2":"value2"}' \
  https://example.com/
```

## 7.2 让Docker 使用insecure registry

`/etc/docker/daemon.json`

```
{
    "insecure-registries" : [ "hostname.cloudapp.net:5000" ]
}
```

https://docs.docker.com/registry/insecure/

## 7.3 使用docker中国的mirror加速镜像拉取速度

docker已经进中国了，有了官方的hub加速

https://www.docker-cn.com/registry-mirror

您可以修改 `/etc/docker/daemon.json` 文件并添加上 registry-mirrors 键值。

```
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
```

重启docker服务

```
# systemctl daemon-reload &&  systemctl restart docker
# docker info |grep Mirror -C 10
```

像mac 这样的不好修改docker daemon参数的，可以直接用docker命令行来操作：

```
docker pull registry.docker-cn.com/library/ubuntu
docker pull registry.docker-cn.com/library/nginx
```

如果pull的不是docker官方的image

```
docker pull registry.docker-cn.com/prom/prometheus:v2.2.0
```

# 8 Image

## 8.1 导出导入image

使用`docker save`导出image.默認輸出到STDOUT。輸出的是tar格式的。

```
$ docker save busybox > busybox.tar
$ docker save -o fedora-all.tar fedora
```

使用`docker load`來導入tarred image . Load an image from a tar archive or STDIN.

```
$ docker load < busybox.tar
$ docker load --input fedora.tar
```

### 通过 docker commit来创建一个image.

Create a new image from a container’s changes

```
$ sudo docker commit 614122c0aabb rhl/apache2
```

## 8.2 Dockerfile

### ADD 更高级的复制文件

`ADD` 指令和 `COPY` 的格式和性质基本一致。但是在 `COPY` 基础上增加了一些功能。

比如 `<源路径>` 可以是一个 `URL`，这种情况下，Docker 引擎会试图去下载这个链接的文件放到 `<目标路径>` 去。下载后的文件权限自动设置为 `600`，如果这并不是想要的权限，那么还需要增加额外的一层 `RUN`进行权限调整，另外，如果下载的是个压缩包，需要解压缩，也一样还需要额外的一层 `RUN` 指令进行解压缩。所以不如直接使用 `RUN` 指令，然后使用 `wget` 或者 `curl` 工具下载，处理权限、解压缩、然后清理无用文件更合理。因此，这个功能其实并不实用，而且不推荐使用。

如果 `<源路径>` 为一个 `tar` 压缩文件的话，压缩格式为 `gzip`, `bzip2` 以及 `xz` 的情况下，`ADD` 指令将会自动解压缩这个压缩文件到 `<目标路径>` 去。

在某些情况下，这个自动解压缩的功能非常有用，比如官方镜像 `ubuntu` 中：

```
FROM scratch
ADD ubuntu-xenial-core-cloudimg-amd64-root.tar.gz /
...
```

但在某些情况下，如果我们真的是希望复制个压缩文件进去，而不解压缩，这时就不可以使用 `ADD` 命令了。

在 Docker 官方的 [Dockerfile 最佳实践文档](https://yeasy.gitbooks.io/docker_practice/content/appendix/best_practices.html) 中要求，尽可能的使用 `COPY`，因为 `COPY` 的语义很明确，就是复制文件而已，而 `ADD` 则包含了更复杂的功能，其行为也不一定很清晰。最适合使用 `ADD` 的场合，就是所提及的需要自动解压缩的场合。

另外需要注意的是，`ADD` 指令会令镜像构建缓存失效，从而可能会令镜像构建变得比较缓慢。

因此在 `COPY` 和 `ADD` 指令中选择的时候，可以遵循这样的原则，所有的文件复制均使用 `COPY` 指令，仅在需要自动解压缩的场合使用 `ADD`。

### Alpine

目前Docker镜像越来越倾向于使用Alpine系统作为基础的系统镜像，Docker Hub 官方制作的镜像都在逐步支持Alpine系统。

**下面的修改以 Alpine 3.7 为例：**

```
# 备份原始文件
cp /etc/apk/repositories /etc/apk/repositories.bak

# 修改为国内镜像源
echo "http://mirrors.aliyun.com/alpine/v3.7/main/" > /etc/apk/repositories
```

## 精简Docker image的方法

https://mp.weixin.qq.com/s?__biz=MzA5OTAyNzQ2OA==&mid=2649698614&idx=1&sn=bef332b5a3781ca09997197b2c83abe8&chksm=88930e55bfe48743f794676c59437576d4ef126ef76ac45935bddff84119a9da81c77e54158a&mpshare=1&scene=24&srcid=09283HaLfU39yAT2FZrcX2HF&key=d281c5c9a9e2ecf1aa3c0ae31abac8d49e970d7ba07691fc1acfa002b0deff074174bf076b00d1e56595382c34ef24b7863b165223d4eb9f249914423eaa87b9f6c3761df9853c93e87d2a5d9dc36b75&ascene=0&uin=NjA5ODc5MDYw&devicetype=iMac+MacBookPro12%2C1+OSX+OSX+10.13.6+build(17G65)&version=12020810&nettype=WIFI&lang=zh_CN&fontScale=100&pass_ticket=sfkgxVc7g%2BbqJRJk%2BejtJroxNELjZT%2FODn7hAQqr8WHlIVvcnNiQmqd%2FvkscNHbf

Dockerfile中每条指令都会为镜像增加一个镜像层，并且你需要在移动到下一个镜像层之前清理不需要的组件。实际上，有一个Dockerfile用于开发（其中包含构建应用程序所需的所有内容）以及一个用于生产的瘦客户端，它只包含你的应用程序以及运行它所需的内容。这被称为“建造者模式”。Docker 17.05.0-ce版本以后支持多阶段构建。使用多阶段构建，你可以在Dockerfile中使用多个FROM语句，每条FROM指令可以使用不同的基础镜像，这样您可以选择性地将服务组件从一个阶段COPY到另一个阶段，在最终镜像中只保留需要的内容。

下面是一个使用COPY --from 和 FROM … AS … 的Dockerfile：

```
# Compile
FROM golang:1.9.0 AS builder
WORKDIR /go/src/v9.git...com/.../k8s-monitor
COPY . .
WORKDIR /go/src/v9.git...com/.../k8s-monitor
RUN make build
RUN mv k8s-monitor /root

# Package
# Use scratch image
FROM scratch
WORKDIR /root/
COPY --from=builder /root .
EXPOSE 8080
CMD ["/root/k8s-monitor"]
```

构建镜像，你会发现生成的镜像只有上面COPY 指令指定的内容，镜像大小只有2M。这样在以前使用两个Dockerfile（一个Dockerfile用于开发和一个用于生产的瘦客户端），现在使用多阶段构建就可以搞定。

# 9  Docker Log

## 9.1 使用JouralD来管理日志

修改docker daemon的启动参数，配置`log-driver`为"journald"

`/etc/docker/daemon.json`

```json
{
  "log-driver": "journald"
}
```

重启docker service.

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker.service
```

基本上，systemd-journald.service 的配置文件主要参考 /etc/systemd/journald.conf 的内容，详细的参数你可以参考 `man 5 journald.conf` 的数据。

```properties
[Journal]
#日志存储到磁盘
Storage=persistent 
#压缩日志
Compress=yes 
#为日志添加序列号
Seal=yes 
#每个用户分别记录日志
SplitMode=uid 
#日志同步到磁盘的间隔，高级别的日志，如：CRIT、ALERT、EMERG 三种总是实时同步
SyncIntervalSec=1m 

#即制日志的最大流量，此处指 30s 内最多记录 100000 条日志，超出的将被丢弃
RateLimitInterval=30s 
#与 RateLimitInterval 配合使用
RateLimitBurst=100000

#限制全部日志文件加在一起最多可以占用多少空间，默认值是10%空间与4G空间两者中的较小者
SystemMaxUse=64G 
#默认值是15%空间与4G空间两者中的较大者
SystemKeepFree=1G 

#单个日志文件的大小限制，超过此限制将触发滚动保存
SystemMaxFileSize=128M 

#日志滚动的最大时间间隔，若不设置则完全以大小限制为准
MaxFileSec=1day
#日志最大保留时间，超过时限的旧日志将被删除
MaxRetentionSec=100year 

#是否转发符合条件的日志记录到本机的其它日志管理系统，如：rsyslog
ForwardToSyslog=yes 
ForwardToKMsg=no
#是否转发符合条件的日志到所有登陆用户的终端
ForwardToWall=yes 
MaxLevelStore=debug 
MaxLevelSyslog=err 
MaxLevelWall=emerg 
ForwardToConsole=no 
#TTYPath=/dev/console
#MaxLevelConsole=info
#MaxLevelKMsg=notice
```

https://www.cnblogs.com/hadex/p/6837688.html

创建目录并分配权限，然后重启journald服务

```
$ mkdir /var/log/journal
$ chmod 775 /var/log/journal

$ systemctl restart systemd-journald
```

```
journalctl --unit=docker.service
journalctl -u docker
```

# Docker build

**Dockerfile**
如果想要添加PATH环境变量,在Dockerfile里添加像这样一行：

```sh
ENV PATH $PATH:/yourpath
```

**Dockerfile中的ENTRYPOINT和CMD**
请看sof的这个帖子[http://stackoverflow.com/a/21564990](http://stackoverflow.com/a/21564990)，讲得比官方文档明白多了。

## 卷映射的问题

我在做agilefant的images时，遇到了一个问题，tomcat总是启动不起来。因为我的用了一个自定义的shell script来处理环境变量，以更新agilefant的配置。在这个脚本的最后我调用了启动tomcat的脚本。

```
$CATALINA_HOME/bin/startup.sh
```

结果容器启动后就关闭，容器退出说明主命令的进程退出了。怎么会？自己折腾了半天还是不行，网上看了别人写的Dockerfile，发现人家都是这样启动tomcat的。

```sh
exec ${CATALINA_HOME}/bin/catalina.sh run
```

为什么要用`exec` ? 这里有讲http://stackoverflow.com/a/18351547。
其大概意思是用exec创建出来的process,会替代调用它的那个进程,一旦exec创建出来的进程结束,整个进程就结束了,不会有shell进程会留一下.

那我把startup.sh加上exec可以吗？

```sh
exec $CATALINA_HOME/bin/startup.sh
```

这样还是不行。

不用exec`catalina.sh run`也能启动tomcat且容器不退出。

```sh
${CATALINA_HOME}/bin/catalina.sh run
```

生成iamge并打上tag.
$ docker build -t vieux/apache:2.0 .

### Dockerfile里的VOLUME指令

这个指令用指定的名创建一个挂载点，然后把它标识为一个外部挂载的卷,这个卷可以是从宿主机(native host)或者是其它容器挂载过来的。

那它有什么用呢？ 简单地说docker run时，会的把images里VOLUME指定的那个目录下的所有文件复制到新的卷里去，注意是每次run的时候。
假设有下面的Dockerfile.

```
FROM ubuntu
RUN mkdir /myvol
RUN echo "hello world" > /myvol/greeting
VOLUME /myvol
```

TODO：： 这里要继续写，给出一些图片说明，然后整理成一篇blog.

# 常用docker命令

```
$ sudo docker run --name mysql -d     -v /opt/mysql/data:/var/lib/mysql     sameersbn/mysql:latest

$ sudo docker run --name mysql -it     ubuntu:latest bash

$ docker run --name ubuntu -it   -p 5000:5000    registry.ecloud.com.cn:5000/ubuntu:14.04 bash
```

# Some sites about Docker

http://container42.com/  作者是docker公司的人。

# SDN And Docker

Calico A pure L3 approach to Virtual Networking for High avaiable scalable data center.
https://www.projectcalico.org/

### IPVLAN

http://networkstatic.net/configuring-macvlan-ipvlan-linux-networking/

docker客户已经在研究IPVLAN了。
https://github.com/docker/docker/blob/master/experimental/vlan-networks.md

### MacVLAN 技术

MacVLAN:
https://docs.docker.com/engine/userguide/networking/get-started-macvlan/
https://sreeninet.wordpress.com/2016/05/29/macvlan-and-ipvlan/
http://kb.netgear.com/21586/What-is-a-MAC-based-VLAN-and-how-does-it-work-with-my-managed-switch?cid=wmt_netgear_organic
[Pipework配置Docker容器macvlan网络](http://blog.gesha.net/archives/611/)

容器网络插件 Calico 与 Contiv Netplugin深入比较
http://dockone.io/article/1935  这个东西Contiv Netplugin不错。

# Other problems

[tomcat在启动时假死]

tomcat在容器里假死在下面这里，我是真心不知道为什么了，在本机是好使的。

```
[INFO] 19:51:56 [ContextLoader][301]: Root WebApplicationContext: initialization completed in 698 ms
```

后来看了http://stackoverflow.com/a/27613367,解决了，感谢大牛，泪流满面。

```
apt-get install haveged -y
```

在线迁移方法：
https://www.infoq.com/articles/container-live-migration

# Docker new features

## Health Check

from v 1.12    
支持用户定义的health check,比如一个http server,可以检查它是否还能响应用户的新请求，是不是已经假死了（进程还在，今是但是连接总是超时）。   

```
HEALTHCHECK --interval=5m --grace=20s --timeout=3s --exit-on-unhealthy \
  CMD curl -f http://localhost/](
```

具体请看： https://github.com/docker/docker/pull/22719

https://github.com/docker/docker/releases/tag/v1.12.0-rc2 找时间把这里的feature都看一遍。

1.13.0 (2017-01-18)

* 1.12引入的实验版本的管理api plugin做了改动。在升级到1.13版之前必须卸载掉你在1.12版本安装的插件。
* (实验性) 添加一个选项，可以在镜像构建成功后粉碎中镜像层 [#22641](https://github.com/docker/docker/pull/22641)

Runtime

* Add boolean flag --init on dockerd and on docker run to use tini a zombie-reaping init process as PID 1 [#26061](https://github.com/docker/docker/pull/26061) [#28037](https://github.com/docker/docker/pull/28037)  为`dockerd`和`docker run`添加了一个boolean的选项 `--init`,它使用`tini`僵尸收割进程来清理僵尸进程。 （这块我要提供一个例子）

* Add a new daemon flag --init-path to allow configuring the path to the docker-init binary #26941 可以配置`docker-init`文件的目录了。

* Add support for live reloading insecure registry in configuration #22337 也就是添加 insecure registry不用重启daemon了。

# Docker on mac

screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
用户名是：root

# Docker做本地开发环境

# Harbor

坑总结：

* 不能把harbor放在nginx后面，nginx做反向代理，我试了，这样在image Push到一半时会报错：
  
  ```
  unauthorized: authentication required
  ```

* 官方文档上的ssl的配置方法没有用，根本不用./prepare，也不用修改什么harbor.cfg，只要把证书放在config/nginx/cert,然后编辑`nginx.conf`这个文件，把ssl配置加上就行了。请不要编辑`nginx.https.conf`,没用。

# 错误解决

问题： Driver devicemapper failed to remove root filesystem 11568bbc999a490ccb783cb23fc5a532de444215b4617132d2185a831d4f1905: Device is Busy

http://blog.hashbangbash.com/2014/11/docker-devicemapper-fix-for-device-or-resource-busy-ebusy/

https://github.com/docker/docker/issues/5684#issuecomment-69052334

http://www.tuicool.com/articles/y2UBjqB

从这个回复看，应该是内核版本太低的原因，我是在CentOS 7上发现这个问题的，内核版本3.10.0。
https://github.com/docker/docker/issues/17902

从这个帖子的last reply来看，应该在3.10的centos7上没有办法解决了，:(  
http://blog.hashbangbash.com/2014/11/docker-devicemapper-fix-for-device-or-resource-busy-ebusy/

Device is Busy这个一般的解决步骤：

1. 看容器进程是否已经杀掉。没有的话，可以手动杀死。
2. mount -l看是不是该容器的路径还在挂载状态。是的话，umount掉。
3. 然后再次尝试docker rm。

问题： 今天发现docker login登录超时了，就是在jenkins这台机器上，用`docker daemon -D`可以看到是请求超时了。把registry.xiangcloud.com.cn手工绑定在/etc/hosts上，瞬间登录成功，看来是dns
的问题，可是我用户dig测试registry.xiangcloud.com.cn时，解析的速度非常快，应该是docker login在处理解析时的问题吧。

Answer: 问题找到了，是host主机的dns的问题：在`/etc/resolv.conf`里配置了两个nameserver，其中的第一个是自建的powerdns的测试，已经不在了，所以导致解析的时候速度极慢。删除了这个nameserver就可以了。
关于docker 的dns，请参考：https://robinwinslow.uk/2016/06/23/fix-docker-networking-dns/

* MySQL in docker exit occasionally with these errors: 

```
2017-04-06T20:10:41.248511Z 0 [ERROR] InnoDB: mmap(137428992 bytes) failed; errno 12
2017-04-06T20:10:41.248530Z 0 [ERROR] InnoDB: Cannot allocate memory for the buffer pool
2017-04-06T20:10:41.248535Z 0 [ERROR] InnoDB: Plugin initialization aborted with error Generic error
2017-04-06T20:10:41.248542Z 0 [ERROR] Plugin 'InnoDB' init function returned error.
2017-04-06T20:10:41.248559Z 0 [ERROR] Plugin 'InnoDB' registration as a STORAGE ENGINE failed.
2017-04-06T20:10:41.248564Z 0 [ERROR] Failed to initialize plugins.
2017-04-06T20:10:41.248567Z 0 [ERROR] Aborting

2017-04-06T20:10:41.248582Z 0 [Note] Binlog end
2017-04-06T20:10:41.248630Z 0 [Note] Shutting down plugin 'MyISAM'
2017-04-06T20:10:41.249775Z 0 [Note] Shutting down plugin 'CSV
```

docker 默认是不限制内存使用的,会向Host申请尽可能多的内存.
这个MySQL是与Gitlab一起用的,Gitlab在备份时会占用大量的内存,导致MySQL无法分配到内存了.解决方案是为gitlab的主机多分配些内存.

http://stackoverflow.com/questions/12114746/mysqld-service-stops-once-a-day-on-ec2-server/12683951#12683951
https://github.com/docker-library/mysql/issues/248
https://www.digitalocean.com/community/questions/mysql-server-keeps-stopping-unexpectedly

## 无法进入容器 executing setns process caused "exit status 15

https://github.com/moby/moby/issues/34488

# 使用supervisord来管理进程

https://docs.docker.com/engine/admin/multi-service_container/

http://liuzxc.github.io/blog/supervisor/

# Ubuntu 16.04 修改启动的 `-H`参数

为了在jenkins里调用docker，我需要为docker daemon添加-H的启动参数，但是在16.04的`/etc/docker/daemon.json`里加是不好使的，因为systemd的启动脚本里指定了host的参数，如果在`/etc/docker/daemon.json`也指定一个host,docker daemon启动就会报错：

```
unable to configure the Docker daemon with file /etc/docker/daemon.json: the following directives are specified both as a flag and in the configuration file: hosts: (from flag: [fd://], from file: [tcp://0.0.0.0:2375 unix:///var/run/docker.sock])
```

这其实是个bug: https://github.com/moby/moby/issues/22339 

所以只能在systemd的service file里来指定它。
$$

$$
docker的systemd的启动文件放在：`/etc/systemd/system/multi-user.target.wants/docker.service`

It is conventional to use port `2375` for un-encrypted, and port `2376` for encrypted communication with the daemon.

# Docker-compose

在Ubuntu 14.04下安装时有时会报这个错误：

```
docker compose  AttributeError: 'module' object has no attribute 'connection'
```

通过[这个帖子](https://github.com/docker/docker-py/issues/1054#issuecomment-246917401)解决了，一定要export `PYTHONPATH`  这个环境变量。

请参考：

1. [https://github.com/docker/distribution/blob/master/docs/deploying.md](https://github.com/docker/distribution/blob/master/docs/deploying.md)
2. [左耳朵耗子写的一些关于docker的文章](http://coolshell.cn/tag/docker)
3. [https://blog.docker.com/2013/07/how-to-use-your-own-registry/](https://blog.docker.com/2013/07/how-to-use-your-own-registry/)

如果用户docker-compose启动了一个服务，并设置为自动启动模式，这个服务在docker engine重启后自动重启。  如果丢失了docker-compose.yml，并且想停止这个服务，可以通过设置容器的`RestartPolicy=no`来实现。

```
$ docker update --restart=no  influxdb_influxdb_1
```

# 12.  Swarm

可以在[这个网站]([https://labs.play-with-docker.com/](https://labs.play-with-docker.com/)实验swarm：https://labs.play-with-docker.com/

[使用docker-compose.yaml来部署服务到swarm](https://docs.docker.com/engine/swarm/stack-deploy/#test-the-app-with-compose)

如果设置了health check,那么在swarm里，如果服务Untheathy了，那么会kill掉重启。

https://codeblog.dotsandbrackets.com/docker-health-check/

```
$ docker swarm init --advertise-addr eth0
Swarm initialized: current node (vq7xx5j4dpe04rgwwm5ur63ce) is now a manager.

$ docker swarm join \
    --token SWMTKN-1-50qba7hmo5exuapkmrj6jki8knfvinceo68xjmh322y7c8f0pj-87mjqjho30uue43oqbhhthjui \
    10.0.120.3:2377

# 如果过一段时间我们忘了这个token，这时如果要添加worker进来，可以用下面的命令把token显示出来。
$ docker swarm join-token worker



# Deploy a service by using NGINX:

$ docker service create --detach=true --name nginx1 --publish 80:80  --mount source=/etc/hostname,target=/usr/share/nginx/html/index.html,type=bind,ro nginx:1.12

pgqdxr41dpy8qwkn6qm7vke0q


$ docker service ls



$ docker service update --image nginx:1.13 --detach=true nginx1
```

## 12.1  config

Docker 17.06 introduces swarm service configs.

Use these links to read about specific commands, or continue to the [example about using configs with a service](https://docs.docker.com/engine/swarm/configs/#example-use-configs-with-a-service).

- [`docker config create`](https://docs.docker.com/engine/reference/commandline/config_create/)
- [`docker config inspect`](https://docs.docker.com/engine/reference/commandline/config_inspect/)
- [`docker config ls`](https://docs.docker.com/engine/reference/commandline/config_ls/)
- [`docker config rm`](https://docs.docker.com/engine/reference/commandline/config_rm/)

### 12.1.1 config create

```
$ echo "This is a config" | docker config create my-config -

$ docker config ls

$ docker secret create site.key site.key

$ docker secret create site.crt site.crt
```

### 12.1.2 查看config

```
$ docker config inspect --pretty admin-backend-application.properties
```

### 12.1.3 使用config

```
$ docker service create \
     --name nginx \
     --secret site.key \
     --secret site.crt \
     --config source=site.conf,target=/etc/nginx/conf.d/site.conf,mode=0440 \
     --publish published=3000,target=443 \
     nginx:latest \
     sh -c "exec nginx -g 'daemon off;'"
```

### 12.1.4 rm config

```
$ docker config rm site.conf
```

## 12.2 Service
