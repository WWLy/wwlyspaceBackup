---
title: GCD与多线程
date: 2016-05-19 22:46
tags: iOS
categories: iOS
---

## 前言
> GCD 的简单介绍

- 纯C语言, 提供了非常多且强大的函数
- 会自动利用更多的CPU内核
- 程序员只需要告诉GCD想要执行什么任务, 不需要编写任何线程管理代码
- 在ARC中,编译器会自动管理GCD的内存, 不需要考虑内存释放
- MRC中需要程序员手动调用 dispatch_release() 操作, 全局并发队列不需要考虑内存释放

## GCD的两个核心概念
### 队列
队列管理开发者提交的任务, GCD队列始终以FIFO(先进先出)的方式来处理任务----但由于任务的执行时间并不相同, 因此先处理的任务并不一定先结束. 队列可以是串行队列,也可以是并发队列. 队列底层会维护一个线程池来处理用户提交的任务，线程池的作用就是执行队列管理的任务。串行队列底层的线程池只要维护一个线程即可，并发队列的底层则需要维护多个线程。

> 串行队列

串行队列底层的线程池只有一个线程, 每次只提供一个线程处理一个任务, 所以必须前一个任务执行完成后,才能执行下一个任务.

> 并发队列

(dispatch_async) 线程池提供多个线程来执行任务, 可以按FIFO的顺序并发启动, 可同时处理多个任务, 因此会有多个任务并发执行.

### 任务
用户提交给队列的工作单元, 这些任务将会提交给队列底层维护的线程池执行, 因此会以多线程的方式执行.

## GCD 的介绍
1. 创建队列
2. 将任务提交给队列

### 队列的创建和访问
```
//创建队列
dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//创建任务
dispatch_block_t task = ^{
    NSLog(@"--- %@", [NSThread currentThread]);
};
//异步执行
dispatch_async(queue, task);
```

```
dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"--- %@", [NSThread currentThread]);
    });
```

---

#### 同步执行 sync

```
void dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
```
#### 异步执行 async
```
void dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
```

### 创建队列的常见方式
获取系统默认的全局并发队列(与并发队列区别: 不能设置名字, 也就不能追踪错误) 

第一个参数: 根据指定服务质量(即优先级), 有4种 (2 0 -2 和 BACKGROUND), 默认是0 (DEFAULT)
 第二个参数: 额外的旗标, 暂未使用, 为以后准备, 一般用 0 

```
dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
``` 

获取系统主线程关联的串行队列(主队列/全局串行队列)

```
dispatch_queue_t queue = dispatch_get_main_queue();
```

创建串行队列  

```
dispatch_queue_t queue = dispatch_queue_create(<#const char *label#>, DISPATCH_QUEUE_SERIAL);
```

创建并发队列

```
dispatch_queue_t queue = dispatch_queue_create(const char *label, DISPATCH_QUEUE_CONCURRENT);
```

> 组合方式: 同步异步决定开不开线程，串行并行决定任务按不按顺序执行或者开多少线程

---

串行队列, 同步执行 ---->  在当前线程执行(不开新线程), 任务按顺序执行, 不能嵌套, 否则死锁 !

---
串行队列, 异步执行 ---->  开启一个新线程执行, 任务在新开辟的子线程中按顺序执行 

---
并发队列, 同步执行 ---->  在当前线程执行(不开新线程), 任务按顺序执行

---
并发队列, 异步执行 ---->  开启多个新线程, 任务随机执行

---
主队列, 同步执行 ---->  死锁: 主线程先执行完主线程上的代码, 才会执行主队列的任务,同步执行会等第一个任务(此时任务在主线程)执行完成才会继续往后执行.  
> 解决方法: 把队列任务放在子线程中执行, 即在外部创建一个异步执行的全局并发队列

---
主队列, 异步执行 ---->  在主线程执行, 任务按顺序执行, 主线程先执行完主线程上的代码, 才会执行主队列的任务(队列中的任务优先级低) 

---
全局并发队列, 同步执行  ---->  在当前线程执行(不开新线程), 任务按顺序执行

---
全局并发队列, 异步执行  ---->  开启多个新线程执行, 任务随机执行

---

注意点: 
当线程执行完任务之后,会被放在线程池中, 不会被立即销毁, 可能会被再次复用, 但一段时间之后没有复用就会被销毁.


### GCD与NSThrea对比
- GCD 通过block执行代码, 更加简单, 便于维护, 而NSThread 通过@selector 执行代码, 代码比较分散
- 使用GCD不需要管理线程生命周期
- 如果要开多个线程, NSThread 需要实例化多个线程对象.

## GCD 的应用
### 线程阻塞 dispatch_barrier
主要用于在多个异步操作完成之后,对非线程安全的对象 (类似于NSMutableArray) 进行统一更新, 适合大规模的I/O操作.

使用dispatch_barrier_async 添加的block会在之前添加的block全部运行结束之后,才会在同一个线程顺序执行, 从而保证对非线程安全的对象进行正确的操作. 参数不能用全局队列,只能用自定义队列.
![](/Users/wwly/WWLySpace/source/_posts/GCD与多线程/GCD01.png
)

### 延迟执行 dispatch_after 
```
void dispatch_after(dispatch_time_t when,
	dispatch_queue_t queue,
	dispatch_block_t block);
```
经过多少纳秒, 队列才开始调度任务

### 一次性执行 dispatch_once
多用于单例, 整个项目中只会执行一次, 内部也有一把锁, 可以保证线程安全.


