# Beego处理请求参数

web.Controller基础控制器，为我们提供了多种读取请求参数的函数，下面分别介绍各种获取参数的场景。

## 1.默认获取参数方式

web.Controller基础控制器为我们提供了GetXXX序列获取参数的函数, XXX指的就是返回不同的数据类型。
例子：

```go
// 处理get请求
func (this *UserController) Get() {
	// 获取参数, 返回int类型
	id ,_:= this.GetInt("id")
	
	// 获取参数，返回string类型, 如果参数不存在返回none作为默认值
	username := this.GetString("username", "none")
	
	// 获取参数，返回float类型, 参数不存在则返回 0
	price, _ := this.GetFloat("price", 0)
}
```

下面是常用的获取参数的函数定义：

- GetString(key string, def ...string) string
- GetInt(key string, def ...int) (int, error)
- GetInt64(key string, def ...int64) (int64, error)
- GetFloat(key string, def ...float64) (float64, error)
- GetBool(key string, def ...bool) (bool, error)

默认情况用户请求的参数都是 **字符串** 类型，如果要转换成其他类型，就可能会出现类型转换失败的可能性，因此除了GetString函数，其他GetXXX函数，都返回两个值，第一个值是需要获取的参数值，第二个就是error，表示是数据类型转换是否失败。

## 2.绑定struct方式

除了上面一个一个的获取请求参数，针对POST请求的表单数据，beego支持直接将表单数据绑定到一个struct变量。

例子:

```go
// 定义一个struct用来保存表单数据
// 通过给字段设置tag， 指定表单字段名， - 表示忽略这个字段不进行赋值
// 默认情况下表单字段名跟struct字段名同名（小写）
type UserForm struct {
    // 忽略掉Id字段
    Id    int         `form:"-"`
    // 表单字段名为username
    Name  string      `form:"username"`
    Phone string      
}
```

> 说明： 如果表单字段跟struct字段（小写）同名，不需要设置form标签。 表单html代码:

```go
<form action="/user" method="POST">
    手机号：<input name="phone" type="text" /><br/>
    用户名：<input name="username" type="text" />
    <input type="submit" value="提交" />
</form>
```

控制器函数:

```go
func (this *UserController) Post() {
    // 定义保存表单数据的struct对象
    u := UserForm{}
    // 通过ParseForm函数，将请求参数绑定到struct变量。
    if err := this.ParseForm(&u); err != nil {
        // 绑定参数失败
    }
}
```

> 提示：使用struct绑定请求参数的方式，仅适用于POST请求。

## 3.处理json请求参数

一般在接口开发的时候，有时候会将json请求参数保存在http请求的body里面。我们就不能使用前的方式获取json数据，需要直接读取请求body的内容，然后格式化数据。

**处理json参数的步骤**：

1. 在app.conf配置文件中，添加CopyRequestBody=true
2. 通过this.Ctx.Input.RequestBody获取请求body的内容
3. 通过json.Unmarshal反序列化json字符串，将json参数绑定到struct变量。

例子:

定义struct用于保存json数据

```go
// 如果json字段跟struct字段名不一样，可以通过json标签设置json字段名
type UserForm struct {
    // 忽略掉Id字段
    Id    int         `json:"-"`
    // json字段名为username
    Name  string      `json:"username"`
    Phone string      
}
```

控制器代码:

```go
func (this *UserController) Post() {
    // 定义保存json数据的struct对象
    u := UserForm{}
    
    // 获取body内容
    body := this.Ctx.Input.RequestBody
    
    // 反序列json数据，结果保存至u
    if err := json.Unmarshal(body, &u); err == nil {
        // 解析参数失败
    }
}
```

> 提示: 如果将请求参数是xml格式，xml参数也是保存在body中，处理方式类似，就是最后一步使用xml反序列化函数进行处理。