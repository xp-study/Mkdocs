# if-else 条件语句

## 1. 条件语句模型

Go里的流程控制方法还是挺丰富，整理了下有如下这么多种：

- if - else 条件语句
- switch - case 选择语句
- for - range 循环语句
- goto 无条件跳转语句
- defer 延迟执行

今天先来讲讲 if-else 条件语句

Go 里的条件语句模型是这样的

```go
if 条件 1 {
  分支 1
} else if 条件 2 {
  分支 2
} else if 条件 ... {
  分支 ...
} else {
  分支 else
}
```

Go编译器，对于 `{` 和 `}` 的位置有严格的要求，它要求 else if （或 else）和 两边的花括号，必须在同一行。

由于 Go是 强类型，所以要求你条件表达式必须严格返回布尔型的数据（nil 和 0 和 1 都不行）。

对于这个模型，分别举几个例子来看一下。

## 2. 单分支判断

只有一个 if ，没有 else

```go
import "fmt"

func main() {
    age := 20
    if age > 18 {
        fmt.Println("已经成年了")
    } 
}
```

如果条件里需要满足多个条件，可以使用 `&&` 和 `||`

- `&&`：表示且，左右都需要为true，最终结果才能为 true，否则为 false
- `||`：表示或，左右只要有一个为true，最终结果即为true，否则 为 false

```go
import "fmt"

func main() {
    age := 20
    gender := "male"
    if (age > 18 && gender == "male") {
        fmt.Println("是成年男性")
    }
}
```

## 3. 多分支判断

if - else 语句

```go
import "fmt"

func main() {
    age := 20
    if age > 18 {
        fmt.Println("已经成年了")
    } else {
        fmt.Println("还未成年")
    }
}
```

if - else if - else 语句

```go
import "fmt"

func main() {
    age := 20
    if age > 18 {
        fmt.Println("已经成年了")
    } else if age >12 {
        fmt.Println("已经是青少年了")
    } else {
        fmt.Println("还不是青少年")
    }
}
```

## 4. 高级写法

在 if 里可以允许先运行一个表达式，取得变量后，再对其进行判断，比如第一个例子里代码也可以写成这样

```go
import "fmt"

func main() {
    if age := 20;age > 18 {
        fmt.Println("已经成年了")
    }
}
```