---
title: 单例模式
date: 2018-05-26 21:28:49
tags: 设计模式
---
# 创建单例

>本文介绍使用Java创建单例的几种方式，后续会增加各种单例的优缺点分析。

## 一：饿汉式单例(静态成员变量初始化)

<!-- more -->
```
  public class Singleton{
    private static final Singleton singleton = new Singleton();

    private Singleton(){}

    public static Singleton getInstance(){
      return singleton;
    }
  }
```

## 二：饿汉式单例(静态代码块)
```
public class Singleton{
  private static Singleton singleton;

  static{
    singleton = new Singleton();
  }

  private Singleton(){}

  public static Singleton getInstance(){
    return singleton;
  }
}
```

### 三：懒汉式单例(多线程不可用)
```
public class Singleton{

  private static Singleton singleton;

  private Singleton(){}

  public static Singleton getInstance(){
    if (null == singleton) {
      singleton = new Singleton();
    }
    return singleton;
  }
}
```

### 四：懒汉式单例(同步方法)
```
public class Singleton{

  private static Singleton singleton;

  private Singleton(){}

  public static synchronized Singleton getInstance(){
    if (null == singleton) {
      singleton = new Singleton();
    }
    return singleton;
  }
}
```

### 五：懒汉式单例(同步代码块)
```
public class Singleton{

  private static Singleton singleton;

  private Singleton(){}

  public static Singleton getInstance(){
    if (null == singleton) {
      synchronized(Singleton.class){
        singleton = new Singleton();
      }
    }
    return singleton;
  }
}
```

### 六：懒汉式单例(双重检查判断)
```
public class Singleton{
  /*需要volatile关键字保证顺序性*/
  private static volatile Singleton singleton;

  private Singleton(){}

  public static Singleton getInstance(){
    if (null == singleton) {
      synchronized(Singleton.class){
        if(null == singleton){
          singleton = new Singleton();
        }
      }
    }
    return singleton;
  }
}
```

## 七：枚举单例
```
public enum Singleton {
  SINGLETON;
  private Singleton(){}
}
```

### 八：静态内部类单例(IODH)
```
public class Singleton {
  private Singleton() {};

  public static Singleton getInstance() {
    return InnerClass.singleton;
  }

  private static class InnerClass {
    private static final Singleton singleton = new Singleton();
  }
}
```

### 九:CAS原理实现单例
```
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.atomic.AtomicReference;

/**
 * @author zhudg39@gmail.com
 * @description CAS原理实现的单例:非阻塞,保证获取到实例是同一个,但是不能保证实例被多次实例化
 * @date 2019/5/6 19:29
 */
public class CASSingleton {
    /**
     * 原子应用类,线程安全
     */
    private static final AtomicReference<CASSingleton> INSTANCE =  new AtomicReference<>();

    /**
     * 私有化构造方法
     */
    private CASSingleton(){}

    /**
     * 获取单例类实例
     * @return
     */
    public static CASSingleton getInstance(){
        for(;;){
            CASSingleton singleton = INSTANCE.get();
            if(null != singleton){
                return singleton;
            }

            singleton = new CASSingleton();
            if(INSTANCE.compareAndSet(null,singleton)){
                return singleton;
            }
        }
    }

    public static void main(String[] args) {
        //模拟多线程并发
        int size = 10;
        CyclicBarrier cyclicBarrier = new CyclicBarrier(size);
        for (int i=0;i<size;i++){
            new Thread(() -> {
                try {
                    System.out.println(Thread.currentThread().getName() + "到达循环栅栏前");
                    cyclicBarrier.await();
                    System.out.println("所有线程已经跨越循环栅栏," + Thread.currentThread().getName() + "开始获取单例类实例:" + getInstance());
                }catch (Exception e){
                    e.printStackTrace();
                }
            }).start();
        }
    }
```
<center> 更新中。。。
