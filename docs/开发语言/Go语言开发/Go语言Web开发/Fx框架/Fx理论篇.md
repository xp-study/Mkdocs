# 解析 Golang 依赖注入经典解决方案 uber/fx 理论篇

[fx](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fuber-go%2Ffx) 是 uber 2017 年开源的依赖注入解决方案，不仅仅支持常规的依赖注入，还支持生命周期管理。

从官方的视角看，fx 能为开发者提供的三大优势：

- 代码复用：方便开发者构建松耦合，可复用的组件；
- 消除全局状态：Fx 会帮我们维护好单例，无需借用 `init()` 函数或者全局变量来做这件事了；
- 经过多年 Uber 内部验证，足够可信。

我们从 uber-go/fx 看到的是 v1 的版本，fx 是遵循 SemVer 规范的，保障了兼容性，这一点大家可以放心。

从劣势的角度分析，其实 uber/fx 最大的劣势还是大量使用反射，导致项目启动阶段会需要一些性能消耗，但这一般是可以接受的。如果对性能有高要求，建议还是采取 wire 这类 codegen 的依赖注入解法。

目前市面上对 Fx 的介绍文章并不多，笔者在学习的时候也啃了很长时间官方文档，这一点有好有坏。的确，再多的例子，再多的介绍，也不如一份完善的官方文档更有力。但同时也给初学者带来较高的门槛。

今天这篇文章希望从一个开发者的角度，带大家理解 Fx 如何使用。

添加 fx 的依赖需要用下面的命令：

```go
go get go.uber.org/fx@v1
```

后面我们会有专门的一篇文章，拿一个实战项目来给大家展示，如何使用 Fx，大家同时也可以参考官方 README 中的 [Getting Started](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fuber-go%2Ffx%2Fblob%2Fmaster%2Fdocs%2Fget-started%2FREADME.md) 来熟悉。

下面一步一步来，我们先来看看 uber/fx 中的核心概念。

# provider 声明依赖关系

在我们的业务服务的声明周期中，对于各个 module 的初始化应该基于我们的 dependency graph 来合理进行。先初始化无外部依赖的对象，随后基于这些对象，初始化对它们有依赖的对象。

Provider 就是我们常说的构造器，能够提供对象的生成逻辑。在 Fx 启动时会创建一个容器，我们需要将业务的构造器传进来，作为 Provider。类似下面这样：

```go
app = fx.New(
   fx.Provide(newZapLogger),
   fx.Provide(newRedisClient),
   fx.Provide(newMeaningOfLifeCacheRedis),
   fx.Provide(newMeaningOfLifeHandler),
)
```

这里面的 newXXX 函数，就是我们的构造器，类似这样：

```go
func NewLogger() *log.Logger {
	logger := log.New(os.Stdout, "" /* prefix */, 0 /* flags */)
	logger.Print("Executing NewLogger.")
	return logger
}
```

我们只需要通过 `fx.Provide` 方法传入进容器，就完成了将对象提供出去的使命。随后 fx 会在需要的时候调用我们的 Provider，生成单例对象使用。

当然，构造器不光是这种没有入参的。还有一些对象是需要显式的传入依赖：

```go
func NewHandler(logger *log.Logger) (http.Handler, error) {
	logger.Print("Executing NewHandler.")
	return http.HandlerFunc(func(http.ResponseWriter, *http.Request) {
		logger.Print("Got a request.")
	}), nil
}
```

注意，这里返回的 http.Handler 也可以成为别人的依赖。

这些，我们通通不用关心！

fx 会自己通过反射，搞明白哪个 Provider 需要什么，能提供什么。构建出来整个 dependency graph。

```go
// Provide registers any number of constructor functions, teaching the
// application how to instantiate various types. The supplied constructor
// function(s) may depend on other types available in the application, must
// return one or more objects, and may return an error. For example:
//
//	// Constructs type *C, depends on *A and *B.
//	func(*A, *B) *C
//
//	// Constructs type *C, depends on *A and *B, and indicates failure by
//	// returning an error.
//	func(*A, *B) (*C, error)
//
//	// Constructs types *B and *C, depends on *A, and can fail.
//	func(*A) (*B, *C, error)
//
// The order in which constructors are provided doesn't matter, and passing
// multiple Provide options appends to the application's collection of
// constructors. Constructors are called only if one or more of their returned
// types are needed, and their results are cached for reuse (so instances of a
// type are effectively singletons within an application). Taken together,
// these properties make it perfectly reasonable to Provide a large number of
// constructors even if only a fraction of them are used.
//
// See the documentation of the In and Out types for advanced features,
// including optional parameters and named instances.
//
// Constructor functions should perform as little external interaction as
// possible, and should avoid spawning goroutines. Things like server listen
// loops, background timer loops, and background processing goroutines should
// instead be managed using Lifecycle callbacks.
func Provide(constructors ...interface{}) Option {
	return provideOption{
		Targets: constructors,
		Stack:   fxreflect.CallerStack(1, 0),
	}
}
```

