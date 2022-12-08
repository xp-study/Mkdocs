# 类型断言

## 1. Type Assertion

Type Assertion（中文名叫：类型断言），通过它可以做到以下几件事情

1. 检查 `i` 是否为 nil
2. 检查 `i` 存储的值是否为某个类型

具体的使用方式有两种：

**第一种：**

```go
t := i.(T)
```

这个表达式可以断言一个接口对象（i）里不是 nil，并且接口对象（i）存储的值的类型是 T，如果断言成功，就会返回值给 t，如果断言失败，就会触发 panic。

来写段代码试验一下

```go
package main

import "fmt"

func main() {
    var i interface{} = 10
    t1 := i.(int)
    fmt.Println(t1)

    fmt.Println("=====分隔线=====")

    t2 := i.(string)
    fmt.Println(t2)
}
```

运行后输出如下，可以发现在执行第二次断言的时候失败了，并且触发了 panic

```go
10
=====分隔线=====
panic: interface conversion: interface {} is int, not string

goroutine 1 [running]:
main.main()
        E:/GoPlayer/src/main.go:12 +0x10e
exit status 2
```

如果要断言的接口值是 nil，那我们来看看也是不是也如预期一样会触发panic

```go
package main

func main() {
    var i interface{} // nil
    var _ = i.(interface{})
}
```

输出如下，确实是会 触发 panic

```go
panic: interface conversion: interface is nil, not interface {}

goroutine 1 [running]:
main.main()
        E:/GoPlayer/src/main.go:5 +0x34
exit status 2
```

**第二种**

```go
t, ok:= i.(T)
```

和上面一样，这个表达式也是可以断言一个接口对象（i）里不是 nil，并且接口对象（i）存储的值的类型是 T，如果断言成功，就会返回其类型给 t，并且此时 ok 的值 为 true，表示断言成功。

如果接口值的类型，并不是我们所断言的 T，就会断言失败，但和第一种表达式不同的事，这个不会触发 panic，而是将 ok 的值设为 false ，表示断言失败，此时t 为 T 的零值。

稍微修改下上面的例子，如下

```go
package main

import "fmt"

func main() {
    var i interface{} = 10
    t1, ok := i.(int)
    fmt.Printf("%d-%t\n", t1, ok)

    fmt.Println("=====分隔线1=====")

    t2, ok := i.(string)
    fmt.Printf("%s-%t\n", t2, ok)

    fmt.Println("=====分隔线2=====")

    var k interface{} // nil
    t3, ok := k.(interface{})
    fmt.Println(t3, "-", ok)

    fmt.Println("=====分隔线3=====")
    k = 10
    t4, ok := k.(interface{})
    fmt.Printf("%d-%t\n", t4, ok)

    t5, ok := k.(int)
    fmt.Printf("%d-%t\n", t5, ok)
}
```

运行后输出如下，可以发现在执行第二次断言的时候，虽然失败了，但并没有触发了 panic。

```go
10-true
=====分隔线1=====
-false
=====分隔线2=====
<nil> - false
=====分隔线3=====
10-true
10-true
```

上面这段输出，仔细看第二个断言的输出在`-false` 之前并不是有没有输出任何 t2 的值，而是由于断言失败，所以 t2 得到的是 string 的零值也是 `""` ，它是零长度的，所以你看不到其输出。

## 2. Type Switch

如果需要区分多种类型，可以使用 type switch 断言，这个将会比一个一个进行类型断言更简单、直接、高效。

```go
package main

import "fmt"

func findType(i interface{}) {
    switch x := i.(type) {
    case int:
        fmt.Println(x, "is int")
    case string:
        fmt.Println(x, "is string")
    case nil:
        fmt.Println(x, "is nil")
    default:
        fmt.Println(x, "not type matched")
    }
}

func main() {
    findType(10)      // int
    findType("hello") // string

    var k interface{} // nil
    findType(k)

    findType(10.23) //float64
}
```

输出如下

```go
10 is int
hello is string
<nil> is nil
10.23 not type matched
```

额外说明一下：

- 如果你的值是 nil，那么匹配的是 `case nil`
- 如果你的值在 switch-case 里并没有匹配对应的类型，那么走的是 default 分支