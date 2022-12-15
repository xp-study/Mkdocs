## 获取Git安装程序

  到Git官网下载，网站地址：https://git-scm.com/downloads，如下图： 

![img](./assets/Git_Windows安装/1.png)

  因为我们是用Windows系统上的浏览器访问的，Git官网自动之别到了我使用的操作系统，所以右侧直接显示下载使用Windows系统的最新版本（如果识别错误，可以在中间选择系统），点击即可下载。我下载的是 2.24.0 for Windows，文件名称是“Git-2.24.0.2-64-bit.exe”。下载到电脑上之后，鼠标双击这个文件即可进入安装过程。

## Git安装过程

  双击看到的第一个界面如下图：

### 01、使用许可声明

![img](./assets/Git_Windows安装/2.png)

  点击“Next”进入下图页面：

### 02、选择安装路径

![img](./assets/Git_Windows安装/3.png)

  在输入框内输入想要安装到的本机路径，也就是实际文件夹位置，或点击“Browse...”选择已经存在的文件夹，然后点击“Next”按钮继续，进入下图界面：

### 03、选择安装组件

![img](./assets/Git_Windows安装/4.png)

  上图红框内的选项是默认勾选的，建议不要动。绿色框1是决定是否在桌面创建快捷方式的。绿色框2是决定在所有控制台窗口中使用TrueType字体和是否每天检查Git是否有Windows更新的。这些根据自己需要选择。

  点击“Next”按钮进入下图界面：

### 04、选择开始菜单页

![img](./assets/Git_Windows安装/5.png)

  这个界面是创建开始菜单中的名称，不需要修改，直接点“Next”按钮继续到下图的界面：

### 05、选择Git文件默认的编辑器

![img](./assets/Git_Windows安装/6.png)

  这个页面是在选择Git文件默认的编辑器，很少用到，所以默认Vim即可，直接点“Next”按钮继续到下图的界面：

### 06、调整您的PATH环境

![img](./assets/Git_Windows安装/7.png)

  这个界面是调整您的PATH环境。

  第一种配置是“仅从Git Bash使用Git”。这是最安全的选择，因为您的PATH根本不会被修改。您只能使用 Git Bash 的 Git [命令行工具](https://cloud.tencent.com/product/cli?from=10680)。但是这将不能通过第三方软件使用。

  第二种配置是“从命令行以及第三方软件进行Git”。该选项被认为是安全的，因为它仅向PATH添加了一些最小的Git包装器，以避免使用可选的Unix工具造成环境混乱。 您将能够从Git Bash，命令提示符和Windows PowerShell以及在PATH中寻找Git的任何第三方软件中使用Git。这也是推荐的选项。

  第三种配置是“从命令提示符使用Git和可选的Unix工具”。警告：这将覆盖Windows工具，如 “ find 和 sort ”。只有在了解其含义后才使用此选项。

  我选择推荐的选项第二种配置，点击“Next”按钮继续到下图的界面：

### 07、选择HTTPS后端传输

![img](./assets/Git_Windows安装/8.png)

  这个界面是选择HTTPS后端传输。

  第一个选项是“使用 OpenSSL 库”。[服务器](https://cloud.tencent.com/product/cvm?from=10680)证书将使用ca-bundle.crt文件进行验证。这也是我们常用的选项。

  第二个选项是“使用本地 Windows 安全通道库”。服务器证书将使用Windows证书存储验证。此选项还允许您使用公司的内部根CA证书，例如通过Active Directory Domain Services 。

  我使用默认选项第一项，点击“Next”按钮继续到下图的界面：

### 08、配置行尾符号转换

![img](./assets/Git_Windows安装/9.png)

  这个界面是配置行尾符号转换。

  第一个选项是“签出Windows风格，提交Unix风格的行尾”。签出文本文件时，Git会将LF转换为CRLF。提交文本文件时，CRLF将转换为LF。对于跨平台项目，这是Windows上的推荐设置（“ core.autocrlf”设置为“ true”）

  第二个选项是“按原样签出，提交Unix样式的行尾”。签出文本文件时，Git不会执行任何转换。 提交文本文件时，CRLF将转换为LF。对于跨平台项目，这是Unix上的建议设置（“ core.autocrlf”设置为“ input”）

  第三种选项是“按原样签出，按原样提交”。当签出或提交文本文件时，Git不会执行任何转换。不建议跨平台项目选择此选项（“ core.autocrlf”设置为“ false”）

  我选择第一种选项，点击“Next”按钮继续到下图的界面：

### 09、配置终端模拟器以与Git Bash一起使用

![img](./assets/Git_Windows安装/10.png)

  这个界面是配置终端模拟器以与Git Bash一起使用。

  第一个选项是“使用MinTTY（MSYS2的默认终端）”。Git Bash将使用MinTTY作为终端模拟器，该模拟器具有可调整大小的窗口，非矩形选择和Unicode字体。Windows控制台程序（例如交互式Python）必须通过“ winpty”启动才能在MinTTY中运行。

  第二个选项是“使用Windows的默认控制台窗口”。Git将使用Windows的默认控制台窗口（“cmd.exe”），该窗口可以与Win32控制台程序（如交互式Python或node.js）一起使用，但默认的回滚非常有限，需要配置为使用unicode 字体以正确显示非ASCII字符，并且在Windows 10之前，其窗口不能自由调整大小，并且只允许矩形文本选择。

  我选择默认的第一种选项，点击“Next”按钮继续到下图的界面：

### 10、配置配置额外的选项

![img](./assets/Git_Windows安装/11.png)

  这个界面是配置配置额外的选项。

  第一个选项是“启用文件系统缓存”。文件系统数据将被批量读取并缓存在内存中用于某些操作（“core.fscache”设置为“true”）。 这提供了显著的性能提升。

  第二个选项是“启用Git凭证管理器”。Windows的Git凭证管理器为Windows提供安全的Git凭证存储，最显着的是对Visual Studio Team Services和GitHub的多因素[身份验证](https://cloud.tencent.com/product/mfas?from=10680)支持。 （需要.NET Framework v4.5.1或更高版本）。

  第三个选项是“启用符号链接”。启用符号链接（需要SeCreateSymbolicLink权限）。请注意，现有存储库不受此设置的影响。

  我勾选默认的第一、第二选项，点击“Next”按钮继续到下图的界面：

### 11、配置实验选项

![img](./assets/Git_Windows安装/12.png)

  这个界面是配置实验选项。

  启用实验性的内置添加 -i / -p。（新！）使用实验性的内置交互式add（“ git add -i”或“ git add -p”）。这使其速度更快（尤其是启动！），但尚未被认为是可靠的。

  默认不勾选，直接点击“Next”按钮继续到下图的安装进度界面：

### 12、安装进度指示

![img](./assets/Git_Windows安装/13.png)

  安装进度结束之后，会出现下图的完成Git安装向导界面：

### 13、安装完成

![img](./assets/Git_Windows安装/14.png)

  在这个界面，可以勾选是否启动启动Git Bash和是否查看发行说明，然后点“Finish”按钮退出安装界面。

### 14、启动测试

  到此，Git的安装完成，可以在开始菜单中看到Git的三个启动图标（Git Bash、Git CMD(Deprecated)、Git GUI）。

  Git Bash，是Git配套的一个控制台，点击打开如下图： 

![img](./assets/Git_Windows安装/15.png)

  Git CMD(Deprecated)，是通过CMD使用Git（不推荐使用），点击打开如下图： 

![img](./assets/Git_Windows安装/16.png)

  Git GUI，是Git的可视化操作工具，点击打开如下图： 

![img](./assets/Git_Windows安装/17.png)
