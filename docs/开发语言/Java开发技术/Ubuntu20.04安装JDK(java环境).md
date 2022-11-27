# Ubuntu20.04安装JDK(java环境) 

#### 1、创建java目录

首先我们创建java的安装目录

```shell
cd /opt
mkdir java
cd java
```

#### 2、下载上传jdk

我们如上在  /opt 目录下创建了 java 目录，然后就是下载 jdk 了。

下载地址: `http://seafile.wsh-study.com/d/9b0d9827ea484f459623/files/?p=%2Fjdk%2Fjdk-8u181-linux-x64.tar.gz&dl=1`

下载文件时，我们需要根据自己的 ubuntu20.04 系统位数下载，比如我的是 x64，那么我需要下载：

`jdk-8u221-linux-x64.tar.gz`

下载下来后上传至上方创建的呢 java 目录

![img](./assets/Ubuntu20.04安装JDK(java环境)/1.png)

上传可以选择 ftp 工具，比如 xftp、winscp等

#### 3、解压jdk

如上，在 `/opt/java` 目录下上传了 jdk1.8 ，然后我们通过命令行工具解压该文件

```shell
tar -zxvf  jdk-8u181-linux-x64.tar.gz
```

解压之后，目录如下图所示：

![img](./assets/Ubuntu20.04安装JDK(java环境)/2.png)

#### 4、配置环境变量

执行如下指令：

```shell
vi /etc/profile
```

![img](./assets/Ubuntu20.04安装JDK(java环境)/3.png)

将如下配置添加至上图的文件中，然后 :wq 保存退出。

```shell
export JAVA_HOME=/opt/java/jdk1.8.0_181
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib
```

> 注意：/opt/java/XXX 后面的目录名称一定要跟你的相对应

![img](./assets/Ubuntu20.04安装JDK(java环境)/4.png)

:wq 保存退出后，接着执行如下指令：

```shell
source /etc/profile
java -version
```

![img](./assets/Ubuntu20.04安装JDK(java环境)/5.png)

> 注意，如上这种方式一定不要拉下 **source /etc/profile**