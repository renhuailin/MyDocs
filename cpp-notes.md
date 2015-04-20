 C++ 备注 for Java Programmer
 -----

# 数据类型
 一定要注意，C++里有无符号型的整型，有可能会溢出。
 请关注下面的两个头文件：
 ```cpp
 #include <climits>
 #include <cfloat>
 ```
float 和double都是有符号的。They are always signed.

# 引用 References.

C++ 默认是Pass by value,Pass by copy.

引用可以理解为别名，所以，对引用所有的操作，会直接作用于它引用的对象。

* 引用必须被初始化。

# Array
C++的Array不是对象。
C++的Array做为函数的参数时，不是传值，而是做为指针传给函数。
