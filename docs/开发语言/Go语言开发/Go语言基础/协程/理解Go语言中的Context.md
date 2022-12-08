# 理解 Go 语言中的 Context

## 1. 什么是 Context？

在 Go 1.7 版本之前，context 还是非编制的，它存在于 golang.org/x/net/context 包中。

后来，Golang 团队发现 context 还挺好用的，就把 context 收编了，在 Go 1.7 版本正式纳入了标准库。

Context，也叫上下文，它的接口定义如下

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error
    Value(key interface{}) interface{}
}
```

可以看到 Context 接口共有 4 个方法

- `Deadline`：返回的第一个值是 **截止时间**，到了这个时间点，Context 会自动触发 Cancel 动作。返回的第二个值是 一个布尔值，true 表示设置了截止时间，false 表示没有设置截止时间，如果没有设置截止时间，就要手动调用 cancel 函数取消 Context。
- `Done`：返回一个只读的通道（只有在被cancel后才会返回），类型为 `struct{}`。当这个通道可读时，意味着parent context已经发起了取消请求，根据这个信号，开发者就可以做一些清理动作，退出goroutine。
- `Err`：返回 context 被 cancel 的原因。
- `Value`：返回被绑定到 Context 的值，是一个键值对，所以要通过一个Key才可以获取对应的值，这个值一般是线程安全的。

## 2. 为何需要 Context？

当一个协程（goroutine）开启后，我们是无法强制关闭它的。

常见的关闭协程的原因有如下几种：

1. goroutine 自己跑完结束退出
2. 主进程crash退出，goroutine 被迫退出
3. 通过通道发送信号，引导协程的关闭。

第一种，属于正常关闭，不在今天讨论范围之内。

第二种，属于异常关闭，应当优化代码。

第三种，才是开发者可以手动控制协程的方法，代码示例如下：

```go
func main() {
    stop := make(chan bool)

    go func() {
        for {
            select {
            case <-stop:
                fmt.Println("监控退出，停止了...")
                return
            default:
                fmt.Println("goroutine监控中...")
                time.Sleep(2 * time.Second)
            }
        }
    }()

    time.Sleep(10 * time.Second)
    fmt.Println("可以了，通知监控停止")
    stop<- true
    //为了检测监控过是否停止，如果没有监控输出，就表示停止了
    time.Sleep(5 * time.Second)

}
```

例子中我们定义一个`stop`的chan，通知他结束后台goroutine。实现也非常简单，在后台goroutine中，使用select判断`stop`是否可以接收到值，如果可以接收到，就表示可以退出停止了；如果没有接收到，就会执行`default`里的监控逻辑，继续监控，只到收到`stop`的通知。

以上是一个 goroutine 的场景，如果是多个 goroutine ，每个goroutine 底下又开启了多个 goroutine 的场景呢？在 飞雪无情的博客 里关于为何要使用 Context，他是这么说的

> chan+select的方式，是比较优雅的结束一个goroutine的方式，不过这种方式也有局限性，如果有很多goroutine都需要控制结束怎么办呢？如果这些goroutine又衍生了其他更多的goroutine怎么办呢？如果一层层的无穷尽的goroutine呢？这就非常复杂了，即使我们定义很多chan也很难解决这个问题，因为goroutine的关系链就导致了这种场景非常复杂。

在这里我不是很赞同他说的话，因为我觉得就算只使用一个通道也能达到控制（取消）多个 goroutine 的目的。下面就用例子来验证一下。

该例子的原理是：使用 close 关闭通道后，如果该通道是无缓冲的，则它会从原来的阻塞变成非阻塞，也就是可读的，只不过读到的会一直是零值，因此根据这个特性就可以判断 拥有该通道的 goroutine 是否要关闭。

```go
package main

import (
    "fmt"
    "time"
)

func monitor(ch chan bool, number int)  {
    for {
        select {
        case v := <-ch:
            // 仅当 ch 通道被 close，或者有数据发过来(无论是true还是false)才会走到这个分支
            fmt.Printf("监控器%v，接收到通道值为：%v，监控结束。\n", number,v)
            return
        default:
            fmt.Printf("监控器%v，正在监控中...\n", number)
            time.Sleep(2 * time.Second)
        }
    }
}

