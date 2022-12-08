# switch-case 选择语句

## 0. 语句模型

Go 里的选择语句模型是这样的

```go
switch 表达式 {
    case 表达式1:
        代码块
    case 表达式2:
        代码块
    case 表达式3:
        代码块
    case 表达式4:
        代码块
    case 表达式5:
        代码块
    default:
        代码块
}
```

拿 switch 后的表达式分别和 case 后的表达式进行对比，只要有一个 case 满足条件，就会执行对应的代码块，然后直接退出 switch - case ，如果 一个都没有满足，才会执行 default 的代码块。

## 1. 最简单的示例

switch 后接一个你要判断变量 `education` （学历），然后 case 会拿这个 变量去和它后面的表达式（可能是常量、变量、表达式等）进行判等。

如果相等，就执行相应的代码块。如果不相等，就接着下一个 case。

```go
import "fmt"

func main() {
    education := "本科"

    switch education {
    case "博士":
        fmt.Println("我是博士")
    case "研究生":
        fmt.Println("我是研究生")
    case "本科":
        fmt.Println("我是本科生")
    case "大专":
        fmt.Println("我是大专生")
    case "高中":
        fmt.Println("我是高中生")
    default:
        fmt.Println("学历未达标..")
    }
}
```

输出如下

```go
我是本科生
```

## 2. 一个 case 多个条件

case 后可以接多个多个条件，多个条件之间是 `或` 的关系，用逗号相隔。

```go
import "fmt"

func main() {
    month := 2

    switch month {
    case 3, 4, 5:
        fmt.Println("春天")
    case 6, 7, 8:
        fmt.Println("夏天")
    case 9, 10, 11:
        fmt.Println("秋天")
    case 12, 1, 2:
        fmt.Println("冬天")
    default:
        fmt.Println("输入有误...")
    }
}
```

输出如下

```go
冬天
```

## 3. case 条件常量不能重复

当 case 后接的是常量时，该常量只能出现一次。

以下两种情况，在编译时，都会报错：duplicate case "male" in switch

**错误案例一**

```go
gender := "male"

switch gender {
    case "male":
        fmt.Println("男性")
    // 与上面重复
    case "male":
        fmt.Println("男性")
    case "female":
        fmt.Println("女性")
}
```

**错误案例二**

```go
gender := "male"

switch gender {
    case "male", "male":
        fmt.Println("男性")
    case "female":
        fmt.Println("女性")
}
```

## 4. switch 后可接函数

switch 后面可以接一个函数，只要保证 case 后的值类型与函数的返回值 一致即可。

```go
import "fmt"

// 判断一个同学是否有挂科记录的函数
// 返回值是布尔类型
func getResult(args ...int) bool {
    for _, i := range args {
        if i < 60 {
            return false
        }
    }
    return true
}

func main() {
    chinese := 80
    english := 50
    math := 100

    switch getResult(chinese, english, math) {
    // case 后也必须 是布尔类型
    case true:
        fmt.Println("该同学所有成绩都合格")
    case false:
        fmt.Println("该同学有挂科记录")
    }
}
```

## 5. switch 可不接表达式

switch 后可以不接任何变量、表达式、函数。

当不接任何东西时，switch - case 就相当于 if - elseif - else

```go
score := 30

switch {
    case score >= 95 && score <= 100:
        fmt.Println("优秀")
    case score >= 80:
        fmt.Println("良好")
    case score >= 60:
        fmt.Println("合格")
    case score >= 0:
        fmt.Println("不合格")
    default:
        fmt.Println("输入有误...")
}
```

## 6. switch 的穿透能力

正常情况下 switch - case 的执行顺序是：只要有一个 case 满足条件，就会直接退出 switch - case ，如果 一个都没有满足，才会执行 default 的代码块。

但是有一种情况是例外。

那就是当  case 使用关键字 `fallthrough` 开启穿透能力的时候。

```go
s ：= "hello"
switch {
case s == "hello":
    fmt.Println("hello")
    fallthrough
case s != "world":
    fmt.Println("world")
}
```

代码输出如下：

```go
hello
world
```

需要注意的是，fallthrough 只能穿透一层，意思是它只给你一次再判断case的机会，不管你有没有匹配上，都要退出了。

```go
s := "hello"
switch {
case s == "hello":
    fmt.Println("hello")
    fallthrough
case s == "xxxx":
    fmt.Println("xxxx")
case s != "world":
    fmt.Println("world")
}
```

输出如下，并不会输出 `world`（即使它符合条件）

```go
hello
```