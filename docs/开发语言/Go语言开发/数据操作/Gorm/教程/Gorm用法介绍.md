# 1. Gorm用法介绍

### 1.1.1. 库安装

```
    go get -u github.com/jinzhu/gorm
```

### 1.1.2. 数据库连接

```go
package main

import (
    "fmt"
    "github.com/jinzhu/gorm"
    _ "github.com/jinzhu/gorm/dialects/mysql"
)

// UserInfo 用户信息
type UserInfo struct {
    ID uint
    Name string
    Gender string
    Hobby string
}

func main() {
    db, err := gorm.Open("mysql", "root:root@(127.0.0.1:3306)/db1?charset=utf8mb4&parseTime=True&loc=Local")
    if err!= nil{
        panic(err)
    }
    defer db.Close()

    // 自动迁移
    db.AutoMigrate(&UserInfo{})

    u1 := UserInfo{1, "枯藤", "男", "篮球"}
    u2 := UserInfo{2, "topgoer.com", "女", "足球"}
    // 创建记录
    db.Create(&u1)
    db.Create(&u2)
    // 查询
    var u = new(UserInfo)
    db.First(u)
    fmt.Printf("%#v\n", u)
    var uu UserInfo
    db.Find(&uu, "hobby=?", "足球")
    fmt.Printf("%#v\n", uu)
    // 更新
    db.Model(&u).Update("hobby", "双色球")
    // 删除
    db.Delete(&u)
}
```

连接比较简单，直接调用 gorm.Open 传入数据库地址即可 github.com/jinzhu/gorm/dialects/mysql 是 golang 的 mysql 驱动，实际上就是 github.com/go-sql-driver/mysql 作者这里为了好记，重新弄了个名字 这里我用的 mysql，实际上支持基本上所有主流的关系数据库，连接方式上略有不同

```go
    db.DB().SetMaxIdleConns(10)
    db.DB().SetMaxOpenConns(100)
```

还可以使用 db.DB() 对象设置连接池信息

### 1.1.3. 表定义

先来定义一个点赞表，这里面一条记录表示某个用户在某个时刻对某篇文章点了一个赞，用 ip + ua 来标识用户，title 标识文章标题

```go
    type Like struct {
        ID        int    `gorm:"primary_key"`
        Ip        string `gorm:"type:varchar(20);not null;index:ip_idx"`
        Ua        string `gorm:"type:varchar(256);not null;"`
        Title     string `gorm:"type:varchar(128);not null;index:title_idx"`
        Hash      uint64 `gorm:"unique_index:hash_idx;"`
        CreatedAt time.Time
    }
```

gorm 用 tag 的方式来标识 mysql 里面的约束

创建索引只需要直接指定列即可，这里创建了两个索引，ip_idx 和 title_idx；如果需要多列组合索引，直接让索引的名字相同即可；如果需要创建唯一索引，指定为 unique_index 即可

支持时间类型，直接使用 time.Time 即可

### 1.1.4. 创建表

```go
    if !db.HasTable(&Like{}) {
        if err := db.Set("gorm:table_options", "ENGINE=InnoDB DEFAULT CHARSET=utf8").CreateTable(&Like{}).Error; err != nil {
            panic(err)
        }
    }
```

直接通过 db.CreateTable 就可以创建表了，非常方便，还可以通过 db.Set 设置一些额外的表属性

### 1.1.5. 插入

```go
    like := &Like{
        Ip:        ip,
        Ua:        ua,
        Title:     title,
        Hash:      murmur3.Sum64([]byte(strings.Join([]string{ip, ua, title}, "-"))) >> 1,
        CreatedAt: time.Now(),
    }

    if err := db.Create(like).Error; err != nil {
        return err
    }
```

先构造已给对象，直接调用 db.Create() 就可以插入一条记录了

### 1.1.6. 删除

```go
    if err := db.Where(&Like{Hash: hash}).Delete(Like{}).Error; err != nil {
        return err
    }
```

先用 db.Where() 构造查询条件，再调用 db.Delete() 就可以删除

### 1.1.7. 查询

```go
    var count int
    err := db.Model(&Like{}).Where(&Like{Ip: ip, Ua: ua, Title: title}).Count(&count).Error
    if err != nil {
        return false, err
    }
```

先用 db.Model() 选择一个表，再用 db.Where() 构造查询条件，后面可以使用 db.Count() 计算数量，如果要获取对象，可以使用 db.Find(&Likes) 或者只需要查一条记录 db.First(&Like)

### 1.1.8. 修改

```go
    db.Model(&user).Update("name", "hello")
    db.Model(&user).Updates(User{Name: "hello", Age: 18})
    db.Model(&user).Updates(User{Name: "", Age: 0, Actived: false}) // nothing update
```

我这个系统里面没有更新需求，这几个例子来自于官网，第一个是更新单条记录；第二个是更新整条记录，注意只有非空字段才会更新；第三个例子是不会更新的，在系统设计的时候要尽量避免这些空值有特殊的含义，如果一定要更新，可以使用第一种方式，设置单个值

### 1.1.9. 错误处理

其实你已经看到了，这里基本上所有的函数都是链式的，全部都返回 db 对象，任何时候调用 db.Error 就能获取到错误信息，非常方便

### 1.1.10. 事务

```go
    func CreateAnimals(db *gorm.DB) err {
        tx := db.Begin()
        if err := tx.Create(&Animal{Name: "Giraffe"}).Error; err != nil {
            tx.Rollback()
            return err
        }
        if err := tx.Create(&Animal{Name: "Lion"}).Error; err != nil {
            tx.Rollback()
            return err
        }
        tx.Commit()
        return nil
    }
```

事务的处理也很简单，用 db.Begin() 声明开启事务，结束的时候调用 tx.Commit()，异常的时候调用 tx.Rollback()

### 1.1.11. 其他

还可以使用如下方式设置日志输出级别以及改变日志输出地方

```go
    db.LogMode(true)
    db.SetLogger(gorm.Logger{revel.TRACE})
    db.SetLogger(log.New(os.Stdout, "\r\n", 0))
```

也支持普通的 sql，但是建议尽量不要使用