MySQL备忘
-------

# 数据库设计
## UUID做为PK的问题

http://kccoder.com/mysql/uuid-vs-int-insert-performance/   

```
Conclusion

As you can see innodb_uuid_no_key performs closely to its integer counterparts, innodb_uuid_no_key_indexed exhibits the same trend as innodb_uuid to a much less severe degree and innodb_uuid_no_key_unique_indexed is nearly identical to innodb_uuid. So the unique index appears to be the issue here. But why? Well, given the above information, I'd say that MySQL is unable to buffer enough data to guarantee a value is unique and is therefore caused to perform a tremendous amount of reading for each insert to guarantee uniqueness. 
```

下面的这篇文章使用binary的方式来保存UUID，同时用一个computed column来显示这个uuid。
[Storing UUID Values in MySQL Tables](http://mysqlserverteam.com/storing-uuid-values-in-mysql-tables/)

这篇文章也是用二进制来保存的，可以看出来，insert 性能和bigint的差不多。
[Store UUID in an optimized way](https://www.percona.com/blog/2014/12/19/store-uuid-optimized-way/)


# 5.7 Full Group By 问题解决

UAT环境的MySQL 的版本为5.7，开发在测试时发现如下问题：

```
1.ERROR 1055 (42000): Expression #7 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'postscan.verifyDelayLog.auditor' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
```

上面的错误说明，应用所使用的SQL与MySQL的配置only_full_group_by不兼容。我们进入MySQL,查看一下当前的sql_mode。

```
mysql> select @@sql_mode;
+-------------------------------------------------------------------------------------------------------------------------------------------+
| @@sql_mode |
+-------------------------------------------------------------------------------------------------------------------------------------------+
| ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION |
+-------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

确认是启用了ONLY_FULL_GROUP_BY，需要把它从sql_mode中移除。

```
mysql> set @@global.sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
```

解决方法，修改 /etc/mysql/mysql.conf.d/mysqld.cnf，在[mysqld]这节下面添加下面的行：

```
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
```

重新启动后，问题解决。

# 常用命令

## 授权 Grant

MySQL 8.0之前：

```
grant all privileges on dayiguoyi.* to rails@'%' identified by '1q2w3e4r' with grant option;

FLUSH PRIVILEGES 
```

`MySQL 8.0以后：`

```
CREATE USER 'jeffrey'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON db1.* TO 'jeffrey'@'localhost';
GRANT SELECT ON db2.invoice TO 'jeffrey'@'localhost';
ALTER USER 'jeffrey'@'localhost' WITH MAX_QUERIES_PER_HOUR 90;
```

=== 授权用户除drop以外的基本权限. ===  

```sql
GRANT ALTER,ALTER ROUTINE,CREATE,CREATE ROUTINE,CREATE VIEW,DELETE,EXECUTE,INDEX,INSERT,LOCK TABLES,SELECT,SHOW VIEW,UPDATE ON DB_Moqee.* TO 'xiaopaozi'@'xxx.xxx.xxx.xxx' IDENTIFIED BY 'dummy' WITH GRANT OPTION;  
```

收回某个权限
```
revoke drop ON DB_XXX..* from 'loginid'@'%'; 
```

  
=== 授权用户除drop以外的基本权限给所有的IP(5.0). ===  
GRANT ALTER,ALTER ROUTINE,CREATE,CREATE ROUTINE,CREATE VIEW,DELETE,EXECUTE,INDEX,INSERT,LOCK TABLES,SELECT,SHOW VIEW,UPDATE ON DB_WAP.* TO 'WapUser'@'%' IDENTIFIED BY '1q2w3e4r' WITH GRANT OPTION;  
  
### 显示用户的权限

```sql
SHOW GRANTS FOR 'xxx'@'123.456.789.001'  
SHOW GRANTS FOR CURRENT_USER();  
```

  
### 查看所有的用户
```
select User,Host from mysql.user;  
```

## 备份和恢复

### 备份backup
```
mysqldump -h 192.168.0.1 -uxxxx -pxxx --defualt-character--set=UTF-8  DB_Temp   --tables T_Adapt_Format > /home/jacky/MyFiles/backup 
```
 
如果只想导出数据库的结构，而不是所有的数据，请使用--no-data, -d这个选项。  

### 恢复restore

```
mysql -u root -p DB_Temp < /home/jacky/MyFiles/  
```

## 修改root密码

```
$ mysqladmin -u root -p  password 'new-password'  
```

## 停止当前的MySQL服务 shutdown MySQL Service

```
$mysqladmin shutdown  
```

## 查看配置内容

```
=== 查看mysql 服务的运行选项,如data路径,配置文件的路径等. ===  
mysqld --help --verbose  
  
或是登录到mysql服务器，运行命令：  
show variables;  
```

  

## 查看连接数  

```
mysql> show processlist;  
```

  
## 打開查詢日志

```
mysql> set global general_log='on';  
mysql> set global general_log_file = '/tmp/mysql-query.log';  
```

  
## 运行多个实例
=== find out what operating parameters ===  
shell> mysqladmin --host=HOST_NAME --port=PORT_NUMBER variables  
=== Running multiple servers on unix. ===  

```
shell> bin/mysqld_safe --datadir=/usr/local/share/mysql4/data --socket=/tmp/mysql4.sock --port=3308 --user=mysql&
```
