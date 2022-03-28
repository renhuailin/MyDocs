# PostgreSQL

------

## 命令行工具

```
$ psql

#这就是进入以后的PG的命令行提示符,获取帮助请输入\?
postgres-# \?
```

```
\? [commands]          show help on backslash commands
\? options             show help on psql command-line options
\? variables           show help on special variables
\h [NAME]              help on syntax of SQL commands, * for all commands
```



第一次登录进来时，是无需密码的。这时你是以postgres这个用户登录进来的。请用下面的命令来修改密码。

```
\password postgres
```

### 创建数据库

有两种方法：

一种是用`createdb`

```
$ createdb test
```

另外一种就是先执行psql进入psql的界面。

```
postgres-# CREATE DATABASE exampledb;
```

### 查看数据库

```
postgres-# \l
```

### 连接数据库

有两种方法：

一种是在用`psql`命令：

```
$ psql gitlab
```

另外一种就是在psql的界面。

```
postgres-# \c gitlab
用法
  \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
```

### 创建一个数据库用户并设置密码

```
CREATE USER dbuser WITH PASSWORD 'password';
```

把数据库所有权限赋给一个用户

```
GRANT ALL PRIVILEGES ON DATABASE exampledb to dbuser;
```

删除一个数据库

```
DROP DATABASE db_name WITH (FORCE);
```

如果有活动的连接，会无法删除，如果想硬删除，请看这里：

[How to drop a PostgreSQL database if there are active connections to it? - Stack Overflow](https://stackoverflow.com/questions/5408156/how-to-drop-a-postgresql-database-if-there-are-active-connections-to-it)

### 允许远程访问

在MySQL中，如果我们想让MySQL可以远程访问，需要修改配置文件，让MySQL的进程监听在0.0.0.0上。同时需要创建一个远程用户。

跟MySQL不同，PostgreSQL没有远程用户这个说法，它的用户是不区分本地或是远程的。如果要允许远程连接，除了要监听在`0.0.0.0`上,还要修改`pg_hba.conf`。

首先登录到psql上。

然后执行

```
show hba_file;
```

就会显示pg_hba.conf的绝对路径了。编辑它，加入下面的内容，重启postgresql的服务。

```
# TYPE  DATABASE  USER  CIDR-ADDRESS  METHOD
host  all  all 0.0.0.0/0 md5
```

## 用户和角色

```
The concept of roles subsumes the concepts of “users” and “groups”. In PostgreSQL versions before
8.1, users and groups were distinct kinds of entities, but now there are only roles. Any role can act
as a user, a group, or both.
```

8.1以后的版本，只有角色了，它也是用户、组或是两者都是。


# docker image

默认的user:`postgres`,默认的密码需要在启动时指定。


