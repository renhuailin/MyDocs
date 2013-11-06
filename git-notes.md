# git备忘

Git never allows you to push changes to the remote if there have been remote changes.

git是分布式的scm，分布式体现在哪儿呢？
如果你git clone一个repository,那么，你就有了一个local repository,你在本地所做所有的修改都会被记录到local repository里。
先说说这个local repository吧。 git的local repository是 full function的，跟svn和cvs不一样的是，local repository通常是跟工作目录在一起的。
也就是工作目录就是一个repository!

```
$ git remote    
origin   #这里的origin是一个短名，shortname
$ git remote add pb git://github.com/paulboone/ticgit.git
$ git remote -v
origin git://github.com/schacon/ticgit.git
pb git://github.com/paulboone/ticgit.git
```
如果你想查看remote更详细的信息。 
```
$ git remote show origin  
*remote origin   
  URL: git://github.com/schacon/ticgit.git  
  Remote branch merged with 'git pull' while on branch master   
    master   
  Tracked remote branches   
    master   
    ticgit  
    
```


```
$git clone
--local, -l
           When the repository to clone from is on a local machine, this flag bypasses the normal "git aware" transport mechanism and clones
	如果仓库是在本地，那么这个选项就会忽略(bypasses) git aware 这个传输机制而进行clone
           the repository by making a copy of HEAD and everything under objects and refs directories. The files under .git/objects/
           directory are hardlinked to save space when possible.
	新仓库会复制 HEAD 和 objects,refs目录下的所有东西，如果能可能，.git/objects下的文件硬连接到新仓库。
           If the repository is specified as a local path (e.g., /path/to/repo), this is the default, and --local is essentially a no-op. If
           the repository is specified as a URL, then this flag is ignored (and we never use the local optimizations). Specifying --no-local
           will override the default when /path/to/repo is given, using the regular git transport instead.
	如果要clone的仓库在本地，--local就不起作用。如果仓库的URL是/path/to/repo，而又想用正常的传输方式来clone，请使用--no-local这个选项。
           To force copying instead of hardlinking (which may be desirable if you are trying to make a back-up of your repository), but
           still avoid the usual "git aware" transport mechanism, --no-hardlinks can be used.
	如果强制使用copy，不想使用hardlinking,（当你想为你的repository做个备份的时候，你可能想这样做），但是你又想避免 git aware 传输机制，你可以使用--no-hardlinks选项。

所以整条语句看起来是这样的：
git clone -l --no-hardlinks file:///opt/git_repo/MessageCenter
```

##分支branch
跟svn的分支不一样，git的分支是指向一个commit的指针。可以说是相当轻量级啊。   

创建一个分支：
```
$git branch message-delivery
```
这样就创建了一个branch，（是在本地还是在远程？应该是在本地）,这时查看branch,你会发现你工作的branch并没有改变。    
```
$ git branch
  message-delivery
* master
```
要切到这个分支上开发，你需要checkout
```
$ git checkout message-delivery
$ git branch
* message-delivery
  master
```
你可以一令命令完成创建分支并切换到它。
```
git checkout -b <new-branch>
```


###参考文献    
A successful Git branching model http://nvie.com/posts/a-successful-git-branching-model/   
Useful Git Tips for Beginners http://sixrevisions.com/web-development/git-tips/



