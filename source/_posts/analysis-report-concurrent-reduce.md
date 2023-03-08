---
title: 分析报告|多线程并发扣减问题
date: 2020-09-13 14:25:31
tags: 分析报告
---

## 前言

上周有天晚上笔者接到一个某知名互联网大厂的面试官打来的电话问最近看不看机会，想让我做一个笔试，由于自己也一直有在复习，所以就打算再试试面试机会。笔试题是一道多线程相关的编程题，要求在白板上使用面向对象的方式解决；在白板上写编程题总感觉没法发挥正常水平，题目类似的解决思路之前也在工作中遇见过或是看过类似的博客文章，最后做完题才发现自己理解错题意，没有多加思考。为了吸取经验教训，乘着这次机会总结一次相关问题。**本文为问题总结,可能有误望谅解**。

## 编程题

<!-- more -->

编程题大致题意是：**有一个数字9，然后线程A每次减2，线程B每次减3，这个数字不能减到小于0，如果数字不够线程减时则线程停止**。
这道题需要注意的问题是不能将数字减到小于0，由此可以得到第一种解法，两个线程同步执行，线程A减完之后线程B再执行。
```Java
public class Solution {

    private int count = 9;

    public static void main(String[] args) {
        Solution solutoin = new Solution();
        new Thread(new Task(2,solutoin)).start();
        new Thread(new Task(3,solutoin)).start();
        while (true) {
            ;
        }
    }

    public static class Task implements Runnable{

        private int num;
        private final Solution solutoin;

        Task(int num, Solution solutoin){
            this.num = num;
            this.solutoin = solutoin;
        }

        @Override
        public void run() {
            while (true){
                synchronized (solutoin){
                    System.out.println(Thread.currentThread().getName() + "减之前" + solutoin.count);
                    if(solutoin.count < num){
                        break;
                    }
                    solutoin.count -= num;
                    System.out.println(Thread.currentThread().getName() + "减之后" + solutoin.count);
                }
            }
        }
    }
}
```
使用锁同步线程缺点也显而易见，多线程并发执行变成了多线程排队串行，性能差。第二种解法是使用原子类来解决
```Java
public class Solution {

    private AtomicLong count = new AtomicLong(9);

    public static void main(String[] args) {
        Solution solutoin = new Solution();
        new Thread(new Task(2,solutoin)).start();
        new Thread(new Task(3,solutoin)).start();
        while (true) {
            ;
        }
    }

    public static class Task implements Runnable{

        private int num;
        private final Solution solutoin;

        Task(int num, Solution solutoin){
            this.num = num;
            this.solutoin = solutoin;
        }

        @Override
        public void run() {
            while (true){
                System.out.println(Thread.currentThread().getName() + "减之前" + solutoin.count);
                if(solutoin.count.get() < num){
                    System.out.println(Thread.currentThread().getName() + "停止" + solutoin.count);
                    return;
                }
                solutoin.count.addAndGet(-num);
                System.out.println(Thread.currentThread().getName() + "减之后" + solutoin.count);
            }
        }
    }
}
```
使用原子类AtomicLong来解决，然后这种方式还是存在问题，当两个线程都执行到if(solutoin.count.get() < num)这行代码时，如果此时数字为3，两个线程分别执行 solutoin.count.addAndGet(-num)，此时数字减为-2，出现"库存超卖问题"。为了避免这个问题，再对代码做出修改，减之后判断结果是否小于0，如果小于0则回滚。

```java
@Override
public void run() {
    while (true){
        System.out.println(Thread.currentThread().getName() + "减之前" + solutoin.count);
        //修改,先减再判断，不足则回滚
        if(solutoin.count.addAndGet(-num) < 0){
            solutoin.count.addAndGet(num);
            System.out.println(Thread.currentThread().getName() + "停止" + solutoin.count);
            return;
        }
        System.out.println(Thread.currentThread().getName() + "减之后" + solutoin.count);
    }
}
```
使用这种方式可以避免"库存超卖问题",但是又会带来新的问题，如果此时数字减为2，两个线程都执行到if(solutoin.count.addAndGet(-num) < 0)，线程B将2减为-1，线程A将-1减为-3，线程B回滚数字为0并终止，线程A回滚数字为2并终止。此时数字为2，还是可以再让线程A执行一次，造成误差。

为了解决"库存超卖问题"和避免误差，使用版本号的思路来解决
```Java
@Override
public void run() {
    //当前版本
    long currentCount;
    while ((currentCount = solutoin.count.get())>=num){
        System.out.println(Thread.currentThread().getName() + "减之前" + solutoin.count);
        if(solutoin.count.compareAndSet(currentCount,currentCount - num)){
            System.out.println(Thread.currentThread().getName() + "减之后" + solutoin.count);
        }
    }
  }
```
在每次更新数字时，比较当前的版本是否是上一个版本，如果版本相同则更新不同则继续判断执行。这种方式可以避免"库存超卖问题"和误差，但是缺点就是线程一直在不断执行循环开销比较大。

## 后记
按照目前的求职环境，如果想要去大厂，在白板写笔试题在所难免。笔者之所有有这次面试机会是因为在2019年10月份投递过其中一个部门，当时经历过一轮电话简历面，几天后再加一轮在线笔试。当时的笔试是一道多线程相关的题目和一道算法题，要求在一个小时内完成；由于没有刷过算法题，最后只完成了多线程相关的题。这次面试过后也有几次其他部门的面试官捞过我的简历让我去面试，并没有每次都参加了面试，只在今年3月份参加过一次，一面就被问到很多分布式相关技术，这方面的知识还是比较欠缺，有些应用过但没有熟悉其中的原理，结果也可想而知。上周的面试之所以答应参加是因为正好也想换一份工作，但立马就参加笔试确实不是明智之举。言归正传，多线程技术是每个程序员进阶都需要掌握的，学习多线程需要结合理论知识和加以实践才能掌握的很好，因为多线程的执行结果往往并不如你所想，需要考虑多很多细节问题。
