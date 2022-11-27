# Seafile文件服务器搭建

## 参考文档

1.[部署 Seafile 服务器（使用 MySQL/MariaDB）](https://cloud.seafile.com/published/seafile-manual-cn/deploy/using_mysql.md)

## 安装环境介绍

* 主机操作系统：`Ubuntu16.04 64位`
* Seafile版本：`7.0.5 64位`
* 撰稿日期：`2020.04.27`

## 安装依赖

```bash
# on Ubuntu 16.04
apt-get update
apt-get install python2.7 python-setuptools python-mysqldb python-urllib3 python-ldap -y
```

## 安装mysql

```bash
sudo apt-get install mysql-server # 会出现字符界面进行安装,设置密码
sudo apt-get install mysql-client
sudo apt-get install libmysqlclient-dev
```

```bash
# 查看mysql是否启动
sudo netstat -tap | grep mysql
```

## 部署和目录设计

这里[下载版本](https://www.seafile.com/download/)为 seafile-server_7.0.5_x86-64.tar.gz 到`/opt/seafile`目录下。 我们建议这样的目录结构:

```bash
mkdir /opt/seafile
mv seafile-server_7.0.5_x86-64.tar.gz /opt/seafile
cd /opt/seafile
#将 seafile-server_7.0.5_x86-64.tar.gz 移动到 seafile 目录下后
tar -xzf seafile-server_7.0.5_x86-64.tar.gz
mkdir installed
mv seafile-server_7.0.5_x86-64.tar.gz installed
```

现在，你的目录看起来应该像这样：

```bash
#tree seafile -L 2

seafile
├── installed
│   └── seafile-server_7.0.5_x86-64.tar.gz
└── seafile-server-7.0.0
    ├── reset-admin.sh
    ├── runtime
    ├── seafile
    ├── seafile.sh
    ├── seahub
    ├── seahub.sh
    ├── setup-seafile-mysql.sh
    └── upgrade
```

这样设计目录的好处在于

* 和 seafile 相关的配置文件都可以放在 `/opt/seafile/conf` 目录下，便于集中管理.
* 后续升级时,你只需要解压最新的安装包到 `/opt/seafile` 目录下.

## 安装

```bash
cd seafile-server-7.0.5s
./setup-seafile-mysql.sh  #运行安装脚本并回答预设问题
What is the name of the server? It will be displayed on the client.
[ server name ] fileServer
What is the ip or domain of the server?
[ This server's ip or domain ] 192.168.101.133
Where do you want to put your seafile data?
Please use a volume with enough free space
[ default "/opt/SourceCode/fileServer/seafile-data" ]
Which port do you want to use for the seafile fileserver?
[ default "8082" ]
-------------------------------------------------------
Please choose a way to initialize seafile databases:
-------------------------------------------------------
[1] Create new ccnet/seafile/seahub databases
[2] Use existing ccnet/seafile/seahub databases
[ 1 or 2 ] 1
What is the host of mysql server?
[ default "localhost" ]
What is the port of mysql server?
[ default "3306" ]
What is the password of the mysql root user?
[ root password ]
verifying password of user root ...  done
Enter the name for mysql user of seafile. It would be created if not exists.
[ default "seafile" ]
Enter the password for mysql user "seafile":
[ password for seafile ]
verifying password of user seafile ...  done
Enter the database name for ccnet-server:
[ default "ccnet-db" ]
Enter the database name for seafile-server:
[ default "seafile-db" ]
Enter the database name for seahub:
[ default "seahub-db" ]
---------------------------------
This is your configuration
---------------------------------
    server name:            fileServer
    server ip/domain:       192.168.101.133

    seafile data dir:       /opt/SourceCode/fileServer/seafile-data
    fileserver port:        8082

    database:               create new
    ccnet database:         ccnet-db
    seafile database:       seafile-db
    seahub database:        seahub-db
    database user:          seafile

Generating ccnet configuration ...
done
Successly create configuration dir /opt/SourceCode/fileServer/ccnet.
Generating seafile configuration ...
Done.
done
Generating seahub configuration ...
----------------------------------------
Now creating seahub database tables ...
----------------------------------------
```

运行后的目录是

```bash
#tree seafile -L 2
seafile
├── ccnet               # configuration files
│   ├── mykey.peer
│   ├── PeerMgr
│   └── seafile.ini
├── conf
│   └── ccnet.conf
│   └── seafile.conf
│   └── seahub_settings.py
│   └── gunicorn.conf
├── installed
│   └── seafile-server_7.0.5_x86-64.tar.gz
├── seafile-data
├── seafile-server-7.0.5  # active version
│   ├── reset-admin.sh
│   ├── runtime
│   ├── seafile
│   ├── seafile.sh
│   ├── seahub
│   ├── seahub.sh
│   ├── setup-seafile-mysql.sh
│   └── upgrade
├── seafile-server-latest  # symbolic link to seafile-server-7.0.5
├── seahub-data
│   └── avatars
```

seafile-server-latest文件夹为指向当前 Seafile 服务器文件夹的符号链接.
将来你升级到新版本后, 升级脚本会自动更新使其始终指向最新的 Seafile 服务器文件夹.

## 启动 Seafile 服务器

### 修改Seafile 服务器和 Seahub 网站的端口

修改conf/gunicorn.conf,修改`Seahub`的端口

```bash
# default localhost:8000
bind = "0.0.0.0:8001"
```

修改fileServer/conf/seafile.conf修改`seafile`服务端口和`MySQL`端口

```conf
[fileserver]
port = 8083

[database]
type = mysql
host = 127.0.0.1
port = 3306
user = seafile
password = 123456
db_name = seafile-db
connection_charset = utf8
```

### 启动 Seafile 服务器和 Seahub 网站

在`seafile-server-latest`目录下，运行如下命令

```bash
./seafile.sh start # 启动 Seafile 服务
./seahub.sh start  # 启动 Seahub 网站
```

### 关闭/重启 Seafile 和 Seahub

在`seafile-server-latest`目录下，运行如下命令

```bash
# 关闭服务
./seahub.sh stop # 停止 Seahub
./seafile.sh stop # 停止 Seafile 进程

# 重启服务

./seafile.sh restart # 停止当前的 Seafile 进程，然后重启 Seafile
./seahub.sh restart  # 停止当前的 Seahub 进程，并重新启动 Seahub
```

## 开机自启动

TODO: 需要将服务进行开机启动，参考[开机自启动 Seafile](https://cloud.seafile.com/published/seafile-manual-cn/deploy/start_seafile_at_system_bootup.md)
