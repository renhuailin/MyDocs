# PostgreSQL

------

## 命令行工具

在debian上首次安装后，需要使用`postgres`的身份进入`psql`，然后修改密码。

```
$ sudo -u postgres psql

postgres=# ALTER USER postgres WITH PASSWORD 'your_password';

```



```
$ psql -U <用户名>

#有时间会找不到本地的sock，可以用-h来指定主机
$ psql -h 127.0.0.1 -U postgres

# 指定编码
$ psql -U 用户名 -d 数据库名 -h 主机名 -p 端口号 -E 编码名称
$ psql --username=用户名 --dbname=数据库名 --host=主机名 --port=端口号 --encoding=编码名称




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

### 查看表
```
\d[S+]                 list tables, views, and sequences
\dt                    list tables
```

### 查看表结构
```
\d table1
```


### List all users
List all user accounts (or roles) in the current PostgreSQL database server
```
postgres-# \du
postgres-# \du+
```

如果有活动的连接，会无法删除，如果想硬删除，请看这里：

[How to drop a PostgreSQL database if there are active connections to it? - Stack Overflow](https://stackoverflow.com/questions/5408156/how-to-drop-a-postgresql-database-if-there-are-active-connections-to-it)

### 允许远程访问

在MySQL中，如果我们想让MySQL可以远程访问，需要修改配置文件，让MySQL的进程监听在0.0.0.0上。同时需要创建一个远程用户。

跟MySQL不同，PostgreSQL没有远程用户这个说法，它的用户是不区分本地或是远程的。

如果要允许远程连接或允许从容器里访问，首先要修改pg的配置，不能让它监听在`127.0.0.1`或`localhost`上,要监听在本地IP上。同时还要修改`pg_hba.conf`。


首先登录到psql上，找到配置文件的位置。

```
postgres=#  SHOW config_file;
               config_file
-----------------------------------------
 /etc/postgresql/15/main/postgresql.conf
(1 row)
```


默认pg是监听在localhost上的,在配置文件中找到下面一行：
```
#listen_addresses = 'localhost'
```
去掉注释，改为本地IP，多个IP要使用逗号来分隔。
```
listen_addresses = 'localhost,127.0.0.1,192.168.1.2'
```


接下来要修改hba文件。
```
postgres=# show hba_file;
```
**注意：** 不要忘掉结尾的分号`;`。

就会显示pg_hba.conf的绝对路径了。
可以先查看一下它的内容
```
# This file controls: which hosts are allowed to connect, how clients
# are authenticated, which PostgreSQL user names they can use, which
# databases they can access.  Records take one of these forms:
#
# local         DATABASE  USER  METHOD  [OPTIONS]
# host          DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostssl       DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostnossl     DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostgssenc    DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostnogssenc  DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# (The uppercase items must be replaced by actual values.)
#
# The first field is the connection type:
# - "local" is a Unix-domain socket
# - "host" is a TCP/IP socket (encrypted or not)
# - "hostssl" is a TCP/IP socket that is SSL-encrypted
# - "hostnossl" is a TCP/IP socket that is not SSL-encrypted
# - "hostgssenc" is a TCP/IP socket that is GSSAPI-encrypted
# - "hostnogssenc" is a TCP/IP socket that is not GSSAPI-encrypted
#
# DATABASE can be "all", "sameuser", "samerole", "replication", a
# database name, or a comma-separated list thereof. The "all"
# keyword does not match "replication". Access to replication
# must be enabled in a separate record (see example below).
#
# USER can be "all", a user name, a group name prefixed with "+", or a
# comma-separated list thereof.  In both the DATABASE and USER fields
# you can also write a file name prefixed with "@" to include names
# from a separate file.
#
# ADDRESS specifies the set of hosts the record matches.  It can be a
# host name, or it is made up of an IP address and a CIDR mask that is
# an integer (between 0 and 32 (IPv4) or 128 (IPv6) inclusive) that
# specifies the number of significant bits in the mask.  A host name
# that starts with a dot (.) matches a suffix of the actual host name.
# Alternatively, you can write an IP address and netmask in separate
# columns to specify the set of hosts.  Instead of a CIDR-address, you
# can write "samehost" to match any of the server's own IP addresses,
# or "samenet" to match any address in any subnet that the server is
# directly connected to.
#
# METHOD can be "trust", "reject", "md5", "password", "scram-sha-256",
# "gss", "sspi", "ident", "peer", "pam", "ldap", "radius" or "cert".
# Note that "password" sends passwords in clear text; "md5" or
# "scram-sha-256" are preferred since they send encrypted passwords.
#
# OPTIONS are a set of options for the authentication in the format
# NAME=VALUE.  The available options depend on the different
# authentication methods -- refer to the "Client Authentication"
# section in the documentation for a list of which options are
# available for which authentication methods.
#
# Database and user names containing spaces, commas, quotes and other
# special characters must be quoted.  Quoting one of the keywords
# "all", "sameuser", "samerole" or "replication" makes the name lose
# its special character, and just match a database or username with
# that name.

# TYPE  DATABASE  USER  CIDR-ADDRESS  METHOD
host  all  all 0.0.0.0/0 md5
```

这个文件的注释部分详细介绍了这个文件的格式。
要注意，第一列和第四列是配合着使用的。

编辑它，加入下面的内容，重启postgresql的服务。


## 用户和角色

```
The concept of roles subsumes the concepts of “users” and “groups”. In PostgreSQL versions before
8.1, users and groups were distinct kinds of entities, but now there are only roles. Any role can act
as a user, a group, or both.
```

8.1以后的版本，只有角色了，它也是用户、组或是两者都是。


## backup and restore

### 备份数据库

```
pg_dump dbname > outfile
```

https://tembo.io/docs/postgres_guides/how-to-backup-and-restore-a-postgres-database


### 恢复数据库

PG backup生成的备份文件里不会生成`drop database`这样的命令,如果要恢复到一个已存在的数据库，需要在使用`pg_restore`恢复时指定`--clean`参数。
```
$ pg_restore -U <username> -d <database> --clean  xxxxxx.tar
```


## docker image

默认的user:`postgres`,默认的密码需要在启动时指定。

## Migrate data from MySQL to PostgreSQL

[pgLoader](https://github.com/dimitri/pgloader)
我现在用的20.04自带的pgLoader有问题，无法支持PG14，13.x都可以。
https://techdocs.broadcom.com/us/en/ca-enterprise-software/layer7-api-management/api-developer-portal/4-5/install-configure-and-upgrade/install-portal-on-docker-swarm/migrating-portal-data-from-postgresql-to-mysql.html
