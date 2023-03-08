---
title: 策略模式
date: 2020-12-06 21:12:22
tags: 设计模式
---

## 前言
在业务开发中，我们常常会遇到实现某一个功能有多种途径，每一条途径对应一种算法，此时我们可以使用一种设计模式来实现灵活地选择解决途径，也能够方便地增加新的解决途径；例如在微博中发布的一篇微博可能是文字，图片，转发的文章，转发的微博，投票或视频等；如果不使用设计模式实现这些功能那么代码一定会写的没有拓展性可言，新增一种类型就需要增加一层判断。本文将介绍一种为了适应算法灵活性而产生的设计模式-策略模式。**本文为个人技术分享，可能有误望谅解**

## 策略模式概述

<!-- more -->

> 在策略模式中，我们可以定义一些独立的类来封装不同的算法，每一个类封装一种具体的算法。在这里，每一个封装算法的类都可以称之为一个策略。为了保证这些策略在使用时具有一致性，一般会提供一个抽象的策略类来做规则的定义，而每种算法则对应于一个具体策略类。

大致的意思就是将判断逻辑单独封装成一个策略类，这些策略类都有一个共同的抽象类，面向抽象类编程，这种编程方式符合“依赖倒转原则”，如果新增一种策略类，只需要新增一个抽象类的具体实现类即可，不需要再修改原有代码，符合“开闭原则”。原先所有的判断逻辑都放在一个类中，不符合“单一职责”，现在将每个判断逻辑拆分开来，封装到具体的策略类中，类的职责也得到分解。
策略模式结构如下图

![](/images/design-pattern/strategy/strategy-pattern.png)

主要分为以下几个角色
- 抽象策略类 Strategy 编程时客户端直接交互的角色
- 具体策略类 StrategyA StrategyB 具体的实现
- 策略工厂类 StrategyFactory 负责通过客户端传递的类型映射具体实现类

## 应用场景

在使用策略模式之前如果要实现一个查看微博详情的功能

```java
Object getForwardContent(int contentType,long contentId) throws Exception {
        if(0 == contentType){
            //查询转发的文章详情
        }else if(1 == contentType){
            //查询转发的微博详情
        }else if(2 == contentType){
            //查询转发的图片详情
        }else if(3 == contentType){
            //查询转发的视频详情
        }else if(4 == contentType){
            //查询转发的投票详情
        }else {
            throw new Exception("不支持的转发类型");
        }
        return null;
}
```

如果要拓展一个新的转发类型就必须要修改原有代码，后期维护十分困难。使用策略模式改写，先提取一个抽象策略类ForwardContent,再将每个查询详情封装成一个具体策略类，最后增加一个策略工厂类，保存转发内容类型和具体策略类的映射关系。

![](/images/design-pattern/strategy/forward-content.png)

抽象策略类和具体实现类

```java
//抽象策略类
public interface ForwardContent {

    int getContentType();

    Object getContent(long contentId);
}

//转发文章详情
public class ArticleForwardContent implements ForwardContent{
    @Override
    public int getContentType() {
        return 0;
    }

    @Override
    public Object getContent(long contentId) {
        return null;
    }
}

//转发微博详情
public class PostForwardContent implements ForwardContent {
    @Override
    public int getContentType() {
        return 1;
    }

    @Override
    public Object getContent(long contentId) {
        return null;
    }
}

//转发图片详情
public class PictureForwardContent implements ForwardContent {
    @Override
    public int getContentType() {
        return 2;
    }

    @Override
    public Object getContent(long contentId) {
        return null;
    }
}

//转发视频详情
public class VideoForwardContent implements ForwardContent {
    @Override
    public int getContentType() {
        return 3;
    }

    @Override
    public Object getContent(long contentId) {
        return null;
    }
}

//转发投票详情
public class VoteForwardContent implements ForwardContent{
    @Override
    public int getContentType() {
        return 4;
    }

    @Override
    public Object getContent(long contentId) {
        return null;
    }
}
```

策略工厂类

```java
public class ForwardContentFactory {

    private static final Map<Integer, ForwardContent> FORWARD_CONTENT_MAP = new HashMap<>();

    static {
        FORWARD_CONTENT_MAP.put(0, new ArticleForwardContent());
        FORWARD_CONTENT_MAP.put(1, new PostForwardContent());
        FORWARD_CONTENT_MAP.put(2, new PictureForwardContent());
        FORWARD_CONTENT_MAP.put(3, new VideoForwardContent());
        FORWARD_CONTENT_MAP.put(4, new VoteForwardContent());
    }

    public static ForwardContent getForwardContent(int contentType) throws Exception {
        ForwardContent forwardContent = FORWARD_CONTENT_MAP.get(contentType);
        if(null == forwardContent){
            throw new Exception("不支持的转发类型" + contentType);
        }
        return forwardContent;
    }
}
```

