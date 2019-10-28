Redis Notes
---------

# List 操作

```
#获取列表长度
127.0.0.1:6379> LLEN "huobi-candlesticks"
#获取列表的内容
127.0.0.1:6379> LRANGE mylist -100 100
```

# Auth 操作

```
 127.0.0.1:6379> CONFIG SET requirepass renhl.com
 127.0.0.1:6379> ping
 (error) NOAUTH Authentication required.

 127.0.0.1:6379> auth renhl.com
 127.0.0.1:6379> ping
 PONG
```

用 Sentinel来实现主从的自动切换。

# 关于数据库

redis的数据库是0序的，没有name。0是默认数据库。在集群环境下不能使用0以外的数据库。