作为开发者，我们只需要保证，所有我们需要的依赖，都通过 `fx.Provide` 函数提供即可。另外需要注意，虽然上面我们是每个 `fx.Provide`，都只包含一个构造器，实际上他是支持多个构造器的。

# module 模块化组织依赖

```go
// Module is a named group of zero or more fx.Options.
// A Module creates a scope in which certain operations are taken
// place. For more information, see [Decorate], [Replace], or [Invoke].
func Module(name string, opts ...Option) Option {
	mo := moduleOption{
		name:    name,
		options: opts,
	}
	return mo
}
```

fx 中的 module 也是经典的概念。实际上我们在进行软件开发时，分层分包是不可避免的。而 fx 也是基于模块化编程。使用 module 能够帮助我们更方便的管理依赖：

```go
// ProvideLogger to fx  
func ProvideLogger() *zap.SugaredLogger {  
logger, _ := zap.NewProduction()  
slogger := logger.Sugar()  
  
return slogger  
}  
  
// Module provided to fx  
var Module = fx.Options(  
fx.Provide(ProvideLogger),  
)
```

我们的 Module 是一个可导出的变量，包含了一组 fx.Option，这里包含了各个 Provider。

这样，我们就不必要在容器初始化时传入那么多 Provider 了，而是每个 Module 干好自己的事即可。

```go
func main() {  
    fx.New(  
        fx.Provide(http.NewServeMux),  
        fx.Invoke(server.New),  
        fx.Invoke(registerHooks),  
        loggerfx.Module,  
    ).Run()  
}
```

# lifecycle 给应用生命周期加上钩子

```go
// Lifecycle allows constructors to register callbacks that are executed on
// application start and stop. See the documentation for App for details on Fx
// applications' initialization, startup, and shutdown logic.
type Lifecycle interface {
	Append(Hook)
}


// A Hook is a pair of start and stop callbacks, either of which can be nil.
// If a Hook's OnStart callback isn't executed (because a previous OnStart
// failure short-circuited application startup), its OnStop callback won't be
// executed.
type Hook struct {
	OnStart func(context.Context) error
	OnStop  func(context.Context) error
}
```

lifecycle 是 Fx 定义的一个接口。我们可以对 fx.Lifecycle 进行 append 操作，增加钩子函数，这里就可以支持我们订阅一些指定行为，如 OnStart 和 OnStop。

如果执行某个 OnStart 钩子时出现错误，应用会立刻停止后续的 OnStart，并针对此前已经执行过 OnStart 的钩子执行对应的 OnStop 用于清理资源。

这里 fx 加上了 15 秒的超时限制，通过 context.Context 实现，大家记得控制好自己的钩子函数执行时间。

# invoker 应用的启动器

provider 是懒加载的，仅仅 Provide 出来我们的构造器，是不会当时就触发调用的，而 invoker 则能够直接触发业务提供的函数运行。并且支持传入一个 fx.Lifecycle 作为入参，业务可以在这里 append 自己想要的 hook。

假设我们有一个 http server，希望在 fx 应用启动的时候同步开启。这个时候就需要两个入参：

1. fx.Lifecycle
2. 我们的主依赖（通常是对服务接口的实现，一个 handler）

我们将这里的逻辑封装起来，就可以作为一个 invoker 让 Fx 来调用了。看下示例代码：

```go
func runHttpServer(lifecycle fx.Lifecycle, molHandler *MeaningOfLifeHandler) {
   lifecycle.Append(fx.Hook{OnStart: func(context.Context) error {
      r := fasthttprouter.New()
      r.Handle(http.MethodGet, "/what-is-the-meaning-of-life", molHandler.Handle)
      return fasthttp.ListenAndServe("localhost:8080", r.Handler)
   }})
}
```

下面我们将它加入 Fx 容器初始化的流程中：

```go
fx.New(
      fx.Provide(newZapLogger),
      fx.Provide(newRedisClient),
      fx.Provide(newMeaningOfLifeCacheRedis),
      fx.Provide(newMeaningOfLifeHandler),
      fx.Invoke(runHttpServer),
)
```

这样在创建容器时，我们的 `runHttpServer` 就会被调用，进而注册了服务启动的逻辑。这里我们需要一个 MeaningOfLifeHandler，Fx 会观察到这一点，进而到 Provider 里面挨个找依赖，每个类型对应一个单例对象，通过懒加载的方式获取到 MeaningOfLifeHandler 的所有依赖，以及子依赖。

