# Beego orm高级查询

针对业务比较复杂，涉及复杂的查询条件的场景，beego orm为我们提供了QuerySeter 对象，用来组织复杂的查询条件。

## 1.QuerySeter入门

因为QuerySeter是专门针对ORM的模型对象进行操作的，所以在使用QuerySeter之前必须先定义好模型。

## 1.1.表定义

模型（model）是跟表结构一一对应的，作为例子这里先定义下表结构。

```go
// 定义用户表
CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL COMMENT '自增ID',
  `username` varchar(30) NOT NULL COMMENT '账号',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `init_time` datetime DEFAULT NULL COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

## 1.2.模型定义

```go
//定义User模型，绑定users表结构
type User struct {
	Id int
	Username string
	Password string
	City string
	// 驼峰式命名，会转换成表字段名，表字段名使用蛇形命名风格，即用下划线将单词连接起来
    // 这里对应数据库表的init_time字段名
	InitTime time.Time
}

// 定义模型表名
func (u *User) TableName() string {
	return "users"
}
```

## 1.3.QuerySeter例子

```go
// 创建orm对象
o := orm.NewOrm()

// 获取 QuerySeter 对象，并设置表名orders
qs := o.QueryTable("users")

// 定义保存查询结果的变量
var users []User

// 使用QuerySeter 对象构造查询条件，并执行查询。
num, err := qs.Filter("city", "shenzhen").  // 设置查询条件
		Filter("init_time__gt", "2019-06-28 22:00:00"). // 设置查询条件
		Limit(10). // 限制返回行数
		All(&users, "id", "username") // All 执行查询，并且返回结果，这里指定返回id和username字段，结果保存在users变量
// 上面代码的等价sql: SELECT T0.`id`, T0.`username` FROM `users` T0 WHERE T0.`city` = 'shenzhen' AND T0.`init_time` > '2019-06-28 22:00:00' LIMIT 10

if err != nil {
	panic(err)
}
fmt.Println("结果行数:", num)
```

## 2.QuerySeter查询表达式

beego orm针对QuerySeter设置一套查询表达式，用于编写查询条件。

> 提示：下面例子，使用Filter函数描述查询表达式，实际上其他查询函数也支持查询表达式。

**表达式格式1**：

```go
qs.Filter("id", 1) // 相当于条件 id = 1
```

**表达式格式2**：
使用**双下划线** __ 作为分隔符，尾部连接操作符

```go
qs.Filter("id__gt", 1) // 相当于条件 id > 1
qs.Filter("id__gte", 1) // 相当于条件 id >= 1
qs.Filter("id__lt", 1) // 相当于条件 id < 1
qs.Filter("id__lte", 1) // 相当于条件 id <= 1
qs.Filter("id__in", 1,2,3,4,5) // 相当于In语句 id in (1,2,3,4,5)
```

下面是支持的操作符：

- exact / iexact 等于
- contains / icontains 包含
- gt / gte 大于 / 大于等于
- lt / lte 小于 / 小于等于
- startswith / istartswith 以…起始
- endswith / iendswith 以…结束
- in
- isnull 后面以 i 开头的表示：大小写不敏感

例子:

```go
qs.Filter("Username", "大锤") // 相当于条件 name = '大锤'
qs.Filter("Username__exact", "大锤") // 相当于条件 name = '大锤'
qs.Filter("Username__iexact", "大锤") // 相当于条件 name LIKE '大锤'
qs.Filter("Username__iexact", "大锤") // 相当于条件 name LIKE '大锤'
qs.Filter("Username__contains", "大锤") // 相当于条件 name LIKE BINARY '%大锤%'   , BINARY 区分大小写
qs.Filter("Username__icontains", "大锤") // 相当于条件 name LIKE '%大锤%'
qs.Filter("Username__istartswith", "大锤") // 相当于条件 name LIKE '大锤%'
qs.Filter("Username__iendswith", "大锤") // 相当于条件 name LIKE '%大锤'
qs.Filter("Username__isnull", true) // 相当于条件 name is null
qs.Filter("Username__isnull", false) // 相当于条件 name is not null
```

多个Filter函数调用使用 **and** 连接查询条件。
例子:

```go
qs.Filter("id__gt", 1).Filter("id__lt", 100) // 相当于条件 id > 1 and id < 100
```

## 3.处理复杂的查询条件

上面的例子多个Filter函数调用只能生成and连接的查询条件，那么如果要设置or条件就不行了；beego orm为我们提供了Condition对象，用于生成查询条件。

例子:

```go
//  创建一个Condition对象
cond := orm.NewCondition()

