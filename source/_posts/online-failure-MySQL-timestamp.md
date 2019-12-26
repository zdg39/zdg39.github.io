---
title: 线上问题排查|MySQL:并发查询timestamp导致CPU使用率飙升
tags: MySQL
date: 2019-12-22 14:17:13
---

## 前言
最近遇见一个很奇怪的线上问题,就是生产环境MySQL(使用的是阿里云的RDS,版本号是5.7)的CPU莫名其妙地会被打满,导致整个服务不可用,最终耗费了很大的精力才定位到出现这个问题的原因。出现这类现象是因为当MySQL的time_zone=SYSTEM时,查询timestamp时会调用系统时区做时区转换,而系统时区存在全局锁,在并发大数据量访问会导致线程上下文频繁切换CPU使用率飙升,系统响应变慢。在排查问题时也在网上找了很多资料,但大都不是同一种问题,所以为这次排查做一次分享。本文为技术分享,可能有误望谅解。

## 问题现象
出现这个问题的业务逻辑是查询一张存储用户搜索词的表,统计出最近七天搜索最多的几个关键词。在正常情况下查询正常,如果并发量增加RDS的CPU使用率飙升并且出现慢查询,这条SQL耗时能达到10s以上。表中的数据在20w左右,存在一个联合索引,正常查询会走索引,数据表的表结构如下:

<!-- more -->

```SQL
***只列出了两个需要查询的字段***
CREATE TABLE `tb_search_keywords` (
  `keywords` varchar(255) NOT NULL DEFAULT '' COMMENT '搜索关键字',
  `t_crt_tm` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  KEY `idx_keywords_tcrttm` (`keywords`,`t_crt_tm`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='搜索关键字表';

```

使用的查询语句:
```SQL
SELECT
	a.keywords
FROM
	(
		SELECT
			k.keywords,
			count(1) c
		FROM
			tb_search_keywords k
		WHERE
			DATE_SUB(CURDATE(), INTERVAL 7 DAY) <= k.t_crt_tm
		AND LENGTH(k.keywords) > 3
		GROUP BY
			k.keywords
	) a
ORDER BY
	a.c DESC
LIMIT 8
```

## 问题复现
为了复现问题,首先将线上的20w数据导入测试环境(测试环境的MySQL没有使用阿里云的RDS机器,而是搭建在应用服务器上),然后对查询接口进行压测,开启20个线程请求测试环境,mysqld的CPU使用率马上就飙升,出现了和生产环境一样的问题。

![](/images/online-failure/MySQL-timestamp/mysqld-cpu.png)

## 排查步骤
首先连接上数据库,使用show processlist命令查看当前正在运行的线程,发现大量的查询处于sending data状态,sending data状态是正在读取和处理一个select语句的行，并发送数据到客户端，因为可能会发生物理读，该状态可能是给定生命周期时间最长的。

> show processlist查看正在运行的线程，如果你有process权限，能够看到所有的线程，如果没有权限只能看到自己的线程

```shell
mysql> show processlist;
+-----+---------------+-----------------------+-------------------+---------+------+--------------+------------------------------------------------------------------------------------------------------+
| Id  | User          | Host                  | db                | Command | Time | State        | Info                                                                                                 |
+-----+---------------+-----------------------+-------------------+---------+------+--------------+------------------------------------------------------------------------------------------------------+
|   3 | dbName | ip:55094   | dbName_new | Sleep   |  958 |              | NULL                                                                                                 |
|  43 | dbName | ip:55434   | dbName_new | Sleep   |  364 |              | NULL                                                                                                 |
| 619 | dbName | ip:64008 | NULL              | Sleep   | 1345 |              | NULL                                                                                                 |
| 620 | dbName | ip:64009 | dbName_new | Sleep   | 1320 |              | NULL                                                                                                 |
| 627 | dbName | ip:64098 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 632 | dbName | ip:64220 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 633 | dbName | ip:64221 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 634 | dbName | ip:64222 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 635 | dbName | ip:64223 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 636 | dbName | ip:64224 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 637 | dbName | ip:64225 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 638 | dbName | ip:64226 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 639 | dbName | ip:64227 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 640 | dbName | ip:64228 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 641 | dbName | ip:64249 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 642 | dbName | ip:64250 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 643 | dbName | ip:64256 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 644 | dbName | ip:64264 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 645 | dbName | ip:64287 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 646 | dbName | ip:64288 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 647 | dbName | ip:64289 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 648 | dbName | ip:64290 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 649 | dbName | ip:64295 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 650 | dbName | ip:64298 | dbName_new | Query   |    2 | Sending data | SELECT a.keywords FROM (SELECT k.keywords,count(1) c FROM tb_search_keyw |
| 657 | dbName | localhost             | dbName_new | Query   |    0 | starting     | show processlist                                                                                     |
+-----+---------------+-----------------------+-------------------+---------+------+--------------+------------------------------------------------------------------------------------------------------+
25 rows in set (0.00 sec)
```

