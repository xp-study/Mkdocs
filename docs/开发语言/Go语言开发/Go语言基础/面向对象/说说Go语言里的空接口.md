# 说说 Go 语言里的空接口

## 1. 什么是空接口？

空接口是特殊形式的接口类型，普通的接口都有方法，而空接口没有定义任何方法口，也因此，我们可以说所有类型都至少实现了空接口。

```go
type empty_iface interface {
}
```

每一个接口都包含两个属性，一个是值，一个是类型。

而对于空接口来说，这两者都是 nil，可以使用 fmt 来验证一下

```go
package main

import (
    "fmt"
)

func main() {
    var i interface{}
    fmt.Printf("type: %T, value: %v", i, i)
}
```

输出如下

```go
type: <nil>, value: <nil>
```

## 2. 如何使用空接口？

**第一**，通常我们会直接使用 `interface{}` 作为类型声明一个实例，而这个实例可以承载任意类型的值。

```go
package main

import (
    "fmt"
)

func main()  {
    // 声明一个空接口实例
    var i interface{}

    // 存 int 没有问题
    i = 1
    fmt.Println(i)

    // 存字符串也没有问题
    i = "hello"
    fmt.Println(i)

    // 存布尔值也没有问题
    i = false
    fmt.Println(i)
}
```

**第二**，如果想让你的函数可以接收任意类型的值 ，也可以使用空接口

**接收一个任意类型的值 示例**

```go
package main

import (
    "fmt"
)

func myfunc(iface interface{}){
    fmt.Println(iface)
}

func main()  {
    a := 10
    b := "hello"
    c := true

    myfunc(a)
    myfunc(b)
    myfunc(c)
}
```

**接收任意个任意类型的值 示例**

```go
package main

import (
    "fmt"
)

func myfunc(ifaces ...interface{}){
    for _,iface := range ifaces{
        fmt.Println(iface)
    }
}

func main()  {
    a := 10
    b := "hello"
    c := true

    myfunc(a, b, c)
}
```

**第三**，你也定义一个可以接收任意类型的 array、slice、map、strcut，例如这边定义一个切片

```go
package main

import "fmt"

func main() {
    any := make([]interface{}, 5)
    any[0] = 11
    any[1] = "hello world"
    any[2] = []int{11, 22, 33, 44}
    for _, value := range any {
        fmt.Println(value)
    }
}
```

## 3. 空接口几个要注意的坑

**坑1**：空接口可以承载任意值，但不代表任意类型就可以承接空接口类型的值

从实现的角度看，任何类型的值都满足空接口。因此空接口类型可以保存任何值，也可以从空接口中取出原值。

但要是你把一个空接口类型的对象，再赋值给一个固定类型（比如 int, string等类型）的对象赋值，是会报错的。

```go
package main

func main() {
    // 声明a变量, 类型int, 初始值为1
    var a int = 1

    // 声明i变量, 类型为interface{}, 初始值为a, 此时i的值变为1
    var i interface{} = a

    // 声明b变量, 尝试赋值i
    var b int = i
}
```

这个报错，它就好比可以放进行礼箱的东西，肯定能放到集装箱里，但是反过来，能放到集装箱的东西就不一定能放到行礼箱了，在 Go 里就直接禁止了这种反向操作。（**声明**：底层原理肯定还另有其因，但对于新手来说，这样解释也许会容易理解一些。）

```go
.\main.go:11:6: cannot use i (type interface {}) as type int in assignment: need type assertion
```

**坑2：**：当空接口承载数组和切片后，该对象无法再进行切片

```go
package main

import "fmt"

func main() {
    sli := []int{2, 3, 5, 7, 11, 13}

    var i interface{}
    i = sli

    g := i[1:3]
    fmt.Println(g)
}
```

执行会报错。

```go
.\main.go:11:8: cannot slice i (type interface {})
```

**坑3**：当你使用空接口来接收任意类型的参数时，它的静态类型是 interface{}，但动态类型（是 int，string 还是其他类型）我们并不知道，因此需要使用类型断言。

```go
package main

import (
    "fmt"
)

func myfunc(i interface{})  {

    switch i.(type) {
    case int:
        fmt.Println("参数的类型是 int")
    case string:
        fmt.Println("参数的类型是 string")
    }
}

func main() {
    a := 10
    b := "hello"
    myfunc(a)
    myfunc(b)
}
```

输出如下

```go
参数的类型是 int
参数的类型是 string
```