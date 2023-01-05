# K8s方式安装部署

## 参考文档

1. [kubernetes-ingress-controller官方使用指南](https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/getting-started.md)
2. [Helm Kong charts代码仓库](https://github.com/Kong/charts)
3. [Kong微服务网关在Kubernetes的实践](https://qhh.me/2019/08/17/Kong-%E5%BE%AE%E6%9C%8D%E5%8A%A1%E7%BD%91%E5%85%B3%E5%9C%A8-Kubernetes-%E7%9A%84%E5%AE%9E%E8%B7%B5/)
4. [Kong系列-03-Helm安装Kong 1.3.0 DB-less with Ingress Controller](https://blog.csdn.net/twingao/article/details/104073112)
5. [Kong系列-04-Helm安装Kong 1.3.0 with PostgreSQL and with Ingress Controller](https://blog.csdn.net/twingao/article/details/104073159)

## 安装环境

* Kubernetes集群版本：1.15.3
* Helm版本：2.16.2
* Helm Kong仓库版本：1.3.1
* Kong Ingress Controller版本：0.7.1
* Kong版本：2.0.2
* 搭建日期：2020.3.23

## 数据库选择

在Kong的[最新官网文档](https://docs.konghq.com/1.4.x/kong-for-kubernetes/install/#using-a-database-for-kong-for-kubernetes)专门提到了使用Kubernetes部署Kong时推荐采用`DB-Less`(无数据库模式)，所有的数据存储在Kubernetes控制面板中，这样可以减少数据库维护的负担。但是使用无数据库模式会导致部分需要使用数据库存储数据的第三方插件不可用，具体的插件兼容情况可以[参考这里](https://docs.konghq.com/2.0.x/db-less-and-declarative-config/)

## 安装

本文档选择采用比较简单的`Helm`方式来部署Kong，按照[官网安装文档](https://docs.konghq.com/1.4.x/kong-for-kubernetes/install/)的建议yaml部署方式不建议在生产环境使用。

添加仓库位置

```bash
helm repo add kong https://charts.konghq.com
helm repo update

# 确认一下版本
root@tt-iot-test-master:~# helm search kong/kong
NAME        CHART VERSION   APP VERSION DESCRIPTION
kong/kong   1.3.1           2.0.0       The Cloud-Native Ingress and API-management
```

在进行安装过程之前需要查阅[Kong charts仓库说明文档](https://github.com/Kong/charts/blob/master/charts/kong/README.md)来了解重要的配置参数。

```bash
helm install kong/kong --name kong --namespace kong \
    --set admin.enabled=true \
    --set admin.useTLS=false \
    --set admin.servicePort=8001 \
    --set admin.containerPort=8001 \
    --set admin.nodePort=32081 \
    --set proxy.type=NodePort \
    --set proxy.http.nodePort=32080 \
    --set proxy.tls.nodePort=32443
```

!!! note "注意事项"
    2019年中Helm Kong仓库的默认值出现了比较大的变动，例如在1.3.1版本中admin服务默认被关闭了(0.28.0版本还是开启的)。所以需要通过查看 `Helm Chart`的具体默认值来进行安装配置。

## 验证

我们将admin服务和proxy服务都通过NodePort方式对外暴露服务，admin的暴露端口为`32081`，proxy的暴露端口为`32080`(HTTP)/`32443`(HTTPS)。下面在集群外的一台主机上面通过curl命令测试3个端口：

```bash
# 下面访问的IP地址是Kubernetes集群中一个节点的公网IP地址

# 测试admin服务，正常的打印输出为一段正常的已格式化JSON字符串
root@VM-4-10-ubuntu:~# curl http://47.105.106.182:32081 | python -m json.tool
# 仅展示JSON字符串片段(删除configuration和plugins字段)
{
    "configuration": {},
    "hostname": "kong-kong-758b7bcb77-dx742",
    "lua_version": "LuaJIT 2.1.0-beta3",
    "node_id": "d808ebcd-4c28-4bc5-a80c-6d320fb9bd40",
    "plugins": {},
    "prng_seeds": {
        "pid: 1": 205231922191,
        "pid: 22": 194247127287
    },
    "tagline": "Welcome to kong",
    "timers": {
        "pending": 10,
        "running": 0
    },
    "version": "2.0.2"
}

# 测试proxy的HTTP服务
root@VM-4-10-ubuntu:~# curl 47.105.106.182:32080
# 下面的输出是没有添加路由时的默认打印，表示proxy的HTTP服务正常
{"message":"no Route matched with those values"}

# 测试proxy的HTTPS服务
root@VM-4-10-ubuntu:~# curl 47.105.106.182:32443
# 下面的输出是没有添加路由时的默认打印，表示proxy的HTTPS服务正常
{"message":"no Route matched with those values"}
```

admin服务的访问测试通过后给集群中的任意主机分配一个公网域名：`api.wsh-study.com`
