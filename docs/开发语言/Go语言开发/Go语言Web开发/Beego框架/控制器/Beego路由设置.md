# Beego路由设置

路由指的就是一个url请求由谁来处理，在beego设计中，url请求可以由控制器的函数来处理，也可以由一个单独的函数来处理，因此路由设置由两部分组成：**url路由** 和 **处理函数**。

beego提供两种设置处理函数的方式:

- 直接绑定一个函数
- 绑定一个控制器对象 （RESTful方式）

## 1.直接绑定处理函数

这种方式直接将一个url路由和一个函数绑定起来。

例子：

```go
// 这就是将url / 和一个闭包函数绑定起来, 这个url的Get请求由这个闭包函数处理。
web.Get("/",func(ctx *context.Context){
     ctx.Output.Body([]byte("hi tizi365.com"))
})

// 定义一个处理函数
func Index(ctx *context.Context){
     ctx.Output.Body([]byte("欢迎访问 tizi365.com"))
}

// 注册路由, 将url /index 和Index函数绑定起来，由Index函数处理这个url的Post请求
web.Post("/index", Index)
```

下面是beego支持的基础函数：

- `web`.Get(router, web.FilterFunc)
- `web`.Post(router, web.FilterFunc)
- `web`.Put(router, web.FilterFunc)
- `web`.Patch(router, web.FilterFunc)
- `web`.Head(router, web.FilterFunc)
- `web`.Options(router, web.FilterFunc)
- `web`.Delete(router, web.FilterFunc)
- `web`.Any(router, web.FilterFunc) - 处理任意http请求，就是不论请求方法（Get,Post,Delete等等）是什么，都由绑定的函数处理

根据不同的http请求方法（Get,Post等等）选择不同的函数设置路由即可。

## 2.RESTful路由方式

RESTful 是一种目前比较流行的url风格，beego默认支持这种风格。
在beego项目中，RESTful路由方式就是将url路由跟一个控制器对象绑定，然后Get请求由控制的Get函数处理，Post请求由Post函数处理，以此类推。

RESTful路由使用**web.Router**函数设置路由。

例子:

```go
// url: / 的所有http请求方法都由MainController控制器的对应函数处理
web.Router("/", &controllers.MainController{})

// url: /user 的所有http请求方法都由UserController控制器的对应函数处理
// 例如: GET /user请求，由Get函数处理, POST /user 请求，由Post函数处理
web.Router("/user", &controllers.UserController{})
```

## 3.url路由方式

上面介绍了设置处理函数的方式，下面介绍beego支持的url路由方式。

> 提示： 下面介绍的所有url路由规则，都适用于上面介绍的所有路由设置函数。

### 3.1.固定路由

前面介绍的url路由例子，都属于固定路由方式，固定路由指的是url规则是固定的一个url。
例子:

```go
web.Router("/user", &controllers.UserController{})
web.Router("/shop/order", &controllers.OrderController{})
web.Router("/shop/comment", &controllers.CommentController{})
```

### 3.2.正则路由

正则路由比较灵活，一个正则路由设置代表的是一序列的url, 正则路由更像是一种url模板。
url路由例子:

- **/user/:id**
  匹配/user/132，参数 :id=132
- **/user/:id([0-9]+)**
  匹配/user/123，参数 :id=123， 跟上面例子的区别就是只能匹配数字
- **/user/:username([\w]+)**
  匹配/user/tizi, 参数 :username=tizi
- **/list_:cat([0-9]+)_:page([0-9]+).html**
  匹配/list_2_1.html, 参数 :cat=2, :page=1
- **/api/***
  匹配/api为前缀的所有url, 例子: /api/user/1 , 参数: :splat=user/1

在 Controller 对象中，可以通过下面的方式获取url路由匹配的参数：

```go
func (c *MainController) Get() {
	c.Ctx.Input.Param(":id")
	c.Ctx.Input.Param(":username")
	c.Ctx.Input.Param(":cat")
	c.Ctx.Input.Param(":page")
	c.Ctx.Input.Param(":splat")
}
```

### 3.3.自动路由

自动路由指的是通过反射获取到控制器的名字和控制器实现的所有函数名字，自动生成url路由。

使用自动路由首先需要beego.AutoRouter函数注册控制器。
例子:

```go
web.AutoRouter(&controllers.UserController{})
```

url自动路由例子:

```go
/user/login   调用 UserController 中的 Login 方法
/user/logout  调用 UserController 中的 Logout 方法
```

除了前缀两个 /:controller/:method 的匹配之外，剩下的 url beego 会帮你自动化解析为参数，保存在 this.Ctx.Input.Params 当中：

```go
/user/list/2019/09/11  调用 UserController 中的 List 方法，参数如下：map[0:2019 1:09 2:11]
```

> 提示：自动路由会将url和控制器名字、函数名字转换成小写。

### 3.4.namespace

路由名字空间(namespace)，一般用来做api版本处理。

例子:

```go
// 创建版本1的名字空间
ns1 := web.NewNamespace("/v1",
    // 内嵌一个/user名字空间
    web.NSNamespace("/user",
        // 下面开始注册路由
        // url路由: /v1/user/info
        web.NSRouter("/info", &controllers.UserController{}),
        // url路由: /v1/user/order
        web.NSRouter("/order", &controllers.UserOrderController{}),
    ),
    // 内嵌一个/shop名字空间
    web.NSNamespace("/shop",
        // 下面开始注册路由
        // url路由: /v1/shop/info
        web.NSRouter("/info", &controllers.ShopController{}),
        // url路由: /v1/shop/order
        web.NSRouter("/order", &controllers.ShopOrderController{}),
    ),
)

// 创建版本2的名字空间
ns2 := web.NewNamespace("/v2",
    web.NSNamespace("/user",
        // url路由: /v2user/info
        web.NSRouter("/info", &controllers.User2Controller{}),
    ),
    web.NSNamespace("/shop",
        // url路由: /v2/shop/order
        web.NSRouter("/order", &controllers.ShopOrder2Controller{}),
    ),
)

//注册 namespace
web.AddNamespace(ns1)
web.AddNamespace(ns2)
```

通过NewNamespace函数创建多个名字空间，NSNamespace函数可以无限嵌套名字空间, 根据上面的例子可以看出来，名字空间的作用其实就是定义url路由的前缀，如果一个名字空间定义url路由为/user, 那么这个名字空间下面定义的所有路由的前缀都是以/user开头。

下面是namespace支持的路由设置函数:

- NewNamespace(prefix string, funcs …interface{})
- NSNamespace(prefix string, funcs …interface{})
- NSInclude(cList …ControllerInterface)
- NSRouter(rootpath string, c ControllerInterface, mappingMethods …string)
- NSGet(rootpath string, f FilterFunc)
- NSPost(rootpath string, f FilterFunc)
- NSDelete(rootpath string, f FilterFunc)
- NSPut(rootpath string, f FilterFunc)
- NSHead(rootpath string, f FilterFunc)
- NSOptions(rootpath string, f FilterFunc)
- NSPatch(rootpath string, f FilterFunc)
- NSAny(rootpath string, f FilterFunc)
- NSHandler(rootpath string, h http.Handler)
- NSAutoRouter(c ControllerInterface)
- NSAutoPrefix(prefix string, c ControllerInterface)

这些路由设置函数的参数，跟前面的路由设置函数一样，区别就是namespace的函数名前面多了NS前缀。