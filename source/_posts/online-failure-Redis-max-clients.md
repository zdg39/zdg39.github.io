---
title: 线上问题排查|Redis:连接未释放导致连接数超过最大值
tags: Redis
date: 2020-05-02 21:51:01
---

## 前言

最近又遇见一个线上问题,就是Redis连接数达到最大值,导致服务无法获取连接,大量用户反馈APP无法登陆。经过一系列的排查最终定位到问题是使用Redis后没有关闭连接,导致无法获取连接。因为出现问题的服务并没有使用连接池,所以在每次使用后必须手动关闭连接,否则运行一段时间后服务连接必将被占满。本文为技术分享,可能有误望谅解。

## 问题现象

<!-- more -->

线上服务日志出现大量的异常:ERR max number of clients reached

```java
redis.clients.jedis.exceptions.JedisDataException: ERR max number of clients reached
        at redis.clients.jedis.Protocol.processError(Protocol.java:117)
        at redis.clients.jedis.Protocol.process(Protocol.java:151)
        at redis.clients.jedis.Protocol.read(Protocol.java:205)
        at redis.clients.jedis.Connection.readProtocolWithCheckingBroken(Connection.java:297)
        at redis.clients.jedis.Connection.getStatusCodeReply(Connection.java:196)
        at redis.clients.jedis.BinaryClient.connect(BinaryClient.java:83)
        at redis.clients.jedis.Connection.sendCommand(Connection.java:100)
        at redis.clients.jedis.Connection.sendCommand(Connection.java:91)
        at redis.clients.jedis.BinaryClient.auth(BinaryClient.java:551)
        at redis.clients.jedis.BinaryJedis.auth(BinaryJedis.java:2048)
```
整个APP使用到Redis的接口也全都不可用,一看到ERR max number of clients reached就猜测是Redis使用后未关闭连接,因为并发请求量还达不到占满Redis连接数的地步,为了验证这一想法按照下面排查步骤一步一步执行。

## 排查步骤

### Linux排查命令

首先介绍关于Linux的一些监控命令,如下图所示

![](/images/online-failure/Redis/linux-command.jpg)

如果想知道服务所在机器和Redis服务建立多少连接可以使用[ss](https://man.linuxde.net/ss)或[netstat](https://man.linuxde.net/netstat)命令来查看。

```shell
$ ss -tn | grep 6379
或者
$ netstat -aln | grep 6379
#搜索与Redis服务建立的socket连接,Redis默认端口是6379,如果是其他端口修改为对应的端口即可

```
同时也可以实时监控连接数的变化

```shell
watch -n 1 -d 'netstat -aln | grep 6379 | wc -l'
```

通过以上命令就可以在你的机器上获取Redis连接数。

### 排查

在机器上使用watch命令搜索目前与Redis建立的连接数,发现连接数一直居高不下,而目前也没有特别多的用户访问,为了尽快恢复线上服务先重启再后续观察。目前的症状是服务运行一段时间后无法获取连接且访问量并不大,首先是去排查代码(如果有权限查看阿里云后台可以先使用Redis的client list命令查看目前客户端的连接信息)看是否有连接未正常关闭。在查看Redis的封装工具类后找到一处代码使用Redis后未关闭连接,如下所示

```java
  Jedis jedis = getJedis();
  return jedis.scard(key);
```

在获取一个jedis连接后,直接调用了一个scard()方法,该方法是获取Redis的Set元素的个数。找到可能出现的问题后,先将此处代码改写,使用try()语法释放jedis连接:

```java
  try(Jedis jedis = getJedis()){
      return jedis.scard(key);
  }
```

try括号中的资源会在try语句执行完后自动释放,前提是这些可关闭的资源必须实现java.lang.AutoCloseable接口。查看Jedis的继承关系:

![](/images/online-failure/Redis/jedis-uml.png)

在将jedis连接正常关闭后,继续使用watch命令查看机器连接数,恢复正常不再保持递增状态。

### Redis相关命令排查

如果能够使用Redis的一些命令,可以更快地排查到是哪一行代码没有释放连接。

- info clients命令:查看Redis连接客户端的信息,可以查看目前有多少客户端连接

```shell
ip:6379>info clients
"# Clients
connected_clients:2
client_recent_max_input_buffer:2
client_recent_max_output_buffer:0
blocked_clients:0
"
```

- client list命令:查看Redis连接客户端的具体信息

```shell
ip:6379>client list
"id=230145929 addr=ip:48324 fd=3370 name= age=19907 idle=19907 flags=N db=0 sub=0 psub=0 multi=-1 qbuf=0 qbuf-free=0 obl=0 oll=0 omem=0 events=r traffic-control= cmd=scard type=user"
"id=230145930 addr=ip:48327 fd=3371 name= age=19907 idle=19907 flags=N db=0 sub=0 psub=0 multi=-1 qbuf=0 qbuf-free=0 obl=0 oll=0 omem=0 events=r traffic-control= cmd=scard type=user"
...
```

在线上Redis服务使用client list命令后发现有大量的未释放连接,cmd=scard这里可以看到是scard命令未释放,idle=19907和age=19907可以看到该命令存活时间达到19907秒。

## 后记

在写代码时一定要注意资源的释放,否则很容易出现线上事故引起用户投诉;在改造成本不大的时候可以使用池化技术来优化系统,例如http连接池,数据库连接池等,自动管理连接避免出现未手动释放的情况,当然如果改造成本比较大时还是注意在每次使用后都要手动关闭!
