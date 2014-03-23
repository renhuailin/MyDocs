



### 自动换行 
light table 默认是关闭了自动换行的，Ctrl + Space 然后 输入 line wrap，选择“Toggle line wrapping in current editor”,可以切换当前的"自动换行"状态。    
我们也可以在用户配置文件里打开“自动换行”

```
;;:editor [:lt.objs.editor/no-wrap
:editor [:lt.objs.editor/wrap
```
