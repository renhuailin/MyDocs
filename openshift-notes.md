OpenStack备注
----

# OpenShift
http://www.pangxie.space/docker/989
http://www.pangxie.space/docker/964
http://dockone.io/article/946


cat > /etc/profile.d/openshift.sh << '__EOF__'
export OPENSHIFT=/opt/openshift-origin-v1.2
export OPENSHIFT_VERSION=v1.2.0
export PATH=$OPENSHIFT:$PATH
export KUBECONFIG=$OPENSHIFT/openshift.local.config/master/admin.kubeconfig
export CURL_CA_BUNDLE=$OPENSHIFT/openshift.local.config/master/ca.crt
__EOF__


./openshift start --write-config=openshift.local.config

cat > /etc/systemd/system/openshift-origin.service << '__EOF__'
[Unit]
Description=Origin Master Service
After=docker.service
Requires=docker.service
 
[Service]
Restart=always
RestartSec=10s
ExecStart=/opt/openshift-origin-v1.2/openshift start
WorkingDirectory=/opt/openshift-origin-v1.2
 
[Install]
WantedBy=multi-user.target
__EOF__


**注意**
我在安装后无法用`system:admin`这个用户登录，经查发现是`/etc/profile.d/openshift.sh`里配置路径`/openshift.daodeyun.com.config/`与`./openshift start --write-config=openshift.local.config`,请一定要使用`local`,不要使用你的域名，因为在`openshift start`生成config时，会生成3个目录，即使你指定了你的域名，生成的其它2个目录还是local的。

另外，使用`oc config view`可以查看openshift的配置情况。

用`system:admin`这个用户登录后会显示你有权限访问下面的项目，如果没有显示这些项目，你一定哪儿配置错了。


```
$ oc login -u system:admin -n default
You have access to the following projects and can switch between them with 'oc project <projectname>':

  * default (current)
  * openshift
  * openshift-infra

Using project "default".
```



You can view an image’s object definition by retrieving an ImageStreamImage definition using the image stream name and ID:

$ oc export isimage <image_stream_name>@<id>


$ oc import-image nginx --from=docker.io/nginx --confirm



[root@localhost system]# systemctl daemon-reload
[root@localhost system]# systemctl restart docker


`system:admin`这个用户无法登录registry，需要新建一个用户
创建一个普通用户user/openshift.     

X1dChgnPYUbQB4EK_T_ukxe4-m_Upa7iO7hYYADpiwI

QduhQicLcBYrihxC_pkQ-69O6PEJxOCXMZLHnTa6iKo

docker login -u user -p W8wbSyCh7hqbHT53rjPHEXB6JHgjR-r4BG9zwD-dJsc -e 123@qq.com 172.30.105.212:5000


获得所有的nodes

$ oc get nodes

Get all services.
$ oc get svc



$ oc status #显示当前的状态

```
In project default on server https://192.168.99.43:8443

svc/docker-registry - 172.30.209.245:5000
  dc/docker-registry deploys docker.io/openshift/origin-docker-registry:v1.2.1 
    deployment #1 failed 3 weeks ago

svc/kubernetes - 172.30.0.1 ports 443, 53, 53

View details with 'oc describe <resource>/<name>' or list everything with 'oc get all'.
```

191  oc login -u system:admin -n default
  192  oc login -u system -n default
  193  oc get svc
  194  oc --help
  195  oc logout
  196  oc
  197  oc login -u system -n default
  198  oc get nodes
  199  systemctl status openshift-origin -l
  200  docker ps
  201  ps -ef|grep docker
  202  reboot
  203  ls
  204  oc get service
  205  systemctl status openshift-origin -l
  206  oc logout
  207  oc login -u system -n default  # 这个是普通用户了，密码是openshift.
  208  oc get svc

### Router
用haproxy来做route,它必须要一Service account
 --host-network=true  使用route所在node的network stack.
 
 为什么要引入`Service Account` ?
 
 When a person uses the OpenShift Origin CLI or web console, their API token authenticates them to the OpenShift Origin API. However, when a regular user’s credentials are not available, it is common for components to make API calls independently. For example:

 Replication controllers make API calls to create or delete pods.

 Applications inside containers can make API calls for discovery purposes.

 External applications can make API calls for monitoring or integration purposes.

 Service accounts provide a flexible way to control API access without sharing a regular user’s credentials.

Service accounts提供一种灵活的方式来控制对API的访问，无需要分享一个普通用户的credentials.

Every service account has an associated user name that can be granted roles, just like a regular user. The user name is derived from its project and name:

每个service account都关联了一个用户名，像普通用户一样，这个用户名可以被分配角色。这个用户名源自项目和名字。

```
system:serviceaccount:<project>:<name>
```

