---
title: 利用aiohttp搭建python服务器
date: 2016-11-21 21:33
tags: Python, http服务器
categories: Python
---

# 利用`aiohttp`搭建`python`服务器

``` python
# -*- coding: utf8 -*-

import logging; logging.basicConfig(level=logging.INFO)

import asyncio, os, json, time
from datetime import datetime

from aiohttp import web

shockRecord = ""
wwlyRecord = ""
result = ""

def index(request):
	global shockRecord
	global wwlyRecord
	global result

	text = '%s' % request.match_info['anything']
	# print(text) 
	if 'shock:' in text:
		tempShock = text[6:]
		shockRecord = shockRecord + "</br>" + tempShock
	elif 'wwly:' in text:
		tempWwly = text[5:]
		wwlyRecord = wwlyRecord + "</br>" + tempWwly
	else:
		result = result + "</br>" + text
	# print(result)
	# print(request.url)
	htmlStr = """
	<h3>Record</h3> 
	<div style="width: 200; float: left;">
	<h4>shock:</h4>
	<p style="font-size: 6px;">%s</p>
	</div>
	<div style="width: 200; float: left;">
	<h4>wwly:</h4>
	<p style="font-size: 6px;">%s</p>
	</div>
	<div style="width: 200; float: left;">
	<h4>未知:</h4>
	<p style="font-size: 6px;">%s</p>
	</div>
	""" % (shockRecord, wwlyRecord, result)
	# htmlStr = htmlStr + ''
	return web.Response(body=htmlStr.encode('utf-8'), content_type='text/html')

@asyncio.coroutine
def init(loop):
	app = web.Application(loop=loop)
	app.router.add_route('GET', '/{anything}', index)
	app.router.add_route('GET', '/*', index)
	srv = yield from loop.create_server(app.make_handler(), '0.0.0.0', 9000)
	logging.info('server started at http://0.0.0.0:9000...')
	return srv

loop = asyncio.get_event_loop()
loop.run_until_complete(init(loop))
loop.run_forever()
```

上面的代码实现了解析对方的`GET`请求, 可以把想传递的内容放在`url`链接后面, 同时会把内容记录在全局变量中并展示出来.

其中:
`app.router.add_route('GET', '/{anything}', index)` 
为了把所有的`url`映射到同一个`index`函数上.

`app.make_handler(), '0.0.0.0', 9000` 
一开始我绑定的本地ip地址`127.0.0.1`, 发现本机可以访问, 但是外网不能通过本机ip进行访问. 后来尝试绑定`0.0.0.0`, 实现了外网通过ip地址访问本地`python`服务器.

`web.Response(body=htmlStr.encode('utf-8'), content_type='text/html')`
`text/html`为了设置响应体格式, 否则对方一访问ip地址就会下载文件.


