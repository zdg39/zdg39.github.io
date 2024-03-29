---
title: API网关接入
date: 2023-04-14 12:00:10
tags: 网关
---

## 前言

随着公司业务的不断扩展，我们的应用程序数量和规模越来越大。为了更好地管理这些应用程序和保护它们的安全性，我们决定实施 API 网关。API 网关是一种将所有应用程序请求路由到相应服务的中间层，从而提高应用程序的可伸缩性和可用性的技术。它还提供了安全认证、流量管理和监控等功能，以保护我们的应用程序不受恶意攻击和过载请求的影响。在本文中，我们将介绍 API 网关的概念、优点和如何在公司技术架构现状下实施 API 网关。**本文为个人技术分享，由于技术水平有限，可能有误望谅解。**

## API 网关

<!-- more -->

### 什么是 API 网关

API 网关为客户与服务系统之间的交互提供了统一的接口，也是管理请求和响应的中心点，选择一个适合的 API 网关，可以有效地简化开发并提高系统的运维与管理效率。 API 网关在微服务架构中是系统设计的一个解决方案，用来整合各个不同模块的微服务，统一协调服务。API 网关作为一个系统访问的切面，对外提供统一的入口供客户端访问，隐藏系统架构实现的细节，让微服务使用更为友好；并集成了一些通用特性（如鉴权、限流、熔断），避免每个微服务单独开发，提升效率，使系统更加标准化，比如身份验证、监控、负载均衡、限流、降级与应用检测等功能。

### API 网关遇到的挑战

微服务网关应该首先要具备 API 路由能力，微服务数量变多，API 数量急剧增加，网关还可以根据具体的场景作为流量过滤器来使用，以提供某些额外可选功能，因此对微服务 API Gateway 提出了更高要求，比如：

- 可观测性：在以往的单体应用中，排查问题往往通过查看日志定位错误信息和异常堆栈；但是在微服务架构中服务繁多，出现问题时的问题定位变得非常困难；因此，如何监控微服务的运行状况、当出现异常时能快速给出报警，这给开发人员带来很大挑战。
- 鉴权认证：而微服务架构下，一个应用会被拆分成若干个微应用，每个微应用都需要对访问进行鉴权，每个微应用都需要明确当前访问用户以及其权限。尤其当访问来源不只是浏览器，还包括其它服务的调用时，单体应用架构下的鉴权方式就不是特别合适了。在微服务架构下，要考虑外部应用接入的场景、用户 - 服务的鉴权、服务 - 服务的鉴权等多种鉴权场景。
- 系统稳定性：若大量请求超过微服务的处理能力时，可能会将服务打垮，甚至产生雪崩效应、影响系统的整体稳定性。
- 服务发现：微服务的分散管理，让微服务的负载均衡的实现也更具有挑战性。

### API 网关选型

- 功能维度
  - API 路由
  - 认证授权
  - 限流降级
  - 协议转换
  - 等。。。。
- 可拓展性
- 可管理性
- 可维护性(Java 技术栈)
- 伸缩性
- 安全性
- 性能

![](/images/api-gateway/api-gateway.png)

**考虑到需要 Java 技术栈，并且目前只需要支持 http 协议代理，所以最终使用 Spring Cloud Gateway 网关。未来是否会有 http→rpc，或者 http→grpc？如果会有这种需求还需要综合考虑协议转换二次开发成本。**

## 目前现状

![](/images/api-gateway/current-status.png)

## 系统架构

![](/images/api-gateway/architecture.png)

### 多级网关

目前系统架构部署了多级网关，需要再增加一层 API 网关。同时使用 LBS（负载均衡系统）和 Nginx 多级网关可以带来一些好处，例如：

1. 提高系统的可用性和可靠性：通过使用 LBS 和 Nginx 多级网关，可以将流量分散到多个服务器上，从而减轻单个服务器的压力。当其中一个服务器出现故障时，负载均衡系统会将流量重新路由到其他可用的服务器上，从而提高整个系统的可用性和可靠性。
2. 改善系统的性能和响应时间：LBS 和 Nginx 多级网关可以根据不同的负载情况和流量分配策略，将请求分配到不同的服务器上，从而避免单个服务器的过载和性能瓶颈。同时，Nginx 多级网关还可以对请求进行缓存和压缩，进一步提高系统的性能和响应时间。
3. 提高系统的安全性：通过使用 LBS 和 Nginx 多级网关，可以将入口流量经过多层过滤和检查，从而提高系统的安全性。Nginx 多级网关可以对请求进行访问控制、IP 黑名单过滤、DDoS 防御等安全措施，防止恶意请求和攻击。

总之，同时使用 LBS 和 Nginx 多级网关可以提高系统的可用性、性能和安全性，从而更好地满足用户的需求和提高用户体验。

### Nginx

Nginx 是一个开源的高性能 Web 服务器和反向代理服务器，也可以用作负载均衡器、HTTP 缓存和作为 HTTP 服务器使用。作为网关，Nginx 可以用于连接不同的网络、协议和应用程序，实现请求路由、负载均衡、安全认证、协议转换等功能。

具体来说，Nginx 作为网关的作用有：

1. 反向代理：将客户端的请求转发给后端的服务器进行处理，从而隐藏后端服务器的真实 IP 地址和端口号，提高系统的安全性和可靠性。
2. 负载均衡：通过分发客户端请求到多个后端服务器，均衡服务器的负载，提高系统的可用性和性能。
3. 缓存服务：通过对静态内容的缓存，减少对后端服务器的访问次数，提高系统的响应速度和性能。
4. 安全认证：对客户端的请求进行验证和授权，提高系统的安全性和可靠性。
5. 协议转换：将客户端的请求转换为后端服务器能够处理的协议格式，从而兼容不同的协议和应用程序。

