---
title: Machine Learning_01_(无)监督学习
date: 2017-05-08 16:20:32
tags: 机器学习
categories: 机器学习
---

## 机器学习定义
TomMitchell (1998) : Well-posed Learning Problem: A computer program is said tolearn from experience E with respect to some task T and some performance measureP, if its performance on T, as measured by P, improves with experience E.

例子：对于一个垃圾邮件识别的问题，将邮件分类为垃圾邮件或非垃圾邮件是任务T，查看哪些邮件被标记为垃圾邮件哪些被标记为非垃圾邮件是经验E，正确识别的垃圾邮件或非垃圾邮件的数量或比率是评测指标P。

## 监督学习
对具有概念标记(分类)的训练样本进行学习, 以尽可能对训练样本集外的数据进行标记(分类)预测. 这里所有的标记(分类)是已知的, 因此, 训练样本的歧义性较低.

> 这种技术高度依赖于事先确定的分类系统给出的信息.

ex:
- 房屋价格预测 -> 回归问题
- 乳腺癌(良性, 恶性)预测 -> 分类问题

回归问题和分类问题都是监督学习的内容.

## 无监督学习

> 我们不告诉计算机怎么做, 而是让计算机自己去学习怎么做.

对没有概念标记(分类)的训练样本进行学习, 以发现训练样本集中的结构性知识. 这里所有的标记(分类)都是未知的, 因此, 训练样本的歧义性高.


无监督学习一般有两种思路:

1. 激励制度
当程序执行后对正确的行为做出某种形式的激励.  ex: 西洋双陆棋

2. 聚合
程序会找到训练数据中的近似点


无监督学习还有一个典型的例子: 鸡尾酒会问题 (声音的分离)
这个酒会上有两种声音, 被两个不同的麦克风在不同的地方接收到, 而利用无监督学习可以分离这两种不同的声音.
代码只有一行:

```
[W, s, v] = svd((repmat(sum(x.*x, 1), size(x, 1), 1).*x)*x');
```

参考: https://www.zhihu.com/question/23194489


