Kubernetes notes
-------------

# Kubernetes 架构图

https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture.md

https://github.com/kubernetes/kubernetes/blob/release-1.5/docs/design/architecture.md

# 安装

kubeadm是用apt安装的，atp支持https_proxy这个系统变量，所以我用 shadowsocks + privoxy 翻墙然后安装了kubeadm.

## 在线体验

You need to have a Kubernetes cluster, and the kubectl command-line tool must be configured to communicate with your cluster. If you do not already have a cluster, you can create one by using Minikube, or you can use one of these Kubernetes playgrounds:
[Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
[Play with Kubernetes](http://labs.play-with-k8s.com/)

## 多节点部署时的 Bootstrap Docker

https://kubernetes.io/docs/getting-started-guides/docker-multinode/

Bootstrap Docker

This guide uses a pattern of running two instances of the Docker daemon:    

1) A bootstrap Docker instance which is used to start etcd and flanneld, on which the Kubernetes components depend    
2) A main Docker instance which is used for the Kubernetes infrastructure and user’s scheduled containers
   This pattern is necessary because the flannel daemon is responsible for setting up and managing the network that interconnects all of the Docker containers created by Kubernetes. To achieve this, it must run outside of the main Docker daemon. However, it is still useful to use containers for deployment and management, so we create a simpler bootstrap daemon to achieve this.

因为这个部署方案的flannel是运行在docker里的。 它必须在主docker daemon外运行，所以需要另外一个docker daemon--Bootstrap Docker Daemon.
那到底什么是 bootstrap docker instance呢？其实它就是另一个docker daemon,这个daemon在启动时指定了一个新的socket文件。

```
This pattern is necessary because the flannel daemon is responsible for setting up and managing the network that interconnects all of the Docker containers created by Kubernetes. To achieve this, it must run outside of the main Docker daemon. However, it is still useful to use containers for deployment and management, so we create a simpler bootstrap daemon to achieve this.
```

```bash
BOOTSTRAP_DOCKER_SOCK="unix:///var/run/docker-bootstrap.sock"
```

在这个daemon下启动的container，用`docker ps`查看的时候必须要加上`-H unix:///var/run/docker-bootstrap.sock`。

```
$ docker -H unix:///var/run/docker-bootstrap.sock ps
```

# Pod

它可以包含一个或多个container，

```
in a pre-container world, they would have executed on the same physical or virtual machine.
```

它们应该在一个物理机或虚机上？

共享ip和端口？？？能通过localhost相互访问。
They can also communicate with each other using standard inter-process communications like SystemV semaphores or POSIX shared memory. 

Q: 不同pod里的容器能不能通过IPC沟通？
A: 它们有不同的IP,不能通过IPC沟通

如果一个节点dies了，上面的pod就会被删除. 这个pod(同一个UID的)不会被调试到新节点上。它会被一个一样的pod替代，所谓一样的就是相同配置，如果你愿意你可以用原来的名字，但是UID是变了的。将来的API可能会实现迁移（UID不变？）

```
我理解这段话的意思是，我们不能用POD的UID来做唯一标识，因为它用变，看来我们只能给每个POD打上一个标签，这个tag应该就是它的配置的一部分，新建的Pod也会用有这个tag.
```

当我们说某个东西有跟Pod一样的生命周期时，如卷，这意味着pod存在，它就存在。如果Pod因为任何原因被删除，它也会被删除。even if一个identical的pod被创建出来，卷也会被destroy,创建一个新的。

这可得注意了。卷会被删除！！！应该只是跟Pod一样的生命周期的卷。

co-location 主机托管

通常用户不应该直接创建pods，而是应该通过controllers。

`-o wide`这个选项可以显示pod的IP和所在主机。

```
$ kubectl get pods -o wide
```

## Forward a local port to a port on the pod

```
$ kubectl port-forward redis-master-765d459796-258hz 6379:6379 
```

### 使用 HostAliases 向 Pod /etc/hosts 文件添加条目

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostaliases-pod
spec:
  hostAliases:
  - ip: "127.0.0.1"
    hostnames:
    - "foo.local"
    - "bar.local"
  - ip: "10.1.2.3"
    hostnames:
    - "foo.remote"
    - "bar.remote"
  containers:
  - name: cat-hosts
    image: busybox
    command:
    - cat
    args:
    - "/etc/hosts"
