Visual Studio Code Notes
---------------------

# Shortcuts

Join lines:  ctrl + j  (mac)

# Tips and Tricks

https://github.com/Microsoft/vscode-tips-and-tricks

`code .` : Open the current folder in a new window
`code -r .` : Open the current folder in the current window
`code -a .` : Add the current folder to the current window

# Golang extension

cmd + shift + p : `Tasks run build task`. 然后它会让你选择 task runner, 我们先`Others`   它会为你创建一个task.json

要debug必须先安装`delve`
brew install go-delve/delve/delve

下面是我的配置:
task.json

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "0.1.0",
    "command": "go",
    "isShellCommand": true,
    "args": [
        "install",
        "src/main.go"
    ],
    "showOutput": "always",
    "options": {
        "env": {
            "GOPATH": "/Users/harley/Documents/Workspace/go-project/XiangCloud/domains-api",
            "GOBIN": "/Users/harley/Documents/Workspace/go-project/XiangCloud/domains-api/bin"
        }
    },
    // "tasks": [
    //     {
    //         "taskName": "install",
    //         "args": [
    //             "-v",
    //             "./..."
    //         ],
    //         "isBuildCommand": true
    //     },
    //     {
    //         "taskName": "test",
    //         "args": [
    //             "-v",
    //             "./..."
    //         ],
    //         "isTestCommand": true
    //     }
    // ]
}
```

```json
{
    "version": "0.2.0",
    "configurations": [

        {
            "name": "Launch",
            "type": "go",
            "request": "launch",
            "mode": "debug",
            "remotePath": "",
            "port": 2345,
            "host": "127.0.0.1",
            "program": "/Users/harley/Documents/Workspace/go-project/XiangCloud/domains-api/src/main.go",
            "env": {"GOPATH":"/Users/harley/Documents/Workspace/go-project/XiangCloud/domains-api"},
            "args": [],
            "showLog": true
        }
    ]
}
```

settings.json

```json
{
    "go.gopath": "/Users/harley/Documents/Workspace/go-project/XiangCloud/domains-api"
}
```

这是我的launch.json，`program`指定了我的程序入口文件。`output`指定debug时的输出文件，这个其实是传给了delve。用这个就行了。

`launch.json`

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [

        {
            "name": "Launch",
            "type": "go",
            "request": "launch",
            "mode": "debug",
            "remotePath": "",
            "port": 2345,
            "host": "127.0.0.1",
            "program": "${workspaceRoot}/src/main.go",
            "env": {},
            "args": [],
            "showLog": true,
            "output": "${workspaceRoot}/dist/main"
        }
    ]
}
```

# hide certain files from the sidebar.

You can configure patterns to hide files and folders from the explorer and searches.

Open VS User Settings (Preferences > User Settings). This will open two side-by-side documents.
Add a new "files.exclude": {...} setting to the User Settings document on the right if it's not already there. This is so you aren't editing the Default Setting directly, but instead adding to it.
Configure the User Setting with new glob patterns as needed. The pattern syntax is powerful. You can find pattern matching details under the Search Across Files topic.
Save the User Settings file.
For example to hide a top level node_modules folder in your workspace:

```json
"files.exclude": {
    "node_modules/": true
}
``

To hide all files that start with ._ such as ._.DS_Store files found on OSX:

​``` json
"files.exclude": {
    "**/._*": true
}
```

You also have the ability to change Workspace Settings (Preferences > Workspace Settings). Workspace settings will create a .vscode/settings.json file in your current workspace and will only be applied to that workspace. User Settings will be applied globally to any instance of VS Code you open, but they won't override Workspace Settings if present. Read more on customizing User and Workspace Settings.

http://stackoverflow.com/a/30142299

## 用vscode来编辑远程文件

[用vscode来编辑远程文件](https://medium.com/@prtdomingo/editing-files-in-your-linux-virtual-machine-made-a-lot-easier-with-remote-vscode-6bb98d0639a4)

1. Launch Visual Studio Code, or install it here if you don’t have it yet

2. Go to the ‘Extensions’ page and search for ‘Remote VSCode’

3. 在linux里安装rmate.
   
   ```
   $ sudo wget -O /usr/local/bin/rmate https://raw.github.com/aurora/rmate/master/rmate
   $ sudo chmod a+x /usr/local/bin/rmate
   ```

4. Go back to your Visual Studio Code and open up the command palette (CTRL+P for Windows and CMD+P for Mac) then execute the `>Remote: Start Server` command.

5. Once the server is ready, open up a new terminal and connect to your Linux Virtual Machine using the following command:

```
$ ssh -R 52698:localhost:52698 VIRTUAL_MACHINE_IP_ADDRESS
```

# 设置Proxy

```
// VSCode: Place your settings in this file to overwrite the default settings
{
  "http.proxy": "http://user:pass@proxy.com:8080",
  "https.proxy": "http://user:pass@proxy.com:8080",
  "http.proxyStrictSSL": false
}
```

**How to add more indentation in the explorer file tree structure?**

Workbench › Tree: Indent

Controls tree indentation in pixels.

"workbench.tree.indent": 10

### LineHeight

In VS Code, `editor.lineHeight` is an absolute value, so setting it to `1.2` does not work. The line height is in [“…in CSS pixels of the amount of space used for lines vertically.”](https://github.com/microsoft/vscode/issues/33968#issuecomment-328780081).

There’s currently an [open issue to allow the user to set line spacing as a relative value](https://github.com/microsoft/vscode/issues/115960), but the feature is not implemented yet.

It looks like the [default line spacing defaults to 1.35 relative to the font size](https://github.com/microsoft/vscode/issues/115960#issuecomment-840530402).

For a font size of `13`, setting the value in `editor.lineHeight` to `22` has the same effect as keeping the default (1.35 relative?). I’ve manually bumped it down to `21`.

# 问题

## rg进程占用CPU

在mac上，我经常发现rg占满了我的CPU，在网上搜索发现大家都有这种情况，解决方案是：

`"search.followSymlinks": false` solved my issue too, thx