其实 Invoker 更多意义上看，像是一个触发器。

我们可以有很多 Provider，但什么时候去调用这些函数，生成依赖呢？Invoker 就是做这件事的。

```go
// New creates and initializes an App, immediately executing any functions
// registered via Invoke options. See the documentation of the App struct for
// details on the application's initialization, startup, and shutdown logic.
func New(opts ...Option) *App
```

最后，有了一个通过 `fx.New` 生成的 fx 应用，我们就可以通过 `Start` 方法来启动了：

```go
func main() {
   ctx, cancel := context.WithCancel(context.Background())
   kill := make(chan os.Signal, 1)
   signal.Notify(kill)

   go func() {
      <-kill
      cancel()
   }()

   app := fx.New(
      fx.Provide(newZapLogger),
      fx.Provide(newRedisClient),
      fx.Provide(newMeaningOfLifeCacheRedis),
      fx.Provide(newMeaningOfLifeHandler),
      fx.Invoke(runHttpServer),
   )
   if err := app.Start(ctx);err != nil{
      fmt.Println(err)
   }
}
```

当然，有了一个 fx 应用后，我们可以直接 `fx.New().Run()` 来启动，也可以随后通过 `app.Start(ctx)` 方法启动，配合 ctx 的取消和超时能力。二者皆可。

# fx.In 封装多个入参

当构造函数参数过多的时候，我们可以使用 fx.In 来统一注入，而不用在构造器里一个个加参数：

```go
type ConstructorParam struct {
    fx.In

    Logger  *log.Logger
    Handler http.Handler

}

type Object struct {
    Logger  *log.Logger
    Handler http.Handler
}

func NewObject(p ConstructorParam) Object {
    return Object {
        Logger:  p.Logger,
        Handler: p.Handler,
    }
}
```

# fx.Out 封装多个出参

和 In 类似，有时候我们需要返回多个参数，这时候一个个写显然比较笨重。我们可以用 fx.Out 的能力用结构体来封装：

```go
type Result struct {
    fx.Out

    Logger  *log.Logger
    Handler http.Handler
}

func NewResult() Result {
    // logger := xxx
    // handler := xxx
    return Result {
        Logger:  logger,
        Handler: handler,
    }
}
```

# 基于同类型提供多种实现

> By default, Fx applications only allow one constructor for each type.

Fx 应用默认只允许每种类型存在一个构造器，这种限制在一些时候是很痛的。

有些时候我们就是会针对一个 interface 提供多种实现，如果做不到，我们就只能在外面套一个类型，这和前一篇文章中我们提到的 wire 里的处理方式是一样的：

```go
type RedisA *redis.Client
type RedisB *redis.Client
```

但这样还是很笨重，有没有比较优雅的解决方案呢？

当然有，要不 uber/fx 怎么能被称为一个功能全面的 DI 方案呢？

既然是同类型，多个不同的值，我们可以给不同的实现命名来区分。进而这涉及两个部分：生产端 和 消费端。

- 在提供依赖的时候，可以声明它的名称，进而即便出现同类型的其他依赖，fx 也知道如何区分。
- 在获取依赖的时候，也要指明我们需要的依赖的名称具体是什么，而不只是简单的明确类型即可。

