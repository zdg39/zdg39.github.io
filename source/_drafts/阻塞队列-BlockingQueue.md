---
title: 阻塞队列(BlockingQueue)
categories: Java
tags: Queue,Concurrent,数据结构
---
# 一 阻塞队列(BlockingQueue)

java.util.concurrent包中的 BlockingQueue 接口表示一个线程安放入和提取实例的队列。

## BlockingQueue的用法

BlockingQueue通常用于一个线程生产数据，另一个线程消费数据的场景，基本原理如下：

<center>
![](/source/images/java/concurrent/queue/BlockingQueue接口.png)
</center>
