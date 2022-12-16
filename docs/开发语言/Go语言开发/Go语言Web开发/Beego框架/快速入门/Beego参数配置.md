# Beego参数配置

beego 默认使用了 INI 格式解析配置文件，通常在项目中会存在很多系统参数、业务参数配置，这些参数通常都是通过配置文件进行配置，而且不是写死在代码里面。

> 提示：例如mysql账号密码之类的系统参数，如果写死在代码里面，每次修改参数都得重新打包升级，非常不灵活。

> 提示：修改配置文件后，需要重启应用，配置才生效，即使使用bee run运行项目也得重启。

## 1.beego系统参数

我先介绍下beego自带的系统参数有哪些？默认情况，conf/app.conf就是我们的默认配置文件。

例子:

```go
# 这是注释
#应用名称
appname = tizi356
#http 服务端口
httpport = 8080
#运行模式，常用的运行模式有dev, test, prod
runmode = dev
```

下面表格是beego常用配置:

> 提示: 参数名不区分大小写， 下面的参数配置，了解下即可，需要的时候再查。

|        参数名         |     默认值     |                             说明                             |
| :-------------------: | :------------: | :----------------------------------------------------------: |
|        AppName        |     beego      |                            应用名                            |
|        RunMode        |      dev       | 程序运行模式，常用模式有dev、test、prod，一般用于区分不同的运行环境 |
|  RouterCaseSensitive  |      true      |                    是否路由忽略大小写匹配                    |
|      ServerName       |     beego      |       beego 服务器默认在请求的时候输出 server 头的值。       |
|     RecoverPanic      |      true      | 是否异常恢复，默认值为 true，即当应用出现异常的情况，通过 recover 恢复回来，而不会导致应用异常退出。 |
|      EnableGzip       |     false      |                      是否开启 gzip 支持                      |
|       MaxMemory       |      64M       |             文件上传默认内存缓存大小，单位是字节             |
|      AutoRender       |      true      | 是否模板自动渲染，对于 API 类型的应用，应用需要把该选项设置为 false，不需要渲染模板。 |
|       StaticDir       |     static     |                       静态文件目录设置                       |
|       ViewsPath       |     views      |                           模板路径                           |
|       Graceful        |     false      |          是否开启热升级，默认是 false，关闭热升级。          |
|     ServerTimeOut     |       0        |           设置 HTTP 的超时时间，默认是 0，不超时。           |
|       HTTPAddr        |                |         应用监听地址，默认为空，监听所有的网卡 IP。          |
|       HTTPPort        |      8080      |                         应用监听端口                         |
|      EnableHTTPS      |     false      | 是否启用 HTTPS，默认是 false 关闭。当需要启用时，先设置 EnableHTTPS = true，并设置 HTTPSCertFile 和 HTTPSKeyFile |
|       HTTPSAddr       |                |       https应用监听地址，默认为空，监听所有的网卡 IP。       |
|       HTTPSPort       |     10443      |                      https应用监听端口                       |
|     HTTPSCertFile     |                |                 开启 HTTPS 后，ssl 证书路径                  |
|     HTTPSKeyFile      |                |          开启 HTTPS 之后，SSL 证书 keyfile 的路径。          |
|      EnableAdmin      |     false      |          是否开启进程内监控模块，默认 false 关闭。           |
|       AdminAddr       |   localhost    |                     监控程序监听的地址。                     |
|       AdminPort       |      8088      |                     监控程序监听的地址。                     |
|       SessionOn       |     false      |                       session 是否开启                       |
|    SessionProvider    |     memory     |          session 的引擎， 详情参考session章节的教程          |
|      SessionName      | beegosessionID |                  存在客户端的 cookie 名称。                  |
| SessionGCMaxLifetime  |      3600      |                  session 过期时间, 单位秒。                  |
| SessionProviderConfig |                | 配置信息，根据不同的session引擎设置不同的配置信息，详细的配置请参考session章节的教程 |
| SessionCookieLifeTime |      3600      |       session 默认存在客户端的 cookie 的时间, 单位秒。       |
|     SessionDomain     |                |                  session cookie 存储域名。                   |

## 2.自定义参数

除了beego系统自带的配置，我们也可以自定义配置，然后通过beego.AppConfig对象的函数读取配置。

例子:
我们在app.conf增加下面自定义配置

