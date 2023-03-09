---
title: 设计报告|全量用户通知未读数系统设计
date: 2020-12-05 16:46:30
tags: 设计报告
---

## 前言
发布系统公告是app的常见功能，运营人员在后台管理系统发布一篇公告，用户在使用app时会有红点或数字提示有未读消息，点击进入公告消息列表页后再返回红点或数字消失。本文将介绍一些关于**全量用户通知未读数系统**的技术设计方案，以及他们各自的优缺点，如果有更多的想法欢迎补充讨论。**本文为个人技术分享，可能有误望谅解**

## 需求背景

<!-- more -->

现要求为一款app增加查看系统发布公告历史记录功能，每个用户都可以进入历史记录列表页，未读的公告显示红点，已读的公告不显示红点，点击返回按钮再次进入列表页红点全部消失。

## 技术方案
首先根据需求分析，功能特点是全量用户共享数据，读取的是同一份数据，但需要知道一条公告消息哪些用户是已读，哪些是未读。要实现这样的一个功能，大致是需要三个接口

* 后台管理系统发布公告接口
* app用户查看公告历史记录列表接口
* 清空用户未读数接口

得到接口列表后我们很快就可以设计出一种最简单的方案，存储全量用户公告消息。

### 方案一：存储全量用户公告消息
存储全量用户公告消息指的是运营人员在后台管理系统发布一篇公告，然后将公告数据推送给app全量用户，每个用户都存储一份公告数据，默认是未读，这种方式叫做推模式(写扩散)。一共会设计两张表，一张公告信息表，另一张是用户公告消息表，记录公告id和已读状态。采用这种方案理解起来也很简单，发布一篇公告，然后每个用户都存储一份公告消息数据，如果分页拉取历史记录列表，直接查询用户公告消息表判断是否已读显示红点，点击清空将所有的未读消息更改状态为已读。但是这种方案的缺点显而易见，每发布一篇公告都要推送给全量用户，假设系统用户有1千万，发布一篇公告的的数据存储成本是写入公告信息表1条数据和读取用户表全量数据写入用户公告消息表1千万条数据。写入会延迟很大并且数据存储成本太大并且这种设计方案很快就会被摒弃。

#### 优点
* 理解简单，最容易想到，适用于企业内部管理系统

#### 缺点
* 发布一篇公告需要扩散给全量用户，延时很大
* 很多未登陆的用户都会存储一份数据，存储成本太大
* 如果公告消息有所变动还需要写扩散给所有用户
* 清空未读消息时，如果有很多未读消息，更新数据较多

### 方案二：存储全量用户已读公告消息
全量用户如果都存储公告消息，那么存储成本会十分巨大，这会带来致命的问题。那么有没有优化的方案来改进存在的问题，存储全量用户公告消息读取全量用户和写入用户公告消息表时延会很大，那么如果只在用户公告消息表存储用户已读消息，那么就会避免读取全量用户和写入用户公告消息表。发布公告时只写入公告信息表，用户读取公告历史列表时分页查询公告信息表，再关联查询用户公告消息表，如果在里面则是已读，反之是未读。这样看起来写扩散最致命的两个问题都得到缓解，但是清空未读消息时就包含大量的写入操作，需要未读的数据写入用户公告消息表。

#### 优点
* 相对存储全量用户公告消息数据量较小

#### 缺点
* 实现较复杂
* 用户量增长或者活跃用户较多数据存储成本也会变大

### 方案三：存储全量用户最新读取公告消息(通用方案)
以上方案都存在种种弊端，获取消息的延迟和数据存储成本这两个问题让人无法接受。方案再次改进，仔细分析需求，每个用户查看的系统公告都是同样的一份数据，前面已经提过，功能特点是全量用户共享数据，只是在共享数据层面加了一层已读未读状态，并且是批量将所有未读消息清空(如果需要支持点击单个消息已读则需要单独存储已读消息的id)，所以可以采用记录公告消息列表中每个人读取的最后一条消息的id，然后根据这个消息来判断哪些消息是已读，哪些消息是未读。该方案设计实现时存在几个关键点
* 用户访问通知页面需要设置未读数为0，更新最近看过的通知为最新的一条消息id
* 如果用户最新看过的消息id为空，可根据业务需求判断是否全为已读

![](/images/design-report/system-notify.jpg)

#### 优点
* 数据存储量很小
* 清空未读消息性能较高，只需要更新用户最新读取的消息id即可

#### 缺点
* 实现较为复杂，不容易想到

## 后记
本文对实现全量用户通知未读数系统设计方案做了一个简要概述，如果在开发中遇到类似的应用场景基本上可以作为通用的方案。

## 参考资料
* 极客时间-高并发系统设计40问-38|计数系统设计(二)