```

## Static Pods

今天在跟陈晖请教如何在ICP安装完后启动audit logs的问题时，知道了这个概念。

# Label

label的key可以分两段，前缀和名字，用`/`分隔。名字部分不能超过63个字符。   
前缀是可选的，但是如果指定，就必须是DNS subdomain。不能超过253字符。
自动化系统组件，如果(e.g. kube-scheduler, kube-controller-manager, kube-apiserver, kubectl, or other third-party automation) 必须指定prefix.`kubernetes.io/`这个前缀保留给kubernetes核心组件使用。

# Replication controller

Replication controller 可保证Pod的复本数量，多了删除，少了创建。注意是pods级别的。

Rolling updates  ,可以通过新建一个Replication controller来实现。新建一个Replication controller，把复本设计为1，原来的Replication controller的复本设置为0，就可以实现平滑升级了。

客户端命令实现了滚动升级：
`kubectl rolling-update`. 

ReplicaSet 是下一代的 Replication Controlle，支持新的set-based label selector. 它目前主要用于`Deployment`，实现Pod的创建，删除等操作。

注意kubernetes推荐使用`Deployment`,而不是直接使用ReplicaSet。

**DaemonSet**
如果你的pods要提示机器级别的功能，如：在所有的pods启动之前启动，在机器重启或关闭之前安全关闭。

# ReplicaSet

ReplicaSet is the next-generation Replication Controller.  The only difference between a *ReplicaSet* and a [*Replication Controller*](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/) right now is the selector support. 

`ReplicaSet`和Replication Controller的唯一区别就是selector的支持。

ReplicaSet supports the new set-based selector requirements as described in the [labels user guide](https://kubernetes.io/docs/user-guide/labels/#label-selectors) whereas a Replication Controller only supports equality-based selector requirements.

`ReplicaSet`支持 new set-based selector，而`Replication Controller`只支持`equality-based selector`.

大部分支持Replication Controller的kubectl命令也支持ReplicaSet，只有[`rolling-update`](https://kubernetes.io/docs/user-guide/kubectl/v1.7/#rolling-update)这个命令例外。

如果你想要支持[`rolling-update`](https://kubernetes.io/docs/user-guide/kubectl/v1.7/#rolling-update) ，请使用*Deployment*。

# Deployment

https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ 

要理解这个概念，这是个非常重要的概念，要注意它与`ReplicaSet`的关系。

A *Deployment* controller provides declarative updates for [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/) and [ReplicaSets](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/).

Deployment为Pod和复本提供了一种声明式的升级方式，它是下一代的Replication Controller。

A typical use case is:
Create a Deployment to bring up a Replica Set and Pods.
Check the status of a Deployment to see if it succeeds or not.
Later, update that Deployment to recreate the Pods (for example, to use a new image).
Rollback to an earlier Deployment revision if the current Deployment isn’t stable.
Pause and resume a Deployment.

**Note:** *You should not manage ReplicaSets owned by a Deployment. All the use cases should be covered by manipulating the Deployment object. Consider opening an issue in the main Kubernetes repository if your use case is not covered below.*

你不要管理由Deployment所创建的ReplicaSets。

### 显示部署的历史记录

```
$ kubectl rollout history deployment/nginx-deployment
```

回退到指定的某次部署

```
$ kubectl rollout history deployment/nginx-deployment --revision=2
```

# Service

Service是一组Pods的逻辑集合和访问它们的相关策略，这些pods是通过Label Selector确定的。

符合这个label的Pod会自动加入Service,移除相关的label或pod死了,也会自动从Service中移除.

这些pods是通过endpoints来expose的.

它是一个抽象的概念.它并不真正地去启动Pod,启动Pods是通过`Deployment`.

## Accessing the Service

K8s支持2种发现服务的方式:环境变量和DNS,
 environment variables and DNS

**环境变量**
文档里举的例子是进入到Pod里查看 evn ,要测试一下在node节点上是否也有这样的evn.
如果先创建的pods,然后创建的Service,那么env里不包含服务相关的信息.但是最常用的创建service的方式.
如果Pods是在Service之后创建的,那么pods里的env里就会包含服务的相关的信息.

文档上为了测试pods在服务之后创建,它先把Service的`replicas`减为0,然后再设置为2. 这样pods就在服务之后创建了.

### DNS

好像这个也是Pods内的,也就是这两种方式都是让其它的pods找到这个service,也就是cluster内部的.

#### A records

“Normal” (not headless) Services are assigned a DNS A record for a name of the form `my-svc.my-namespace.svc.cluster.local`. This resolves to the cluster IP of the Service.

“Headless” (without a cluster IP) Services are also assigned a DNS A record for a name of the form `my-svc.my-namespace.svc.cluster.local`. Unlike normal Services, this resolves to the set of IPs of the pods selected by the Service. Clients are expected to consume the set or else use standard round-robin selection from the set.

比如，我的服务名叫`nginx`,在`default`名空间里，我的clust的域名是`cluster.local`(这是在安装时指定的)，那么我们可以通过`nginx.default.svc.cluster.local`这个域名来访问此服务。

#### SRV records

SRV Records are created for named ports that are part of normal or [Headless Services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services). For each named port, the SRV record would have the form `_my-port-name._my-port-protocol.my-svc.my-namespace.svc.cluster.local`. For a regular service, this resolves to the port number and the CNAME: `my-svc.my-namespace.svc.cluster.local`. For a headless service, this resolves to multiple answers, one for each pod that is backing the service, and contains the port number and a CNAME of the pod of the form `auto-generated-name.my-svc.my-namespace.svc.cluster.local`.

#### 自定义DNS

https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/

```
$ kubectl -n kube-system edit configmap kube-dns
```

kubectl run -it --image=10.226.57.149:8080/tsf_100000000/ubuntu:16.04 bash

## Exposing the Service

这个就是把服务暴露给外部使用了.
支持NodePort和LoadBalancer这两种方式.

### Services without selectors

Services without selectors，也就是后端不是Pods。
什么时候会用到无selector的Service呢？

* You want to have an external database cluster in production, but in test you use your own databases.
* You want to point your service to a service in another Namespace or on another cluster.
* You are migrating your workload to Kubernetes and some of your backends run outside of Kubernetes.

一般我们使用外部服务时，用这种方式。

https://cloud.google.com/blog/products/gcp/kubernetes-best-practices-mapping-external-services

Q: Proxy-mode: userspace的Service工作原理？
A: 

Q: Proxy-mode: iptables 工作原理？

Q: 上述两种模式有什么区别？

### [IPVS proxy mode]([Service | Kubernetes](https://kubernetes.io/docs/concepts/services-networking/service/#proxy-mode-ipvs))

这里讲的是当一个服务后台有N个pod时的负载均衡策略。默认的是round-robin。

IPVS可以支持更多负载均衡策略

IPVS provides more options for balancing traffic to backend Pods; these are:

- `rr`: round-robin
- `lc`: least connection (smallest number of open connections)
- `dh`: destination hashing
- `sh`: source hashing
- `sed`: shortest expected delay
- `nq`: never queue

Headless services      
如果以后两种模式你都不想要，那你可以定义`Headless services`.    
you can create “headless” services by specifying "None" for the cluster IP (spec.clusterIP).

## Publishing Service.

ServiceType

* **ClusterIP：** 只能集群内部访问。 
* **NodePort：**  映射到Node上某个Port，并且在每个Node上都使用相同Port。
* **LoadBalancer：** 使用云提供的Load Balancer。
* **externName** : Maps the service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up. This requires version 1.7 or higher of kube-dns.  这个还没弄明白。

Expose与Publish的区别是什么？

## Deployment  ReplicaSet  Service的关系

Deployment负责维护pods的数量，我们可以手动pod，然后通过Service来expose。这种情况，如果我们kill一个pod,系统不会自动启动一个pod.而使用Deployment后系统会自动维护一定数量的replica.这样再expose成Service，Servcie就更稳定。

## Service Load Balancer

[Service Load Balancer](https://github.com/kubernetes/contrib/tree/master/service-loadbalancer)

## 腾讯云上让服务使用内网的负载均衡

```yaml
kind: Service
apiVersion: v1
metadata:
  # Unique key of the Service instance
  name: jcyd-admin-backend-service
  annotations:
    service.kubernetes.io/qcloud-loadbalancer-internal-subnetid: subnet-3ce2fphz
