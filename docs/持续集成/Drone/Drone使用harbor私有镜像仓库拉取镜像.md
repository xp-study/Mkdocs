相对于采用公共的镜像仓库，使用私有镜像仓库，可以部署在内网中，利用内网的安全防护如防火墙等，更安全更高效，方便内部控制。

`Harbor`是一个企业级可以应用于生产环境的镜像仓库。`Harbor `是由`VMware`的中国区研发中心创建的，主力开发都是中国人，很多国内公司都在使用。

#### 优点

1. 高效的`docker`文件分层传输，提供高效的镜像上传下载
2. 提供镜像安全性扫描，漏洞扫描功能
3. 提供易于操作的用户`web`界面
4. 企业级的安全认证方式（多种）
5. 主力开发人员是中国人，方便交流

#### 与Drone CI 集成

通过`Harbor`界面创建一个`test`名字的项目，`tag`想要上传的镜像，然后`push`镜像：

```shell
docker tag hello-world harbor.wsh-study.com/test/hello-world
docker push harbor.wsh-study.com/test/hello-world
```

`drone.yml`

```yml
kind: pipeline
name: default

steps:
- name: build
  image: harbor.wsh-study.com/test/hello-world
  commands:
  - ps

image_pull_secrets:
- dockerconfigjson
```

通过`drone web ui `界面添加 `Secrets`

`name: dockerconfigjson`

`value:`

```js
{
    "auths": {
        "https//harbor.wsh-study.com": {
            "auth": "YWRtaW46SGFyYm9yMTIzNDU="
        }
    }
}
```

`auth `文件里内容实际是用户名密码串简单的`base64`形式，可以简单的通过l类似下边的命令获取。

```shell
echo -n 'admin:Harbor12345' | base64
YWRtaW46SGFyYm9yMTIzNDU=
```

（例子中用户名密码是`Harbor`默认值）