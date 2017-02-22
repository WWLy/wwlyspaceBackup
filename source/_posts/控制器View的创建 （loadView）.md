---
title: 控制器View的创建 （loadView）
date: 2015-11-18 23:27
tags: iOS
categories: iOS
---

在创建控制器的时候会自动创建view

```
self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//加载storyboard
UIStoryboard *sb = [UIStoryboard storyboardWithNibName:@"Main" bundle:nil];
self.window.rootViewController = [sb instantiateInitialViewController];
[self.window makeKeyAndVisible];
```

UIViewController 中有一个方法：loadView，它会去加载指定的storyboard中所描述的控制器的view

作用：创建控制器view

调用：当我们第一次使用到控制器的view时就会去调用loadView

只要重写loadView方法，就需要自己创建控制器的view，系统不再自动创建

> loadView底层：（Xcode 7之前）

1. 判断loadView方法中有没有创建view
2. 然后判断有没有指定storyboard，若有，则加载指定storyboard描述的控制器的view，
3. 再判断有没有指定nibName，有，则加载nibName描述的控制器的view

如果没有指定nibName：
4. 即nibName为nil时，尝试先去找和控制器同名，但是不带Controller的xib
5. 再然后寻找带Controller的xib

> loadView底层：（Xcode 7或之后）

1. 判断loadView方法中有没有创建view，有，则加载自定义view
2. 然后判断有没有指定storyboard，若有，则加载指定storyboard描述的控制器的view，
3. 再判断有没有指定nibName，有，则加载nibName描述的控制器的view

如果没有指定nibName：
4. 即nibName为nil时，尝试先去找和控制器同名带Controller的xib
5. 再然后寻找不带Controller的xib

---

> 默认控制器view的颜色是几乎透明的
> 透明（alpha = 0）具有穿透效果，类似于hidden = YES;
> 而默认创建的view为clear color，没有穿透效果


