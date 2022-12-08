# for 循环语句

## 0. 语句模型

这是 for 循环的基本模型。

```go
for [condition |  ( init; condition; increment ) | Range]
{
   statement(s);
}
```

可以看到 for 后面，可以接三种类型的表达式。

1. 接一个条件表达式
2. 接三个表达式
3. 接一个 range 表达式

但其实还有第四种

1. 不接表达式

## 1. 接一个条件表达式

这个例子会打印 1 到 5 的数值。

```go
a := 1
for a <= 5 {
    fmt.Println(a)
    a ++ 
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

## 2. 接三个表达式

for 后面，紧接着三个表达式，使用 `;` 分隔。

这三个表达式，各有各的用途

- 第一个表达式：初始化控制变量，在整个循环生命周期内，只运行一次；
- 第二个表达式：设置循环控制条件，当返回true，继续循环，返回false，结束循环；
- 第三个表达式：每次循完开始（除第一次）时，给控制变量增量或减量。

这边的例子和上面的例子，是等价的。

```go
import "fmt"

func main() {
    for i := 1; i <= 5; i++ {
        fmt.Println(i)
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

## 2. 不接表达式：无限循环

在 Go 语言中，没有 while 循环，如果要实现无限循环，也完全可以 for 来实现。

当你不加任何的判断条件时， 就相当于你每次的判断都为 true，程序就会一直处于运行状态，但是一般我们并不会让程序处于死循环，在满足一定的条件下，可以使用关键字 `break` 退出循环体，也可以使用 `continue` 直接跳到下一循环。

下面两种写法都是无限循环的写法。

```go
for {
    代码块
}

// 等价于
for ;; {
    代码块
}
```

举个例子

```go
import "fmt"

func main() {
    var i int = 1
    for {
        if i > 5 {
            break
        }
        fmt.Printf("hello, %d\n", i)
        i++
    }
}
```

输出如下

```go
hello, 1
hello, 2
hello, 3
hello, 4
hello, 5
```

## 3. 接 for-range 语句

遍历一个可迭代对象，是一个很常用的操作。在 Go 可以使用 for-range 的方式来实现。

range 后可接数组、切片，字符串等

由于 range 会返回两个值：索引和数据，若你后面的代码用不到索引，需要使用 `_` 表示 。

```go
import "fmt"

func main() {
    myarr := [...]string{"world", "python", "go"}
    for _, item := range myarr {
        fmt.Printf("hello, %s\n", item)
    }
}
```

输出如下

```go
hello, world
hello, python
hello, go
```