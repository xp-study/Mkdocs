# Beego orm数据库连接设置

本章介绍beego orm数据库连接相关设置。

## 1.beego支持的数据库类型

目前 ORM 支持三种数据库，分别是:

- mysql
- sqlite3
- Postgres

使用不通的数据库，需要导入不通的数据库驱动：

```go
import (
    // 导入mysql驱动
    _ "github.com/go-sql-driver/mysql"
    // 导入sqlite3驱动
    _ "github.com/mattn/go-sqlite3"
    // 导入Postgres驱动
    _ "github.com/lib/pq"
)
```

根据需要导入自己想要的驱动即可。

## 2.mysql数据库连接

这里介绍mysql数据库的详细链接参数，要想连接mysql数据库，首先得注册一个数据库，在调用查询函数会自动创建连接。

ORM 必须注册一个别名为 **default** 的数据库，作为默认使用的数据库。

注册数据库的函数原型：

func RegisterDataBase(aliasName, driverName, dataSource string, params ...int) error

**参数说明**：

|   参数名   |                   说明                    |
| :--------: | :---------------------------------------: |
| aliasName  | 数据库的别名，用来在 ORM 中切换数据库使用 |
| driverName |                 驱动名字                  |
| dataSource |             数据库连接字符串              |
|   params   |                 附加参数                  |

例子:

```go
// 注册默认数据库，驱动为mysql, 第三个参数就是我们的数据库连接字符串。
orm.RegisterDataBase("default", "mysql", "root:123456@tcp(localhost:3306)/tizi?charset=utf8")
```

mysql数据库连接字符串DSN (Data Source Name)详解：

格式:

```go
username:password@protocol(address)/dbname?param=value
```

**参数说明**：

|   参数名    |                             说明                             |
| :---------: | :----------------------------------------------------------: |
|  username   |                          数据库账号                          |
|  password   |                          数据库密码                          |
|  protocol   |                    连接协议，一般就是tcp                     |
|   address   | 数据库地址，可以包含端口。例: localhost:3306 , 127.0.0.1:3306 |
|   dbname    |                          数据库名字                          |
| param=value | 最后面问号（?)之后可以包含多个键值对的附加参数,多个参数之间用&连接。 |

常用附加参数说明：

|   参数名    | 默认值 |                             说明                             |
| :---------: | :----: | :----------------------------------------------------------: |
|   charset   |  none  |          设置字符集，相当于 SET NAMES <value> 语句           |
|     loc     |  UTC   |        设置时区，可以设置为Local，表示根据本地时区走         |
|  parseTime  | false  | 是否需要将 mysql的 DATE 和 DATETIME 类型值转换成GO的time.Time类型。 |
| readTimeout |   0    | I/O 读超时时间, sql查询超时时间. 单位 ("ms", "s", "m", "h"), 例子: "30s", "0.5m" or "1m30s". |
|   timeout   |   0    | 连接超时时间，单位("ms", "s", "m", "h"), 例子: "30s", "0.5m" or "1m30s". |

例子:

```go
root:123456@(123.180.11.30:3306)/tizi?charset=utf8&timeout=5s&loc=Local&parseTime=true
```

## 3.数据库连接池设置

数据库连接词参数主要有下面两个：

### 3.1. SetMaxIdleConns

根据数据库的别名，设置数据库的最大空闲连接

```go
orm.SetMaxIdleConns("default", 20)
```

### 3.2. SetMaxOpenConns

根据数据库的别名，设置数据库的最大数据库连接

```go
orm.SetMaxOpenConns("default", 100)
```

## 4.数据库调试模式

打开调试模式，当执行orm查询的时候，会打印出对应的sql语句。

```go
orm.Debug = true
```