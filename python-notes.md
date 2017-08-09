Python - Auto generate requirements.txt
[pipreqs](https://github.com/bndr/pipreqs)


``` python
import rlcompleter
import readline
readline.parse_and_bind("tab: complete")
```

今天在mac 10.11上安装 python-neutronclient 报了个错：
```
OSError: [Errno 1] Operation not permitted: '/tmp/pip-Ayqiin-uninstall/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/six-1.4.1-py2.7.egg-info'
```
six这个包受系统保护不能删除，还好Pip是可以忽略依赖的包的。

```
$ sudo pip install  python-neutronclient  --ignore-installed six
```

# Collections
## namedtuple
namedtuple我感觉很适合做string类型的enum。

``` python
InstanceStatus = namedtuple("InstanceStatus",['Running','Stopped'])
status = InstanceStatus('run','stop')
status.Running
```

##
list comprehension和普通的for loop还是有区别的,因为它产生一个list!!! 所以你不能用它来只做赋值用.
http://stackoverflow.com/a/10292038


# Functions
Python 3 允许指定参数必须用参数名的方式传入。
Python 3: Keyword-only arguments: arguments that must be passed by name

``` python
def func(request, *args, **kwargs):
 # *args - Assign extra nonkeyword arguments to *args tuple. 
 # **kwargs - Assign extra keyword arguments to **kwargs dictionary.
 ```
请参见：Learning Python 5th . Chapter 18. Arguments `Special Argument-Matching Modes`


python 中像ruby的pp的函数： 

``` python
from pprint import pprint
pprint(myobj)
```
# pip 自定义豆瓣 pypi 源

sudo pip install -v Flask -i https://pypi.douban.com/simple

pip install  -r requirements.txt -i https://pypi.douban.com/simple

Python PIP 使用笔记
https://github.com/greatghoul/notes/blob/master/dev/python/pip.rst


# Google python style guide
http://zh-google-styleguide.readthedocs.io/en/latest/google-python-styleguide/contents/




# Python setup


# django

$ python manage.py startapp admin
注意 startproject和startapp这两个命令的区别。 https://docs.djangoproject.com/en/1.10/intro/tutorial01/


$ python manage.py makemigrations

$ python manage.py makemigrations --name changed_my_model your_app_label


python manage.py sqlmigrate

```
$ python manage.py sqlmigrate  website 0001_initial
```

python manage.py showmigrations

python manage.py migrate

## view

``` python
HttpResponseRedirect(reverse('author-detail', kwargs={'pk': self.object.pk}))
```
## Managing static files
https://docs.djangoproject.com/en/1.10/howto/static-files/

注意`STATIC_ROOT`的意义
http://stackoverflow.com/a/6015706

## templates

在include其它页面时指定页面里的变量：

```
{% include "name_snippet.html" with person="Jane" greeting="Hello" %}
```

##  write custom template  tags

https://docs.djangoproject.com/en/1.11/howto/custom-template-tags/

## Form 
### Create model from a from.
https://docs.djangoproject.com/en/1.10/topics/forms/modelforms/


djanto Form在产生的html widget里会生成`required`这个属性,如果不想生成这个属性,需要在model定义时添加`blank=True`这个参数.
``` python
tags = models.CharField(max_length=191, null=True, blank=True)
```

## models

从现有的数据库生成model.

https://docs.djangoproject.com/en/1.11/howto/legacy-databases/

###  查询 


[字段的查找](https://docs.djangoproject.com/en/1.11/topics/db/queries/#field-lookups-intro)  格式为:  
`field__lookuptype=value`. (That’s a double-underscore)

[filter](https://docs.djangoproject.com/en/1.11/ref/models/querysets/#django.db.models.query.QuerySet.filter)  里定义很我magic的操作如 `gt` `gte`.

这一章的内容非常值得好好研究一下,如`annotate`,`values`等这些操作.


多条件的查询请使用Q expression.



实现SQL里的limit.
QuerySets are lazy.  也就是用户在使用这个queryset时才真正地去查询数据库.
``` python
articles = Article.objects.filter(
        Q(title__contains=key) | Q(synopsis__contains=key) | Q(content__contains=key))[:5]
```


## ajax post

我发现我在其它WebFrame上用的jquery的ajax脚本,在django下不能用了.

``` js
$.ajax({
    type: "POST",
    contentType: "application/json; charset=utf-8",
    url: url,
    data: JSON.stringify({ provinceId: provinceId }),
    dataType: "json",
    success: function (json) {
        resolve(json);
    }
});
```
在view里用`request.POST['provinceId']`获取不到provinceId的值.感觉很诡异.用PyCharm调试发现数据在`request.body`里.问了强大的Google,找到了原因:
在 [django 1.5](https://docs.djangoproject.com/en/dev/releases/1.5/#non-form-data-in-http-requests) 以后,content-type不是
`multipart/form-data` or `application/x-www-form-urlencoded` post请求的数据将不会放在django的request.POST里.

http://stackoverflow.com/a/23008197    
http://stackoverflow.com/questions/1208067/wheres-my-json-data-in-my-incoming-django-request    

把ajax请求改成下面这样,request.POST里就能拿到post的数据了.
``` js
$.ajax({
    type: "POST",
    contentType: "application/json; charset=utf-8",
    url: url,
    data: {'provinceId':'1'},
    contentType: 'application/x-www-form-urlencoded; charset=utf-8',
    success: function (json) {
        resolve(json);
    }
});
```
## Django Channels
这是个异步的框架,可以处理WebSocket,HTTP2等请求.可以运行后台的任务.


# Setup tools 

https://setuptools.readthedocs.io/en/latest/

http://yansu.org/2013/06/07/learn-python-setuptools-in-detail.html

## pipreqs


## gRPC

$ sudo python -m pip install grpcio -i https://pypi.douban.com/simple

$ sudo python -m pip install grpcio-tools -i https://pypi.douban.com/simple

[这个工具](https://github.com/bndr/pipreqs) 可以根据源代码里的import来生成requirements.txt.



# 问题及解决

最近发现我们的django的项目,一旦出现问题,比如忘记安装包了,或者数据库没配置了等等,在打开的时候就会卡死.查看后台日志,发现过几分钟后会有一个发邮件的超时.后来我才明白,因为我关闭了debug,所以django在出错时不能直接显示错误,只能给管理员发邮件.而我们又没有配置smtp,导致发邮件超时.这个问题的解决方式很简单,出错的时候打开debug.就不会卡死了.