spec:
  ports:
  - name: http
      # The port that will be exposed by this service.
    port: 80
    # The port that pod exposed.
    targetPort: 8081
  selector:
    # Loadbalance traffic across Pods matching
    # this label selector
    app: jcyd-admin-backend
  #type: NodePort
  type: LoadBalancer
```

# Network

解析k8s网络  http://dockone.io/article/3211

https://blog.csdn.net/zjysource/article/details/52052420



## iptables vs ipvs

我们知道，默认，k8s的service的实现依赖iptables，但是当集群变大，服务数量增多时，会在节点上生成很多iptables的规则，这时节点会消耗很多的CPU来执行IPTables的规则的处理，服务路由的性能也会显著地下降。

一句话： iptables不适合大规模集群。

IPVS就不一样，它是基于LVS的。具体的请参见kubernetes blog:  [IPVS-Based In-Cluster Load Balancing Deep Dive]([IPVS-Based In-Cluster Load Balancing Deep Dive | Kubernetes](https://kubernetes.io/zh/blog/2018/07/09/ipvs-based-in-cluster-load-balancing-deep-dive/)) 和  [ 华为云在 K8S 大规模场景下的 Service 性能优化实践](https://zhuanlan.zhihu.com/p/37230013)

# Volumes

## hostPath

这个是我们在用docker最常用的模式，但是在k8s里时要注意：

* when Kubernetes adds resource-aware scheduling, as is planned, it will not be able to account for resources used by a hostPath     k8s执行资源调度时，`hostPath`使用的资源（也就是磁盘容量）不会被计算在内！！！

## 让PVC claim指定的PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-gitlab-pv
  labels:
    pvname: pv-nfs-gitlab
spec:
  capacity:
    storage: 400Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 172.21.16.49
    path: "/gitlab-backup"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-gitlab-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  selector:
    matchLabels:
      pvname: pv-nfs-gitlab
  resources:
    requests:
      storage: 400Gi
```

## Lifecycle of a volume and claim

