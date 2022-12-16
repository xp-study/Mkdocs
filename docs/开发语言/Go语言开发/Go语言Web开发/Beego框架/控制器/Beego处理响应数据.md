# Beego处理响应数据

我们处理完用户的请求之后，通常我们都会返回html代码，然后浏览器就可以显示html内容；除了返回html，在api接口开发中，我们还可以返回json、xml、jsonp格式的数据。

下面分别介绍beego返回不同数据类型的处理方式。

> 注意：如果使用beego开发api，那么在app.conf中设置AutoRender = false， 禁止自动渲染模板，否则beego每次处理请求都会尝试渲染模板，如果模板不存在则报错。

## 1.返回json数据

下面是返回json数据的例子:

```go
// 定义struct
// 如果struct字段名跟json字段名不一样，可以使用json标签,指定json字段名
type User struct {
    // - 表示忽略id字段
	Id       int	`json:"-"`
	Username string `json:"name"`
	Phone    string
}

func (this *UserController) Get() {
    // 定义需要返回给客户端的数据
    user := User{1, "tizi365", "13089818901"}
    
    // 将需要返回的数据赋值给json字段
    this.Data["json"] = &user
    
    // 将this.Data["json"]的数据，序列化成json字符串，然后返回给客户端
    this.ServeJSON()
}
```

> 提示：请参考Go处理json数据教程，了解详细的json数据处理方式。

## 2.返回xml数据

下面是返回xml数据的处理方式跟json类似。

例子:

```go
// 定义struct
// 如果struct字段名跟xml字段名不一样，可以使用xml标签,指定xml字段名
type User struct {
    // - 表示忽略id字段
	Id       int	`xml:"-"`
	Username string `xml:"name"`
	Phone    string
}

func (this *UserController) Get() {
    // 定义需要返回给客户端的数据
    user := User{1, "tizi365", "13089818901"}
    
    // 将需要返回的数据赋值给xml字段
    this.Data["xml"] = &user
    
    // 将this.Data["xml"]的数据，序列化成xml字符串，然后返回给客户端
    this.ServeXML()
}
```

> 提示：请参考Go处理xml数据教程，了解详细的xml数据处理方式。

## 3.返回jsonp数据

返回jsonp数据，于返回json数据方式类似。

例子:

```go
func (this *UserController) Get() {
    // 定义需要返回给客户端的数据
    user := User{1, "tizi365", "13089818901"}
    
    // 将需要返回的数据赋值给jsonp字段
    this.Data["jsonp"] = &user
    
    // 将this.Data["json"]的数据，序列化成json字符串，然后返回给客户端
    this.ServeJSONP()
}
```

## 4.返回html

如果我们开发的是网页，那么通常需要返回html代码，在beego项目中关于html视图部分，使用的是模板引擎技术，渲染html，然后将结果返回给浏览器。

例子:

```go
func (c *MainController) Get() {
    // 设置模板参数
	c.Data["Website"] = "tizi365.com"
	c.Data["Email"] = "tizi365@demo.com"
	
	// 需要渲染的模板， beego会渲染这个模板，然后返回结果
	c.TplName = "index.tpl"
}
```

## 5.添加响应头

为http请求添加header

```go
func (c *MainController) Get() {
    // 通过this.Ctx.Output.Header设置响应头
    this.Ctx.Output.Header("Content-Type", "message/http")
    this.Ctx.Output.Header("Cache-Control", "no-cache, no-store, must-revalidate")
}
```