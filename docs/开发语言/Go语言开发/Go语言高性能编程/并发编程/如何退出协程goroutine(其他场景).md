# 如何退出协程 goroutine (其他场景)

## 1 channel 忘记关闭的陷阱

除了超时场景，其他使用协程(goroutine)的场景，也很容易因为实现不当，导致协程无法退出，随着时间的积累，造成内存耗尽，程序崩溃。

例如下面的例子：

```go
func do(taskCh chan int) {
	for {
		select {
		case t := <-taskCh:
			time.Sleep(time.Millisecond)
			fmt.Printf("task %d is done\n", t)
		}
	}
}

func sendTasks() {
	taskCh := make(chan int, 10)
	go do(taskCh)
	for i := 0; i < 1000; i++ {
		taskCh <- i
	}
}

func TestDo(t *testing.T) {
    t.Log(runtime.NumGoroutine())
    sendTasks()
	time.Sleep(time.Second)
	t.Log(runtime.NumGoroutine())
}
```

- `do` 的实现非常简单，for + select 的模式，等待信道 taskCh 传递任务，并执行。
- `sendTasks` 模拟向信道中发送任务。

该用例执行结果如下：

```go
$ go test . -v
--- PASS: TestDo (2.34s)
    exit_test.go:29: 2
    exit_test.go:32: 3
```

单元测试执行结束后，子协程多了一个，也就是说，有一个协程一直没有得到释放。我们仔细看代码，很容易发现 `sendTasks` 中启动了一个子协程 `go do(taskCh)`，因为这个协程一直处于阻塞状态，等待接收任务，因此直到程序结束，协程也没有释放。

如果任务全部发送成功，我们如何通知该协程结束等待，正常退出呢？

## 2 channel 的简单回顾

### 2.1 channel 的常见操作

- 创建 channel

```go
ch := make(chan int) // 不带缓冲区
ch := make(chan int, 10) // 带缓冲区，缓冲区满之前，即使没有接收方，发送方不阻塞
```

- 关闭 channel

```go
close(ch)
```

- 向通道发送值 v

```go
ch <- v
```

- 从通道中接收值

```go
<-ch // 忽略接收值
v := <-ch // 接收值并赋值给变量 v
```

接收操作可以有 2 个返回值。

```go
v, beforeClosed := <-ch
```

beforeClosed 代表 v 是否是信道关闭前发送的。true 代表是信道关闭前发送的，false 代表信道已经关闭。如果一个信道已经关闭，`<-ch` 将永远不会发生阻塞，但是我们可以通过第二个返回值 beforeClosed 得知信道已经关闭，作出相应的处理。

- 与其他容器类型一致，支持查询长度和容量

```go
len(ch)
cap(ch)
```

### 2.2 channel 的三种状态和三种操作结果

|   操作   | 空值(nil) | 非空已关闭 |    非空未关闭    |
| :------: | :-------: | :--------: | :--------------: |
|   关闭   |   panic   |   panic    |     成功关闭     |
| 发送数据 | 永久阻塞  |   panic    |  阻塞或成功发送  |
| 接收数据 | 永久阻塞  |  永不阻塞  | 阻塞或者成功接收 |

## 3 如何解决

```
func doCheckClose(taskCh chan int) {
	for {
		select {
		case t, beforeClosed := <-taskCh:
			if !beforeClosed {
				fmt.Println("taskCh has been closed")
				return
			}
			time.Sleep(time.Millisecond)
			fmt.Printf("task %d is done\n", t)
		}
	}
}

func sendTasksCheckClose() {
	taskCh := make(chan int, 10)
	go doCheckClose(taskCh)
	for i := 0; i < 1000; i++ {
		taskCh <- i
	}
	close(taskCh)
}

func TestDoCheckClose(t *testing.T) {
	t.Log(runtime.NumGoroutine())
	sendTasksCheckClose()
	time.Sleep(time.Second)
	runtime.GC()
	t.Log(runtime.NumGoroutine())
}
```

两个地方修改下即可：

- `t, beforeClosed := <-taskCh` 判断 channel 是否已经关闭，beforeClosed 为 false 表示信道已被关闭。若关闭，则不再阻塞等待，直接返回，对应的协程随之退出。
- `sendTasks` 函数中，任务发送结束之后，使用 `close(taskCh)` 将 channel taskCh 关闭。

测试用例执行结果如下：

```
$ go test -run=TestDoCheckClose -v
task 999 is done
taskCh has been closed
--- PASS: TestDoCheckClose (2.34s)
    exit_test.go:59: 2
    exit_test.go:63: 2
```

可以发现，启动的协程已经正常退出，该协程以及使用到的信道 taskCh 将被垃圾回收，资源得到释放。

> 关于通道和协程的垃圾回收
>
> 注意，一个通道被其发送数据协程队列和接收数据协程队列中的所有协程引用着。因此，如果一个通道的这两个队列只要有一个不为空，则此通道肯定不会被垃圾回收。另一方面，如果一个协程处于一个通道的某个协程队列之中，则此协程也肯定不会被垃圾回收，即使此通道仅被此协程所引用。事实上，一个协程只有在退出后才能被垃圾回收。

## 4 通道关闭原则

> 通道关闭原则
>
> 一个常用的使用Go通道的原则是不要在数据接收方或者在有多个发送者的情况下关闭通道。换句话说，我们只应该让一个通道唯一的发送者关闭此通道。

### 4.1 粗鲁的方式（非常不推荐）

如果 channel 已经被关闭，再次关闭会产生 panic，这时通过 recover 使程序恢复正常。

```go
func SafeClose(ch chan T) (justClosed bool) {
	defer func() {
		if recover() != nil {
			// 一个函数的返回结果可以在defer调用中修改。
			justClosed = false
		}
	}()

	// 假设ch != nil。
	close(ch)   // 如果 ch 已关闭，将 panic
	return true // <=> justClosed = true; return
}
```

### 4.2 礼貌的方式

使用 sync.Once 或互斥锁(sync.Mutex)确保 channel 只被关闭一次。

```go
type MyChannel struct {
	C    chan T
	once sync.Once
}

func NewMyChannel() *MyChannel {
	return &MyChannel{C: make(chan T)}
}

func (mc *MyChannel) SafeClose() {
	mc.once.Do(func() {
		close(mc.C)
	})
}
```