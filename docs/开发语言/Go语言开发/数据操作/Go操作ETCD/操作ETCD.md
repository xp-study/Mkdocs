# 1. 操作ETCD

这里使用官方的`etcd/clientv3`包来连接etcd并进行相关操作。

### 1.1.1. 安装

```shell
    go get go.etcd.io/etcd/clientv3
```

### 1.1.2. put和get操作

put命令用来设置键值对数据，get命令用来根据key获取值。

```go
package main

import (
    "context"
    "fmt"
    "time"

    "go.etcd.io/etcd/clientv3"
)

// etcd client put/get demo
// use etcd/clientv3

func main() {
    cli, err := clientv3.New(clientv3.Config{
        Endpoints:   []string{"127.0.0.1:2379"},
        DialTimeout: 5 * time.Second,
    })
    if err != nil {
        // handle error!
        fmt.Printf("connect to etcd failed, err:%v\n", err)
        return
    }
    fmt.Println("connect to etcd success")
    defer cli.Close()
    // put
    ctx, cancel := context.WithTimeout(context.Background(), time.Second)
    _, err = cli.Put(ctx, "lmh", "lmh")
    cancel()
    if err != nil {
        fmt.Printf("put to etcd failed, err:%v\n", err)
        return
    }
    // get
    ctx, cancel = context.WithTimeout(context.Background(), time.Second)
    resp, err := cli.Get(ctx, "lmh")
    cancel()
    if err != nil {
        fmt.Printf("get from etcd failed, err:%v\n", err)
        return
    }
    for _, ev := range resp.Kvs {
        fmt.Printf("%s:%s\n", ev.Key, ev.Value)
    }
}
```

### 1.1.3. watch操作

watch用来获取未来更改的通知。

```go
package main

import (
    "context"
    "fmt"
    "time"

    "go.etcd.io/etcd/clientv3"
)

// watch demo

func main() {
    cli, err := clientv3.New(clientv3.Config{
        Endpoints:   []string{"127.0.0.1:2379"},
        DialTimeout: 5 * time.Second,
    })
    if err != nil {
        fmt.Printf("connect to etcd failed, err:%v\n", err)
        return
    }
    fmt.Println("connect to etcd success")
    defer cli.Close()
    // watch key:lmh change
    rch := cli.Watch(context.Background(), "lmh") // <-chan WatchResponse
    for wresp := range rch {
        for _, ev := range wresp.Events {
            fmt.Printf("Type: %s Key:%s Value:%s\n", ev.Type, ev.Kv.Key, ev.Kv.Value)
        }
    }
}
```

将上面的代码保存编译执行，此时程序就会等待etcd中lmh这个key的变化。

例如：我们打开终端执行以下命令修改、删除、设置lmh这个key。

```shell
    etcd> etcdctl.exe --endpoints=http://127.0.0.1:2379 put lmh "lmh1"
    OK

    etcd> etcdctl.exe --endpoints=http://127.0.0.1:2379 del lmh
    1

    etcd> etcdctl.exe --endpoints=http://127.0.0.1:2379 put lmh "lmh2"
    OK
```

上面的程序都能收到如下通知。

```shell
    watch>watch.exe
    connect to etcd success
    Type: PUT Key:lmh Value:lmh1
    Type: DELETE Key:lmh Value:
    Type: PUT Key:lmh Value:lmh2
```

### 1.1.4. lease租约

```go
package main

import (
    "fmt"
    "time"
)

// etcd lease

import (
    "context"
    "log"

    "go.etcd.io/etcd/clientv3"
)

func main() {
    cli, err := clientv3.New(clientv3.Config{
        Endpoints:   []string{"127.0.0.1:2379"},
        DialTimeout: time.Second * 5,
    })
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println("connect to etcd success.")
    defer cli.Close()

    // 创建一个5秒的租约
    resp, err := cli.Grant(context.TODO(), 5)
    if err != nil {
        log.Fatal(err)
    }

    // 5秒钟之后, /lmh/ 这个key就会被移除
    _, err = cli.Put(context.TODO(), "/lmh/", "lmh", clientv3.WithLease(resp.ID))
    if err != nil {
        log.Fatal(err)
    }
}
```

### 1.1.5. keepAlive

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    "go.etcd.io/etcd/clientv3"
)

// etcd keepAlive

func main() {
    cli, err := clientv3.New(clientv3.Config{
        Endpoints:   []string{"127.0.0.1:2379"},
        DialTimeout: time.Second * 5,
    })
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println("connect to etcd success.")
    defer cli.Close()

    resp, err := cli.Grant(context.TODO(), 5)
    if err != nil {
        log.Fatal(err)
    }

    _, err = cli.Put(context.TODO(), "/lmh/", "lmh", clientv3.WithLease(resp.ID))
    if err != nil {
        log.Fatal(err)
    }

    // the key 'foo' will be kept forever
    ch, kaerr := cli.KeepAlive(context.TODO(), resp.ID)
    if kaerr != nil {
        log.Fatal(kaerr)
    }
    for {
        ka := <-ch
        fmt.Println("ttl:", ka.TTL)
    }
}
```

### 1.1.6. 基于etcd实现分布式锁

go.etcd.io/etcd/clientv3/concurrency在etcd之上实现并发操作，如分布式锁、屏障和选举。

导入该包：

```shell
    import "go.etcd.io/etcd/clientv3/concurrency"
```

基于etcd实现的分布式锁示例：

```go
cli, err := clientv3.New(clientv3.Config{Endpoints: endpoints})
if err != nil {
    log.Fatal(err)
}
defer cli.Close()

// 创建两个单独的会话用来演示锁竞争
s1, err := concurrency.NewSession(cli)
if err != nil {
    log.Fatal(err)
}
defer s1.Close()
m1 := concurrency.NewMutex(s1, "/my-lock/")

s2, err := concurrency.NewSession(cli)
if err != nil {
    log.Fatal(err)
}
defer s2.Close()
m2 := concurrency.NewMutex(s2, "/my-lock/")

// 会话s1获取锁
if err := m1.Lock(context.TODO()); err != nil {
    log.Fatal(err)
}
fmt.Println("acquired lock for s1")

m2Locked := make(chan struct{})
go func() {
    defer close(m2Locked)
    // 等待直到会话s1释放了/my-lock/的锁
    if err := m2.Lock(context.TODO()); err != nil {
        log.Fatal(err)
    }
}()

if err := m1.Unlock(context.TODO()); err != nil {
    log.Fatal(err)
}
fmt.Println("released lock for s1")

<-m2Locked
fmt.Println("acquired lock for s2")
```

输出：

```shell
    acquired lock for s1
    released lock for s1
    acquired lock for s2
```

[查看文档了解更多](https://godoc.org/go.etcd.io/etcd/clientv3/concurrency)