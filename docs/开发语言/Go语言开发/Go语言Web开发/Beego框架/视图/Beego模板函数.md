# Beego模板函数

## 1.beego内置模板函数

|   函数名    |                             说明                             |                        例子                        |
| :---------: | :----------------------------------------------------------: | :------------------------------------------------: |
| dateformat  |                实现了时间的格式化，返回字符串                | {{dateformat .Time "2006-01-02T15:04:05Z07:00"}}。 |
|    date     |              类似php的date函数，用于格式化时间               |            {{date .Time "Y-m-d H:i:s"}}            |
|   compare   |   实现了比较两个对象的比较，如果相同返回 true，否者 false    |                 {{compare .A .B}}                  |
|   substr    |                      实现了字符串的截取                      |                {{substr .Str 0 20}}                |
|  html2str   | 实现了把 html 转化为字符串，剔除一些 script、css 之类的元素  |               {{html2str .Htmlinfo}}               |
|  str2html   |         实现了把相应的字符串当作 HTML 来输出，不转义         |               {{str2html .Strhtml}}                |
|  htmlquote  |                  实现了基本的 html 字符转义                  |               {{htmlquote .content}}               |
| htmlunquote |                    实现了基本的反转移字符                    |              {{htmlunquote .content}}              |
| renderform  |              根据 StructTag 直接生成对应的表单               |           {{&structData \| renderform}}            |
|  assets_js  |               为 js 文件生成一个 <script> 标签               |               {{assets_js srcPath}}                |
| assets_css  |               为 css 文件生成一个 <link> 标签                |               {{assets_css srcPath}}               |
|   config    | 获取 AppConfig 的值, 用于读取配置文件信息， 可选的 configType 有 String, Bool, Int, Int64, Float, DIY |    {{config configType configKey defaultValue}}    |
|   urlfor    |                     获取控制器方法的 URL                     |          {{urlfor "UserController.Get"}}           |

## 2.自定义模板函数

除了使用beego提供的默认模板函数，我们也可以定义新的模板函数，下面是beego对html/template封装后定义模板函数的例子:

```go
// 定义模板函数, 自动在字符串后面加上标题
func demo(in string)(out string){
    out = in + " - 欢迎访问梯子教程"
    return
}

// 注册模板函数
web.AddFuncMap("helloFunc",demo)
```

下面是调用自定义模板函数例子:

```go
{{.title | helloFunc}}
```