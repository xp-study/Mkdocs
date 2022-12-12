# Go语言Windows开发环境搭建

## 参考文档

## 开发环境介绍

* 主机操作系统：Windows操作系统 64位
* 目标平台：Windows操作系统 32位 和 64位
* Go版本：1.14.4
* TMD-GCC版本：9.2 64位

## 下载安装

## 解决Windows系统下无法进行cgo开发问题

在Windows系统下使用golang语言进行cgo开发需要gcc编译器的支持,Windows系统没有安装gcc编译器的情况下编译包含C库的go文件会报如下错误

```bash
exec: "gcc": executable file not found in %PATH%
```

因此需要安装Windows系统下的gcc编译器,具体安装操作如下:

### 下载TDM-GCC

访问[TDG-GCC官方下载链接](http://tdm-gcc.tdragon.net/download)下载TDM-GCC安装包

### 安装TDM-GCC

双击下载到的执行文件,根据Windows系统的位数安装TDM-GCC

### 确认GCC版本

在cmd命令窗口输入`gcc -v`指令,若出现gcc的版本信息,则表示TDG-GCC安装成功(**注意版本信息中操作系统的位数**)

### 编译包含C库的golang程序

此时执行`go build`指令即可编译包含C库的golang程序

## Go多版本解决方案(g)

g的官方地址为：[https://github.com/voidint/g](https://github.com/voidint/g)

### 安装

下载相应系统的二进制安装包：[https://github.com/voidint/g/releases](https://github.com/voidint/g/releases)，在这里我们选择`g1.2.0.windows-386.zip`，将压缩包内的执行文件放置到系统目录 `C:\g\` 下

### 配置

* 系统变量`PATH`新增值`C:\g`
* 将原有的`C:\Go\bin`从`PATH`中移除，新增值`%USERPROFILE%\.g\go\bin`
* 将系统变量`GOROOT`值调整为`%USERPROFILE%\.g\go`
* 新增系统变量`G_MIRROR`,并设置值为`https://golang.google.cn/dl/`

### 使用

```bash
# 查询可供安装的Go版本
g ls-remote

# 下载安装指定版本的Go(未启用)
g install 1.16.3

# 查询已经下载安装的Go版本
g ls

# 启用指定版本的Go
g use 1.16.3

# 卸载删除指定版本的Go
g uninstall 1.16.3
```
