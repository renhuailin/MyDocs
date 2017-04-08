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

# Functions
Python 3 允许指定参数必须用参数名的方式传入。
Python 3: Keyword-only arguments: arguments that must be passed by name

``` python
def func(request, *args, **kwargs):
 # *args - Assign extra nonkeyword arguments to *args tuple. 
 # **kwargs - Assign extra keyword arguments to **kwargs dictionary.
 ```
请参见：Learning Python 5th . Chapter 18. Arguments `Special Argument-Matching Modes`


# pip 自定义豆瓣 pypi 源

sudo pip install -v Flask -i https://pypi.douban.com/simple

Python PIP 使用笔记
https://github.com/greatghoul/notes/blob/master/dev/python/pip.rst


# Google python style guide
http://zh-google-styleguide.readthedocs.io/en/latest/google-python-styleguide/contents/




# Python setup


# django

$ python manage.py startapp admin
注意 startproject和startapp这两个命令的区别。 https://docs.djangoproject.com/en/1.10/intro/tutorial01/


python manage.py makemigrations

$ python manage.py makemigrations --name changed_my_model your_app_label


python manage.py sqlmigrate

```
$ python manage.py sqlmigrate  website 0001_initial
```

python manage.py showmigrations

python manage.py migrate

 
## Managing static files
https://docs.djangoproject.com/en/1.10/howto/static-files/

## Form 
### Create model from a from.
https://docs.djangoproject.com/en/1.10/topics/forms/modelforms/


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
