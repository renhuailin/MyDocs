SQLite Notes
---

# 1. 自增列

根据[SQLite的文档](https://www.sqlite.org/faq.html#q1),如果一个列被定义为`INTEGER PRIMARY KEY`，那它就是自增列了，你在插入数据时，给这个列`NULL`值就可以了。当然也你可以手工指定要插入的值。





# 2. 命令行

To display column attributes, enter `.headers ON`. 
To display rows in column style, enter `.mode column`. 



```
sqlite> select * from servers;
id          group_name  host           name        port        username    tags        comment     created_at  modified_at
----------  ----------  -------------  ----------  ----------  ----------  ----------  ----------  ----------  -----------
1           default     10.218.128.38  k8s-slave1  22          ubuntu      k8s,ubuntu  k8s slave1
```



# 3. Swift 例子

https://www.raywenderlich.com/385-sqlite-with-swift-tutorial-getting-started#toc-anchor-013

