# Gitlab部署HTTPS

## 腾讯云申请证书

* 相关操作见[腾讯云申请免费证书](https://cloud.tencent.com/document/product/400/6814)

## 部署证书

在gitlab配置文件下创建ssl目录，并将证书拷贝到该目录下。

```shell
# /opt/gitlab/config/ssl 对应容器中的 /etc/gitlab/ssl/ 路径
mkdir -p /opt/gitlab/config/ssl
cp /opt/certs/gitlab.wsh-study.com_nginx/* /opt/gitlab/config/ssl/
```

## 修改Gitlab配置

```shell
vim /etc/gitlab/gitlab.rb
 # 修改外部URL
 external_url='https://gitlab.wsh-study.com'
 # 修改nginx配置 
letsencrypt['enable'] = false
nginx['redirect_http_to_https'] =true
nginx['redirect_http_to_https_port'] = 80
nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.wsh-study.com_bundle.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.wsh-study.com.key"
nginx['listen_port'] = 443 # 此处的443端口对应宿主机的8443端口
```

修改完成后，进入容器内部，让配置生效：

```shell
docker exec -it gitlab bash
```

在容器内执行:

```shell
gitlab-ctl reconfigure
gitlab-ctl restart
```

## 修改配置nginx.conf文件

```shell
server {
    listen 80;
    #请填写绑定证书的域名
    server_name gitlab.wsh-study.com;
    #把http的域名请求转成https
    return 301 https://$host$request_uri;
}


server {
        #SSL 默认访问端口号为 443
        listen 443 ssl;
        #请填写绑定证书的域名
        server_name gitlab.wsh-study.com;
        #请填写证书文件的相对路径或绝对路径
        ssl_certificate /opt/certs/gitlab.wsh-study.com_nginx/gitlab.wsh-study.com_bundle.crt;
        #请填写私钥文件的相对路径或绝对路径
        ssl_certificate_key /opt/certs/gitlab.wsh-study.com_nginx/gitlab.wsh-study.com.key;
        ssl_session_timeout 5m;
        #请按照以下协议配置
        ssl_protocols TLSv1.2 TLSv1.3;
        #请按照以下套件配置，配置加密套件，写法遵循 openssl 标准。
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
        ssl_prefer_server_ciphers on;
        location ^~ {
                proxy_set_header HOST $host;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass https://127.0.0.1:8443;
        }
}
```

