# byte、rune与string

**1. byte 与 rune**

**byte**，占用1个节字，就 8 个比特位，所以它和 `uint8` 类型本质上没有区别，它表示的是 ACSII 表中的一个字符。

如下这段代码，分别定义了 byte 类型和 uint8 类型的变量 a 和 b

```go
import "fmt"

func main() {
    var a byte = 65 
    // 8进制写法: var c byte = '\101'     其中 \ 是固定前缀
    // 16进制写法: var c byte = '\x41'    其中 \x 是固定前缀

    var b uint8 = 66
    fmt.Printf("a 的值: %c \nb 的值: %c", a, b)
    // 或者使用 string 函数
    // fmt.Println("a 的值: ", string(a)," \nb 的值: ", string(b))
}
```

在 ASCII 表中，由于字母 A 的ASCII 的编号为 65 ，字母 B 的ASCII 编号为 66，所以上面的代码也可以写成这样

```go
import "fmt"

func main() {
    var a byte = 'A'
    var b uint8 = 'B'
    fmt.Printf("a 的值: %c \nb 的值: %c", a, b)
}
```

他们的输出结果都是一样的。

```go
a 的值: A 
b 的值: B
```

**rune**，占用4个字节，共32位比特位，所以它和 `uint32` 本质上也没有区别。它表示的是一个 Unicode字符（Unicode是一个可以表示世界范围内的绝大部分字符的编码规范）。

```go
import (
    "fmt"
    "unsafe"
)

func main() {
    var a byte = 'A'
    var b rune = 'B'
    fmt.Printf("a 占用 %d 个字节数\nb 占用 %d 个字节数", unsafe.Sizeof(a), unsafe.Sizeof(b))
}
```

输出如下

```go
a 占用 1 个字节数
b 占用 4 个字节数
```

由于 byte 类型能表示的值是有限，只有 2^8=256 个。所以如果你想表示中文的话，你只能使用 rune 类型。

```go
var name rune = '中'
```

或许你已经发现，上面我们在定义字符时，不管是 byte 还是 rune ，我都是使用单引号，而没使用双引号。

对于从 Python 转过来的人，这里一定要注意了，**在 Go 中单引号与 双引号并不是等价的**。

单引号用来表示字符，在上面的例子里，如果你使用双引号，就意味着你要定义一个字符串，赋值时与前面声明的不一致，这样在编译的时候就会出错。

```go
cannot use "A" (type string) as type byte in assignment
```

上面我说了，byte 和 uint8 没有区别，rune 和 uint32 没有区别，**那为什么还要多出 byte 和 rune 类型呢**？多乱呀。

理由很简单，因为uint8 和 uint32 ，直观上让人以为这是一个数值，但是实际上，它也可以表示一个字符，所以为了消除这种直观错觉，就诞生了 byte 和 rune 这两个别名类型。

## 2. 字符串

字符串，可以说是大家很熟悉的数据类型之一。定义方法很简单

```go
var mystr string = "hello"
```

上面说的byte 和 rune 都是字符类型，若多个字符放在一起，就组成了字符串，也就是这里要说的 string 类型。

比如 `hello` ，对照 ASCII 编码表，每个字母对应的编号是：104,101,108,108,111

```go
import (
    "fmt"
)

func main() {
    var mystr01 sting = "hello"
    var mystr02 [5]byte = [5]byte{104, 101, 108, 108, 111}
    fmt.Printf("mystr01: %s\n", mystr01)
    fmt.Printf("mystr02: %s", mystr02)
}
```

输出如下，mystr01 和 mystr02 输出一样，说明了 string 的本质，其实是一个 byte数组

```go
mystr01: hello
mystr02: hello
```

通过以上学习，我们知道字符分为 byte 和 rune，占用的大小不同。

这里来考一下大家，`hello,中国` 占用几个字节？

要回答这个问题，你得知道 Go 语言的 string 是用 uft-8 进行编码的，英文字母占用一个字节，而中文字母占用 3个字节，所以 `hello,中国` 的长度为 5+1+（3＊2)= 12个字节。

```go
import (
    "fmt"
)

func main() {
    var country string = "hello,中国"
    fmt.Println(len(country))
}
// 输出
12
```