卷有两种提供方式：

* static
  
  A cluster administrator creates a number of PVs. They carry the details of the real storage which is available for use by cluster users. They exist in the Kubernetes API and are available for consumption.

* dynamic

| 卷类型       | Multi-Writers |     |
| --------- | ------------- | --- |
| NFS       | Yes           |     |
| GlusterFS | Yes           |     |
| CephFS    | Yes           |     |

# Config Map and Secret

使用configmap

可以使用kubectl set 的方式把configmap以环境变量的方式注入到容器里。

```
kubectl set env --from=secret/mysecret deployment/myapp
```

`kubectl set` 还可以以文件等方式设置env，请参考kubectl命令。

每次你更新Config Map 或 Secret时，使用了此配置的pod都会相应地更新。

## Create Config Map

```
# Create the configmap
$ kubectl create configmap game-config --from-file=configure-pod-container/configmap/
```

`configure-pod-container/configmap/`  is a directory contains properties file.

```
game.properties
ui.properties
```

```
$ kubectl describe configmaps game-config
Name:           game-config
Namespace:      default
Labels:         <none>
Annotations:    <none>

Data
====
game.properties:        158 bytes
ui.properties:          83 bytes
```

You can use `kubectl create configmap` to create a ConfigMap from an individual file, or from multiple files.

For example,

```shell
kubectl create configmap game-config-2 --from-file=configure-pod-container/configmap/game.properties
```

would produce the following ConfigMap:

```shell
kubectl describe configmaps game-config-2
```

where the output is similar to this:

```
Name:           game-config-2Namespace:      defaultLabels:         <none>Annotations:    <none>Data====game.properties:        158 bytes
```

You can pass in the `--from-file` argument multiple times to create a ConfigMap from multiple data sources.

```shell
kubectl create configmap game-config-3 --from-file=<my-key-name>=<path-to-file>
```

where `<my-key-name>` is the key you want to use in the ConfigMap and `<path-to-file>` is the location of the data source file you want the key to represent.

For example:

```shell
kubectl create configmap game-config-3 --from-file=game-special-key=configure-pod-container/configmap/game.properties
```

### Create a ConfigMap from generator

`kubectl` supports `kustomization.yaml` since 1.14. You can also create a ConfigMap from generators and then apply it to create the object on the Apiserver. The generators should be specified in a `kustomization.yaml` inside a directory.

#### Generate ConfigMaps from files

For example, to generate a ConfigMap from files `configure-pod-container/configmap/game.properties`

```shell
# Create a kustomization.yaml file with ConfigMapGenerator
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: game-config-4
  files:
  - configure-pod-container/configmap/game.properties
EOF
```

Apply the kustomization directory to create the ConfigMap object.

```shell
kubectl apply -k .
configmap/game-config-4-m9dm2f92bt created
```

You can check that the ConfigMap was created like this:

```shell
kubectl get configmap
NAME                       DATA   AGEgame-config-4-m9dm2f92bt   1      37skubectl describe configmaps/game-config-4-m9dm2f92btName:         game-config-4-m9dm2f92btNamespace:    defaultLabels:       <none>Annotations:  kubectl.kubernetes.io/last-applied-configuration:                {"apiVersion":"v1","data":{"game.properties":"enemies=aliens\nlives=3\nenemies.cheat=true\nenemies.cheat.level=noGoodRotten\nsecret.code.p...

Data
====
game.properties:
----
enemies=aliens
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten
secret.code.passphrase=UUDDLRLRBABAS
secret.code.allowed=true
secret.code.lives=30
Events:  <none>
```

Note that the generated ConfigMap name has a suffix appended by hashing the contents. This ensures that a new ConfigMap is generated each time the content is modified.

#### Define the key to use when generating a ConfigMap from a file

You can define a key other than the file name to use in the ConfigMap generator. For example, to generate a ConfigMap from files `configure-pod-container/configmap/game.properties` with the key `game-special-key`

```shell
# Create a kustomization.yaml file with ConfigMapGenerator
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: game-config-5
  files:
  - game-special-key=configure-pod-container/configmap/game.properties
EOF
```

Apply the kustomization directory to create the ConfigMap object.

```shell
kubectl apply -k .configmap/game-config-5-m67dt67794 created
```

#### Generate ConfigMaps from Literals

To generate a ConfigMap from literals `special.type=charm` and `special.how=very`, you can specify the ConfigMap generator in `kustomization.yaml` as

```shell
# Create a kustomization.yaml file with ConfigMapGenerator
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: special-config-2
  literals:
  - special.how=very
  - special.type=charm
EOF
```

Apply the kustomization directory to create the ConfigMap object.

```shell
kubectl apply -k .configmap/special-config-2-c92b5mmcf2 created
```

## Config Map as volume

