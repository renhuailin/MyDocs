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


# pip 自定义豆瓣 pypi 源

sudo pip install -v Flask -i https://pypi.douban.com/simple

Python PIP 使用笔记
https://github.com/greatghoul/notes/blob/master/dev/python/pip.rst


# Google python style guide
http://zh-google-styleguide.readthedocs.io/en/latest/google-python-styleguide/contents/




# Python setup