func main() {
    stopSingal := make(chan bool)

    for i :=1 ; i <= 5; i++ {
        go monitor(stopSingal, i)
    }

    time.Sleep( 1 * time.Second)
    // 关闭所有 goroutine
    close(stopSingal)

    // 等待5s，若此时屏幕没有输出 <正在监控中> 就说明所有的goroutine都已经关闭
    time.Sleep( 5 * time.Second)

    fmt.Println("主程序退出！！")

}
```

输出如下

```go
监控器4，正在监控中...
监控器1，正在监控中...
监控器2，正在监控中...
监控器3，正在监控中...
监控器5，正在监控中...
监控器2，接收到通道值为：false，监控结束。
监控器3，接收到通道值为：false，监控结束。
监控器5，接收到通道值为：false，监控结束。
监控器1，接收到通道值为：false，监控结束。
监控器4，接收到通道值为：false，监控结束。
主程序退出！！
```

上面的例子，说明当我们定义一个无缓冲通道时，如果要对所有的 goroutine 进行关闭，可以使用 close 关闭通道，然后在所有的 goroutine 里不断检查通道是否关闭(前提你得约定好，该通道你只会进行 close 而不会发送其他数据，否则发送一次数据就会关闭一个goroutine，这样会不符合咱们的预期，所以最好你对这个通道再做一层封装做个限制)来决定是否结束 goroutine。

所以你看到这里，我做为初学者还是没有找到使用 Context 的必然理由，我只能说 Context 是个很好用的东西，使用它方便了我们在处理并发时候的一些问题，但是它并不是不可或缺的。

换句话说，它解决的并不是 **能不能** 的问题，而是解决 **更好用** 的问题。

## 3. 简单使用 Context

如果不使用上面 close 通道的方式，还有没有其他更优雅的方法来实现呢？

**有，那就是本文要讲的 Context**

我使用 Context 对上面的例子进行了一番改造。

```go
package main

import (
    "context"
    "fmt"
    "time"
)

func monitor(ctx context.Context, number int)  {
    for {
        select {
        // 其实可以写成 case <- ctx.Done()
        // 这里仅是为了让你看到 Done 返回的内容
        case v :=<- ctx.Done():
            fmt.Printf("监控器%v，接收到通道值为：%v，监控结束。\n", number,v)
            return
        default:
            fmt.Printf("监控器%v，正在监控中...\n", number)
            time.Sleep(2 * time.Second)
        }
    }
}

func main() {
    ctx, cancel := context.WithCancel(context.Background())

    for i :=1 ; i <= 5; i++ {
        go monitor(ctx, i)
    }

    time.Sleep( 1 * time.Second)
    // 关闭所有 goroutine
    cancel()

    // 等待5s，若此时屏幕没有输出 <正在监控中> 就说明所有的goroutine都已经关闭
    time.Sleep( 5 * time.Second)

    fmt.Println("主程序退出！！")

}
```

这里面的关键代码，也就三行

第一行：以 context.Background() 为 parent context 定义一个可取消的 context

```go
ctx, cancel := context.WithCancel(context.Background())
```

第二行：然后你可以在所有的goroutine 里利用 for + select 搭配来不断检查 ctx.Done() 是否可读，可读就说明该 context 已经取消，你可以清理 goroutine 并退出了。

```go
case <- ctx.Done():
```

第三行：当你想到取消 context 的时候，只要调用一下 cancel 方法即可。这个 cancel 就是我们在创建 ctx 的时候返回的第二个值。

```go
cancel()
```

运行结果输出如下。可以发现我们实现了和 close 通道一样的效果。

```go
监控器3，正在监控中...
监控器4，正在监控中...
监控器1，正在监控中...
监控器2，正在监控中...
监控器2，接收到通道值为：{}，监控结束。
监控器5，接收到通道值为：{}，监控结束。
监控器4，接收到通道值为：{}，监控结束。
监控器1，接收到通道值为：{}，监控结束。
监控器3，接收到通道值为：{}，监控结束。
主程序退出！！
```

## 4. 根Context 是什么？

创建 Context 必须要指定一个 父 Context，当我们要创建第一个Context时该怎么办呢？

不用担心，Go 已经帮我们实现了2个，我们代码中最开始都是以这两个内置context作为最顶层的parent context，衍生出更多的子Context。

```go
var (
    background = new(emptyCtx)
    todo       = new(emptyCtx)
)