```yaml
volumeMounts:
        - mountPath: /app/config
          name: cm-bootstrap-yml
volumes:
      - hostPath:
          path: /var/lib/docker/containers
          type: ""
      - configMap:
          defaultMode: 420
          name: yonyou-cdp-activity-bootstrap-yaml
        name: cm-bootstrap-yml
```

# Namespaces

Kubernetes supports multiple virtual clusters backed by the same physical cluster. These virtual clusters are called namespaces.

k8s支持物理集群上的多个虚拟集群，这些虚拟集群被称做`namespaces`.

# Service Accounts

A service account provides an identity for processes that run in a Pod.
service account我称之为服务账号,为运行在Pod里的进程提供了一个身份。

# Daemon Set

A Daemon Set确保所有的节点都运行一个Pod的复本，当一个新的节点加入到集群时，这个pod就自动加入到这个。

典型的应用场景如为所有的节点提供存储的Pod，日志收集，监控。

DaemonSet管理的Pods用的是hostPort，所以能用节点的IP直接访问。

# Ingress Resources

如果我们用的不GCE，AWS等云主机，是物理机那该如何配置loadbalancer？请参考：
https://github.com/kubernetes/contrib/tree/master/service-loadbalancer  这是用Haproxy来做负载均衡的项目。

要想做PaaS这是相当重要的一块。

集群内的服务可以通过ClusterIP来相互访问，但是这边些服务无法越过Cluster边界被外部的系统访问。Ingress是集群外部访问集群内服务的入口控制器。

部署一个Ingress

http://blog.frognew.com/2017/04/kubernetes-ingress.html

