Ansible Notes
-----


Documentation for each module can be accessed from the command line with the ansible-doc tool:
```
$ ansible-doc yum
```

A list of all installed modules is also available:
```
$ ansible-doc -l
```

```
$ ansible-playbook playbook.yml --list-hosts
```

```
$ ansible-playbook $WORKSPACE/cicd/ansible/account-api-container.yml --extra-vars "repository=$REPOSITORY image_name=$IMAGE_NAME image_version=$IMAGE_VERSION"
```

ansible -m debug -a "var=hostvars['hostname']" localhost

如果我们不需要收集主机的信息请使用`gather_facts: False`
```
- hosts: os_CentOS
  gather_facts: False
  tasks:
     - # tasks that only happen on CentOS go here
```

# docker

如果报错：
```
"Error: docker-py version is 1.10.2. Minimum version required is 1.7.0."
```
这是个bug:
docker-py version is checked incorrectly #17495

https://github.com/ansible/ansible/pull/17496
修改的文件为：`/usr/lib/python2.7/site-packages/ansible/module_utils/docker_common.py`


用ansible安装docker engine时一定不要忘记设置开机自动启动！



# Host key checking 
在/etc/ansible/ansible.cfg里可以禁用。



https://stackoverflow.com/a/23094433


#Become
有些操作需要root权限，而如果你希望用sudo来做，可以在ansible.cfg里配置一下。
become: yes
become_method: sudo


