Visual Studio Code Notes
---------------------

# Shortcuts

Join lines:  ctrl + j  (mac)

## Add "Open in VSCode"  to folder action.

1. Launch Automator

2. Create New Document

3. Create a new Quick Action [![Select "Quick Action"](https://i.stack.imgur.com/BwWGs.png)](https://i.stack.imgur.com/BwWGs.png)

4. Add the Action...
   
   - Workflow receives current **files and folders** from **Finder**.
   - Add a new Run Shell Script action to the workflow. (drag the "Run Shell Script" object, highlighted in the screenshot, to the empty window on the right)

5. Configure the Workflow
   
   - Set the Pass Input to be **as arguments**
   - Paste the following in the input box:
   
   ```
   open -n -b "com.microsoft.VSCode" --args "$*" 
   ```
   
   [![Screenshot of Workflow](https://i.stack.imgur.com/MnPT6.png)](https://i.stack.imgur.com/MnPT6.png)

6. Save the action using a name like **Open In Visual Studio Code**.

## Launching from the command line[#](https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line)

You can also run VS Code from the terminal by typing 'code' after adding it to the path:

- Launch VS Code.
- Open the **Command Palette** (Cmd+Shift+P) and type 'shell command' to find the **Shell Command: Install 'code' command in PATH** command.

![macOS shell commands](https://code.visualstudio.com/assets/docs/setup/mac/shell-command.png)

- Restart the terminal for the new `$PATH` value to take effect. You'll be able to type 'code .' in any folder to start editing files in that folder.

> **Note:** If you still have the old `code` alias in your `.bash_profile` (or equivalent) from an early VS Code version, remove it and replace it by executing the **Shell Command: Install 'code' command in PATH** command.

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

# Hide certain files from the sidebar.

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


# Editor 设置

##  eslint 和 prettier   tabwidth冲突的问题

eslint 和 prettier在tabwidth上是有冲突，如果你喜欢设置tabwidth为4，同时喜欢用空格替代tab的话，你会发现eslint一直在报错。

![images/Pasted-image-20240509221442.png](images/Pasted-image-20240509221442.png)
明明4个空格是对的，但是就是报错，看着非常难受。
网上说了好多解决方案，我发现只有下面这个能解决，修改ESLint的配置文件如下：。
https://stackoverflow.com/a/72215152/3012163
```js
module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    tsconfigRootDir: __dirname,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint/eslint-plugin'],
  extends: [
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended',
  ],
  root: true,
  env: {
    node: true,
    jest: true,
  },
  ignorePatterns: ['.eslintrc.js'],
  rules: {
    '@typescript-eslint/interface-name-prefix': 'off',
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    "prettier/prettier": [
      "error",
      {
        "tabWidth": 4
      }
    ]
  },
};
```

最主要的是这几行：
```js
 "prettier/prettier": [
      "error",
      {
        "tabWidth": 4
      }
    ]
```

## How do I change the code formatter in VS Code?

**Set a default formatter**

1. Open a Python file in VS Code.
2. Right-click on the editor to display the context menu.
3. Select Format Document With....
4. Select Configure Default Formatter... from the drop-down menu.
5. Select your preferred formatter extension from the list.


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

## Fonts

`"Source Code Pro"`

Anonymous Pro

`"IBM Plex Mono"`

`0xProto`

"Fira Code"
## disable Bracket Pairs 
如果打开了这个设置，vs code会在两个括号之间显示一条彩色的竖线，特别烦人。所以要禁用它。
在setting里搜`Bracket Pairs`然后禁用它。



# 问题

## rg进程占用CPU

在mac上，我经常发现rg占满了我的CPU，在网上搜索发现大家都有这种情况，解决方案是：

`"search.followSymlinks": false` solved my issue too, thx
