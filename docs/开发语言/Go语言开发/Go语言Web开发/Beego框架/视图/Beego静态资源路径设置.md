# Beego静态资源路径设置

我们在使用beego开发项目的时候，除了html模板之外，往往还存在js/css/jpg之类的静态资源文件，beego如何处理这些静态文件呢？

下面例子介绍如何自定义静态资源路径和访问url

主要通过beego.SetStaticPath函数设置静态资源路由和目录

```go
// 通过 /images/资源路径  可以访问static/images目录的内容
// 例: /images/user/1.jpg 实际访问的是 static/images/user/1.jpg 
web.SetStaticPath("/images","static/images")

// 通过 /css/资源路径  可以访问static/css目录的内容
web.SetStaticPath("/css","static/css")

// 通过 /js/资源路径  可以访问static/js目录的内容
web.SetStaticPath("/js","static/js")
```

> 提示: 如果静态资源文件不存在，则返回404错误.