func Background() Context {
    return background
}

func TODO() Context {
    return todo
}
```

一个是Background，主要用于main函数、初始化以及测试代码中，作为Context这个树结构的最顶层的Context，也就是根Context，它不能被取消。

一个是TODO，如果我们不知道该使用什么Context的时候，可以使用这个，但是实际应用中，暂时还没有使用过这个TODO。

他们两个本质上都是emptyCtx结构体类型，是一个不可取消，没有设置截止时间，没有携带任何值的Context。

```go
type emptyCtx int

func (*emptyCtx) Deadline() (deadline time.Time, ok bool) {
    return
}

func (*emptyCtx) Done() <-chan struct{} {
    return nil
}

func (*emptyCtx) Err() error {
    return nil
}

func (*emptyCtx) Value(key interface{}) interface{} {
    return nil
}
```

## 5. Context 的继承衍生

上面在定义我们自己的 Context 时，我们使用的是 `WithCancel` 这个方法。

除它之外，context 包还有其他几个 With 系列的函数

```go
func WithCancel(parent Context) (ctx Context, cancel CancelFunc)
func WithDeadline(parent Context, deadline time.Time) (Context, CancelFunc)
func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc)
func WithValue(parent Context, key, val interface{}) Context
```

这四个函数有一个共同的特点，就是第一个参数，都是接收一个 父context。

通过一次继承，就多实现了一个功能，比如使用 WithCancel 函数传入 根context ，就创建出了一个子 context，该子context 相比 父context，就多了一个 cancel context 的功能。

如果此时，我们再以上面的子context（context01）做为父context，并将它做为第一个参数传入WithDeadline函数，获得的子子context（context02），相比子context（context01）而言，又多出了一个超过 deadline 时间后，自动 cancel context 的功能。

接下来我会举例介绍一下这几种 context，其中 WithCancel 在上面已经讲过了，下面就不再举例了

### 例子 1：WithDeadline

```go
package main

import (
    "context"
    "fmt"
    "time"
)

func monitor(ctx context.Context, number int)  {
    for {
        select {
        case <- ctx.Done():
            fmt.Printf("监控器%v，监控结束。\n", number)
            return
        default:
            fmt.Printf("监控器%v，正在监控中...\n", number)
            time.Sleep(2 * time.Second)
        }
    }
}

func main() {
    ctx01, cancel := context.WithCancel(context.Background())
    ctx02, cancel := context.WithDeadline(ctx01, time.Now().Add(1 * time.Second))

    defer cancel()

    for i :=1 ; i <= 5; i++ {
        go monitor(ctx02, i)
    }

    time.Sleep(5  * time.Second)
    if ctx02.Err() != nil {
        fmt.Println("监控器取消的原因: ", ctx02.Err())
    }

    fmt.Println("主程序退出！！")
}
```

输出如下

```go
监控器5，正在监控中...
监控器1，正在监控中...
监控器2，正在监控中...
监控器3，正在监控中...
监控器4，正在监控中...
监控器3，监控结束。
监控器4，监控结束。
监控器2，监控结束。
监控器1，监控结束。
监控器5，监控结束。
监控器取消的原因:  context deadline exceeded
主程序退出！！
```

### 例子 2：WithTimeout

WithTimeout 和 WithDeadline 使用方法及功能基本一致，都是表示超过一定的时间会自动 cancel context。

唯一不同的地方，我们可以从函数的定义看出

```go
func WithDeadline(parent Context, deadline time.Time) (Context, CancelFunc)

