# Beego控制器函数

控制器函数指的是处理用户请求的函数，前面路由设置章节介绍过，beego框架支持两种处理用户请求的函数。

- beego.FilterFunc 类型的独立函数
- 控制器函数 (RESTful 风格实现, beego默认推荐的格式)

## 1.beego.FilterFunc函数

这是最简单的请求处理函数，函数原型定义：

```go
type FilterFunc func(*context.Context)
```

也就是只要定义一个函数，并且接收一个Context参数，那么这个函数就可以作为处理用户请求的函数。

例子:

```go
func DoLogin(ctx *context.Context) {
     // ..处理请求的逻辑...
     // 可以通过Context 获取请求参数，返回请求结果
}
```

有了处理函数，我们就可以将处理函数跟一个url路由绑定起来.

例子:

```go
web.Get("/user/login", DoLogin)
```

> 提示: 新版的beego设计，默认不推荐使用beego.FilterFunc函数方式，这种方式处理请求的方式比较原始，后面介绍的控制器函数拥有更多高级特性，后续的教程以控制器函数为主。

## 2.控制器函数

控制器函数是beego的RESTful api的实现方式，在beego的设计中，控制器就是一个嵌套了**beego.Controller**的结构体对象。

例子:

```go
// 定义一个新的控制器
type UserController struct {
    // 嵌套beego基础控制器
    web.Controller
}
```

前面介绍过，struct嵌套，就类似其他高级语言的 **继承** 特性，嵌套了web.Controller控制器，就拥有了web.Controller定义的属性和函数。

控制器命名规则约定：**Xxx**Controller
**Xxx**就是我们的控制器名字, 这是为了便于阅读，看到Controller结尾的struct就知道是一个控制器。

下面看一个完整控制器的例子:

```go
type UserController struct {
    // 嵌套beego基础控制器
    web.Controller
}

// 在调用其他控制器函数之前，会优先调用Prepare函数
func (this *UserController) Prepare() {
    // 这里可以跑一些初始化工作
}

// 处理get请求
func (this *UserController) Get() {
    // 处理逻辑
}

// 处理post请求
func (this *UserController) Post() {
    // 处理逻辑
}
```

注册路由

```go
// 在这里参数:id是可选的
web.Router("/user/?:id", &controllers.UserController{})
```

根据上面注册的路由规则, 下面的展示对应的http请求和处理函数:

- GET /user/2 - 由Get函数处理
- POST /user - 由Post函数处理

> 提示：前面路由设置章节介绍过控制器的路由规则是Get请求由Get函数处理，Post请求由Post函数处理，以此类推。

下表展示了web.Controller默认为我们提供了哪些可选的函数:

> 提示: 根据业务需要，控制器可以覆盖下表中的函数。

|  函数名   |                             说明                             |
| :-------: | :----------------------------------------------------------: |
| Prepare() | 这个函数会优先执行，才会执行Get、Post之类的函数, 可以在Prepare做一些初始化工作。 |
|   Get()   |    处理get请求， 如果没有实现该函数，默认会返回405错误。     |
|  Post()   |              处理Post请求, 默认会返回405错误。               |
| Delete()  |             处理Delete请求, 默认会返回405错误。              |
|   Put()   |               处理PUT请求, 默认会返回405错误。               |
| Finish()  | 执行完Get、Post之类http请求函数之后执行，我们可以在Finish函数处理一些回收工作。 |

## 3.如何提前结束请求。

如果我们在Prepare函数处理用户的权限验证，验证不通过，我们一般都希望结束请求，不要执行后面的函数，beego提供了StopRun函数来结束请求。
例子:

```go
func (this *UserController) Prepare() {
    // 处理权限验证逻辑
    
    // 验证不通过，返回错误信息，结束请求
    this.Data["json"] = map[string]interface{}{"error":"没有权限", "errno":401}
	this.ServeJSON()
    this.StopRun()
}
```

> 提示：调用 StopRun 之后，不会再执行Finish函数，如果有需要可以在调用StopRun之后，手动调用Finish函数。