客户端测试

```java
public class Client {

    public static void main(String[] args) throws Exception {
        long contentId = 1;
        //查询转发文章详情
        ForwardContentFactory.getForwardContent(0).getContent(contentId);
        //查询转发微博详情
        ForwardContentFactory.getForwardContent(1).getContent(contentId);
        //查询转发图片详情
        ForwardContentFactory.getForwardContent(2).getContent(contentId);
        //查询转发视频详情
        ForwardContentFactory.getForwardContent(3).getContent(contentId);
        //查询转发投票详情
        ForwardContentFactory.getForwardContent(4).getContent(contentId);
    }
}
```

使用策略模式改写后新增一种转发类型只需要新增一个具体实现类并且将它注册到工厂类即可，但是还是修改了原先的代码，代码拓展性的极致就是不修改一行代码。那么是否有方法做到不修改代码，答案是有的。JDK内置一种动态服务提供发现机制SPI，约定在classpath下的META-INF/services目录下创建一个以服务接口命名的文件，然后文件里面记录的是此jar包提供的具体实现类的全限定名。这种方式可以做到不修改原来代码，如果新增一个具体实现类只需要在配置文件中新增一行记录即可。JAVA-SPI机制会加载所有实现类并全部实例化，如果使用这种方式的话就只多了修改配置这一操作，但还是有些繁琐，每次新增实现类都要记得修改配置类。那么是否存在更好的实现方式，那就是结合Spring实现策略模式。Spring几乎是每个项目中都在应用，这种方式也是比较推荐的一种。

## 改进

如果要结合Spring框架实现策略模式，那么就必须将所有的实现类都统一由Spinrg容器管理。

```java
public interface ForwardContent{}

@Component
public class ArticleForwardContent implements ForwardContent{}

@Component
public class PostForwardContent implements ForwardContent{}

@Component
public class PictureForwardContent implements ForwardContent{}

@Component
public class VideoForwardContent implements ForwardContent{}

@Component
public class VoteForwardContent implements ForwardContent{}

```

主要改进的地方是在策略工厂类，具体实现类注册到工厂类改为动态实现。

```java
@Component
public class ForwardContentFactory implements InitializingBean, ApplicationContextAware {

    private static final Map<Integer, ForwardContent> FORWARD_CONTENT_MAP = new HashMap<>();

    private ApplicationContext applicationContext;

    public static ForwardContent getForwardContent(int contentType) throws Exception {
        ForwardContent forwardContent = FORWARD_CONTENT_MAP.get(contentType);
        if (null == forwardContent) {
            throw new Exception("不支持的转发类型" + contentType);
        }
        return forwardContent;
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        //getBeansOfType()获取某个类所有由Spring管理的实现
        applicationContext.getBeansOfType(ForwardContent.class).values()
                .forEach(forwardContent -> FORWARD_CONTENT_MAP.put(forwardContent.getContentType(), forwardContent));
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext = applicationContext;
    }
}

```
代码改进之后如果新增一个策略类只需要将其交由Spring管理即可，这种实现方式是目前发现的“最佳套路”。

## 总结
策略模式是应用较为广泛的设计模式之一，开发者都应该掌握，只要涉及到算法的封装，复用和切换都可以考虑使用策略模式。策略模式的主要优点是
- 提供了对开闭原则的完美支持
- 使用策略模式可以避免多重条件选择语句
- 策略模式提供了一种算法的复用机制，在不同的场景都可以很方便地复用这些策略类

主要缺点如下
- 客户端需要知道所有的策略类，并自行决定使用哪一个策略类
- 策略模式将导致系统产生很多的策略类，任何细小的变化都将导致要增加一个新的具体策略类
- 无法同时使用多个策略类，也就是说每次只能使用一个策略类，不支持切换

## 参考资料
* [刘伟(Sunny)-设计模式](https://gof.quanke.name)
* [设计模式最佳套路—— 愉快地使用策略模式](https://mp.weixin.qq.com/s/VA1_dEBpWN33WorJ3jhTqw)