func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc)
```

WithDeadline 传入的第二个参数是 time.Time 类型，它是一个绝对的时间，意思是在什么时间点超时取消。

而 WithTimeout 传入的第二个参数是 time.Duration 类型，它是一个相对的时间，意思是多长时间后超时取消。

```go
package main

import (
    "context"
    "fmt"
    "time"
)

func monitor(ctx context.Context, number int)  {
    for {
        select {
        case <- ctx.Done():
            fmt.Printf("监控器%v，监控结束。\n", number)
            return
        default:
            fmt.Printf("监控器%v，正在监控中...\n", number)
            time.Sleep(2 * time.Second)
        }
    }
}

func main() {
    ctx01, cancel := context.WithCancel(context.Background())

      // 相比例子1，仅有这一行改动
    ctx02, cancel := context.WithTimeout(ctx01, 1* time.Second)

    defer cancel()

    for i :=1 ; i <= 5; i++ {
        go monitor(ctx02, i)
    }

    time.Sleep(5  * time.Second)
    if ctx02.Err() != nil {
        fmt.Println("监控器取消的原因: ", ctx02.Err())
    }

    fmt.Println("主程序退出！！")
}
```

输出的结果和上面一样

```go
监控器1，正在监控中...
监控器5，正在监控中...
监控器3，正在监控中...
监控器2，正在监控中...
监控器4，正在监控中...
监控器4，监控结束。
监控器2，监控结束。
监控器5，监控结束。
监控器1，监控结束。
监控器3，监控结束。
监控器取消的原因:  context deadline exceeded
主程序退出！！
```

### 例子 3：WithValue

通过Context我们也可以传递一些必须的元数据，这些数据会附加在Context上以供使用。

元数据以 Key-Value 的方式传入，Key 必须有可比性，Value 必须是线程安全的。

还是用上面的例子，以 ctx02 为父 context，再创建一个能携带 value 的ctx03，由于他的父context 是 ctx02，所以 ctx03 也具备超时自动取消的功能。

```go
package main

import (
    "context"
    "fmt"
    "time"
)

func monitor(ctx context.Context, number int)  {
    for {
        select {
        case <- ctx.Done():
            fmt.Printf("监控器%v，监控结束。\n", number)
            return
        default:
              // 获取 item 的值
            value := ctx.Value("item")
            fmt.Printf("监控器%v，正在监控 %v \n", number, value)
            time.Sleep(2 * time.Second)
        }
    }
}

func main() {
    ctx01, cancel := context.WithCancel(context.Background())
    ctx02, cancel := context.WithTimeout(ctx01, 1* time.Second)
    ctx03 := context.WithValue(ctx02, "item", "CPU")

    defer cancel()

    for i :=1 ; i <= 5; i++ {
        go monitor(ctx03, i)
    }

    time.Sleep(5  * time.Second)
    if ctx02.Err() != nil {
        fmt.Println("监控器取消的原因: ", ctx02.Err())
    }

    fmt.Println("主程序退出！！")
}
```

输出如下

```go
监控器4，正在监控 CPU 
监控器5，正在监控 CPU 
监控器1，正在监控 CPU 
监控器3，正在监控 CPU 
监控器2，正在监控 CPU 
监控器2，监控结束。
监控器5，监控结束。
监控器3，监控结束。
监控器1，监控结束。
监控器4，监控结束。
监控器取消的原因:  context deadline exceeded
主程序退出！！
```

## 6. Context 使用注意事项

1. 通常 Context 都是做为函数的第一个参数进行传递（规范性做法），并且变量名建议统一叫 ctx
2. Context 是线程安全的，可以放心地在多个 goroutine 中使用。
3. 当你把 Context 传递给多个 goroutine 使用时，只要执行一次 cancel 操作，所有的 goroutine 就可以收到 取消的信号
4. 不要把原本可以由函数参数来传递的变量，交给 Context 的 Value 来传递。
5. 当一个函数需要接收一个 Context 时，但是此时你还不知道要传递什么 Context 时，可以先用 context.TODO 来代替，而不要选择传递一个 nil。
6. 当一个 Context 被 cancel 时，继承自该 Context 的所有 子 Context 都会被 cancel。