```go
# 下面是关于mysql数据库的配置参数
mysql_user = "root"
mysql_password = "123456"
mysql_host = "127.0.0.1:3306"
mysql_dbname = "tizi365"
```

下面是读取配置代码:

```go
web.AppConfig.String("mysql_user")
web.AppConfig.String("mysql_password")
web.AppConfig.String("mysql_host")
web.AppConfig.String("mysql_dbname")
```

beego.AppConfig对象，为我们定义了一些常用的函数，用于读取配置，下面列出一些常用的函数:

| 函数名 |           说明            |
| :----: | :-----------------------: |
| String |  以字符串的方式返回参数   |
|  Int   |  以int类型的方式返回参数  |
| Int64  | 以Int64类型的方式返回参数 |
|  Bool  | 以Bool类型的方式返回参数  |
| Float  | 以Float类型的方式返回参数 |

> 提示: 以上函数，只有一个参数，就是配置的名字

如果配置项的参数为空，希望返回默认值，可以使用下面的函数:

|    函数名     |           说明            |
| :-----------: | :-----------------------: |
| DefaultString |  以字符串的方式返回参数   |
|  DefaultInt   |  以int类型的方式返回参数  |
| DefaultInt64  | 以Int64类型的方式返回参数 |
|  DefaultBool  | 以Bool类型的方式返回参数  |
| DefaultFloat  | 以Float类型的方式返回参数 |

> 提示: 以上函数，只有两个参数，第一个参数是配置项名字，第二个参数是默认值

例子:

```go
// 如果mysql_port配置项的参数为空，则返回3306
web.AppConfig.DefaultInt("mysql_port", 3306)
```

## 3.不同运行级别的参数

前面提到runmode参数可以设置不同的运行级别，我们一般用来区分不用的运行环境，例如: dev、test等等。
如果我们希望数据库配置在不同环境，账号密码都不一样，可以使用如下配置方式：

例子:

```go
# 配置运行级别
runmode ="dev"

[dev]
mysql_user = "root"
mysql_password = "123456"
mysql_host = "127.0.0.1:3306"
mysql_dbname = "tizi365"

[test]
mysql_user = "root"
mysql_password = "Ihd9ay86asgk"
mysql_host = "61.99.21.1:3306"
mysql_dbname = "tizi365"

[prod]
mysql_user = "root"
mysql_password = "8hlabdias986"
mysql_host = "202.12.91.1:3306"
mysql_dbname = "tizi365"
```

上面的例子，我们为dev,test,prod三个环境配置了不同的数据库参数，当我们通过web.AppConfig读取参数的时候，由runmode决定读取那个环境的参数。 例如：当runmode=test, mysql_password=Ihd9ay86asgk

## 4.使用多个配置文件

在实际项目中，我们一般都使用多个配置文件管理配置，多个配置文件也方便我们模块化管理配置。

例如: 我们新建一个mysql.conf配置文件，保存数据库配置。
文件: conf/mysql.conf

```go
[dev]
mysql_user = "root"
mysql_password = "123456"
mysql_host = "127.0.0.1:3306"
mysql_dbname = "tizi365"
```

然后我们在conf/app.conf主配置文件中，通过include 将mysql配置文件包含进去。

```go
AppName = tizi356
HttpPort = 8080
runmode = dev

# 包含mysql配置
include "mysql.conf"
```

这种通过include包含其他配置文件的方式，跟把所有配置都写在一个配置文件的效果是一样的, 区别就是使用多个配置文件，各个模块的配置更加清晰。

> 说明： 无论是使用include包含配置文件，还是直接将所有配置都写在一个配置文件，读取配置的方式都一样。

## 5.支持环境变量配置

到目前为止，我们的配置参数都是通过ini配置文件进行配置，如果想通过环境变量进行配置怎么办？尤其是在docker容器环境运行，通常都需要通过环境变量配置应用参数。

beego支持优先从环境变量中读取参数, 只要在ini配置文件中通过 **${环境变量名}**，定义配置项的值。

例子：

```go
runmode  = "${APP_RUN_MODE || dev}"
httpport = "${APP_PORT || 9090}"
```

上面例子的意思就是:
如果环境变量APP_RUN_MODE值不为空，runmode配置的参数就等于APP_RUN_MODE环境变量的值，如果为空，则使用dev作为默认参数。 同理APP_PORT为空，则使用9090作为默认值，否则使用APP_PORT的值。