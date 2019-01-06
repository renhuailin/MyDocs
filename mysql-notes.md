MySQL备忘
-------



# UUID做为PK的问题

http://kccoder.com/mysql/uuid-vs-int-insert-performance/   
```
Conclusion

As you can see innodb_uuid_no_key performs closely to its integer counterparts, innodb_uuid_no_key_indexed exhibits the same trend as innodb_uuid to a much less severe degree and innodb_uuid_no_key_unique_indexed is nearly identical to innodb_uuid. So the unique index appears to be the issue here. But why? Well, given the above information, I'd say that MySQL is unable to buffer enough data to guarantee a value is unique and is therefore caused to perform a tremendous amount of reading for each insert to guarantee uniqueness. 
```

下面的这篇文章使用binary的方式来保存UUID，同时用一个computed column来显示这个uuid。
[Storing UUID Values in MySQL Tables](http://mysqlserverteam.com/storing-uuid-values-in-mysql-tables/)


这篇文章也是用二进制来保存的，可以看出来，insert 性能和bigint的差不多。
[Store UUID in an optimized way](https://www.percona.com/blog/2014/12/19/store-uuid-optimized-way/)

关键是Java里要怎么写？



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

解决方法，修改 /etc/mysql/mysql.conf.d/mysqld.cnf，在[mysqld]这节下面添加下面的行：

```
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

```

重新启动后，问题解决。

