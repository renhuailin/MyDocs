# PostgreSQL

------
## 1. 数据类型

### 1.1 json和jsonb

简单来说，**`json` 存储原始文本，`jsonb` 存储优化过的二进制格式**。这导致了它们在性能、功能和存储上的核心差异。

#### 核心区别总结

| 特性 (Feature) | `json` 类型                               | `jsonb` 类型                                                              |
| :----------- | :-------------------------------------- | :---------------------------------------------------------------------- |
| **存储格式**     | **纯文本 (Text)**                          | **二进制 (Binary)**                                                        |
| **输入/写入速度**  | **更快**。因为它只检查JSON是否合法，然后原样存入。           | **稍慢**。因为它需要解析JSON文本，转换为优化的二进制格式再存入。                                    |
| **处理/查询速度**  | **慢得多**。每次查询都需要重新解析整个JSON文本。            | **快得多**。因为数据已是预解析的二进制格式，查询时无需重复解析。                                      |
| **索引支持**     | 有限。只能在整个JSON文档上创建B-tree索引（用于精确匹配）或哈希索引。 | **非常强大**。支持 **GIN** (Generalized Inverted Index) 索引，可以高效地索引JSON内的所有键和值。 |
| **格式保留**     | **保留**。会完整保留原始JSON的空格、键的顺序和重复的键。        | **不保留**。会移除空格，不保证键的顺序，且如果存在重复的键，**只会保留最后一个**。                           |
| **验证**       | 仅验证是否是合法的JSON。                          | 验证并进行语义解析，例如对重复键进行处理。                                                   |

---

#### 详细解析与类比

你可以这样理解：

*   **`json` 类型**：就像你把一份合同（JSON字符串）的 **扫描件（图片）** 存入档案柜。
    *   **存入快**：扫描一下直接放进去就行。
    *   **查找慢**：当你需要找合同里 "条款A" 的内容时，你必须把每份扫描件都拿出来，用眼睛从头到尾阅读一遍，才能找到。
    *   **保真**：扫描件和你手里的原件一模一样，包括排版、签名位置等。

*   **`jsonb` 类型**：就像你把合同里的所有信息 **录入到一个结构化的数据库系统** 里。
    *   **存入慢**：你需要花时间阅读合同，把“甲方”、“乙方”、“金额”、“条款A”、“条款B”等信息分门别类地录入系统。这个过程就是解析和转换。
    *   **查找极快**：当你需要找 "条款A" 的内容时，你直接在系统里查询 `条款A` 字段，系统能瞬间定位到结果。尤其是你给这个字段建了索引之后。
    *   **不保真**：录入系统后，原始合同的排版、字体、空格就都丢失了，只保留了核心数据。如果合同里有两个叫 "备注" 的条款，录入系统时可能只会保留最后一个。

---

#### 应用场景 (When to use which?)

根据上述区别，选择就变得很清晰了。

#### 使用 `json` 的场景（非常少见）

你应该只在以下特定情况下才考虑使用 `json`：

1.  **严格需要保留原始格式**：
    你的应用是一个日志系统、审计系统或数据中转站，必须保证存入的 JSON 和取出的 JSON 在文本上一字不差，包括空格、键的顺序、甚至重复的键。某些旧系统可能对 JSON 键的顺序有依赖（虽然这是不好的设计）。

2.  **写多读少，且不关心内部数据**：
    你只是把 PostgreSQL 当作一个 JSON 文档的“存储桶”，写入操作非常频繁，但几乎从不对 JSON 内部的键值进行查询、过滤或分析。在这种情况下，`json` 的写入性能优势可能会体现出来。

**总结：除非你有“必须保存原始文本”的硬性要求，否则基本不用 `json`。**

#### 使用 `jsonb` 的场景（绝大多数情况）

**在99%的情况下，`jsonb` 都是更好的选择。**

1.  **需要对 JSON 数据进行查询**：
    这是最常见的场景。你需要根据 JSON 对象中的某个键的值来过滤数据，例如：`WHERE user_profile->>'city' = '北京'`。`jsonb` 在这种查询上性能远超 `json`。

