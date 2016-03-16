



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






