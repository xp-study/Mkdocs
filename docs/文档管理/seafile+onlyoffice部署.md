# seafile+onlyoffice部署与集成

## `seafile`部署

* 创建文件夹`/opt/seafile`

```shell
mkdir -p /opt/seafile
```

* 创建 `docker-compose.yml`文件,文件内容如下:

```json
version: '2.0'
services:
  db:
    image: mariadb:10.5
    container_name: seafile-mysql
    environment:
      - MYSQL_ROOT_PASSWORD=db_dev  # Requested, set the root's password of MySQL service.
      - MYSQL_LOG_CONSOLE=true
    volumes:
      - /opt/seafile/seafile-mysql/db:/var/lib/mysql  # Requested, specifies the path to MySQL data persistent store.
    networks:
      - seafile-net

  memcached:
    image: memcached:1.6
    container_name: seafile-memcached
    entrypoint: memcached -m 256
    networks:
      - seafile-net

  seafile:
    image: seafileltd/seafile-mc:latest
    container_name: seafile
    ports:
      - "32080:80"
        #- "38000:8000"
        #- "32443:443"  # If https is enabled, cancel the comment.
    volumes:
      - /opt/seafile/seafile-data:/shared   # Requested, specifies the path to Seafile data persistent store.
    environment:
      - DB_HOST=db
      - DB_ROOT_PASSWD=db_dev  # Requested, the value shuold be root's password of MySQL service.
#      - TIME_ZONE=Asia/Shanghai # Optional, default is UTC. Should be uncomment and set to your local time zone.
      - SEAFILE_ADMIN_EMAIL=475031724@qq.com # Specifies Seafile admin user, default is 'me@example.com'.
      - SEAFILE_ADMIN_PASSWORD=XU173168penga     # Specifies Seafile admin password, default is 'asecret'.
      - SEAFILE_SERVER_LETSENCRYPT=false   # Whether use letsencrypt to generate cert.
    depends_on:
      - db
      - memcached
    networks:
      - seafile-net

networks:
  seafile-net:
```

```shell
docker-compose up -d
```

## `onlyoffice`部署

创建文件夹

```shell
mkdir -p /opt/onlyoffice{logs,data,lib,database,fonts}
```



```json
version: '2.0'
services:
  seafile:
    image: onlyoffice/documentserver:7.1
    container_name: onlyoffice
    ports:
      - "10003:80"
    volumes:
      - /opt/onlyoffice/logs:/var/log/onlyoffice
      - /opt/onlyoffice/data:/var/www/onlyoffice/Data
      - /opt/onlyoffice/lib:/var/lib/onlyoffice
      - /opt/onlyoffice/database:/var/lib/postgresql
      - /opt/onlyoffice/fonts:/usr/share/fonts
```

```shell
docker-compose up -d
```

`seafile`集成`onlyoffice`

```shell
cd /opt/seafile/seafile-data/seafile/conf
vim seahub_settings.py
```

在文件末尾添加如下配置

```shell
ENABLE_ONLYOFFICE = True
VERIFY_ONLYOFFICE_CERTIFICATE = False
ONLYOFFICE_APIJS_URL = 'https://onlyoffice.wsh-study.com/web-apps/apps/api/documents/api.js' #ip 改为 本机ip
ONLYOFFICE_FILE_EXTENSION = ('doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'odt', 'fodt', 'odp', 'fodp', 'ods', 'fods')
ONLYOFFICE_EDIT_FILE_EXTENSION = ('docx', 'pptx', 'xlsx')
```

## 参考文档

[Seafile与Mkdocs部署参考文档点击这里](https://cloud.seafile.com/published/seafile-manual-cn/docker/%E7%94%A8Docker%E9%83%A8%E7%BD%B2Seafile.md)