2.  **需要为 JSON 的键值创建索引**：
    如果你的数据量很大，并且查询频繁，那么索引是必不可少的。`jsonb` 支持强大的 GIN 索引，可以极大地加速查询。这是 `jsonb` 的“杀手级”特性。
    ```sql
    -- 为 user_profile 字段中的所有键值对创建 GIN 索引
    CREATE INDEX idx_gin_user_profile ON users USING GIN (user_profile);
    
    -- 为特定的路径创建索引，提高特定查询的效率（PG 12+）
    CREATE INDEX idx_gin_user_city ON users USING GIN ((user_profile->'city'));
    ```

3.  **需要对 JSON 数据进行更新和操作**：
    PostgreSQL 提供了丰富的函数来操作 `jsonb` 类型，如添加键值对 (`jsonb_set`)、删除键 (`-`) 等。这些操作在 `jsonb` 上更高效。

4.  **数据清洗和规范化**：
    由于 `jsonb` 会去除不必要的空格并处理重复键，它自然地对数据进行了一层清洗和规范化，确保了存储的数据结构更加一致。

---

#### 示例代码

让我们看一个实际的例子来感受区别：

```sql
-- 创建一个表，同时包含 json 和 jsonb 类型的列
CREATE TABLE test_json (
    id serial primary key,
    data_json json,
    data_jsonb jsonb
);

-- 插入一个带有额外空格、特定顺序和重复键的 JSON 字符串
INSERT INTO test_json (data_json, data_jsonb)
VALUES
(
  '{ "name": "Alice", "active": true, "items": [1, 2], "name": "Bob"  }',
  '{ "name": "Alice", "active": true, "items": [1, 2], "name": "Bob"  }'
);

-- 查询并查看结果
SELECT * FROM test_json;
```

**查询结果：**

| id | data_json | data_jsonb |
| :-- | :--- | :--- |
| 1 | `{ "name": "Alice", "active": true, "items": [1, 2], "name": "Bob"  }` | `{"name": "Bob", "items": [1, 2], "active": true}` |

**观察结果：**

*   `data_json` 列：**原封不动**地保留了所有内容，包括结尾的空格和两个 `"name"` 键。
*   `data_jsonb` 列：
    *   多余的空格被**移除**了。
    *   键的顺序被**重排**了（按字母或长度等内部规则）。
    *   重复的 `"name"` 键，只**保留了最后一个** `"name": "Bob"`。

#### 最终建议

**经验法则：始终默认使用 `jsonb`**，除非你有一个非常明确且强烈的理由去使用 `json` 来保留原始文本。`jsonb` 提供的查询性能和索引能力对于绝大多数应用来说都是至关重要的。


#### 查询
```sql
SELECT 
count(id)  as  "totalLeadCount",
COUNT(*) FILTER (WHERE "synchronizationStatus"->'转接状态'->>'status' = '转接成功' ) AS "transferCount",
COUNT(*) FILTER (WHERE "synchronizationStatus"['瓜子二手车']['leadState'] = '1'::jsonb) AS "validLeadsCount"
FROM public."UsedCarLeads"
where  
-- -- and  "synchronizationStatus" ? '瓜子二手车'
"submitter" = 47
and "createdAt" >= '2025-11-28'::date
```

