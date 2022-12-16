# Beego 模板入门教程

beego 的视图(view)模板引擎是基于Go原生的模板库（html/template）进行开发的，因此在开始编写view模板代码之前需要先学习下Go内置模板引擎的语法。

beego模板，默认支持 tpl 和 html 的后缀名。

## 1.基础例子

下面看个视图模板的例子。
模板文件: views/user/index.html

```go
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<h1>用户个人信息:</h1>
<p>
    {{ if ne .user nil}}
        用户名: {{.user.Username}} <br/>
        注册时间: {{.user.InitTime}}
    {{else}}
        用户不存在!
    {{end}}}
</p>
</body>
</html>
```

下面看控制器如何渲染这个模板文件。

```go
// 处理get请求
func (this *UserController) Get() {
    // 初始化，模板渲染需要的数据
	user := &User{1, "tizi365", time.Now()}
	
	// 通过Data， 将参数传入模板,  Data是map类型支持任意类型数据
	this.Data["user"] = user
	
	// 设置我们要渲染的模板路径， 也就是views目录下面的相对路径
	// 如果你不设置TplName，那么beego就按照 <控制器名字>/<方法名>.tpl 这种格式去查找模板文件。
	this.TplName = "user/index.html"
	
	// 如果你关闭了自动渲染，则需要手动调用渲染函数, beego 默认是开启自动渲染的
	// this.Render()
}
```

> 提示：在app.conf配置文件中配置AutoRender参数为true或者false,表示是否开启自动渲染。

## 2.模板标签冲突

默认情况，模板引擎使用 **{{ 模板表达式 }}** 作为模板标签，如果我们前端开发使用的是Vue、angular之类的框架，这些前端框架也是使用 **{{ 模板表达式 }}** 作为模板标签，这样就造成冲突了。

我们可以通过修改Go模板引擎的默认标签解决模板标签冲突问题。

例子:

```go
// 修改Go的模板标签
web.TemplateLeft = "<<<"
web.TemplateRight = ">>>"
```

修改后的模板表达式:

```go
<<<.user.username>>>
```