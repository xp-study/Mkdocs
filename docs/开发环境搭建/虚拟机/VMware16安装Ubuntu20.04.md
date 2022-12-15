# VMware16安装Ubuntu20.04

# 1 VM和Ubuntu下载

**Ubuntu系统下载官方链接：**[Ubuntu系统下载](https://ubuntu.com/download/desktop)

![img](./assets/VMware16安装Ubuntu20.04/1.png)

**VMware下载官方链接:** [VMware Workstation 16 Player下载 ](https://www.vmware.com/cn/products/workstation-player/workstation-player-evaluation.html)

![img](./assets/VMware16安装Ubuntu20.04/2.png)

**下完VMware直接安装就行了**

# 2 VM安装Ubuntu

**双击打开VMware Workstation 16 Player** 

![img](./assets/VMware16安装Ubuntu20.04/3.png)

 **点击创建新虚拟机**

![img](./assets/VMware16安装Ubuntu20.04/4.png)

 **选择稍后安装操作系统，再点下一步**

![img](./assets/VMware16安装Ubuntu20.04/5.png)

 **然后注意这两个地方，选择操作系统和版本如下，再点下一步**

![img](./assets/VMware16安装Ubuntu20.04/6.png)

 **自己定一个系统存储位置，再下一步**

![img](./assets/VMware16安装Ubuntu20.04/7.png)

 **最大磁盘大小按需修改，选择存储为单个文件，再下一步**

![img](./assets/VMware16安装Ubuntu20.04/8.png)

 **点击自定义硬件**

![img](./assets/VMware16安装Ubuntu20.04/9.png)

 **选择使用ISO映像文件，浏览选中刚开始下载的Ubuntu系统，然后点右下角的关闭，再点完成**

![img](./assets/VMware16安装Ubuntu20.04/10.png)

 **选中，点击播放虚拟机**

![img](./assets/VMware16安装Ubuntu20.04/11.png)

 **然后等待…**

![img](./assets/VMware16安装Ubuntu20.04/12.png)

 **进入之后，下拉选中 中文简体，再点Ubuntu安装**

![img](./assets/VMware16安装Ubuntu20.04/13.png)

 **再双击chinese。这里因为Ubuntu系统显示器大小不对，下面的界面显示不出来，我们在下一步先来修改它的显示器大小**

![img](./assets/VMware16安装Ubuntu20.04/14.png)

 **到这里后，本来右下箭头所指地方有 继续 按钮，但是显示不出来，我们先关掉安装界面，退出安装**

![img](./assets/VMware16安装Ubuntu20.04/15.png)

![img](./assets/VMware16安装Ubuntu20.04/16.png)

 **等待…然后进入如下页面，点击右上角倒三角形，再点击设置**

![img](./assets/VMware16安装Ubuntu20.04/17.png)

 **下拉找到显示器，点击分辨率**

![img](./assets/VMware16安装Ubuntu20.04/18.png)

 **任意改为另一个，例如1024×768，再点击应用**

![img](./assets/VMware16安装Ubuntu20.04/19.png)

 **选择保留更改**

![img](./assets/VMware16安装Ubuntu20.04/20.png)

 **然后点击左上角图标，重新进入系统安装**

![img](./assets/VMware16安装Ubuntu20.04/21.png)

 **可以看到这时能显示继续的按钮，点击继续**

![img](./assets/VMware16安装Ubuntu20.04/22.png)

![img](./assets/VMware16安装Ubuntu20.04/23.png)

![img](./assets/VMware16安装Ubuntu20.04/24.png)

 **点击现在安装**

![img](./assets/VMware16安装Ubuntu20.04/25.png)

 **再点击继续**

![img](./assets/VMware16安装Ubuntu20.04/26.png)

 **选择地区**

![img](./assets/VMware16安装Ubuntu20.04/27.png)

 **自行填写以下信息**

![img](./assets/VMware16安装Ubuntu20.04/28.png)

 **然后便进入安装等待界面**

![img](./assets/VMware16安装Ubuntu20.04/29.png)

 **下载文件时间较长，可点击展开选择skip，然后再等待一段时间…**

![img](./assets/VMware16安装Ubuntu20.04/30.png)

 **安装完成，提示重启，点击重启**

![img](./assets/VMware16安装Ubuntu20.04/31.png)

 **然后根据提示，进入系统，显示如下界面，即安装完成。**

![img](./assets/VMware16安装Ubuntu20.04/32.png)

# 3 更改Ubuntu软件源

**配置系统的软件源，提高下载速度** **先点左下角矩形网格，找到并打开 软件与更新**

![img](./assets/VMware16安装Ubuntu20.04/33.png)

 **按图示修改**

![img](./assets/VMware16安装Ubuntu20.04/34.png)

![img](./assets/VMware16安装Ubuntu20.04/35.png)

 **点击选择一个**[**服务器**](https://cloud.tencent.com/product/cvm?from=10680)**，如第一个，再点选择服务器**

![img](./assets/VMware16安装Ubuntu20.04/36.png)

 **再点关闭**

![img](./assets/VMware16安装Ubuntu20.04/37.png)

 **点击重新载入，并等待**

![img](./assets/VMware16安装Ubuntu20.04/38.png)

 **其中需输入密码，即之前自行设置的密码，此后有软件更新点击更新即可** **到这里软件源更改完成。**

# 4 Windows与Ubuntu跨系统复制粘贴

**打开终端，手动输入以下命令，再重启ubuntu系统就可以了** **即通过安装VMtools实现了Windows与Ubuntu跨系统复制粘贴，也实现了Ubuntu窗口自适应**

```shell
sudo apt-get autoremove open-vm-tools
sudo apt-get install open-vm-tools
sudo apt-get install open-vm-tools-desktop
```