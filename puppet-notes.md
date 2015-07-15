Puppet Notes 备注
-------

Testing changes in the development environment
```
# puppet agent --noop --test --environment=development
```




# Scaling Puppet
跟




# ubuntu 14.04 安装 puppet 4 

https://apt.puppetlabs.com/

```
$ lsb_release -a

$ wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb

```

安装客户端：
```
# apt-get install puppet-agent
```

# puppet 4主要变化

http://docs.puppetlabs.com/puppet/4.2/reference/whered_it_go.html

## *nix Executables are in /opt/puppetlabs/bin/
On *nix platforms, the main executables moved to /opt/puppetlabs/bin. This means Puppet and related tools aren’t included in your PATH by default. You’ll need to either:

Add /opt/puppetlabs/bin to your PATH



## puppet 4新的`codedir`保存着所有的模块、配置和数据。

New codedir Holds All Modules/Manifests/Data
All of the content used to configure nodes has moved into a new directory, named codedir. (This stuff used to be in the confdir.)

The default codedir location is:

**`/etc/puppetlabs/code`** on *nix
C:\ProgramData\PuppetLabs\code on Windows
<USER DIRECTORY>/.puppetlabs/etc/code if you’re running as a non-root user


默认安装完后的目录结构：
```
├── environments
│   └── production
│       ├── environment.conf
│       ├── manifests
│       └── modules
├── hieradata
├── hiera.yaml
└── modules
```

**Directory Environments are Always On**

Directory environments are always enabled now.

The default environmentpath is $codedir/environments. On install, we create a directory for the default production environment.

This means that if you’re starting from scratch, you should:

* Put modules in $codedir/environments/production/modules.
* Put your main manifest in $codedir/environments/production/manifests.
* You can still put global modules in $codedir/modules, and can configure a global main manifest with the default_manifest setting.

## 配置目录变成 /etc/puppetlabs/puppet
*nix confdir is Now /etc/puppetlabs/puppet
Puppet’s system confdir (used by root and the puppet user) is now /etc/puppetlabs/puppet, instead of `/etc/puppet`. Open source Puppet now uses the same confdir as Puppet Enterprise.

The confdir is the directory that holds config files like puppet.conf and auth.conf.

On Windows, this stayed the same. It’s still in the COMMON_APPDATA folder, defaulting to C:\ProgramData\PuppetLabs\puppet\etc on modern Windows versions.

ssldir is Inside confdir

On some Linux distros, our default config used to set Puppet’s ssldir as $vardir/ssl rather than $confdir/ssl. Now we’re not doing that; the default location is in the confdir on all platforms.

Other Stuff in /etc/puppetlabs

We’re also moving other related configs into the /etc/puppetlabs directory. Puppet Server now uses /etc/puppetlabs/puppetserver, and MCollective uses /etc/puppetlabs/mcollective.


# 证书

```
$ puppet agent --test --server puppet.domain.com
```
客户端在第一次请求时会发送证书验证请求。如果我们不指定--server这个参数，puppet会去寻找一个名为`puppet`的主机。

We can also specify this in the main section of the /etc/puppet/puppet.conf configuration file on the client:

``` conf
# /etc/puppetlabs/puppet/puppet.conf
[main]
server=puppet.pro-puppet.com
```

## 服务器端完成认证
```
# puppet cert --list
# puppet cert sign agent.domain.com
```

**注意**
puppet server的域名或hostname要用小写的，如果用大写的，agent也会用小写的，会导致错误。    
下面是在我的机器上报的错误，明显是因为我的主机名是大写的，但是puppet用的是小写的。

```
Error: Could not retrieve catalog; skipping run
Error: Could not send report: Server hostname 'harley-ThinkPad-T420' did not match server certificate; expected one of harley-thinkpad-t420, DNS:puppet, DNS:harley-thinkpad-t420
```

# Puppet 语法

## 语法检查

```
#puppet parser validate init.pp
```