总之，Nginx 作为网关可以实现多种功能，提高系统的可用性、性能和安全性。

## 功能模块

> 功能模块接入按照需求优先级排序

### 服务注册发现

目前公司使用的服务发现组件 Consul，Java 应用和 Golang 应用使用了两套环境，Java 应用之间通过 Dubbo 和 Consul 技术栈通信，Golang 应用之间通过 Grpc+Consul 技术栈通信，Java 应用和 Golang 应用之间通过 Golang 应用的 Consul 集群实现服务发现。Dubbo 版本使用的是 2.7.x 版本，使用的还是“接口粒度”的服务发现，发布一个接口 Consul 便会有一条记录；Golang 则使用的是“应用粒度”的服务发现，一个应用只会有一条记录，而 Spring Cloud 通过注册中心只同步了应用与实例地址，消费方可以基于实例地址与服务提供方建立连接,所以服务发现组件使用 Golang 环境能快速接入省去了长时间的技术改造成本。

### 动态配置

动态配置使用 Nacos 组件即可。

### 动态路由

动态路由需要自定义拓展路由配置加载策略，将路由配置放在 Nacos 组件即可，之后上下线新的业务系统更加灵活。

### 负载均衡

负载均衡使用 SpringCoud Ribbon 组件即可，负载均衡算法同 Nginx 保持一致。

### 协议转换

协议转换目前只需要支持 http→http 即可，不需要二次开发。

### 无损发布

网关系统的节点上下线通过 nginx 的心跳实现，业务系统则通过服务发现来实现。

### 监控告警

监控先接入`actuator`,`prometheus` 。

### 限流降级

限流考虑使用 Redis 来实现。

### 认证授权

目前所有业务系统认证是通过解析 jwt 实现，考虑到 API 网关只能实现应用粒度的认证授权，不能做到接口粒度，如果要做到接口粒度需二次开发成本较高。真实需求是一个业务系统中部分接口需要认证，部分接口即支持认证也可以不认证，还有部分接口公开访问。所以 API 网关如果获取不到 token 则不解析，如果能从 http 请求头获取到 token 则解析，并将解析获取到的 uid 写入请求头转发给业务系统，由业务系统根据不同的接口需要来认证鉴权。这里考虑到可能客户端会伪装 uid 请求头，所以网关会先过滤客户端传递的 uid 请求头。

### 安全机制

ip 黑白名单，可后续定制开发。

### 链路追踪

后续接入。

### 业务分组隔离

为了防止部分业务拖垮 API 网关，所以需要为不同的业务分组隔离，可后续定制开发。

## 网关部署

Java 应用和 Golang 应用部署在不同的机房，前者部署在北京机房后者部署在深圳机房，网关系统如果部署在单个机房都会导致另一方访问会有几百 ms 的延迟。考虑 http 接口应用大部分是 Java 应用，为了节省部署成本可先在北京机房部署一套 API 网关集群。

## 业务迁移

### Nginx 配置

首先，引入 API 网关后需要修改的就是 nginx 的配置，原先 nginx 反向代理的是业务系统的真实 ip，需要将 nginx 修改为反向代理 API 网关系统的真实 ip。

```lua
    upstream server.api.chaos {
        server  ip1:port  weight=1;
        server  ip2:port  weight=1;
        # 每隔三秒检查后端真实节点状态，成功2次为up状态，失败3次为down状态，超时时间为1秒，检查类型为http
        check interval=3000 rise=2 fall=3 timeout=1000 type=http;
        check_http_send "HEAD /actuator/info HTTP/1.0\r\n\r\n";
        check_http_expect_alive http_2xx http_3xx;
    }
```

### API 网关路由配置

目前公司内部后端业务系统有多个应用对外暴露 http 接口，Java 应用都有统一的 path 前缀，Golang 应用无统一的 path 前缀，所以需要支持多种路由策略。

```
spring:
  application:
    name: api-gateway
  cloud:
    gateway:
      routes:
        - id: serviceId1
          #注册中心上的serviceId
          uri: lb://service1
          predicates:
            # 匹配路径转发
            - Path=/service1/**
	    - id: serviceId2
          uri: lb://service2
          predicates:
            # 匹配Host转发
            - Host=xxx.com
```

这里只是演示一下路由配置，实际网关应用中的路由配置需要自定义拓展实现动态加载提升灵活性，例如使用 nacos 管理路由配置。

## 后记

API 网关的实施需要考虑公司的技术架构和业务需求，以确保其能够满足我们的需求并与现有系统集成。因此，在实施 API 网关之前，我们需要进行充分的规划和评估，并与团队进行充分的沟通和协作。

总之，API 网关是一种强大的技术，可以帮助我们更好地管理和保护我们的应用程序，并提高其可伸缩性和可用性。在实施 API 网关之前，我们需要仔细考虑公司的技术架构和业务需求，并进行充分的规划和评估，以确保其能够满足我们的需求并与现有系统集成。

## 参考资料

- [微服务为什么要用到 API 网关](https://apisix.apache.org/zh/blog/2023/03/08/why-do-microservices-need-an-api-gateway/)
- [路由凭什么作为微服务网关的基础职能？-极客时间](https://time.geekbang.org/column/article/340106?screen=full)
- [Spring Cloud Gateway](https://cloud.spring.io/spring-cloud-gateway/reference/html/#gateway-starter)
- [vivo 微服务 API 网关架构实践](https://mp.weixin.qq.com/s/5U1rgpcW21LDYzv8K9EX7g)
