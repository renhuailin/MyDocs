MyDocs
======

imessage enabler    
http://www.souldevteam.net/blog/2012/11/28/enable-imessage-on-hackintosh/




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

bundle exec rake gitlab:setup RAILS_ENV=production
发现系统提示
```
rake aborted!
libicui18n.so.52: cannot open shared object file: No such file or directory - /home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/charlock_holmes-0.6.9.4/lib/charlock_holmes/charlock_holmes.so
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:251:in `require'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:251:in `block in require'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:236:in `load_dependency'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:251:in `require'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/charlock_holmes-0.6.9.4/lib/charlock_holmes.rb:1:in `<top (required)>'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:251:in `require'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:251:in `block in require'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:236:in `load_dependency'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:251:in `require'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/gitlab-grit-2.6.1/lib/grit.rb:79:in `<top (required)>'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:251:in `require'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:251:in `block in require'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:236:in `load_dependency'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/activesupport-3.2.13/lib/active_support/dependencies.rb:251:in `require'
/home/git/gitlab/vendor/bundle/ruby/2.0.0/gems/gitlab_git-3.0.0.rc2/lib/gitlab_git.rb:4:in `<top (required)>'
/usr/local/rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5/lib/bundler/runtime.rb:72:in `require'
/usr/local/rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5/lib/bundler/runtime.rb:72:in `block (2 levels) in require'
/usr/local/rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5/lib/bundler/runtime.rb:70:in `each'
/usr/local/rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5/lib/bundler/runtime.rb:70:in `block in require'
/usr/local/rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5/lib/bundler/runtime.rb:59:in `each'
/usr/local/rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5/lib/bundler/runtime.rb:59:in `require'
/usr/local/rvm/gems/ruby-2.0.0-p247@global/gems/bundler-1.3.5/lib/bundler.rb:132:in `require'
/home/git/gitlab/config/application.rb:9:in `<top (required)>'
/home/git/gitlab/Rakefile:5:in `require'
/home/git/gitlab/Rakefile:5:in `<top (required)>'
(See full trace by running task with --trace)

```
在网上看到一个兄弟写到
```
Experiencing the same issue on Arch Linux. Did a full system upgraded, got icu-52.1, sidekiq fails with charlock loading error.

Downgrading to icu-51 solves the issue.

Running Gitlab 6.1.
```

看来要安装icu-51 才行。
