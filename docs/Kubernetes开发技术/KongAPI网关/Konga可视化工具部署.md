# Konga可视化工具部署

## 参考文档

1. [使用Kong和Konga管理微服务和API](https://segmentfault.com/a/1190000020375323?utm_source=tag-newest)

## 安装环境

* Helm Kong仓库版本：1.3.1
* Kong Ingress Controller版本：0.7.1
* Kong版本：2.0.2(>=1.0.0)
* Konga版本：v0.14.7
* 搭建日期：2020.3.23

在部署Konga前按照[K8s方式安装部署Kong](../K8s方式安装部署)这篇文档来完成Kong的部署，需要注意的是Konga依赖的是`Kong Admin API`，但是最新的Helm仓库将该功能关闭了所以需要手动开启。

## 部署数据库

Konga支持`PostgreSQL`和`Cassandra`执行数据存储。本文档选择PostgreSQL作为Konga的数据库，下面将使用Docker部署的方式启动数据库：

```bash
# 创建Docker网络，保证多个容器之前可以互相通信
docker network create konga-net

# 运行数据库
docker pull postgres:9.6
docker run -d --name konga-database \
    --network=konga-net \
    -p 5432:5432 \
    -e "POSTGRES_USER=konga" \
    -e "POSTGRES_DB=konga" \
    -e "POSTGRES_PASSWORD=konga" \
    postgres:9.6
```

## 部署Konga

```bash
# 拉取Konga镜像
docker pull pantsel/konga:0.14.7

# 准备Konga数据库
# 数据库连接参数的内容组成为 postgresql://数据库用户名:数据库密码@数据库地址:数据库端口/数据库名称
# 需要注意如下要点：
# 1. 数据库用户名、数据库密码和数据库名称为部署数据库时的指定值
# 2. 数据库地址需要填写部署数据库的主机IP地址
docker run --rm \
    --network=konga-net \
    pantsel/konga:0.14.7 -c prepare -a postgres -u postgresql://konga:konga@47.105.106.182:5432/konga
# 正常的输出如下：
debug: Preparing database...
Using postgres DB Adapter.
Database exists. Continue...
debug: Hook:api_health_checks:process() called
debug: Hook:health_checks:process() called
debug: Hook:start-scheduled-snapshots:process() called
debug: Hook:upstream_health_checks:process() called
debug: Hook:user_events_hook:process() called
debug: Seeding User...
debug: User seed planted
debug: Seeding Kongnode...
debug: Kongnode seed planted
debug: Seeding Emailtransport...
debug: Emailtransport seed planted
debug: Database migrations completed!

# 运行Konga
docker run -d -p 1337:1337  \
    --network konga-net  \
    -e "DB_ADAPTER=postgres"  \
    -e "DB_URI=postgresql://konga:konga@47.105.106.182:5432/konga"  \
    -e "NODE_ENV=production"  \
    -e "DB_USER=konga" \
    -e "DB_PASSWORD=konga" \
    --name konga \
    pantsel/konga:0.14.7
```

Konga容器运行成功后将运行Konga容器的主机IP地址分配了一个公网域名：`konga.wsh-study.com:1337`

## 验证

可以访问[http://konga.wsh-study.com:1337](http://konga.wsh-study.com:1337)，首次登录时会要求创建一个管理用户，创建用户登录后能看到如下界面：

![Konga主页](./assets/Konga主页.png)

设置Kong Admin API地址：

* Name：任意设置即可
* Kong Admin URL：填写在[K8s方式安装部署Kong](../K8s方式安装部署)设置的admin服务暴露地址

![Konga设置Kong参数](./assets/Konga设置Kong参数.png)

至此Konga的环境已经搭建完成