接下来使用show profile查看详细的查询耗时,使用show profile需要使用set profiling=1打开配置

```shell
mysql> set profiling=1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> show profiles;
Empty set, 1 warning (0.00 sec)
```

将异常的sql执行一次,再使用show profiles;得到query_id

```shell
mysql> SELECT a.keywords FROM(SELECT k.keywords,count(1) c FROM tb_search_keywords k WHERE DATE_SUB(CURDATE(), INTERVAL 7 DAY) <= k.t_crt_tm AND LENGTH(k.keywords) > 3 GROUP BY k.keywords) a ORDER BY a.c DESC LIMIT 8;
+----------+
| keywords |
+----------+
| xxxxx    |
| xxxxx    |
| xxxxx    |
| xxxxx    |
| xxxxx    |
| xxxxx    |
| xxxxx    |
| xxxxx    |
+--------------+
8 rows in set (2.72 sec)
mysql> show profiles;                                                                                                                                     +----------+------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                                                                                                                             |
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|        1 | 2.71795375 | SELECT a.keywords FROM(SELECT k.keywords,count(1) c FROM tb_search_keywords k WHERE DATE_SUB(CURDATE(), INTERVAL 7 DAY) <= k.t_crt_tm AND LENGTH(k.keywords) > 3 GROUP BY k.keywords) a ORDER BY a.c DESC LIMIT 8 |
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set, 1 warning (0.00 sec)

```

得到query_id后使用show profile all for query Query_ID查看语句工作情况和耗时,很明显sending data状态的Context_voluntary的值十分大,达到了1223336,Context_voluntary指的时上下文主动切换次数,一般是越小越好。

