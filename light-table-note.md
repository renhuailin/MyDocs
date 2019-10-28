### 设置字体

Setting : User behaviors

```clojure
:editor [:lt.objs.editor/no-wrap
               (:lt.objs.style/font-settings "Source Code Pro" 11 1.3)  ;这一句是修改字体
              (:lt.objs.style/set-theme "default")]
```

### Show line numbers

```clojure
:editor [:lt.objs.editor/no-wrap
         :lt.objs.editor/line-numbers  ;; Add this line to show line numbers.
               (:lt.objs.style/font-settings "Source Code Pro" 11 1.3)  ;这一句是修改字体
              (:lt.objs.style/set-theme "default")]
```

### 自动换行

light table 默认是关闭了自动换行的，Ctrl + Space 然后 输入 line wrap，选择“Toggle line wrapping in current editor”,可以切换当前的"自动换行"状态。    
我们也可以在用户配置文件里打开“自动换行”

```clojure
;;:editor [:lt.objs.editor/no-wrap
:editor [:lt.objs.editor/wrap
```

### 设置color theme

```clojure
(:lt.objs.style/set-theme "default")
```

把上面的default删除，然后按tab，就会列出可用的color theme。推荐几个“ambiance“、“lesser-dark”和”twilight”。