// 组织查询条件, 并返回一个新的Condition对象
cond1 := cond.And("Id__gt", 100).Or("City","shenzhen")
// 相当于条件 id > 100 or city = 'shenzhen'

var users []User

qs.SetCond(cond1). // 设置查询条件
  Limit(10). // 限制返回数据函数
  All(&users) // 查询多行数据
```

## 3.查询数据

### 3.1.查询多行数据

使用All函数可以返回多行数据。

例子:

```go
// 创建orm对象
o := orm.NewOrm()

// 获取 QuerySeter 对象，并设置表名orders
qs := o.QueryTable("users")

// 定义保存查询结果的变量
var users []User

// 使用QuerySeter 对象构造查询条件，并执行查询。
// 等价sql: select * from users where id > 1 and id < 100 limit 10
num, err := qs.Filter("Id__gt", 1).
		Filter("Id__lt", 100).
		Limit(10). // 限制返回行数
		All(&users) // 返回多行数据， 也可以设置返回指定字段All(&users, "id", "username")
```

### 3.2.查询一行数据

使用One函数返回一条记录

```go
var user User

// 等价sql: select * from users where id = 1 limit 1
err := o.QueryTable("users").Filter("id", 1).One(&user)

if err == orm.ErrNoRows {
    fmt.Printf("查询不到数据")
}
```

One也可以返回指定字段值, 例: One(&user, "id", "username")

### 3.3. Group By & Order BY

这里介绍一个包含group by, order by语句的例子

```go
// 创建orm对象
o := orm.NewOrm()

// 获取 QuerySeter 对象，并设置表名orders
qs := o.QueryTable("users")

// 定义保存查询结果的变量
var users []User

// 使用QuerySeter 对象构造查询条件，并执行查询。
// 等价sql: select * from users where id > 1 and id < 100 group by city order by init_time desc limit 10
num, err := qs.Filter("Id__gt", 1).
		Filter("Id__lt", 100).
		GroupBy("City").   // 根据city字段分组
		OrderBy("-InitTime").   // order by字段名前面的减号 - , 代表倒序。
		Limit(10). // 限制返回行数
		All(&users)

if err != nil {
	panic(err)
}
fmt.Println("结果行数:", num)
```

### 3.4. Count统计总数

sql语句中的count语句的例子

```go
// 这里可以忽略错误。
num, _ := o.QueryTable("users").Filter("Id__gt", 1).Filter("Id__lt", 100).Count()

// 等价sql: select count(*) from users where id > 1 and id < 100

fmt.Printf("总数: %s", num)
```

## 4.更新数据

使用QuerySeter更新数据，可以根据复杂的查询条件更新数据, 用法组织好查询条件后调用Update函数即可。

例子:

```go
// Update参数，使用的是orm.Params对象，这是一个map[string]interface{}类型, 用于指定我们要更新的数据
num, err := o.QueryTable("users").Filter("Id__gt", 1).Filter("Id__lt", 100).Update(orm.Params{
    "City": "深圳",
    "Password": "123456",
})

// 等价sql: update users set city = '深圳', password = '123456' where id > 1 and id < 100

fmt.Printf("影响行数: %s, %s", num, err)
```

## 5,删除数据

组织好查询条件后，调用Delete函数即可。

```go
num, err := o.QueryTable("users").Filter("Id__gt", 1).Filter("Id__lt", 100).Delete()

// 等价sql: delete from users where id > 1 and id < 100

fmt.Printf("影响行数: %s, %s", num, err)
```