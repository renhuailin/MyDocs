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