# goroutine

说到Go语言，很多没接触过它的人，对它的第一印象，一定是它从语言层面天生支持并发，非常方便，让开发者能快速写出高性能且易于理解的程序。

一个 goroutine 本身就是一个函数，当你直接调用时，它就是一个普通函数，如果你在调用前加一个关键字 `go` ，那你就开启了一个 goroutine。

```go
// 执行一个函数
func()

// 开启一个协程执行这个函数
go func()
```

## 1. 协程的初步使用

一个 Go 程序的入口通常是 main 函数，程序启动后，main 函数最先运行，我们称之为 `main goroutine`。

在 main 中或者其下调用的代码中才可以使用 `go + func()` 的方法来启动协程。

main 的地位相当于主线程，当 main 函数执行完成后，这个线程也就终结了，其下的运行着的所有协程也不管代码是不是还在跑，也得乖乖退出。

因此如下这段代码运行完，只会输出  `hello, world` ，而不会输出`hello, go`（因为协程的创建需要时间，当 `hello, world`打印后，协程还没来得及并执行）。

```go
import "fmt"

func mytest() {
    fmt.Println("hello, go")
}

func main() {
    // 启动一个协程
    go mytest()
    fmt.Println("hello, world")
}
```

对于刚学习Go的协程同学来说，可以使用 time.Sleep 来使 main 阻塞，使其他协程能够有机会运行完全，但你要注意的是，**这并不是推荐的方式**（后续我们会学习其他更优雅的方式）。

当我在代码中加入一行 time.Sleep 输出就符合预期了。

```go
import (
    "fmt"
    "time"
)

func mytest() {
    fmt.Println("hello, go")
}

func main() {
    go mytest()
    fmt.Println("hello, world")
    time.Sleep(time.Second)
}
```

输出如下

```go
hello, world
hello, go
```

## 2. 多个协程的效果

为了让你看到并发的效果，这里举个最简单的例子

```go
import (
    "fmt"
    "time"
)

func mygo(name string) {
    for i := 0; i < 10; i++ {
        fmt.Printf("In goroutine %s\n", name)
        // 为了避免第一个协程执行过快，观察不到并发的效果，加个休眠
        time.Sleep(10 * time.Millisecond) 
    }
}

func main() {
    go mygo("协程1号") // 第一个协程
    go mygo("协程2号") // 第二个协程
    time.Sleep(time.Second)
}
```

输出如下，可以观察到两个协程就如两个线程一样，并发执行

```go
In goroutine 协程2号
In goroutine 协程1号
In goroutine 协程1号
In goroutine 协程2号
In goroutine 协程2号
In goroutine 协程1号
In goroutine 协程1号
In goroutine 协程2号
In goroutine 协程1号
In goroutine 协程2号
In goroutine 协程1号
In goroutine 协程2号
In goroutine 协程1号
In goroutine 协程2号
In goroutine 协程1号
In goroutine 协程2号
In goroutine 协程1号
In goroutine 协程2号
In goroutine 协程1号
In goroutine 协程2号
```

通过以上简单的例子，是不是折服于Go的这种强大的并发特性，将同步代码转为异步代码，真的只要一个关键字就可以了，也不需要使用其他库，简单方便。