```shell

mysql> show profile all for query 1;
+----------------------+----------+----------+------------+-------------------+---------------------+--------------+---------------+---------------+-------------------+-------------------+-------------------+-------+-----------------------+----------------------+-------------+
| Status               | Duration | CPU_user | CPU_system | Context_voluntary | Context_involuntary | Block_ops_in | Block_ops_out | Messages_sent | Messages_received | Page_faults_major | Page_faults_minor | Swaps | Source_function       | Source_file          | Source_line |
+----------------------+----------+----------+------------+-------------------+---------------------+--------------+---------------+---------------+-------------------+-------------------+-------------------+-------+-----------------------+----------------------+-------------+
| starting             | 0.000178 | 0.000270 |   0.000369 |                44 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | NULL                  | NULL                 |        NULL |
| checking permissions | 0.000013 | 0.000019 |   0.000026 |                 3 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | check_access          | sql_authorization.cc |         810 |
| Opening tables       | 0.000031 | 0.000053 |   0.000072 |                 8 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | open_tables           | sql_base.cc          |        5650 |
| init                 | 0.000084 | 0.000143 |   0.000197 |                25 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | handle_query          | sql_select.cc        |         121 |
| System lock          | 0.000016 | 0.000026 |   0.000035 |                 5 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | mysql_lock_tables     | lock.cc              |         323 |
| optimizing           | 0.000009 | 0.000017 |   0.000024 |                 3 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | optimize              | sql_optimizer.cc     |         151 |
| optimizing           | 0.000017 | 0.000025 |   0.000034 |                 3 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | optimize              | sql_optimizer.cc     |         151 |
| statistics           | 0.000086 | 0.000146 |   0.000199 |                33 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | optimize              | sql_optimizer.cc     |         367 |
| preparing            | 0.000026 | 0.000043 |   0.000059 |                 5 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | optimize              | sql_optimizer.cc     |         475 |
| Sorting result       | 0.000007 | 0.000012 |   0.000017 |                 1 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | make_tmp_tables_info  | sql_select.cc        |        3829 |
| statistics           | 0.000008 | 0.000013 |   0.000018 |                 2 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | optimize              | sql_optimizer.cc     |         367 |
| preparing            | 0.000007 | 0.000011 |   0.000015 |                 2 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | optimize              | sql_optimizer.cc     |         475 |
| Sorting result       | 0.000006 | 0.000011 |   0.000015 |                 3 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | make_tmp_tables_info  | sql_select.cc        |        3829 |
| executing            | 0.000012 | 0.000020 |   0.000026 |                 3 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | exec                  | sql_executor.cc      |         119 |
| Sending data         | 0.000010 | 0.000018 |   0.000026 |                 2 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | exec                  | sql_executor.cc      |         195 |
| executing            | 0.000015 | 0.000000 |   0.000052 |                10 |                   1 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | exec                  | sql_executor.cc      |         119 |
| Sending data         | 2.716164 | 4.374872 |   6.204002 |           1223336 |                4957 |            0 |            16 |             0 |                 0 |                 0 |               497 |     0 | exec                  | sql_executor.cc      |         195 |
| Creating sort index  | 0.001164 | 0.000489 |   0.000672 |                 0 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 1 |     0 | sort_table            | sql_executor.cc      |        2595 |
| end                  | 0.000019 | 0.000003 |   0.000005 |                 0 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | handle_query          | sql_select.cc        |         199 |
| query end            | 0.000011 | 0.000005 |   0.000006 |                 0 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | mysql_execute_command | sql_parse.cc         |        4965 |
| closing tables       | 0.000003 | 0.000001 |   0.000002 |                 0 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | mysql_execute_command | sql_parse.cc         |        5017 |
| removing tmp table   | 0.000013 | 0.000006 |   0.000007 |                 0 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | free_tmp_table        | sql_tmp_table.cc     |        2401 |
| closing tables       | 0.000008 | 0.000003 |   0.000005 |                 0 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | free_tmp_table        | sql_tmp_table.cc     |        2430 |
| freeing items        | 0.000032 | 0.000014 |   0.000018 |                 0 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | mysql_parse           | sql_parse.cc         |        5622 |
| cleaning up          | 0.000017 | 0.000006 |   0.000010 |                 0 |                   0 |            0 |             0 |             0 |                 0 |                 0 |                 0 |     0 | dispatch_command      | sql_parse.cc         |        1898 |
+----------------------+----------+----------+------------+-------------------+---------------------+--------------+---------------+---------------+-------------------+-------------------+-------------------+-------+-----------------------+----------------------+-------------+
25 rows in set, 1 warning (0.00 sec)
```
到这里已经差不多快接近定位到是由于什么原因了,只要知道是什么会导致Context_voluntary偏大,经过不断地查找资料,终于找到[一篇细说MySQL的timestamp的文章](http://blog.elight.cn/?post=326)。
文中指出:当MySQL参数time_zone=system时，查询timestamp字段会调用系统时区做时区转换，而由于系统时区存在全局锁问题，在多并发大数据量访问时会导致线程上下文频繁切换，CPU使用率暴涨，系统响应变慢设置假死。
查到可能的原因马上尝试一番,使用show variables like '%time_zone'命令查看time_zone的值,果不其然time_zone的值是SYSTEM。

```shell
mysql> show variables like '%time_zone';
+------------------+--------+
| Variable_name    | Value  |
+------------------+--------+
| system_time_zone | CST    |
| time_zone        | SYSTEM |
+------------------+--------+
2 rows in set (0.00 sec)
```

因为mysqld进程是在应用服务器上,可以使用linux的[pstack](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/pstack.html)命令来查看各个线程的状态,也很容易看到是因为时区转换存在全局锁,pstack信息如下:
```shell
Thread 2 (Thread 0x7fc5a702c700 (LWP 11259)):
#0  0x00007fc5dd03a57c in __lll_lock_wait_private () from /lib64/libc.so.6
#1  0x00007fc5dcfe4c5c in _L_lock_2546 () from /lib64/libc.so.6
#2  0x00007fc5dcfe4a97 in __tz_convert () from /lib64/libc.so.6
#3  0x0000000000d76c81 in Time_zone_system::gmt_sec_to_TIME (this=<optimized out>, tmp=0x7fc5a7029f00, t=<optimized out>) at /export/home2/pb2/build/sb_1-26514852-1514433675.01/rpm/BUILD/mysql-5.7.21/mysql-5.7.21/sql/tztime.cc:1094
#4  0x00000000007d554d in gmt_sec_to_TIME (tv=..., tmp=0x7fc5a7029f00, this=<optimized out>) at /export/home2/pb2/build/sb_1-26514852-1514433675.01/rpm/BUILD/mysql-5.7.21/mysql-5.7.21/sql/tztime.h:60
#5  Field_timestampf::get_date_internal (this=<optimized out>, ltime=0x7fc5a7029f00) at /export/home2/pb2/build/sb_1-26514852-1514433675.01/rpm/BUILD/mysql-5.7.21/mysql-5.7.21/sql/field.cc:5986
```
搜索__tz_convert发现19个线程都是处于请求锁的状态,前文提到使用了20个线程对接口压测,则证明了是存在锁。

![](/images/online-failure/MySQL-timestamp/mysqld-stack.png)

## 修复方案
#### 一:将time_zone参数设置为system外的值，如中国地区服务器设置为'+8:00'；
- 修改time_zone是最直接的方式,这样就不会访问linux的系统时区,不会存在锁
- 修改time_zone在业务场景对时区有要求时不适用

#### 二:使用datetime代替timestamp
