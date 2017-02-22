---
title: 多线程之NSOperation简介
date: 2016-05-21 23:27
tags: iOS
categories: iOS
---

> 多线程之NSOperation简介

在iOS开发中，为了提升用户体验，我们通常会将操作耗时的操作放在主线程之外的线程进行处理。对于正常的简单操作，我们更多的是选择代码更少的GCD，让我们专注于自己的业务逻辑开发。NSOperation在ios4后也基于GCD实现，但是相对于GCD来说可控性更强，并且可以加入操作依赖。

NSOperation是一个抽象的基类，表示一个独立的计算单元，可以为子类提供有用且线程安全的建立状态，优先级，依赖和取消等操作。系统已经给我们封装了NSBlockOperation和NSInvocationOperation这两个实体类。使用起来也非常简单，不过我们更多的使用是自己继承并定制自己的操作。

### NSOperation定义
```
- (void)start;
- (void)main;

@property (readonly, getter=isCancelled) BOOL cancelled;
- (void)cancel;

@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished) BOOL finished;
@property (readonly, getter=isConcurrent) BOOL concurrent; // To be deprecated; use and override 'asynchronous' below
@property (readonly, getter=isAsynchronous) BOOL asynchronous NS_AVAILABLE(10_8, 7_0);
@property (readonly, getter=isReady) BOOL ready;

- (void)addDependency:(NSOperation *)op;
- (void)removeDependency:(NSOperation *)op;

@property (readonly, copy) NSArray *dependencies;

typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
    NSOperationQueuePriorityVeryLow = -8L,
    NSOperationQueuePriorityLow = -4L,
    NSOperationQueuePriorityNormal = 0,
    NSOperationQueuePriorityHigh = 4,
    NSOperationQueuePriorityVeryHigh = 8
};

@property NSOperationQueuePriority queuePriority;

@property (copy) void (^completionBlock)(void) NS_AVAILABLE(10_6, 4_0);

- (void)waitUntilFinished NS_AVAILABLE(10_6, 4_0);

@property double threadPriority NS_DEPRECATED(10_6, 10_10, 4_0, 8_0);

@property NSQualityOfService qualityOfService NS_AVAILABLE(10_10, 8_0);

@property (copy) NSString *name NS_AVAILABLE(10_10, 8_0);
```

### 状态
NSOperation提供了ready cancelled executing finished这几个状态变化，我们的开发也是必须处理自己关心的其中的状态。这些状态都是基于keypath的KVO通知决定，所以在你手动改变自己关心的状态时，请别忘了手动发送通知。这里面每个属性都是相互独立的，同时只可能有一个状态是YES。finished这个状态在操作完成后请及时设置为YES，因为NSOperationQueue所管理的队列中，只有isFinished为YES时才将其移除队列，这点在内存管理和避免死锁很关键。

### 依赖
NSOperation中我们可以为操作分解为若干个小的任务，通过添加他们之间的依赖关系进行操作，这点在设计上是很有意义的。比如我们最常用的图片异步加载，第一步我们是去通过网络进行加载，第二步我们可能需要对图片进行下处理（调整大小或者压缩保存）。我们可以直接调用`- (void)addDependency:(NSOperation*)op;`这个方法添加依赖：

```
[imgRsizingOperation addDependency:networkOperation];
[operationQueue addOperation:networkOperation];
[operationQueue addOperation:imgRsizingOperation];
```

这点我们必须要注意的是不能添加相互依赖，像A依赖B，B依赖A，这样会导致死锁！还有一点必须要注意的时候，在每个操作完成时，请将`isFinished`设置为YES，不然后续的操作是不会开始执行的。

### 执行
执行一个operation有两种方法，第一种是自己手动的调用`start`这个方法，这种方法调用会在当前调用的线程进行同步执行，所以在主线程里面自己一定要小心的调用，不然就会把主线程给卡死，还不如直接用GCD呢。第二种是将operation添加到operationQueue中去，这个也是我们用得最多的也是提倡的方法。NSOperationQueue会在我们添加进去operation的时候尽快进行执行。当然如果NSOperationQueue的`maxConcurrentOperationCount`如果设置为1的话，进相当于FIFO了。

队列是怎么调用我们的执行的操作的呢？如果你只是想弄一个同步的方法，那很简单，你只要重写main这个函数，在里面添加你要的操作。如果想定义异步的方法的话就重写start方法。在你添加进operationQueue中的时候系统将自动调用你这个start方法，这时将不再调用main里面的方法。

### 取消
NSOperation允许我们调用`-(void)cancel`取消一个操作的执行。当然，这个操作并不是我们所想象的取消。这个取消的步骤是这样的，如果这个操作在队列中没有执行，那么这个时候取消并将状态`finished`设置为YES，那么这个时候的取消就是直接取消了。如果这个操作已经在执行了，那么我们只能等其操作完成。当我们调用cancel方法的时候，他只是将`isCancelled`设置为YES。所以，在我们的操作中，我们应该在每个操作开始前，或者在每个有意义的实际操作完成后，先检查下这个属性是不是已经设置为YES。如果是YES，则后面操作都可以不用在执行了。

### completionBlock
iOS4后添加了这个block，在这个操作完成时，将会调用这个block一次，这样也非常方便的让我们对view进行更新或者添加自己的业务逻辑代码。

### 优先级
operationQueue有`maxConcurrentOperationCount`设置，当队列中operation很多时而你想让后续的操作提前被执行的时候，你可以为你的operation设置优先级

```
NSOperationQueuePriorityVeryLow = -8L,
NSOperationQueuePriorityLow = -4L,
NSOperationQueuePriorityNormal = 0,
NSOperationQueuePriorityHigh = 4,
NSOperationQueuePriorityVeryHigh = 8
```

### 简单示例代码
最后我们看看一个简单的小示例，在.m文件里面我们将重写`finished` `executing`两个属性。我们重写set方法，手动发送keyPath的KVO通知。在`start`函数中，我们首先判断是否已经取消，如果取消的话，我们将直接return，并将`finished`设置为YES。如果没有取消操作，我们将`_executing`设置为YES，表示当前operation正在执行，继续执行我们的逻辑代码。在执行完我们的代码后，别忘了设置operation的状态，将`_executing`设置为NO，并将`finished`设置为YES，这样我们就已经很简单的完成了我们的多线程操作任务。

```
@interface TestOperation ()

@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL executing;

@end

@implementation TestOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

- (void)start
{
    if ([self isCancelled]) {
        _finished = YES;
        return;
    } else {
        _executing = YES;
        //start your task;

        //end your task

        _executing = NO;
        _finished = YES;
    }
}
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}
```

