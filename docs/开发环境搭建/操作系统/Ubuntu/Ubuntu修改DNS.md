在 `Ubuntu` 下修改 `DNS `一共有两种方法，建议优先采用方法一。

### 方法一

修改下面文件：

```shell
sudo vim /etc/resolvconf/resolv.conf.d/base
```

加入想要修改成的 `DNS`，比如：

```shell
nameserver 8.8.8.8
nameserver 114.114.114.114
```

如果多个 `DNS`，那么一行一个。修改之后保存即可。

### 方法二

一、修改下面文件：

```shell
sudo vim /etc/network/interfaces
```

在文件最后加入：

```shell
dns-nameservers 8.8.8.8
```

这里的 `8.8.8.8 `都只是举例，大家可以修改成自己想要的 `DNS`。

二、使修改的 `DNS` 生效

光修改还不够，修改完保存了并不是立即生效的。输入下面命令使配置生效：

```shell
sudo /etc/init.d/networking restart # 使网卡配置生效
sudo /etc/init.d/resolvconf restart # 使 DNS 生效
```

然后我们打印一下下面文件看看是否已经生效：

```shell
cat /etc/resolv.conf
```

如果已经变成了你设置的 `DNS`，那就没问题了。

### 方法三

上面的方法都是永久修改的，如果只想临时改一下，那么直接编辑下面的文件：

```shell
sudo vim /etc/resolv.conf
```

改为以下内容：

```shell
nameserver 8.8.8.8 # 希望修改成的 DNS
nameserver 114.114.114.114 # 希望修改成的 DNS
```

这种方法重启就失效了，不建议使用。