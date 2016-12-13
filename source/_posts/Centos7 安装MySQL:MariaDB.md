---
title: Centos7 安装MySQL/MariaDB
date: 2016-11-30 16:48
tags: Linux, Mysql
categories: Linux
---
# Centos7 安装MySQL/MariaDB

> `MariaDB`数据库管理系统是`MySQL`的一个分支.
在`CentOS7`中`MySQL`被`MariaDB`所代替.

一开始安装的时候执行的`yum install mysql`, 发现装上之后不能启动, 后来发现在`CentOS7`中`MySQL`被`MariaDB`所代替.
然后再删除`mysql`, 重新安装`MariaDB`, 但是神奇的是还是不能启动.

最后找到解决方案:
1. 删除`/var/lib/mysql`文件夹
2. 删除`/etc/my.cnf`文件夹
3. 卸载`yum remove mariadb* `
4. 重装`yum -y install mariadb*`
5. 启动`systemctl start mariadb.service`

终于不报错了!

----

接着再进行一些初始化配置
1. 设置开机启动
`systemctl enable mariadb`
2. 设置密码
`mysql_secure_installation`

- 会提示输入密码: `Enter current password for root (enter for none):` 此时是没有密码的, 直接回车
- 然后设置密码
`Set root password? [Y/n] `
`New password:`
`Re-enter new password:`


3. 是否删除匿名用户
`Remove anonymous users? [Y/n]`  直接回车
4. 是否禁止root远程登录
`Disallow root login remotely? [Y/n]`  直接回车
5. 是否删除test数据库
`Remove test database and access to it? [Y/n]`  直接回车
6. 是否重新加载权限表
`Reload privilege tables now? [Y/n]`  直接回车

接下来可以测试登录
`mysql -uroot -pnewpassword`

Over!