这里我们需要用到 fx.In 和 fx.Out 的能力。参照 [官方文档](https://link.juejin.cn?target=https%3A%2F%2Fpkg.go.dev%2Fgo.uber.org%2Ffx%23hdr-Named_Values) 我们来了解一下 fx 的解法：Named Values。

fx 支持开发者声明 name 标签，用来给依赖「起名」，类似这样：`name:"rw"`。

```go
type GatewayParams struct {
  fx.In

  WriteToConn  *sql.DB `name:"rw"`
  ReadFromConn *sql.DB `name:"ro" optional:"true"`
}

func NewCommentGateway(p GatewayParams, log *log.Logger) (*CommentGateway, error) {
  if p.ReadFromConn == nil {
    log.Print("Warning: Using RW connection for reads")
    p.ReadFromConn = p.WriteToConn
  }
  // ...
}

type ConnectionResult struct {
  fx.Out

  ReadWrite *sql.DB `name:"rw"`
  ReadOnly  *sql.DB `name:"ro"`
}

func ConnectToDatabase(...) (ConnectionResult, error) {
  // ...
  return ConnectionResult{ReadWrite: rw, ReadOnly:  ro}, nil
}
```

这样 fx 就知道，我们去构建 `NewCommentGateway` 的时候，传入的 *sql.DB 需要是 rw 这个名称的。而此前`ConnectToDatabase` 已经提供了这个名称，同类型的实例，所以依赖构建成功。

使用起来非常简单，在我们对 In 和 Out 的 wrapper 中声明各个依赖的 name，也可以搭配 optional 标签使用。fx 支持任意多个 name 的实例。

这里需要注意，同名称的生产端和消费端的类型必须一致，不能一个是 sql.DB 另一个是 *sql.DB。命名的能力只有在同类型的情况下才有用处。

# Annotate 注解器

> Annotate lets you annotate a function's parameters and returns without you having to declare separate struct definitions for them.

注解器能帮我们修改函数的入参和出参，无需定义单独的结构体。fx 的这个能力非常强大，目前暂时没有看到其他 DI 工具能做到这一点。

```go
func Annotate(t interface{}, anns ...Annotation) interface{} {
	result := annotated{Target: t}
	for _, ann := range anns {
		if err := ann.apply(&result); err != nil {
			return annotationError{
				target: t,
				err:    err,
			}
		}
	}
	return result
}
```

我们来看看如何用 Annotate 来添加 ParamTag, ResultTag 来实现同一个 interface 多种实现。

```go
// Given,
type Doer interface{ ... }

// And three implementations,
type GoodDoer struct{ ... }
func NewGoodDoer() *GoodDoer

type BadDoer struct{ ... }
func NewBadDoer() *BadDoer

type UglyDoer struct{ ... }
func NewUglyDoer() *UglyDoer

fx.Provide(
  fx.Annotate(NewGoodDoer, fx.As(new(Doer)), fx.ResultTags(`name:"good"`)),
  fx.Annotate(NewBadDoer, fx.As(new(Doer)), fx.ResultTags(`name:"bad"`)),
  fx.Annotate(NewUglyDoer, fx.As(new(Doer)), fx.ResultTags(`name:"ugly"`)),
)
```

这里我们有 `Doer` 接口，以及对应的三种实现：`GoodDoer`, `BadDoer`, `UglyDoer`，三种实现的构造器返回值甚至都不需要是`Doer`，完全可以是自己的 struct 类型。

这里还是不得不感慨 fx 强大的装饰器能力。我们用一个简单的：

```go
fx.Annotate(NewGoodDoer, fx.As(new(Doer))) 
```

就可以对构造器 `NewGoodDoer` 完成类型转换。

这里还可以写一个 helper 函数简化一下处理：

```go
func AsDoer(f any, name string) any {
  return fx.Anntoate(f, fx.As(new(Doer)), fx.ResultTags("name:" + strconv.Quote(name)))
}

fx.Provide(
 AsDoer(NewGoodDoer, "good"),
 AsDoer(NewBadDoer, "bad"),
 AsDoer(NewUglyDoer, "ugly"),
)
```

与之相对的，提供依赖的时候我们用 ResultTag，消费依赖的时候需要用 ParamTag。

```go
func Do(good, bad, ugly Doer) {
  // ...
}

fx.Invoke(
  fx.Annotate(Do, fx.ParamTags(`name:"good"`, `name:"bad"`, `name:"ugly"`)),
)
```

这样就无需通过 fx.In 和 fx.Out 的封装能力来实现了，非常简洁。

当然，如果我们上面的返回值直接就是 interface，那么久不需要 `fx.As` 这一步转换了。

```go
func NewGateway(ro, rw *db.Conn) *Gateway { ... }
fx.Provide(
  fx.Annotate(
    NewGateway,
    fx.ParamTags(`name:"ro" optional:"true"`, `name:"rw"`),
    fx.ResultTags(`name:"foo"`),
  ),
)
```

和下面的实现是等价的：

```go
type params struct {
  fx.In

  RO *db.Conn `name:"ro" optional:"true"`
  RW *db.Conn `name:"rw"`
}

type result struct {
  fx.Out

  GW *Gateway `name:"foo"`
}

fx.Provide(func(p params) result {
   return result{GW: NewGateway(p.RO, p.RW)}
})
```

这里需要注意存在两个限制：

- Annotate 不能应用于包含 fx.In 和 fx.Out 的函数，它的存在本身就是为了简化；
- 不能在一个 Annotate 中多次使用同一个注解，比如下面这个例子会报错：

```go
fx.Provide(
  fx.Annotate(
    NewGateWay,
    fx.ParamTags(`name:"ro" optional:"true"`),
    fx.ParamTags(`name:"rw"), // ERROR: ParamTags was already used above
    fx.ResultTags(`name:"foo"`)
  )
)
```

# 小结

这里是 uber/fx 的理论篇，我们了解了 fx 的核心概念和基础用法。和 wire 一样，它们都要求强制编写构造函数，有额外的编码成本。但好处在于功能全面、设计比较优雅，对业务代码无侵入。