# Kong参考指南

## 参考文档

1. [Proxy Reference官方参考指南](https://docs.konghq.com/2.0.x/proxy/)
2. [Admin API for DB Mode官方文档](https://docs.konghq.com/2.0.x/admin-api/)
3. [Admin API for DB-less Mode官方文档](https://docs.konghq.com/2.0.x/db-less-admin-api/)
4. [Kong Kubernetes-Native实战](https://mp.weixin.qq.com/s?subscene=23&__biz=MzAxMjMwODMzOA==&mid=2247483789&idx=1&sn=546cb8f3d235987f48a6f58e50e69441)
5. [Kong系列CSDN博客](https://blog.csdn.net/twingao/category_9594007.html)
6. [Kong官方文档中文版](https://github.com/qianyugang/kong-docs-cn)
7. [CNCF关于Kong的研讨会PPT](./assets/CNCF-Webinar-Kong-for-Kubernetes-January-2020.pdf)
8. [Kubernetes Ingress官方文档](https://kubernetes.io/zh/docs/concepts/services-networking/ingress/)
9. [Kong如何代理外部服务官方文档](https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/using-external-service.md)
10. [kong官方文档翻译参考](https://www.cnblogs.com/zhoujie/tag/kong/)

## 核心实体概念

* Client：通过Kong代理端口发起请求的客户端
* Upstream：最终用户实现的API接口或服务，处于Kong之后的用户服务
* Service：Kong对于Upstream服务的抽象表示
* Route：路由，是Kong的入口，通过指定规则将请求分发给指定Service
* Plugin：插件，可以嵌入到Kong代理流程执行的逻辑。

### Service

### Route

## Ingress Controller

## 代理外部服务

## URL Rewrite

[URL Rewriting in Kong官方博客](https://konghq.com/blog/url-rewriting-in-kong)
