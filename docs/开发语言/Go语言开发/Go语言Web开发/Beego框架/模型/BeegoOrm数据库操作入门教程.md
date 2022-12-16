# Beego orm数据库操作入门教程

Beego ORM框架是一个独立的ORM模块，主要用于数据库操作。

> 说明: 对象-关系映射（Object/Relation Mapping，简称ORM）, 在Go语言中就是将struct类型和数据库记录进行映射。

下面介绍如何操作mysql数据库。

## 1.安装包

因为beego orm是独立的模块，所以需要单独安装包。

```go
// 安装beego orm包
go get github.com/beego/beego/v2/client/orm
```

安装mysql驱动

```go
go get github.com/go-sql-driver/mysql
```

beego orm包操作什么数据库，就需要单独安装对应的数据库驱动。

## 2.导入包

```go
import (
    // 导入orm包
    "github.com/beego/beego/v2/client/orm"
    
    // 导入mysql驱动
    _ "github.com/go-sql-driver/mysql"
)
```

## 3.连接mysql数据库

操作数据库之前首先需要配置好mysql数据库连接参数，通常在beego项目中，我们都会在main.go文件，对数据库进行配置，方便整个项目操作数据库。

例子：

```go
package main

import (
	_ "beegodemo/routers"
	"github.com/beego/beego/v2/server/web"
	// 导入orm包
	"github.com/beego/beego/v2/client/orm"
	// 导入mysql驱动
	_ "github.com/go-sql-driver/mysql"
)

// 通过init函数配置mysql数据库连接信息
func init() {
    // 这里注册一个default默认数据库，数据库驱动是mysql.
    // 第三个参数是数据库dsn, 配置数据库的账号密码，数据库名等参数
    //  dsn参数说明：
    //      username    - mysql账号
    //      password    - mysql密码
    //      db_name     - 数据库名
    //      127.0.0.1:3306 - 数据库的地址和端口
	orm.RegisterDataBase("default", "mysql", "username:password@tcp(127.0.0.1:3306)/db_name?charset=utf8&parseTime=true&loc=Local")
	
	// 打开调试模式，开发的时候方便查看orm生成什么样子的sql语句
	orm.Debug = true
}

func main() {
	web.Run()
}
```

## 4.定义模型(Model)

orm操作通常都是围绕struct对象进行，我们先定义一个表结构，方便后面演示数据库操作。

### 4.1.定义表结构

这里我们创建一个简单的订单表。

```go
CREATE TABLE `orders` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `shop_id` int(10) unsigned NOT NULL COMMENT '店铺id',
  `customer_id` int(10) unsigned NOT NULL COMMENT '用户id',
  `nickname` varchar(20) DEFAULT NULL COMMENT '用户昵称',
  `address` varchar(200) NOT NULL DEFAULT '' COMMENT '用户地址',
  `init_time` datetime NOT NULL COMMENT '创建订单的时间',
   PRIMARY KEY (`id`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8
```

### 4.2.定义模型

所谓模型(Model)指的就是关联数据库表的struct类型。
这里我们定义个Order结构体， 他们的字段对应着上面的orders表结构。

```go
// 默认情况struct字段名按照下面规则转换成mysql表字段名：
// 规则:  以下滑线分割首字母大写的单词，然后转换成小写字母。
type Order struct {
    // 对应表字段名为: id
	Id int
	// 对应表字段名为: shop_id , 下面字段名转换规则以此类推。
	ShopId int
	// struct字段名跟表字段名不一样，通过orm标签指定表字段名为customer_id
	Uid int	`orm:"column(customer_id)"`
	Nickname string
	Address string
	// 数据库init_time字段是datetime类型，支持自动转换成Go的time.Time类型，但是数据库连接参数必须设置参数parseTime=true
	InitTime time.Time
}

// 指定Order结构体默认绑定的表名
func (o *Order) TableName() string {
	return "orders"
}

// 注册模型
orm.RegisterModel(new(Order))
```

