# 1. Belongs To

## 1.1. 属于

`belongs to` 关联建立一个和另一个模型的一对一连接，使得模型声明每个实例都「属于」另一个模型的一个实例 。

例如，如果你的应用包含了用户和用户资料， 并且每一个用户资料只分配给一个用户

```go
type User struct {
  gorm.Model
  Name string
}

// `Profile` 属于 `User`， `UserID` 是外键
type Profile struct {
  gorm.Model
  UserID int
  User   User
  Name   string
}
```

## 1.2. 外键

为了定义从属关系， 外键是必须存在的， 默认的外键使用所有者类型名称加上其主键。

像上面的例子，为了声明一个模型属于 `User`，它的外键应该为 `UserID`。

GORM 提供了一个定制外键的方法，例如:

```go
type User struct {
    gorm.Model
    Name string
}

type Profile struct {
    gorm.Model
  Name      string
  User      User `gorm:"foreignkey:UserRefer"` // 使用 UserRefer 作为外键
  UserRefer string
}
```

## 1.3. 关联外键

对于从属关系， GORM 通常使用所有者的主键作为外键值，在上面的例子中，就是 `User` 的 `ID`。

当你分配一个资料给一个用户， GORM 将保存用户表的 `ID` 值 到 用户资料表的 `UserID` 字段里。

你可以通过改变标签 `association_foreignkey` 来改变它， 例如：

```go
type User struct {
    gorm.Model
  Refer int
    Name string
}

type Profile struct {
    gorm.Model
  Name      string
  User      User `gorm:"association_foreignkey:Refer"` // use Refer 作为关联外键
  UserRefer string
}
```

## 1.4. 使用属于

你能找到 `belongs to` 和 `Related` 的关联

```go
db.Model(&user).Related(&profile)
//// SELECT * FROM profiles WHERE user_id = 111; // 111 is user's ID
```