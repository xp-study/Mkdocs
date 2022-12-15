# 如何在 Ubuntu 20.04 上安装 Visual Studio Code

**简介：** Visual Studio Code 是一个由微软开发的强大的开源代码编辑器。它包含内建的调试支持，嵌入的 Git 版本控制，语法高亮，代码自动完成，集成终端，代码重构以及代码片段功能。本文主要为大家讲解两种在 Ubuntu 20.04 上安装 Visual Studio Code 的方式。

![1.jpg](./assets/VSCode_Ubuntu安装教程/1.jpg)

Visual Studio Code 是一个由微软开发的强大的开源代码编辑器。它包含内建的调试支持，嵌入的 Git 版本控制，语法高亮，代码自动完成，集成终端，代码重构以及代码片段功能。
Visual Studio Code 是跨平台的，在 Windows, Linux, 和 macOS 上可用。
这篇指南显示了两种在 Ubuntu 20.04 上安装 Visual Studio Code 的方式。 VS Code 可以通过 [Snapcraft 商店](https://snapcraft.io/store)或者微软源仓库中的一个 deb 软件包来安装。你可以选择最适合你的环境的安装方式。

## 一、作为一个 Snap 软件包安装 Visual Studio Code

Visual Studio Code snap 软件包由微软来进行分发和维护。
Snaps 是一种自包含的软件包，它包含需要运行这个应用所有的依赖。 Snap 软件包容易升级，并且非常安全。和标准的 deb 软件包不同，snaps 需要占用更大的磁盘空间，和 更长的应用启动时间。
Snap 软件包可以通过命令行或者 Ubuntu 软件应用来安装。
想要安装 VS Code snap版，打开你的终端(`Ctrl+Alt+T`)并且运行下面的命令：

```shell
sudo snap install --classic code
```

就这些。Visual Studio Code 已经在你的 Ubuntu 机器上安装好了，你可以开始使用它了。
如果你喜欢使用 GUI 图形界面，打开 Ubuntu 软件中心，并且搜索“Visual Studio Code”,然后安装应用：

![2.png](./assets/VSCode_Ubuntu安装教程/2.jpg)
不管何时，当新版本发布时，Visual Studio Code 软件包都会在后台被自动升级。

## 二、使用 apt 安装 Visual Studio Code

Visual Studio Code 在官方的微软 Apt 源仓库中可用。想要安装它，按照下面的步骤来：

1. 以 sudo 用户身份运行下面的命令，更新软件包索引，并且安装依赖软件：

```shell
sudo apt update
sudo apt install software-properties-common apt-transport-https wget
```

1. 使用 wget 命令插入 Microsoft GPG key ：

```shell
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
```

启用 Visual Studio Code 源仓库，输入：

```shell
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
```

1. 一旦 apt 软件源被启用，安装 Visual Studio Code 软件包：

```shell
sudo apt install code
```

当一个新版本被发布时，你可以通过你的桌面标准软件工具，或者在你的终端运行命令，来升级 Visual Studio Code 软件包：

```shell
sudo apt update
sudo apt upgrade
```

## 三、启动 Visual Studio Code

在 Activities 搜索栏输入 "Visual Studio Code"，并且点击图标，启动应用。
当你第一次启动 VS Code 时，一个类似下面的窗口应该会出现：
![3.png](./assets/VSCode_Ubuntu安装教程/3.jpg)
你可以开始安装插件，并且根据你的喜好配置 VS Code 了。
VS Code 也可以通过在终端命令行输入`code`进行启动。

## 四、总结

我们已经为大家讲解了如何在 Ubuntu 20.04 上安装 VS Code。现在你可以开始安装新插件，并且定制化你的工作区。想要了解更多关于 VS Code 的信息，浏览他们的[官方文档页面](https://code.visualstudio.com/docs/)。