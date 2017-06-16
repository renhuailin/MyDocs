Visual Studio Code Notes
---------------------


# Shortcuts

Join lines:  ctrl + j  (mac)

# Tips and Tricks
https://github.com/Microsoft/vscode-tips-and-tricks



# Golang extension

cmd + shift + p : `Tasks run build task`. 然后它会让你选择 task runner, 我们先`Others`   它会为你创建一个task.json


要debug必须先安装`delve`
brew install go-delve/delve/delve

下面是我的配置:
task.json

``` json
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

``` json
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


``` json
{
    "go.gopath": "/Users/harley/Documents/Workspace/go-project/XiangCloud/domains-api"
}
```

# hide certain files from the sidebar.

You can configure patterns to hide files and folders from the explorer and searches.

Open VS User Settings (Preferences > User Settings). This will open two side-by-side documents.
Add a new "files.exclude": {...} setting to the User Settings document on the right if it's not already there. This is so you aren't editing the Default Setting directly, but instead adding to it.
Configure the User Setting with new glob patterns as needed. The pattern syntax is powerful. You can find pattern matching details under the Search Across Files topic.
Save the User Settings file.
For example to hide a top level node_modules folder in your workspace:

``` json
"files.exclude": {
    "node_modules/": true
}
``

To hide all files that start with ._ such as ._.DS_Store files found on OSX:

``` json
"files.exclude": {
    "**/._*": true
}
```
You also have the ability to change Workspace Settings (Preferences > Workspace Settings). Workspace settings will create a .vscode/settings.json file in your current workspace and will only be applied to that workspace. User Settings will be applied globally to any instance of VS Code you open, but they won't override Workspace Settings if present. Read more on customizing User and Workspace Settings.


http://stackoverflow.com/a/30142299