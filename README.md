MyDocs
======


 Useful Git Tips for Beginners
http://sixrevisions.com/web-development/git-tips/ 



gitosis   gitlab

#centos 5.8 install gitlab.

https://github.com/gitlabhq/gitlabhq/blob/6-2-stable/doc/install/installation.md

手动编译ruby2.0 python 2.7.5
一定要先安装 openssl然后再编译ruby.

yum install openssl-devel curl-devel


install rvm

\curl -L https://get.rvm.io | bash -s stable


vm pkg install openssl

rvm install 2.0.0  --with-openssl-dir=$HOME/.rvm/usr  --verify-downloads 1

我发现Cent os 5.8自带的libicu-devel版要太低
#yum install libicu-devel

要手动下载icu.
wget http://download.icu-project.org/files/icu4c/52.1/icu4c-52_1-src.tgz
./runConfigureICU Linux/gcc
make
make install

sudo gem install charlock_holmes --version '0.6.9.4'

$ sudo -u git -H bundle install --deployment --without development test postgres aws
/usr/bin/env: ruby_executable_hooks: No such file or directory


一定要参考这篇文章 ：  http://www.cnblogs.com/lenolix/archive/2013/02/06/2906466.html