[DockOne微信分享（一三三）：深入理解Kubernetes网络策略](http://dockone.io/article/2529) 这里面讲到了network policy.

## Nginx ingress controller

在baremetal上，因为没有loadbalancer，所以ingress的Address是空的。

要访问ingress需要用ingress controller的NodePort来访问

```
[root@iaas-tsf-k8s-master1 ingress]# kubectl get svc -n test
NAME                        TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
demo1                       NodePort   172.16.255.61    <none>        18081:32719/TCP              5d
ingress-nginx               NodePort   172.16.255.185   <none>        80:30067/TCP,443:32145/TCP   18m
tima-cdp-api-gateway-test   NodePort   172.16.255.171   <none>        8080:30231/TCP               4d
tima-cdp-user-test          NodePort   172.16.255.118   <none>        10001:31095/TCP              3h
```

通过上面的输出我们可以发现， ingress-nginx的NodePort为：  http: 30067,https: 32145。我们可以在所有的Node**节点**上访问这个服务。

# Horizontal Pod Autoscaling

目前只能跟deployment绑定。

目前主要是依据cpu来做scale,1.2版添加了自定义的metrics, like QPS (queries per second) or average request latency.
集群启动时`ENABLE_CUSTOM_METRICS`必须被设置为true.
The cluster has to be started with `ENABLE_CUSTOM_METRICS` environment variable set to true.

```
$ kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

# Job

可以执行一次的任务，也可以定时多次执行。

### backoffLimit

这个参数控制着这个Job在重试多少次之后就失败。

```
There are situations where you want to fail a Job after some amount of retries due to a logical error in configuration etc. To do so, set .spec.backoffLimit to specify the number of retries before considering a Job as failed. The back-off limit is set by default to 6. Failed Pods associated with the Job are recreated by the Job controller with an exponential back-off delay (10s, 20s, 40s …) capped at six minutes, The back-off limit is reset if no new failed Pods appear before the Job’s next status check.
```

```bash
# 批量删除一些jobs
for job in $(kubectl get job|grep gitlab-confluence-backup-cronjob|awk {'print $1'});do  kubectl delete job $job; done
```

# Pet Set

一组有状态的Pods,有状态的东西都很麻烦。
A Pet Set, in contrast, is a group of stateful pods that require a stronger notion of identity.

# 源代码分析

http://blog.csdn.net/screscent/article/category/2488081

# 概念 CONCEPTS

## Cluster Administration

### Cluster Networking

这章一定要好好理解，这是k8s的网络基础。

1. Highly-coupled container-to-container communications: this is solved by pods and localhost communications.
2. Pod-to-Pod communications: this is the primary focus of this document.
3. Pod-to-Service communications: this is covered by services.
4. External-to-Service communications: this is covered by services.

Kubernetes imposes the following fundamental requirements on any networking implementation (barring any intentional network segmentation policies):

* all containers can communicate with all other containers without NAT
* all nodes can communicate with all containers (and vice-versa) without NAT
* the IP that a container sees itself as is the same IP that others see it as
  看来K8S的网络真追求速度呀，最后一条很有用的呢。

This model is not only less complex overall, but it is principally compatible with the desire for Kubernetes to enable low-friction porting of apps from VMs to containers. If your job previously ran in a VM, your VM had an IP and could talk to other VMs in your project. This is the same basic model.

## Network Policies

https://kubernetes.io/docs/concepts/services-networking/networkpolicies/
https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/

A network policy is a specification of how groups of pods are allowed to communicate with each other and other network endpoints.
y default, all traffic is allowed between all pods (and NetworkPolicy resources have no effect).
Isolation can be configured on a per-namespace basis. Currently, only isolation on inbound traffic (ingress) can be defined. When a namespace has been configured to isolate inbound traffic, all traffic to pods in that namespace (even from other pods in the same namespace) will be blocked. NetworkPolicy objects can then be added to the isolated namespace to specify what traffic should be allowed

# CLI

## Kubectl

[Kubectl Overview](https://kubernetes.io/docs/user-guide/kubectl-overview/)   这里包含了它的sub commands , resource type.

[Kubectl Cheat Sheet](https://kubernetes.io/docs/user-guide/kubectl-cheatsheet/)

[API 1.7](https://v1-7.docs.kubernetes.io/docs/api-reference/v1.7/)  这里有ymal的具体格式 

把所有的相关文件放在一个目录里，用一条命令创建。

```
$ kubectl apply -f <directory>/
```

zsh下的completion

```
$ source <(kubectl completion zsh)
```

bash下的completion

```
$ source <(kubectl completion bash)
```

强制删除一个pod.

```
$ kubectl delete pod gitlab --grace-period=0 --force
```

显示pods的更多信息

```shell
# Config kubectl for ICP
$ kubectl config set-cluster mycluster.icp --server=https://10.8.152.111:8001 --insecure-skip-tls-verify=true
$ kubectl config set-context mycluster.icp-context --cluster=mycluster.icp
$ kubectl config set-credentials admin --token=eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImF0X2hhc2giOiJyU3hWc0tQbUpwR2gtdXJPdlJFamxnIiwiaXNzIjoiaHR0cHM6Ly9teWNsdXN0ZXIuaWNwOjk0NDMvb2lkYy9lbmRwb2ludC9PUCIsImF1ZCI6Ijk3MTEwODc4N2E5ODQwNTA5OTQ2YTRmMGM4MzIwZjEzIiwiZXhwIjoxNTE1MDczNDA3LCJpYXQiOjE1MTUwMzAyMDd9.nwH86HUBrKea1eTWPzIbRPK8cR08CJUb_qQKMMZ4C8oi8olnWkUaN8Ucptb1iuD05Hki5qi4ZLwQC7VcTKMWaXCd-d1xvAaNipwGn8jNYMhpmhQ6sZs2y4Tl1X68rWa7a8UT_7lew7OxmF-85UEFhj8xVq1O5OP4KUFEZElVNDo1ZuMfx-lukCAEHBHPmmCnYOWsUQlgp3AVfrNk6R7DQYjuJaVrEeFFFfMDLgela4MUsNhYSjBdH_XeZOxE7TpF-Nhm6MCDi0xBTed3bpCijfdLsThOl2MSgUgT7GGHEjhY0DySG53F4LmbHR75WmRgE1E5iprFwHbq6A-qAHvoHw
$ kubectl config set-context mycluster.icp-context --user=admin --namespace=default
$ kubectl config use-context mycluster.icp-context

# Config kubectl for Kubernetes
# kubectl config set-credentials default-admin --username=admin --password=6666o9oIB2gHD88882quIfLMy6666
# kubectl config set-cluster default-cluster --server=https://cls-66668888.ccs.tencent-cloud.com --certificate-authority=/etc/kubernetes/cluster-ca.crt
# kubectl config set-context default-system --cluster=default-cluster --user=default-admin
# kubectl config use-context default-system

# set namespace
$ kubectl config set-context $(kubectl config current-context) --namespace=<insert-namespace-name-here>

$ kubectl config  view

$ kubectl get pods -o wide

$ kubectl create -f my-nginx.yml

$ kubectl describe deployment my-nginx

$ kubectl get jobs --watch

$ kubectl expose   deployment/my-nginx

$ kubectl expose   deployment/my-nginx  --name=name --port=80 --target-port=8080 --type=NodePort

$ kubectl delete services example-service     # unexpose a service

$ kubectl get pods --namespace=kube-system

#显示某个 label的pods
$ kubectl get pod -l app=msa-demo

# Get a Shell to a running pod.
$ kubectl exec -it shell-demo -- /bin/bash

# Create multiple YAML objects from stdin
$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox-sleep
spec:
  containers:
  - name: busybox
    image: busybox
    args:
    - sleep
    - "1000000"
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-sleep-less
spec:
  containers:
  - name: busybox
    image: busybox
    args:
    - sleep
    - "1000"
EOF

# Create a secret with several keys
$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  password: $(echo "s33msi4" | base64)
  username: $(echo "jane" | base64)
EOF


# The kubectl command can create a proxy that will forward communications into the cluster-wide, private network. The proxy can be terminated by pressing control-C and won't show any output while its running.
$ kubectl proxy


# You can see all those APIs hosted through the proxy endpoint, now available at through http://localhost:8001. For example, we can query the version directly through the API using the curl command:

$ curl http://localhost:8001/version

# Show cluster info.
$ kubectl cluster-info


# kubectl explain
# Get documentation of various resources. For instance pods, nodes, services, etc.

$ kubectl explain pod
$ kubectl explain pod.spec.affinity



$ kubectl drain <node name>
# 这时节点的状态是不能调度的。
10.218.132.42    Ready,SchedulingDisabled   <none>    13d       1.8.13-qcloud

# 要变成可调度的要用uncordon这个命令。
$ kubectl uncordon <node name>


# You can call kubectl get pod with the -o go-template=... option to fetch the status of previously terminated Containers:

$ kubectl get pod -o go-template='{{range.status.containerStatuses}}{{"Container Name: "}}{{.name}}{{"\r\nLastState: "}}{{.lastState}}{{end}}'  simmemleak-hra99
```

http://deployment-msa-demo.default.svc.cluster.local:8082

## Helm and Charts

https://github.com/kubernetes/helm/blob/master/docs/charts.md

https://aliacs-app-catalog.oss-cn-hangzhou.aliyuncs.com/charts/

## Autoscaling

为了实现autoscaling,必须对容器所使用的资源进行限制,参考 [kubernetes 资源限制](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) 。

resources下面有两个属性： requests ,limits

* `requests` 是在pod调试时用的，schedular用它来计算应该在哪个节点启动容器。
* `limits` 是在运行时判断的，如果运行的容器的CPU超过了这个限制，容器会被杀掉。

下面是json格式的Deployment的创建文件：限制了cpu和内存。

```json
{
  "apiVersion": "extensions/v1beta1",
  "kind": "Deployment",
  "metadata": {
    "name": "msa-demo",
    "namespace": "default",
    "resourceVersion": "247395",
    "labels": {
      "app": "msa-demo"
    },
    "annotations": {
      "deployment.kubernetes.io/revision": "1"
    }
  },
  "spec": {
    "replicas": 1,
    "selector": {
      "matchLabels": {
        "app": "msa-demo"
      }
    },
    "template": {
      "metadata": {
        "creationTimestamp": null,
        "labels": {
          "app": "msa-demo"
        }
      },
      "spec": {
        "containers": [
          {
            "name": "msa-demo-container",
            "image": "harleyren/scm-msa-demo:1.0.41",
            "ports": [
              {
                "containerPort": 8082,
                "protocol": "TCP"
              }
            ],
            "resources": {"limits": {"memory": "128Mi","cpu": "1"}},
            "terminationMessagePath": "/dev/termination-log",
            "terminationMessagePolicy": "File",
            "imagePullPolicy": "IfNotPresent",
            "securityContext": {
              "privileged": false
            }
          }
        ],
        "restartPolicy": "Always",
        "terminationGracePeriodSeconds": 30,
        "dnsPolicy": "ClusterFirst",
        "securityContext": {},
        "schedulerName": "default-scheduler"
      }
    },
    "strategy": {
      "type": "RollingUpdate",
      "rollingUpdate": {
        "maxUnavailable": 1,
        "maxSurge": 1
      }
    }
  }
}
```

下面是autoscaling的相关命令。

```shell
$ kubectl help autoscale
$ kubectl autoscale deployment deployment-msa-demo --min=1 --max=4 --cpu-percent=80
$ kubectl get hpa
$ kubectl delete horizontalpodautoscalers deployment-msa-demo
```

用wget来做压力测试：

```shell
while true; do wget -q -O- http://9.112.190.95:32758/; done
```

ab的压力测试

```shell
$ ab -n 100 -c 10 http://9.112.190.95:32758/
$ ab -n 100 0-c 10 http://9.112.190.95:32758/
$ ab -n 1000 -c 10 http://9.112.190.95:32758/
$ ab -n 1000 -c 100 http://9.112.190.95:32758/
$ ab -n 10000 -c 500 http://9.112.190.95:32758/
$ ab -n 100000 -c 1000 http://9.112.190.95:32758/
$ ab -n 10000000 -c 100 http://9.112.190.95:32758/
$ ab -n 100000 -c 100 http://9.112.190.95:32758/
$ ab -n 10000000 -c 100 http://9.112.190.95:32758/
```

## Kompose

https://github.com/kubernetes/kompose

这个工具可以把`docker-compose.yaml`转成kubernetes的资源。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mc1
spec:
  volumes:
  - name: html
    emptyDir: {}
  containers:
  - name: 1st
    image: nginx
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
  - name: 2nd
    image: debian
    volumeMounts:
    - name: html
      mountPath: /html
    command: ["/bin/sh", "-c"]
    args:
      - while true; do
          date >> /html/index.html;
          sleep 1;
        done
```

## How to create a service account

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tke-admin
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tke-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tke-admin
subjects:
- kind: ServiceAccount
  name: tke-admin
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tke-admin
  namespace: kube-system
```

## PersistentVolumeClaimResize

1.8 支持PV的resize,但是要开启 [feature gate](https://kubernetes.io/docs/reference/feature-gates/) `ExpandPersistentVolumes`  同时最好要开启`PersistentVolumeClaimResize` admission controller。

# Helm & Charts

For more information about Helm, see [https://github.com/kubernetes/helm/tree/master/docs ![External link icon](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/images/icons/launch-glyph.svg)](https://github.com/kubernetes/helm/tree/master/docs).

Helm 参考：https://docs.helm.sh/using_helm/#quickstart

```
$ helm init --client-only --skip-refresh
$ helm repo add https://aliacs-app-catalog.oss-cn-hangzhou.aliyuncs.com/charts
$ helm search -l
$ 
```

# # Pod资源限制

根据[kubernetes的文档]([https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)，对Pod的资源限制主要是下面的4个选项来决定。

* spec.containers[].resources.limits.cpu

* spec.containers[].resources.limits.memory

* spec.containers[].resources.requests.cpu

* spec.containers[].resources.requests.memory

## 有resource requests的Pod是如何被调度的？

The scheduler ensures that, for each resource type, the sum of the **resource requests** of the scheduled Containers is less than the capacity of the node. Note that although actual memory or CPU resource usage on nodes is very low, the scheduler still refuses to place a Pod on a node if the capacity check fails.

也就是在调度时，用的是resources.requests。

## 有resource limits的Pod是如何运行的？

When using Docker:

- The `spec.containers[].resources.requests.cpu` is converted to its core value, which is potentially fractional, and multiplied by 1024. The greater of this number or 2 is used as the value of the [`--cpu-shares`](https://docs.docker.com/engine/reference/run/#cpu-share-constraint) flag in the `docker run` command.

- The `spec.containers[].resources.limits.cpu` is converted to its millicore value and multiplied by 100. The resulting value is the total amount of CPU time that a container can use every 100ms. A container cannot use more than its share of CPU time during this interval.

注意上面的这句话：The greater of this number or 2 is used as the value of the [`--cpu-shares`](https://docs.docker.com/engine/reference/run/#cpu-share-constraint) flag in the `docker run` command. 它的意思是如果这个数小于2，就用2做为参数传给 `--cpu-shares`。要注意理解Docker  `--cpu-shares` 这个参数的含义，它是把一台宿主机上所有容器的 `--cpu-shares`的值都加起来，然后计算每个容器所占的比例来分配CPU的。这个值越大，分配的可以会越大，只是可能。

所以，**基本上request是在调度时使用，而limit是在运行时生效**。

# 监控

kubernetes不再用 `model API`提供的api来实现监控了，而是用 [metrics](https://github.com/kubernetes/metrics) 项目来做收集监控信息。

Grafana service by default requests for a LoadBalancer. If that is not available in your cluster, consider changing that to NodePort. Use the external IP assigned to the Grafana service, to access Grafana. The default user name and password is 'admin'. Once you login to Grafana, add a datasource that is InfluxDB. The URL for InfluxDB will be `http://INFLUXDB_HOST:INFLUXDB_PORT`. Database name is 'k8s'. Default user name and password is 'root'. Grafana documentation for InfluxDB [here](http://docs.grafana.org/datasources/influxdb/).

# 开发环境

https://www.ibm.com/developerworks/cn/opensource/os-kubernetes-developer-guide/index.html

# 案例分享

[DockOne微信分享（一四二）：容器云在万达的落地经验](http://dockone.io/article/2730)    这里有不少的干货，包含kubemaster的高可用，Etcd的高可用，存储的方案，ceph的使用。网络的Open VSwitch的开发是基于`OpenShift SDN` .

请参考：
[https://github.com/docker/distribution/blob/master/docs/deploying.md](https://github.com/docker/distribution/blob/master/docs/deploying.md)
[左耳朵耗子写的一些关于docker的文章](http://coolshell.cn/tag/docker)
[https://blog.docker.com/2013/07/how-to-use-your-own-registry/](https://blog.docker.com/2013/07/how-to-use-your-own-registry/)

[唯品会基于Kubernetes的网络方案演进](http://dockone.io/article/1815)  这个有讲到用HAProxy来实现公网IP访问。

[Kubernetes 有状态集群服务部署与管理](http://dockone.io/article/2016)    这里有不少干货，不错。 [这里是infoQ上的视频](http://www.infoq.com/cn/presentations/kubernetes-stateful-cluster-service-deployment-and-management)

https://www.safaribooksonline.com/library/view/kubernetes-cookbook/9781785880063/

[基于Jenkins和Kubernetes的CI工作流](http://dockone.io/article/2114)

[使用JENKINS实现CI/CD【ZOUES](http://www.zoues.com/2017/03/19/%E4%BD%BF%E7%94%A8kubernetes-jenkins%E5%AE%9E%E7%8E%B0cicd%E3%80%90zoues-com%E3%80%91/)
