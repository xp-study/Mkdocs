# Beego orm如何执行SQL查询

beego orm包除了支持model查询的方式，也支持直接编写sql语句的方式查询数据。

sql原生查询有如下特点:

- 使用 Raw SQL 查询，无需使用 ORM 表定义
- 多数据库，都可直接使用占位符号 ?，自动转换
- 查询时的参数，支持使用 Model Struct 和 Slice, Array

## 1.原生sql查询

在遇到比较复杂的查询的时候，使用sql语句更加灵活和直观，也比较容易把控sql查询的性能。

## 1.1. 执行插入、更新、删除SQL语句

执行insert、update、delete语句，需要使用Exec函数，执行后返回 sql.Result 对象，通过sql.Result对象我们可以查询最新插入的自增ID，影响行数。

例子:

```go
// 创建orm对象
o := orm.NewOrm()

// insert
// 使用Raw函数设置sql语句和参数
res, err := o.Raw("insert into users(username, password) values(?, ?)", "tizi365", "123456").Exec()

// 插入数据的自增id
id := res.LastInsertId()

// update
res, err := o.Raw("update users set password=? where username=?", "654321", "tizi365").Exec()

// 获取更新数据影响的行数
rows := res.RowsAffected()

// delete
o.Raw("delete from users where username=?", "tizi365").Exec()
```

## 1.2. 查询语句

查询数据主要通过QueryRow和QueryRows两个函数，分别对应查询一条数据还是多条数据，这两个函数都支持将查询结果保存到struct中.

### 1.2.1. 查询一行数据

```go
type User struct {
    Id       int
    Username string
}

var user User
err := o.Raw("SELECT id, username FROM users WHERE id = ?", 1).QueryRow(&user)
```

### 1.2.2. 查询多行数据

```go
type User struct {
    Id       int
    UserName string
}

var users []User

num, err := o.Raw("SELECT id, username FROM users WHERE id > ? and id < ?", 1, 100).QueryRows(&users)

if err == nil {
    fmt.Println("查询总数: ", num)
}
```

## 2.QueryBuilder sql生成工具

除了上面直接手写sql语句之外，beego orm也为我们提供了一个工具QueryBuilder对象，可以用来生成sql语句.

例子:

```go
// 定义保存用户信息的struct
type User struct {
	Id int
	Username string
	Password string
}

// 定义保存结果的数组变量
var users []User

// 获取 QueryBuilder 对象. 需要指定数据库驱动参数。
// 第二个返回值是错误对象，在这里略过
qb, _ := orm.NewQueryBuilder("mysql")

// 组织sql语句, 跟手写sql语句很像，区别就是sql语句的关键词都变成函数了
qb.Select("id", "username", "password").
	From("users").
	Where("id > ?").
	And("id < ?").
	Or("init_time > ?").
	OrderBy("init_time").Desc().
	Limit(10)

// 生成SQL语句
sql := qb.String()
// 生成这样的sql语句 SELECT id, username, password FROM users WHERE id > ? AND id < ? OR init_time > ? ORDER BY init_time DESC LIMIT 10

// 执行SQL
o := orm.NewOrm()
// 上面sql有三个参数(问号)，这里传入三个参数。
o.Raw(sql, 1, 100, "2019-06-20 11:10:00").QueryRows(&users)
```