### 问题陈述

在64位机上执行某些程序时提示：

```shell
bash: ./mkbootimg: No such file or directory
或
./arm-linux-gnueabi-gcc: error while loading shared libraries: libstdc++.so.6: cannot open shared object file: No such file or directory
注意：以上两个错误提示例子中mkbootimg和arm-linux-gnueabi-gcc在执行的当目录中一定存在且没有被破坏
```

查看`mkbootimg`和`arm-linux-gnueabi-gcc`信息，如下图所示：

![image-20221125215119612](./assets/ubuntu16.04(64位)兼容32位程序/1.png)

![image-20221125215216399](./assets/ubuntu16.04(64位)兼容32位程序/2.png)

由此可知，`mkbootimg`和`arm-linux-gnueabi-gcc`都是32位程序，在64位机上无法运行。

### 解决办法

在`ubuntu 12.04`及之前的版本，如果需要在64位机上运行32位程序，可以直接安装 `ia32-libs`，其命令如下：

```shell
sudo apt-get install ia32-libs
```

但是在`ubuntu 12.04`之后的版本不能直接安装`ia32-libs`，已经没有该软件包，需要手动安转兼容包。

### 兼容32位程序

在`ubuntu 64`位机上只是兼容32位程序，使其可以运行，需要安装的软件包有：`libc6:i386、libstdc++6:i386`，安装以上两个包之后32位程序就可以在64位机上运行，其安装指令为：

```shell
sudo apt install libc6:i386
sudo apt install libstdc++6:i386
# 或者直接安装gcc-multilib解决问题（推荐使用此方法）
sudo apt install gcc-multilib
```

