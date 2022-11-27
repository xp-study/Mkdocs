# Kong日志插件

## 参考文档

1. [File Log插件官方文档](https://docs.konghq.com/hub/kong-inc/file-log/)
2. [kubernetes-ingress-controller插件使用](https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/using-kongplugin-resource.md)

## 安装环境

* Kubernetes集群版本：1.15.3
* Kong Ingress Controller版本：0.7.1
* Kong版本：2.0.2(>=1.0.0)

## 插件介绍

file log插件主要是将请求和响应数据附加到磁盘上的日志文件中。

## 插件部署

编写file-log的yaml文件

```yaml  tab="file-log.yaml"
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: file-log
  namespace: dev
  labels:
    global: "true"  # 这里设置为global，所有的通过kong的请求和回复都会被记录到日志
config:
  path: /tmp/file.log  # 日志存储路径和日志名称
plugin: file-log
```

部署插件

```bash
kubectl apply -f file-log.yaml
```

查看部署的插件

```bash
root@tt-iot-test-master:~/devEnv# kubectl get crd
NAME                                       CREATED AT
aliyunlogconfigs.log.alibabacloud.com      2020-03-27T10:03:05Z
kongconsumers.configuration.konghq.com     2020-03-23T08:20:22Z
kongcredentials.configuration.konghq.com   2020-03-23T08:20:22Z
kongingresses.configuration.konghq.com     2020-03-23T08:20:22Z
kongplugins.configuration.konghq.com       2020-03-23T08:20:22Z
root@tt-iot-test-master:~/devEnv# kubectl get  kongplugins.configuration.konghq.com 
NAME       PLUGIN-TYPE   AGE
file-log   file-log      6d12h
```

## 查看日志

然后我们可以在kong的工作节点搜索该日志的位置，并且查看

```bash
root@tt-iot-test-node1:~# find / -name file.log
/var/lib/kubelet/pods/2e5b7a97-0b3b-4b6e-9b9a-ae44fd498f0f/volumes/kubernetes.io~empty-dir/kong-kong-tmp/file.log

```

为了查看方便我们可以做一个软链接，链接到主机的/tmp/目录下

```bash
ln -s /var/lib/kubelet/pods/2e5b7a97-0b3b-4b6e-9b9a-ae44fd498f0f/volumes/kubernetes.io~empty-dir/kong-kong-tmp/file.log /tmp/
```

日志格式如下,每个请求是以json格式保存的，可以查看到请求和应答的详细信息

```json
{
    "latencies":{
        "request":25,
        "kong":1,
        "proxy":24
    },
    "service":{
        "host":"proxy-to-cloudpark.dev.80.svc",
        "created_at":1585970971,
        "connect_timeout":10000,
        "id":"4c9b5ff1-af80-588c-9253-cb96a9504256",
        "protocol":"http",
        "name":"dev.proxy-to-cloudpark.80",
        "read_timeout":10000,
        "port":80,
        "path":"/cloudpark-web/home/",
        "updated_at":1585970971,
        "write_timeout":10000,
        "retries":10
    },
    "request":{
        "querystring":{
            "park_name":"",
            "current_page":"1",
            "token":"PBwn0lC4CRrZZXSzhO5IcHv/Lu/zuUly3Tq7axI+8io=",
            "session_id":"89855CB37BA9AC96BF83E4624F0F6ACE",
            "operator_id":"1898",
            "page_size":"10"
        },
        "size":"424",
        "uri":"/dev/cloudpark/v1//park?operator_id=1898&park_name=¤t_page=1&page_size=10&session_id=89855CB37BA9AC96BF83E4624F0F6ACE&token=PBwn0lC4CRrZZXSzhO5IcHv%2FLu%2FzuUly3Tq7axI%2B8io%3D",
        "url":"http://api.wsh-study.com:8000/dev/cloudpark/v1//park?operator_id=1898&park_name=¤t_page=1&page_size=10&session_id=89855CB37BA9AC96BF83E4624F0F6ACE&token=PBwn0lC4CRrZZXSzhO5IcHv%2FLu%2FzuUly3Tq7axI%2B8io%3D",
        "headers":{
            "host":"api.wsh-study.com:32080",
            "content-type":"application/x-www-form-urlencoded",
            "accept-encoding":"gzip",
            "user-agent":"MI 9(Android/10) (cn.com.wsh-study.implement/ColorUi for UniApp 2.1.4) Weex/0.26.0 1080x2161",
            "connection":"Keep-Alive"
        },
        "method":"GET"
    },
    "client_ip":"10.244.1.1",
    "tries":[
        {
            "balancer_latency":0,
            "port":80,
            "balancer_start":1586183690870,
            "ip":"121.42.174.178"
        }
    ],
    "upstream_uri":"/cloudpark-web/home//park?operator_id=1898&park_name=¤t_page=1&page_size=10&session_id=89855CB37BA9AC96BF83E4624F0F6ACE&token=PBwn0lC4CRrZZXSzhO5IcHv%2FLu%2FzuUly3Tq7axI%2B8io%3D",
    "response":{
        "headers":{
            "access-control-max-age":"3600",
            "content-type":"text/json;charset=UTF-8",
            "date":"Mon, 06 Apr 2020 14:34:50 GMT",
            "connection":"close",
            "via":"kong/2.0.2",
            "access-control-allow-headers":"x-requested-with,Content-Type,X-Auth-Token",
            "x-kong-proxy-latency":"1",
            "server":"openresty/1.15.8.2",
            "transfer-encoding":"chunked",
            "x-kong-upstream-latency":"24",
            "access-control-allow-methods":"POST, GET, OPTIONS, DELETE,PUT",
            "access-control-allow-origin":"*"
        },
        "status":200,
        "size":"1537"
    },
    "route":{
        "created_at":1585970971,
        "methods":[
            "POST",
            "GET",
            "PUT",
            "DELETE"
        ],
        "id":"f5820e73-6ae7-5d27-8552-68f0cad6402a",
        "service":{
            "id":"4c9b5ff1-af80-588c-9253-cb96a9504256"
        },
        "name":"dev.cloudpark-ingress.00",
        "strip_path":true,
        "preserve_host":true,
        "regex_priority":0,
        "updated_at":1585970971,
        "paths":[
            "/dev/cloudpark/v1"
        ],
        "https_redirect_status_code":426,
        "protocols":[
            "http",
            "https"
        ],
        "path_handling":"v0"
    },
    "started_at":1586183690869
}
```

这样所有经过kong进行请求和响应数据都可以在日志中查看到，至此kong日志插件部署完成

## 将日志接入到阿里云日志平台

TODO:将采集的日志接入到阿里云日志平台