## 5.插入数据

例子1:

```go
// 创建orm对象, 后面都是通过orm对象操作数据库
o := orm.NewOrm()

// 创建一个新的订单
order := Order{}
// 对order对象赋值
order.ShopId = 1
order.Uid = 1002
order.Nickname = "大锤"
order.Address = "深圳南山区"
order.InitTime = time.Now()

// 调用orm的Insert函数插入数据
// 等价sql： INSERT INTO `orders` (`shop_id`, `customer_id`, `nickname`,
`address`, `init_time`) VALUES (1, 1002, '大锤', '深圳南山区', '2019-06-24 23:08:57')
id, err := o.Insert(&order)

if err != nil {
    fmt.Println("插入失败")
} else {
    // 插入成功会返回插入数据自增字段，生成的id
    fmt.Println("新插入数据的id为:", id)
}
```

例子2 批量插入数据：

```go
o := orm.NewOrm()

orders := []Order{
    {ShopId:1, Uid:1001, Nickname:"大锤1", Address:"深圳南山区", InitTime: time.Now()},
    {ShopId:1, Uid:1002, Nickname:"大锤2", Address:"深圳南山区", InitTime: time.Now()},
    {ShopId:1, Uid:1003, Nickname:"大锤3", Address:"深圳南山区", InitTime: time.Now()},
}

// 调用InsertMulti函数批量插入， 第一个参数指的是要插入多少数据
nums, err := o.InsertMulti(3, orders)
```

## 6.更新数据

orm的Update函数是根据主键id进行更新数据的，因此需要预先对id赋值。

例子:

```go
o := orm.NewOrm()

// 需要更新的order对象
order := Order{}
// 先对主键id赋值, 更新数据的条件就是where id=2
order.Id = 2

// 对需要更新的数据进行赋值
order.Nickname = "小锤"
order.Address = "深圳宝安区"

// 调用Update函数更新数据, 默认Update根据struct字段，更新所有字段值，如果字段值为空也一样更新。
// 等价sql: update orders set shop_id=0, customer_id=0, nickname='小锤', address='深圳宝安区', init_time='0000:00:00'  where id = 2
num, err := o.Update(&order)
if err != nil {
    fmt.Println("更新失败")
} else {
    fmt.Println("更新数据影响的行数:", num)
}


// 上面Update直接更新order结构体的所有字段，如果只想更新指定字段，可以这么写
num, err := o.Update(&order, "Nickname", "Address")
// 这里只是更新Nickname和Address两个字段
```

## 7.查询数据

默认orm的Read函数也是通过主键id查询数据。

例子:

```go
o := orm.NewOrm()
// 定义order
order := Order{}
// 先对主键id赋值, 查询数据的条件就是where id=2
order.Id = 2

// 通过Read函数查询数据
// 等价sql: select id, shop_id, customer_id, nickname, address, init_time from orders where id = 2
err := o.Read(&order)

if err == orm.ErrNoRows {
    fmt.Println("查询不到")
} else if err == orm.ErrMissPK {
    fmt.Println("找不到主键")
} else {
    fmt.Println(order.Id, order.Nickname)
}

// 通过ReadOrCreate函数，先尝试根据主键id查询数据，如果数据不存在则插入一条数据
created, id, err := o.ReadOrCreate(&order, "Id")
// ReadOrCreate返回三个参数，第一个参数表示是否插入了一条数据，第二个参数表示插入的id
```

## 8.删除数据

orm的Delete函数根据主键id删除数据。

例子:

```go
o := orm.NewOrm()
// 定义order
order := Order{}
// 先对主键id赋值, 删除数据的条件就是where id=2
order.Id = 2

if num, err := o.Delete(&order); err != nil {
    fmt.Println("删除失败")
} else {
    fmt.Println("删除数据影响的行数:", num)
}
```