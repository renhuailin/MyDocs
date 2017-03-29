Docker notes
-------------


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

Policy | Result
-------|-------
no     | 不自动重启
on-failure[:max-retries] | 当容器以非0的返回值退出时，重启，这时可以指定最大重启次数。
always | 一直重启，没有次数限制


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
根据sof这篇文章　[http://stackoverflow.com/a/28725899](http://stackoverflow.com/a/28725899)　来看mesos更成熟．



# 7 registry

$ sudo docker run -p 5000:5000 registry:2.0  -e ICESCRUM_EMAIL_DEV=dev@icescrum.org

docker run \
         -e SETTINGS_FLAVOR=s3 \
         -e AWS_BUCKET=acme-docker \
         -e STORAGE_PATH=/registry \
         -e AWS_KEY=AKIAHSHB43HS3J92MXZ \
         -e AWS_SECRET=xdDowwlK7TJajV1Y7EoOZrmuPEJlHYcNP2k4j49T \
         -e SEARCH_BACKEND=sqlalchemy \
         -p 5000:5000 \
         registry


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
    -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry \
    -v /myregistrydata:/var/lib/registry \
    --restart=always --name registry registry:2

mkdir -p certs && openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
    -x509 -days 365 -out certs/domain.crt

```    
$ openssl req  -newkey rsa:4096 -nodes -sha256 -keyout certs/registry_ecloud_com_cn.key -x509 -days 365 -out certs/registry_ecloud_com_cn.crt
```

Then you have to instruct every docker daemon to trust that certificate. This is done by copying the registry_ecloud_com_cn.crt file to /etc/docker/certs.d/registry.ecloud.com.cn:5000/registry_ecloud_com_cn.crt (don't forget to restart docker after doing so).

restart your Docker daemon: on ubuntu, this is usually service docker stop && service docker start


``` yaml
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

# 7.1 查看 private registry．


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


# 8 Image

# 8.1 导出导入image

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
$ sudo docker commit 614122c0aabb rhl/apache2


# Docker build

**Dockerfile**
如果想要添加PATH环境变量,在Dockerfile里添加像这样一行：

``` sh
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
``` sh
exec ${CATALINA_HOME}/bin/catalina.sh run
```
为什么要用`exec` ? 这里有讲http://stackoverflow.com/a/18351547。
其大概意思是用exec创建出来的process,会替代调用它的那个进程,一旦exec创建出来的进程结束,整个进程就结束了,不会有shell进程会留一下.


那我把startup.sh加上exec可以吗？
``` sh
exec $CATALINA_HOME/bin/startup.sh
```
这样还是不行。

不用exec`catalina.sh run`也能启动tomcat且容器不退出。
``` sh
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

请参考：
[https://github.com/docker/distribution/blob/master/docs/deploying.md](https://github.com/docker/distribution/blob/master/docs/deploying.md)
[左耳朵耗子写的一些关于docker的文章](http://coolshell.cn/tag/docker)
[https://blog.docker.com/2013/07/how-to-use-your-own-registry/](https://blog.docker.com/2013/07/how-to-use-your-own-registry/)
