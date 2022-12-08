# goto无条件跳转

很难想象在 Go 居然会保留 goto，因为很多人不建议使用 goto，所以在一些编程语言中甚至直接取消了 goto。

我感觉 Go 既然保留，一定有人家的理由，只是我目前还没感受到。不管怎样，咱还是照常学习吧。

## 0. 基本模型

`goto` 顾言思义，是跳转的意思。

goto 后接一个标签，这个标签的意义是告诉 Go程序下一步要执行哪里的代码。

所以这个标签如何放置，放置在哪里，是 goto 里最需要注意的。

```go
goto 标签;
...
...
标签: 表达式;
```

## 1. 最简单的示例

`goto` 可以打破原有代码执行顺序，直接跳转到某一行执行代码。

```go
import "fmt"

func main() {

    goto flag
    fmt.Println("B")
flag:
    fmt.Println("A")

}
```

执行结果，并不会输出 B ，而只会输出 A

```go
A
```

## 2. 如何使用？

`goto` 语句通常与条件语句配合使用。可用来实现条件转移， 构成循环，跳出循环体等功能。

这边举一个例子，用 `goto` 的方式来实现一个打印 1到5 的循环。

```go
import "fmt"

func main() {
    i := 1
flag:
    if i <= 5 {
        fmt.Println(i)
        i++
        goto flag
    }
}
```

输出如下

```go
1
2
3
4
5
```

再举个例子，使用 goto 实现 类型` break` 的效果。

```go
import "fmt"

func main() {
    i := 1
    for {
        if i > 5 {
            goto flag
        }
        fmt.Println(i)
        i++
    }
flag:
}
```

输出如下

```go
1
2
3
4
5
```

最后再举个例子，使用 goto 实现 类型 `continue`的效果，打印 1到10 的所有偶数。

```go
import "fmt"

func main() {
    i := 1
flag:
    for i <= 10 {
        if i%2 == 1 {
            i++
            goto flag
        }
        fmt.Println(i)
        i++
    }
}
```

输出如下

```go
2
4
6
8
10
```

## 3. 注意事项

goto语句与标签之间不能有变量声明，否则编译错误。

```go
import "fmt"

func main() {
    fmt.Println("start")
    goto flag
    var say = "hello oldboy"
    fmt.Println(say)
flag:
    fmt.Println("end")
}
```

编译错误

```go
.\main.go:7:7: goto flag jumps over declaration of say at .\main.go:8:6
```