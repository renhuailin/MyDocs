# Installation

## Install python with pyenv on mac

```
$ brew upgrade pyenv
```

Python - Auto generate requirements.txt
[pipreqs](https://github.com/bndr/pipreqs)

```python
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

```python
from collections import namedtuple
InstanceStatus = namedtuple("InstanceStatus",['Running','Stopped'])
status = InstanceStatus('run','stop')
print(status.Running)
# run

Animal = namedtuple('Animal', 'name age type')
big_yellow = Animal(name="big_yellow", age=3, type="dog")
print(big_yellow.name)
# output: big_yellow
```

## 

list comprehension和普通的for loop还是有区别的,因为它产生一个list!!! 所以你不能用它来只做赋值用.
http://stackoverflow.com/a/10292038

# Functions

Python 3 允许指定参数必须用参数名的方式传入。
Python 3: Keyword-only arguments: arguments that must be passed by name

```python
def func(request, *args, **kwargs):
 # *args - Assign extra nonkeyword arguments to *args tuple. 
 # **kwargs - Assign extra keyword arguments to **kwargs dictionary.
```

请参见：Learning Python 5th . Chapter 18. Arguments `Special Argument-Matching Modes`

python 中像ruby的pp的函数： 

```python
from pprint import pprint
pprint(myobj)
```

# pip 自定义豆瓣 pypi 源

```
python -m pip install -r requirements.txt -i https://pypi.douban.com/simple # for windows

sudo pip install -v Flask -i https://pypi.douban.com/simple

pip install  -r requirements.txt -i https://pypi.douban.com/simple

sudo pip install [package_name] --upgrade
```

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

```python
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

## write custom template  tags

https://docs.djangoproject.com/en/1.11/howto/custom-template-tags/

## Form

### Create model from a from.

https://docs.djangoproject.com/en/1.10/topics/forms/modelforms/

djanto Form在产生的html widget里会生成`required`这个属性,如果不想生成这个属性,需要在model定义时添加`blank=True`这个参数.

```python
tags = models.CharField(max_length=191, null=True, blank=True)
```

## models

从现有的数据库生成model.

https://docs.djangoproject.com/en/1.11/howto/legacy-databases/

### 查询

[字段的查找](https://docs.djangoproject.com/en/1.11/topics/db/queries/#field-lookups-intro)  格式为:  
`field__lookuptype=value`. (That’s a double-underscore)

[filter](https://docs.djangoproject.com/en/1.11/ref/models/querysets/#django.db.models.query.QuerySet.filter)  里定义很我magic的操作如 `gt` `gte`.

这一章的内容非常值得好好研究一下,如`annotate`,`values`等这些操作.

多条件的查询请使用Q expression.

实现SQL里的limit.
QuerySets are lazy.  也就是用户在使用这个queryset时才真正地去查询数据库.

```python
articles = Article.objects.filter(
        Q(title__contains=key) | Q(synopsis__contains=key) | Q(content__contains=key))[:5]
```

## ajax post

我发现我在其它WebFrame上用的jquery的ajax脚本,在django下不能用了.

```js
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

```js
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

## Static files

所有的用户上传的文件都应该放在media_root下

## `STATIC_ROOT` 和 `STATICFILES_DIRS`

我发现在运行`python manage.py collectstatic`时报错了：

```
django.core.exceptions.ImproperlyConfigured: The STATICFILES_DIRS setting should not contain the STATIC_ROOT setting
```

```python
STATIC_ROOT = os.path.join(BASE_DIR, 'collected_static_files')
STATICFILES_DIRS = [
    os.path.join(BASE_DIR, "static/"),
    # os.path.join(BASE_DIR, "media"),
]
```

我没有理解`STATIC_ROOT` 和 `STATICFILES_DIRS`的作用，
`STATIC_ROOT`是`collectstatic`收集到的文件存放的目录，collectstatic除了`INSTALLED_APPS`下的所有的静态文件外，还会去STATICFILES_DIRS下的静态文件。
STATICFILES_DIRS这个目录下的文件是开发模式服务器`runserver`寻找静态文件的目录。

当我们部署在生产环境，尤其是用apache部署时，通常我们是用apache来服务静态文件的，我们要先运行`python manage.py collectstatic`，再在apache的配置文件里把`/static/` alias到`STATIC_ROOT下就行了。

总之django的这个思路是挺奇怪的，他假设你在部署的时候一定是用nginx或apache等来服务静态文件的。开发模式和生产模式是完全不一样的。

# Setup tools

https://setuptools.readthedocs.io/en/latest/

http://yansu.org/2013/06/07/learn-python-setuptools-in-detail.html

## pipreqs

## gRPC

$ sudo python -m pip install grpcio -i https://pypi.douban.com/simple

$ sudo python -m pip install grpcio-tools -i https://pypi.douban.com/simple

[这个工具](https://github.com/bndr/pipreqs) 可以根据源代码里的import来生成requirements.txt.

# 数据分析

1. NumPy 和 SciPy：用于处理数据数组和科学计算的高效库，是被重点关注并且维护良好的工具。2.
2. Pandas：一个开源库，可以为 Python 编程语言提供快速简化的初步数据处理和数据分析工具。
3. Matplotlib ：数据视觉化实用工具。
4. Seaborn ：提供更多的绘图功能和更专门的绘图。
5. Scikit ：是一个很好的通用机器学习工具，它为数据挖掘和分析提供了有效的工具，而且有很好的使用介面。
6. Dask：非常适合处理大型的数据框架库，它还能在多个处理器中并行运算。
7. TensorFlow、Keras 和 PyTorch：皆适合建立深度学习模型。

matplotlib   画图的library.

## Numpy

Check if two arrays are equal

```
>>> np.array_equal([1, 2], [1, 2])
True
>>> np.array_equal(np.array([1, 2]), np.array([1, 2]))
True
>>> np.array_equal([1, 2], [1, 2, 3])
False
>>> np.array_equal([1, 2], [1, 4])
False
```

# matplotlib

下表包含所有默认的快捷键，可以使用`matplotlibrc`（`#keymap.*`）覆盖。

| 命令              | 快捷键                   |
| --------------- | --------------------- |
| 主页/重置           | `h`、`r`或`home`        |
| 后退              | `c`、左箭头或`backspace`   |
| 前进              | `v`或右箭头               |
| 平移/缩放           | `p`                   |
| 缩放到矩形           | `o`                   |
| 保存              | `ctrl + s`            |
| 切换全屏            | `ctrl + f`            |
| 关闭绘图            | `ctrl + w`            |
| 将平移/缩放限制于`x`轴   | 使用鼠标平移/缩放时按住`x`       |
| 将平移/缩放限制于`y`轴   | 使用鼠标平移/缩放时按住`y`       |
| 保留宽高比           | 使用鼠标平移/缩放时按住`CONTROL` |
| 切换网格            | 鼠标在轴域上时按下`g`          |
| 切换`x`轴刻度（对数/线性） | 鼠标在轴域上时按下`L`或`k`      |
| 切换`y`轴刻度（对数/线性） | 鼠标在轴域上时按下`l`          |

如果你使用`matplotlib.pyplot`，则会为每个图形自动创建工具栏。 如果你正在编写自己的用户界面代码，则可以将工具栏添加为窗口小部件。 确切的语法取决于你的 UI，但在

# 问题及解决

* 最近发现我们的django的项目,一旦出现问题,比如忘记安装包了,或者数据库没配置了等等,在打开的时候就会卡死.查看后台日志,发现过几分钟后会有一个发邮件的超时.后来我才明白,因为我关闭了debug,所以django在出错时不能直接显示错误,只能给管理员发邮件.而我们又没有配置smtp,导致发邮件超时.这个问题的解决方式很简单,出错的时候打开debug.就不会卡死了.

* python3 运行非根目录下的文件报错问题的解决:
  
  参见： https://pyliaorachel.github.io/blog/tech/python/2017/09/15/pythons-import-trap.html
  
  ```python
  $ python -m juejin.strategy
  ```

# Typing

Python 3.5引入了Typing,从此它不再是动态类型的语言了。：）

https://docs.python.org/3/library/typing.html

这里有built in types. http://mypy.readthedocs.io/en/latest/cheat_sheet_py3.html

## [Class and instance variable annotations](https://www.python.org/dev/peps/pep-0526/#id9)

```python
class BasicStarship:
    captain: str = 'Picard'   # instance variable with default
    damage: int    # instance variable without default
    stats: ClassVar[Dict[str, int]] = {}  # class variable
```

注意，上面的代码来自标准 PEP 526，但是我实际验证时，发现这3个变量都是class variable，不知道是不是实现的时候没有遵循这个标准。原来在这个标准下面有一段是被拒绝了提议。

**Forget about**  ClassVar  **altogether:** This was proposed since mypy seems to be getting along fine without a way to distinguish between class and instance variables. But a type checker can do useful things with the extra information, for example flag accidental assignments to a class variable via the instance (which would create an instance variable shadowing the class variable). It could also flag instance variables with mutable defaults, a well-known hazard.

# Pyenv

在mac下安装python 3.6时要加上参数`--enable-framework` ,才能用`matplotlib`。

```
$ PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install 3.6.5
```

# 时间与日期

```python
import time
from datetime import timedelta
import datetime # form python 3.6

# 打印时间差
start_time = time.monotonic()
end_time = time.monotonic()
print(timedelta(seconds=end_time - start_time))

# 从unix timestamp生成datatime.
from datetime import datetime
from pytz import timezone

tzchina = timezone('Asia/Chongqing')

local_time = datetime.fromtimestamp(1530185399999/1000, tzchina)
local_time.strftime("%Y-%m-%d %H:%M:%S")

#to unix time stamp
datetime.datetime(2012,4,1,0,0).timestamp()
datetime.datetime.now().timestamp()

# parse datetime from string 
datetime_object = datetime.strptime('Jun 1 2005  1:33PM', '%b %d %Y %I:%M%p')

datetime_object = datetime.strptime('2015-12-25 01:22:33', "%Y-%m-%d %H:%M:%S")
```

# 字符串格式化表达式

```python
#打印bool
print "%r, %r" % (True, False)
```

| Conversion | Meaning                                                                               |
| ---------- | ------------------------------------------------------------------------------------- |
| `d`        | Signed integer decimal.                                                               |
| `i`        | Signed integer decimal.                                                               |
| `o`        | Unsigned octal.                                                                       |
| `u`        | Obsolete and equivalent to 'd', i.e. signed integer decimal.                          |
| `x`        | Unsigned hexadecimal (lowercase).                                                     |
| `X`        | Unsigned hexadecimal (uppercase).                                                     |
| `e`        | Floating point exponential format (lowercase).                                        |
| `E`        | Floating point exponential format (uppercase).                                        |
| `f`        | Floating point decimal format.                                                        |
| `F`        | Floating point decimal format.                                                        |
| `g`        | Same as "`e`" if exponent is greater than -4 or less than precision, "`f`" otherwise. |
| `G`        | Same as "`E`" if exponent is greater than -4 or less than precision, "`F`" otherwise. |
| `c`        | Single character (accepts integer or single character string).                        |
| `r`        | String (converts any python object using `repr()`).                                   |
| `s`        | String (converts any python object using `str()`).                                    |
| `%`        | No argument is converted, results in a "`%`" character in the result.                 |

举例

```
# 最常用的，格式化float
>>> s = "Price: $ %8.2f"% (356.08977)
>>> print(s)
Price: $   356.09
>>>
```

参考文献1，P216

## List Comprehension

```python
[ expression for item in list if conditional ]
```

## MySQL

### Named Placeholder in SQL

```python
select_stmt = "SELECT * FROM employees WHERE emp_no = %(emp_no)s"
cursor.execute(select_stmt, { 'emp_no': 2 })
```

如何自动关闭mysql connection.

https://stackoverflow.com/a/22618781

```python
from contextlib import closing
import MySQLdb

with closing(MySQLdb.connect(...)) as my_conn:
    with closing(my_conn.cursor()) as my_curs:
        my_curs.execute('select 1;')
        result = my_curs.fetchall()
try:
    my_curs.execute('select 1;')
    print 'my_curs is open;',
except MySQLdb.ProgrammingError:
    print 'my_curs is closed;',
if my_conn.open:
    print 'my_conn is open'
else:
    print 'my_conn is closed'
```

## 把object转成dict

可以直接用`__dict__`,不过推荐用`vars`这个内置函数。

```python
vars(obj)
```

为python对象添加新的字段

```python
dict = {'newField': 'value'}
order.__dict__.update(dict)
```

# # Json

jsonpickle  , django都在用它。

```python
# pip install jsonpickle
import jsonpickle
frozen = jsonpickle.encode(obj)
```

# SQLalchemy

通过表来生成model，参考：https://simpletutorials.com/c/2220/SQLAlchemy+Code+Generation

```
# pip install sqlalchemy
# pip install sqlacodegen

$ sqlacodegen "mysql+mysqlconnector://root:mysql@localhost/virtual_exchange?charset=utf8" --outfile models.py 
```

# SimpleHTTPServer

```

$ python2.7 -m SimpleHTTPServer 8000
$ python3 -m http.server
```

# 参考文献：

1. 《Oreilly.Learning.Python.5th.Edition.June.2013》
