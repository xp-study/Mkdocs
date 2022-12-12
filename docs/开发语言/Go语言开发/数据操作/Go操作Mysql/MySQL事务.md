# 1. MySQL事务

mysql事务特性：

```shell
    1) 原子性
    2) 一致性
    3) 隔离性
    4) 持久性
```

golang MySQL事务应用：

```go
    1） import (“github.com/jmoiron/sqlx")
    2)  Db.Begin()        开始事务
    3)  Db.Commit()        提交事务
    4)  Db.Rollback()     回滚事务
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
    }

    func main() {
        conn, err := Db.Begin()
        if err != nil {
            fmt.Println("begin failed :", err)
            return
        }

        r, err := conn.Exec("insert into person(username, sex, email)values(?, ?, ?)", "stu001", "man", "stu01@qq.com")
        if err != nil {
            fmt.Println("exec failed, ", err)
            conn.Rollback()
            return
        }
        id, err := r.LastInsertId()
        if err != nil {
            fmt.Println("exec failed, ", err)
            conn.Rollback()
            return
        }
        fmt.Println("insert succ:", id)

        r, err = conn.Exec("insert into person(username, sex, email)values(?, ?, ?)", "stu001", "man", "stu01@qq.com")
        if err != nil {
            fmt.Println("exec failed, ", err)
            conn.Rollback()
            return
        }
        id, err = r.LastInsertId()
        if err != nil {
            fmt.Println("exec failed, ", err)
            conn.Rollback()
            return
        }
        fmt.Println("insert succ:", id)

        conn.Commit()
    }
```

输出结果：

```mysql
    insert succ: 2
    insert succ: 3
```

查看MySQL：

```mysql
    mysql> select * from person;
    +---------+----------+------+--------------+
    | user_id | username | sex  | email        |
    +---------+----------+------+--------------+
    |       2 | stu001   | man  | stu01@qq.com |
    |       3 | stu001   | man  | stu01@qq.com |
    +---------+----------+------+--------------+
    2 rows in set (0.00 sec)
```