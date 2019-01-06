

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
    @x = 0　 # Create instance variable @x and assign a default. WRONG!這樣定義的不是Point實例的實例變量，而是Point的class的實例變量. 相當於java類裏的static變量。 
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
安装指定版本的包
$ gem install jekyll -v 1.8

# Active Record
如何删除 `has_and_belongs_to_many`里的关联对象？

使用delete, `collection.delete(object, ...)`,请参见：
http://guides.rubyonrails.org/association_basics.html#has-and-belongs-to-many-association-reference


* Migration里的`create_join_table`有什么作用？

用来创建`has_and_belongs_to_many`关联的中间表的。
如果不用

``` ruby
create_table :assemblies_parts, id: false do |t|
  t.belongs_to :assembly, index: true
  t.belongs_to :part, index: true
end
```

用`create_join_table`
``` ruby
create_join_table :members, :tags do |t|
  t.index :member_id
  t.index :tag_id
end
```

# Use rvm install ruby.


#  Incorporating Discourse SSO with Existing Rails Site with Devise
[Incorporating Discourse SSO with Existing Rails Site with Devise](http://stackoverflow.com/questions/25478510/incorporating-discourse-sso-with-existing-rails-site-with-devise)  讲了如何整合Discourse与现有的rails项目。

https://meta.discourse.org/t/official-single-sign-on-for-discourse/13045  



Q. How to reconfigurate discourse? 
A. Edit app.yml and then ./launcher rebuild app

Test Discourse account: admin/2dff3a0858d6f658

部署rails

apt install libmysqlclient-dev

sudo apt-get install nodejs





# Use VS Code as Ruby IDE

```
sudo gem install ruby-debug-ide -v 0.6.0

sudo gem install debase -v 0.2.2.beta10

```





cmd + shift + p 然后输入launch,选择`Debug:Open launch.json`

请参见： https://github.com/rubyide/vscode-ruby/wiki/2.-Launching-from-VS-Code





## Rails Debug



https://github.com/rubyide/vscode-ruby/wiki/4.-Running-gem-scripts



转到rails项目的根目录，执行`bin/bundle install --binstubs`  ,  `--binstubs` 的意义请看[这里](https://github.com/rbenv/rbenv/wiki/Understanding-binstubs)。



`${workspaceRoot}/bin/rails`



然后安装

```
$ gem install rubocop
```



按`F5`启动debug,报错了: 



```
/Users/harley/.rvm/rubies/ruby-2.3.0/lib/ruby/2.3.0/rubygems/specification.rb:2158:in `method_missing': undefined method `this' for #<Gem::Specification:0x3fea6c491c90 debase-0.2.2.beta11> (NoMethodError)
	from /Users/harley/.rvm/rubies/ruby-2.3.0/lib/ruby/2.3.0/rubygems/specification.rb:1057:in `find_active_stub_by_path'
	from /Users/harley/.rvm/rubies/ruby-2.3.0/lib/ruby/2.3.0/rubygems/core_ext/kernel_require.rb:64:in `require'
	from /Users/harley/.rvm/gems/ruby-2.3.0/gems/debase-0.2.2.beta11/lib/debase.rb:4:in `<top (required)>'
	from /Users/harley/.rvm/rubies/ruby-2.3.0/lib/ruby/2.3.0/rubygems/core_ext/kernel_require.rb:127:in `require'
	from /Users/harley/.rvm/rubies/ruby-2.3.0/lib/ruby/2.3.0/rubygems/core_ext/kernel_require.rb:127:in `rescue in require'
	from /Users/harley/.rvm/rubies/ruby-2.3.0/lib/ruby/2.3.0/rubygems/core_ext/kernel_require.rb:40:in `require'
	from /Users/harley/.rvm/rubies/ruby-2.3.0/lib/ruby/gems/2.3.0/gems/ruby-debug-ide-0.6.0/lib/ruby-debug-ide.rb:8:in `<top (required)>'
	from /Users/harley/.rvm/gems/ruby-2.3.0@global/gems/ruby-debug-ide-0.6.0/bin/rdebug-ide:8:in `require_relative'
	from /Users/harley/.rvm/gems/ruby-2.3.0@global/gems/ruby-debug-ide-0.6.0/bin/rdebug-ide:8:in `<top (required)>'
	from /Users/harley/.rvm/rubies/ruby-2.3.0/bin/rdebug-ide:23:in `load'
	from /Users/harley/.rvm/rubies/ruby-2.3.0/bin/rdebug-ide:23:in `<main>'
	from /Users/harley/.rvm/gems/ruby-2.3.0/bin/ruby_executable_hooks:15:in `eval'
	from /Users/harley/.rvm/gems/ruby-2.3.0/bin/ruby_executable_hooks:15:in `<main>'
```



参考了github上的这个[issue](https://github.com/rubygems/rubygems/issues/1420#issuecomment-256350006),  通过运行`gem update --system`解决此问题。



10367  gem install rubocop
10368  gem install rcodetools
10373  gem install debase -v 0.2.2.beta11
10377  gem update --system
10378  gem install reek



Ruby [Code Smells](https://github.com/troessner/reek/blob/master/docs/Code-Smells.md).