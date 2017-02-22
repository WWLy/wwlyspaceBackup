---
title: GCD和自定义NSOperation的对比
date: 2016-05-21 23:27
tags: iOS
categories: iOS
---

GCD 技术是一个轻量的，底层实现隐藏的神奇技术，我们能够通过GCD和block轻松实现多线程编程，有时候，GCD相比其他系统提供的多线程方法更加有效，当然，有时候GCD不是最佳选择，另一个多线程编程的技术 `NSOprationQueue` 让我们能够将后台线程以队列方式依序执行，并提供更多操作的入口，这和 GCD 的实现有些类似。

这种类似不是一个巧合，在早期，MacOX 与 iOS 的程序都普遍采用Operation Queue来进行编写后台线程代码，而之后出现的GCD技术大体是依照前者的原则来实现的，而随着GCD的普及，在iOS 4 与 MacOS X 10.6以后，Operation Queue的底层实现都是用GCD来实现的。

----

那这两者直接有什么区别呢？

1. GCD是底层的C语言构成的API，而NSOperationQueue及相关对象是Objc的对象。在GCD中，在队列中执行的是由block构成的任务，这是一个轻量级的数据结构；而Operation作为一个对象，为我们提供了更多的选择；
2. 在NSOperationQueue中，我们可以随时取消已经设定要准备执行的任务(当然，已经开始的任务就无法阻止了)，而GCD没法停止已经加入queue的block(其实是有的，但需要许多复杂的代码)；
3. NSOperation能够方便地设置依赖关系，我们可以让一个Operation依赖于另一个Operation，这样的话尽管两个Operation处于同一个并行队列中，但前者会直到后者执行完毕后再执行；
4. 我们能将KVO应用在NSOperation中，可以监听一个Operation是否完成或取消，这样子能比GCD更加有效地掌控我们执行的后台任务；
5. 在NSOperation中，我们能够设置NSOperation的priority优先级，能够使同一个并行队列中的任务区分先后地执行，而在GCD中，我们只能区分不同任务队列的优先级，如果要区分block任务的优先级，也需要大量的复杂代码；
6. 我们能够对NSOperation进行继承，在这之上添加成员变量与成员方法，提高整个代码的复用度，这比简单地将block任务排入执行队列更有自由度，能够在其之上添加更多自定制的功能。

---

总的来说，Operation queue 提供了更多你在编写多线程程序时需要的功能，并隐藏了许多线程调度，线程取消与线程优先级的复杂代码，为我们提供简单的API入口。从编程原则来说，一般我们需要尽可能的使用高等级、封装完美的API，在必须时才使用底层API。但是我认为当我们的需求能够以更简单的底层代码完成的时候，简洁的GCD或许是个更好的选择，而Operation queue 为我们提供能更多的选择。

