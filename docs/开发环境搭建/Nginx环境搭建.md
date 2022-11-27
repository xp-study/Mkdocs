# acme.sh+nginx配置https

## 参考文档

1. [快速签发 Let's Encrypt 证书指南](https://www.cnblogs.com/esofar/p/9291685.html)
2. [HTTPS之acme.sh申请证书](https://yq.aliyun.com/articles/674835)

## 安装环境介绍

* 主机操作系统：Ubuntu16.04 64位

## acme.sh简介

acme.sh实现了acme协议，可以从[let‘s encrypt](https://letsencrypt.org/) 生成免费的证书。

* 一个纯粹用Shell（Unix shell）语言编写的ACME协议客户端。
* 完整的ACME协议实施。支持ACME v1和ACME v2，支持ACME v2通配符证书
* 简单，功能强大且易于使用。你只需要3分钟就可以学习它。
* Let's Encrypt免费证书客户端最简单的shell脚本。
* 纯粹用Shell编写，不依赖于python或官方的Let's Encrypt客户端。
* 只需一个脚本即可自动颁发，续订和安装证书。不需要root/sudoer访问权限。
* 支持在Docker内使用，支持IPv6

## 安装acme.sh步骤

### 安装

``` bash
curl https://get.acme.sh | sh
```

成功安装之后进行下一步

### 更新环境变量

``` bash
source ~/.bashrc
```

更新完环境变量后进行下一步

### 测试

``` bash
acme.sh --version
```

出现版本信息，说明安装成功

## 生成证书

``` bash
acme.sh --issue -d api.wsh-study.com -w /usr/share/nginx/html
```

参数说明：

* --issue是acme.sh脚本用来颁发证书的指令；
* -d是--domain的简称，其后面须填写已备案的域名，申请多个域名时，继续加`-d 域名`；
* -w是--webroot的简称，其后面须填写nginx配置的根目录.

## 安装证书

拷贝证书到指定位置

``` bash
acme.sh  --installcert -d api.wsh-study.com \
         --key-file /usr/share/nginx/html/api.wsh-study.com.key \
         --fullchain-file /usr/share/nginx/html/api.wsh-study.com.key.pem \
         --reloadcmd "nginx -s reload"
```

## 修改nginx配置文件

修改nginx.conf文件中的server配置

``` bash
server {
    listen 443;
    server_name api.wsh-study.com;
    ssl on;
    root html;
    index index.html index.htm;
    // 配置证书文件
    ssl_certificate   /usr/share/nginx/html/api.wsh-study.com.key.pem;
    ssl_certificate_key  /usr/share/nginx/html/api.wsh-study.com.key;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;

    location / {
        proxy_pass http://localhost:8000; //配置代理端口
    }
}
```

## 证书更新

### 证书的更新

目前证书在 60 天以后会通过定时任务自动更新, 你无需任何操作。
今后有可能会缩短这个时间, 不过都是自动的, 你不用关心.

### acme.sh更新

目前由于acme协议和letsencrypt CA都在频繁的更新，因此acme.sh也经常更新以保持同步.
升级acme.sh到最新版:

```bash
acme.sh --upgrade
```

如果你不想手动升级, 可以开启自动升级:

``` bash
acme.sh  --upgrade  --auto-upgrade
```

之后,acme.sh就会自动保持更新了.
你也可以随时关闭自动更新:

``` bash
acme.sh --upgrade  --auto-upgrade  0
```
