# 1. Select操作

```go
package main

import (
    "fmt"

    _ "github.com/go-sql-driver/mysql"
    "github.com/jmoiron/sqlx"
)

type Person struct {
    UserId   int    `db:"user_id"`
    Username string `db:"username"`
    Sex      string `db:"sex"`
    Email    string `db:"email"`
}

type Place struct {
    Country string `db:"country"`
    City    string `db:"city"`
    TelCode int    `db:"telcode"`
}

var Db *sqlx.DB

func init() {

    database, err := sqlx.Open("mysql", "root:root@tcp(127.0.0.1:3306)/test")
    if err != nil {
        fmt.Println("open mysql failed,", err)
        return
    }

    Db = database
    defer db.Close()  // 注意这行代码要写在上面err判断的下面
}

func main() {

    var person []Person
    err := Db.Select(&person, "select user_id, username, sex, email from person where user_id=?", 1)
    if err != nil {
        fmt.Println("exec failed, ", err)
        return
    }

    fmt.Println("select succ:", person)
}
```

输出结果：

```shell
    select succ: [{1 stu001 man stu01@qq.com}]
```