#### 参考文献
[An introduction to working with JSON data in PostgreSQL](https://medium.com/@suffyan.asad1/an-introduction-to-working-with-json-data-in-postgresql-730aa889c5d3)

### 日期 Datetime & Timestamp

这是一个非常棒的思路！**把时间转换成 Unix Timestamp（时间戳）进行比对，是彻底消除“时区差”和“格式化”烦恼的终极手段。**

因为 Unix 时间戳是一个绝对数值（从 1970年1月1日 UTC 到现在的秒数或毫秒数），它不携带任何时区信息，**全球统一**。


在 PostgreSQL 中，使用 `EXTRACT(EPOCH FROM ...)` 函数可以将 `timestamp` 或 `timestamptz` 转换为 Unix 时间戳（**单位是秒**）。

```sql
-- 返回的是秒，带小数（微秒精度），例如: 1700452800.123456
SELECT EXTRACT(EPOCH FROM "createdAt") FROM "User";
```


这里有一个关键的单位换算问题：
*   **Postgres**: `EXTRACT(EPOCH ...)` 出来的单位是 **秒 (Seconds)**。
*   **JavaScript**: `Date.getTime()` 或 `Date.now()` 出来的单位是 **毫秒 (Milliseconds)**。

**你必须在其中一边做乘除法来对齐单位。**

#### Prisma `queryRaw` 实战代码

建议在 SQL 里把单位统一成**毫秒**（乘以 1000），这样可以直接跟 JS 的 `date.getTime()` 对比，也不会丢失毫秒级的精度。

#### 场景：查询某个时间点之后创建的用户

```typescript
// 1. 获取 JS 时间的毫秒数 (Unix Timestamp in MS)
const targetDate = new Date('2023-11-20 12:00:00');
const targetTimestamp = targetDate.getTime(); // 例如 1700452800000

// 2. 执行 Raw Query
// 注意 SQL 中：EXTRACT(EPOCH FROM "createdAt") * 1000
const users = await prisma.$queryRaw`
  SELECT id, "createdAt"
  FROM "User"
  WHERE (EXTRACT(EPOCH FROM "createdAt") * 1000) > ${targetTimestamp}
`;
```

#### 进阶：如果你想直接 SELECT 出数字

如果你想让查询结果里直接包含时间戳数字，方便前端或其他逻辑处理：

```typescript
const result = await prisma.$queryRaw`
  SELECT 
    id, 
    -- 强制转为 bigint 整数，去掉小数点，单位毫秒
    CAST(EXTRACT(EPOCH FROM "createdAt") * 1000 AS BIGINT) as "createdAtTs"
  FROM "User"
`;

// result[0].createdAtTs 将会是一个类似于 1700452800000 的数字 (BigInt)
// 注意：在 JS 中 BigInt 不能直接 JSON.stringify，需要处理一下
console.log(Number(result[0].createdAtTs)); 
```

####  关于性能的补充（索引优化）

使用函数 `EXTRACT(EPOCH FROM ...)` 作为查询条件时，如果数据量极大（几百万行），标准的 `createdAt` 索引可能不会被高效利用。

如果你非常依赖这种查询方式，可以在 Postgres 里加一个**函数索引**：

```sql
-- 在数据库里手动执行
CREATE INDEX idx_user_createdat_epoch ON "User" ((EXTRACT(EPOCH FROM "createdAt")));
```

### 总结

你的方法非常稳健：
1.  **JS 端**：用 `date.getTime()` 获取毫秒整数。
2.  **PG 端**：用 `EXTRACT(EPOCH FROM "createdAt") * 1000` 转成毫秒数值。
3.  **比对**：直接比大小。

**没有时区，没有字符串解析，只有纯粹的数字比较。完美！**


## 2. 命令行工具

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

先查看一下日志，看看你的容器的 IP 是多少

```
tail -f /var/log/postgresql/postgresql-15-main.log
```
通常我们会看到类似下面的内容
```
postgres@qianshou FATAL:  no pg_hba.conf entry for host "172.23.0.2", user "xxxxx", database "qianshou", SSL encryption
```

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

 hba_file
-------------------------------------
 /etc/postgresql/15/main/pg_hba.conf
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


pg_dump -h 127.0.0.1  -U postgres -d qianshou > qianshou.bak
```

https://tembo.io/docs/postgres_guides/how-to-backup-and-restore-a-postgres-database


To dump a single table named `mytab`:

```
$ pg_dump -t mytab mydb > db.sql 
```

`-a`  
`--data-only`


```
$ pg_dump  -a -t mytab mydb > db.sql 
```

### 恢复数据库

PG backup生成的备份文件里不会生成`drop database`这样的命令,如果要恢复到一个已存在的数据库，需要在使用`pg_restore`恢复时指定`--clean`参数。
```
$ pg_restore -U <username> -d <database> --clean  xxxxxx.tar
```


## 查询
psql默认使用了分页器（pager），通常是 less 或 more，来显示查询结果，特别是当结果超过一屏时。这在浏览大量数据时很有用，但在你描述的场景下（比如想边看主键边写 DELETE 语句）确实不方便。

有几种方法可以禁止 psql 使用分页器，让结果直接输出到命令行窗口：

1. **在 psql 会话中临时关闭分页器：**  
    这是最常用的方法，只在当前会话中生效。
    
    ```
    \pset pager off
    -- 或者
    \pset pager 0
    ```
    
    执行这个命令后，后续的查询结果就会直接打印到屏幕上。  
    如果你想再次启用分页器（比如之后要查一个非常大的表），可以执行：
    
    ```
    \pset pager on
    -- 或者
    \pset pager 1
    ```


## 更新
### 使用触发器自动更新updateAt列

```sql
-- 首先要定义一个function,
BEGIN
    NEW."updatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;

-- 然后在一个表上创建触发器，调用这个function.
CREATE TRIGGER trg_update_updated_at_column
BEFORE UPDATE ON public."SecondCarLeads"
FOR EACH ROW                          -- 对每一行受影响的行执行
EXECUTE FUNCTION update_updated_at_column();

```






### Rename table name

```sql
ALTER TABLE "OldTable" RENAME TO "NewTable";
```






## docker image

默认的user:`postgres`,默认的密码需要在启动时指定。

# Migrate data from MySQL to PostgreSQL

[pgLoader](https://github.com/dimitri/pgloader)
我现在用的20.04自带的pgLoader有问题，无法支持PG14，13.x都可以。
https://techdocs.broadcom.com/us/en/ca-enterprise-software/layer7-api-management/api-developer-portal/4-5/install-configure-and-upgrade/install-portal-on-docker-swarm/migrating-portal-data-from-postgresql-to-mysql.html

可以使用pgLoader的docker image

下面的使用就可以一键把MySQL的库迁移到PostgreSQL中。
```
pgloader mysql://<Mysql user>:<password>@<ip or hostname >/<dbname> pgsql://<pg user>:<password>@<ip or hostname >/<pg database>


pgloader mysql://billgates:m!cr0soft@192.168.1.44/mydb pgsql://billgates:m!cr0soft@192.168.1.44/mydb
```




# AI 问答

## 1.  对于pg的表，数据量达到多少量级的时候，会出现性能瓶颈，就需要考虑使用新的分区表了？

对于 PostgreSQL 的单表性能瓶颈，通常有三个关键阈值。

以你的 `point_logs`（积分流水）表为例，假设每行数据大约 200 字节，包含 `id`, `user_id`, `created_at` 等索引：

### 1. **2000 万行 - 舒适区上限**
*   **状态**：此时表大小约 4GB - 8GB。
*   **性能**：在这个量级下，B-Tree 索引高度通常为 3 层，查询非常快（毫秒级）。
*   **运维**：备份、恢复、VACUUM（垃圾回收）都很快，几乎无感知。
*   **建议**：完全不需要分区，单表跑得飞起。

### 2. **5000 万行 - 性能拐点 (Soft Limit)**
*   **状态**：表大小约 10GB - 20GB。
*   **性能**：
    *   **写入**：依然很快。
    *   **查询**：如果你做复杂的 `JOIN` 或大范围扫描（例如统计某用户一年的积分），IO 压力开始显现。内存缓存命中率下降。
    *   **索引**：索引可能膨胀到几个 G，导致部分查询变慢。
*   **建议**：**开始规划分区**。这是最佳的分区介入时机。你可以平滑地创建新分区，把新数据引流过去。

### 3. **1 亿行 - 硬瓶颈 (Hard Limit)**
*   **状态**：表大小约 20GB - 50GB。
*   **性能**：
    *   **维护困难**：一次 `VACUUM FULL` 可能锁表数小时。
    *   **写入抖动**：频繁的 Checkpoint 和 Autovacuum 会导致写入延迟增加。
    *   **查询慢**：大范围查询如果不走索引，几乎不可用。
*   **风险**：此时再想做分区迁移（Migrate），涉及大量数据搬运，通常需要停机维护或复杂的在线迁移工具（如 `pg_repack`）。

### 总结建议

**监控指标：**
关注你的 `point_logs_default` 表的大小。当它达到 **10GB** 或 **3000 万行** 时，就是你动手创建 `point_logs_2026`（或者按月分区）的最佳时刻。

**当前策略：**
现在用 `DEFAULT` 分区完全没问题。设置一个监控告警（比如 Prometheus/Grafana），当行数超过 3000 万时提醒你，到时候执行一句 SQL 建个新分区即可，完全来得及。

## 2  在带分区的表中，如果要使用RLS，是不是在主表上创建策略就行了，我需要为每个具体的分区表再创建策略吗？


这是一个关于 PostgreSQL 分区表和 RLS（行级安全）结合的非常关键的问题。

答案是：**在绝大多数情况下，你只需要在主表（Partitioned Table）上创建 RLS 策略即可，不需要为每个具体的子分区表重复创建。**

但是，这里有几个重要的细节和“坑”需要注意，特别是当你使用自动分区工具或手动维护分区时。

### 1. 为什么只需要在主表上创建？

PostgreSQL 的设计哲学是：**子分区表继承主表的属性和策略。**

当你执行查询时（例如 `SELECT * FROM point_logs`），PostgreSQL 会经历以下过程：
1.  **解析主表**：优化器看到你要查 `point_logs`（主表）。
2.  **应用 RLS**：优化器发现主表上有 RLS 策略 `tenant_isolation_policy`，于是把 `tenant_id = current_setting(...)` 这个条件附加到查询树中。
3.  **分区裁剪**：优化器根据附加的条件和查询中的其他条件（如 `created_at`），决定扫描哪些子分区。
4.  **执行查询**：在选定的子分区上执行带有 RLS 过滤条件的查询。

**结论**：因为 RLS 策略在查询解析阶段就已经被附加到了主表上，所以它会自动、隐式地应用到所有被扫描的子分区。你不需要（也不应该）在子表上重新定义策略。

### 2. 前提条件：子表必须通过主表访问

这个机制生效的一个核心前提是：**你的应用层代码必须始终通过主表名来访问数据。**

*   **正确（受 RLS 保护）**：
    `SELECT * FROM point_logs WHERE id = 123;`
    （通过主表 `point_logs` 查询，RLS 生效）
*   **错误（可能绕过 RLS）**：
    如果你有一个老旧的脚本或特定业务逻辑，直接去查某个具体的子表：
    `SELECT * FROM point_logs_2024_05 WHERE id = 123;`
    **警告**：如果子表本身没有定义 RLS 策略，直接访问子表**不会**触发主表的 RLS 策略！数据将完全暴露。

### 3. 如何防止“直接访问子表绕过 RLS”的安全漏洞？

为了确保绝对的安全（Zero Trust），特别是对于大健康系统，你需要防止任何人（包括开发人员的临时脚本）直接访问子表而绕过隔离。

#### 最佳实践：也在子表上强制开启 RLS

虽然查询主表时会自动应用策略，但为了防止上述“直接访问子表”的漏洞，**你应该在创建每个子表时，也强制开启 RLS 并绑定策略。**

但这听起来很麻烦，每次建新分区都要写一遍 `CREATE POLICY` 吗？
**不需要！**

你可以利用 PostgreSQL 的一个特性：**子表会自动继承主表的 RLS 策略，但前提是子表必须手动启用 RLS。**

#### 操作步骤：

1.  **在主表上开启 RLS 并创建策略（只需做一次）**：
    ```sql
    ALTER TABLE point_logs ENABLE ROW LEVEL SECURITY;
    
    CREATE POLICY tenant_isolation_policy ON point_logs
        USING (tenant_id = current_setting('app.current_tenant_id')::bigint);
    ```

2.  **在创建新子分区时，仅仅“开启”RLS 即可**：
    当你新建 2025 年的分区时，执行：
    ```sql
    CREATE TABLE point_logs_2025 PARTITION OF point_logs
        FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
    
    -- 关键：只开启 RLS，不写 CREATE POLICY
    ALTER TABLE point_logs_2025 ENABLE ROW LEVEL SECURITY;
    ```

**原理解析：**
因为子表 `point_logs_2025` 继承自 `point_logs`，它已经继承了 `tenant_isolation_policy` 策略的定义。但是，表的 `row_security` 属性（即是否开启 RLS）是**不继承**的。
只要你对子表执行了 `ENABLE ROW LEVEL SECURITY`，即使有人直接执行 `SELECT * FROM point_logs_2025`，继承来的策略也会生效，阻止越权访问。

### 4. 总结与建议架构

对于你的 Drizzle + PostgreSQL 亿级系统：

1.  **日常开发**：你的 Drizzle schema 只映射主表。所有 CRUD 操作全部针对主表，RLS 会完美自动下发到子表。
2.  **运维建表规范**：
    无论是你写 Flyway/Drizzle 迁移脚本，还是 DBA 手动建分区表，**必须将 `ALTER TABLE 子表名 ENABLE ROW LEVEL SECURITY;` 作为建表规范的标配步骤。**
3.  **如果使用了自动化分区工具 (如 `pg_partman`)**：
    你需要配置 `pg_partman` 在创建新分区时，自动应用一段 template 脚本来 `ENABLE ROW LEVEL SECURITY`。通常它会继承主表的权限，但 RLS 开关建议通过钩子（Hook）或触发器再次确认开启。