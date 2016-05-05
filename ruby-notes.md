



# 创建一个空的map
```ruby
dict = {}
```


# Get current file's path

``` ruby
File.expand_path(File.dirname(__FILE__))
```

# Join 目录

``` ruby
File.join("/usr","share","fonts")
```


# Write to file;

``` ruby
File.open(yourfile, 'w') { |file| file.write("your text") }
```


http://www.opensourcerails.com/



# Upgrade jekyll to version 3.0.0

$ gem install jekyll
remove Gemfile.lock
run `bundle install`

https://jekyllrb.com/docs/upgrading/2-to-3/


jekyll serve报错：

```
cannot load such file -- jekyll/deprecator
```

可以运行

```
$ bundle exec jekyll serve
```




# 自定义配置的用法

http://guides.rubyonrails.org/configuring.html#custom-configuration



# Class

Instance Variable Encapsulation
The instance variables of an object can only be accessed by the instance methods of
that object. Code that is not inside an instance method cannot read or set the value of
an instance variable (unless it uses one of the reflective techniques that are described
in Chapter 8).

ruby的實例變量只能通過實例方法來訪問，注意只能。

下面的寫法都是錯的

``` ruby
# Incorrect code!
class Point
    @x = 0　 # Create instance variable @x and assign a default. WRONG!這樣定義的不是　Point實例的實例變量，而是Point的class的實例變量. 相當於java類裏的static變量。 
    @y = 0　 # Create instance variable @y and assign a default. WRONG!
    def initialize(x,y)
        @x, @y = x, y　# Now initialize previously created @x and @y.
    end
end
```


｀eql?｀　用來在hash裏做判斷，有點像java的equals方法，Map要用它來做判斷。



因为要用emoji字符，所以要把数据库改成utf8mb4，这时在migration里字符串的长度要设置为191，否则会报错：
 Mysql2::Error: Specified key was too long; max key length is 767 bytes


# gem

列出某个gem在source上的所有版本
gem list rhc --remote --all

查询某个包
$ gem search jekyll



