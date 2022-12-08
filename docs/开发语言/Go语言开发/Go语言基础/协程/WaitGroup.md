# WaitGroup

在前几篇文章里，我们学习了 `协程` 和 `信道` 的内容，里面有很多例子，当时为了保证 main goroutine 在所有的 goroutine 都执行完毕后再退出，我使用了 time.Sleep 这种方式。

由于写的 demo 都是比较简单的， sleep 个 1 秒，我们主观上认为是够用的。

但在实际开发中，开发人员是无法预知，所有的 goroutine 需要多长的时间才能执行完毕，sleep 多了吧主程序就阻塞了， sleep 少了吧有的子协程的任务就没法完成。

因此，使用time.Sleep 是一种极不推荐的方式，今天主要就要来介绍一下如何优雅的处理这种情况。

## 1. 使用信道来标记完成

> “不要通过共享内存来通信，要通过通信来共享内存”

学习了信道后，我们知道，信道可以实现多个协程间的通信，那么我们只要定义一个信道，在任务完成后，往信道中写入true，然后在主协程中获取到true，就认为子协程已经执行完毕。

```go
import "fmt"

func main() {
    done := make(chan bool)
    go func() {
        for i := 0; i < 5; i++ {
            fmt.Println(i)
        }
        done <- true
    }()
    <-done
}
```

输出如下

```go
0
1
2
3
4
```

## 2. 使用 WaitGroup

上面使用信道的方法，在单个协程或者协程数少的时候，并不会有什么问题，但在协程数多的时候，代码就会显得非常复杂，有兴趣可以自己尝试一下。

那么有没有一种更加优雅的方式呢？

有，这就要说到 sync包 提供的 WaitGroup 类型。

WaitGroup  你只要实例化了就能使用

```go
var 实例名 sync.WaitGroup 
```

实例化完成后，就可以使用它的几个方法：

- `Add`：初始值为0，你传入的值会往计数器上加，这里直接传入你子协程的数量
- `Done`：当某个子协程完成后，可调用此方法，会从计数器上减一，通常可以使用 defer 来调用。
- `Wait`：阻塞当前协程，直到实例里的计数器归零。

举一个例子：

```go
import (
    "fmt"
    "sync"
)

func worker(x int, wg *sync.WaitGroup) {
    defer wg.Done()
    for i := 0; i < 5; i++ {
        fmt.Printf("worker %d: %d\n", x, i)
    }
}

func main() {
    var wg sync.WaitGroup

    wg.Add(2)
    go worker(1, &wg)
    go worker(2, &wg)

    wg.Wait()
}
```

输出如下

```go
worker 2: 0
worker 2: 1
worker 2: 2
worker 2: 3
worker 2: 4
worker 1: 0
worker 1: 1
worker 1: 2
worker 1: 3
worker 1: 4
```

以上就是我们在 Go 语言中实现一主多子的协程协作方式，推荐使用 sync.WaitGroup。