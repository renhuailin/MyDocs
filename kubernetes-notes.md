Docker notes
-------------


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


# Service

Service是一组Pods的逻辑集合，和访问它们的相关策略，这些pods是通过Label Selector确定的。


### Services without selectors

Services without selectors，也就是后端不是Pods。
什么时候会用到无selector的Service呢？

* You want to have an external database cluster in production, but in test you use your own databases.
* You want to point your service to a service in another Namespace or on another cluster.
* You are migrating your workload to Kubernetes and some of your backends run outside of Kubernetes.

Q: Proxy-mode: userspace的Service工作原理？
A: 


Q: Proxy-mode: iptables 工作原理？


Q: 上述两种模式有什么区别？


Headless services      
如果以后两种模式你都不想要，那你可以定义`Headless services`.    
you can create “headless” services by specifying "None" for the cluster IP (spec.clusterIP).

## Publishing Service.
ServiceType

* **ClusterIP：** 只能集群内部访问。 
* **NodePort：**  映射到Node上某个Port，并且在每个Node上都使用相同Port。
* **LoadBalancer：** 使用云提供的Load Balancer。



# Volumes

## hostPath
这个是我们在用docker最常用的模式，但是在k8s里时要注意：

* when Kubernetes adds resource-aware scheduling, as is planned, it will not be able to account for resources used by a hostPath     k8s执行资源调度时，`hostPath`使用的资源（也就是磁盘容量了）不会被计算在内！！！


# Namespaces
Kubernetes supports multiple virtual clusters backed by the same physical cluster. These virtual clusters are called namespaces.

k8s支持物理集群上的多个虚拟集群，这些虚拟集群被称做`namespaces`.

# Service Accounts
A service account provides an identity for processes that run in a Pod.
service account我称之为服务账号为运行在Pod里的进程提供了一个身份。

# Daemon Set
A Daemon Set确保所有的节点都运行一个Pod的复本，当一个新的节点加入到集群时，这个pod就自动加入到这个。

典型的应用场景如为所有的节点提供存储的Pod，日志收集，监控。

DaemonSet管理的Pods用的是hostPort也，所以能用节点的IP直接访问。


# Deployment
Deployment为Pod和复本提供了一种声明式的升级方式，它是下一代的Replication Controller。


A typical use case is:
Create a Deployment to bring up a Replica Set and Pods.
Check the status of a Deployment to see if it succeeds or not.
Later, update that Deployment to recreate the Pods (for example, to use a new image).
Rollback to an earlier Deployment revision if the current Deployment isn’t stable.
Pause and resume a Deployment.


#  Ingress Resources

如果我们用的不GCE，AWS等云主机，是物理机那该如何配置loadbalancer？请参考：
https://github.com/kubernetes/contrib/tree/master/service-loadbalancer



# Horizontal Pod Autoscaling


目前只能跟deployment绑定。

目前主要是依据cpu来做scale,1.2版添加了自定义的metrics, like QPS (queries per second) or average request latency.
集群启动时`ENABLE_CUSTOM_METRICS`必须被设置为true.
The cluster has to be started with `ENABLE_CUSTOM_METRICS` environment variable set to true.

# Job
这个干嘛用的，还没研究明白



# Pet Set
一组有状态的Pods,有状态的东西都很麻烦。
A Pet Set, in contrast, is a group of stateful pods that require a stronger notion of identity.


请参考：
[https://github.com/docker/distribution/blob/master/docs/deploying.md](https://github.com/docker/distribution/blob/master/docs/deploying.md)
[左耳朵耗子写的一些关于docker的文章](http://coolshell.cn/tag/docker)
[https://blog.docker.com/2013/07/how-to-use-your-own-registry/](https://blog.docker.com/2013/07/how-to-use-your-own-registry/)
