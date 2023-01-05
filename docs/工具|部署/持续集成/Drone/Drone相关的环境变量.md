Runner配置参数:

```shell
DRONE_DEBUG=true        // Enables debug level logging
DRONE_HTTP_BIND=:3000   // 监听端口, 不建议修改
DRONE_HTTP_HOST=runner.company.com:3000   // 默认为空字串,不建议修改
DRONE_HTTP_PROTO=http   // 默认为http,不建议修改

DRONE_RPC_DUMP_HTTP=true    // 调试专用,日志打印http请求的request and response
DRONE_RPC_DUMP_HTTP_BODY=true   // 调试专用
DRONE_RPC_HOST=drone.company.com:3333   // 定义连接Drone server的hostname
DRONE_RPC_PROTO=https     // 定义连接Drone server的协议
DRONE_RPC_SECRET=bea26a2221fd8090ea38720fc445eca6  // 请求认证密钥
DRONE_RPC_SKIP_VERIFY=false   // 停止连接Drone server的http requests的SSL验证(不安全,不建议修改)

DRONE_RUNNER_CAPACITY=10    // 限制并发pipelines的数量
DRONE_RUNNER_ENVIRON=foo:bar,baz:qux    // 设定全局环境变量(会inject到pipeline的每一step)
DRONE_RUNNER_LABELS       // todo
DRONE_RUNNER_MAX_PROCS=10   // 设定一个pipeline下多step并发数(默认禁止)

DRONE_SECRET_PLUGIN_ENDPOINT=http://1.2.3.4:3000   // 设定给外部Secret插件提供http请求的endpoint
DRONE_SECRET_PLUGIN_SKIP_VERIFY=false       // 停止插件http请求的ssl验证
DRONE_SECRET_PLUGIN_TOKEN=bea26a2221fd8090ea38720fc445eca6   // 设定插件请求的token

DRONE_TRACE=true          // 启动trace level logging.
DRONE_UI_DISABLE=true     // 禁止UI界面
DRONE_UI_USERNAME=root    // 设定UI界面用户名
DRONE_UI_PASSWORD=root    // 设定UI界面密码
DRONE_UI_REALM=DroneRealm // 设定基本的authentication realm
```

### pineline

```shell
CI=true         // 将当前环境标识为持续集成环境（Continuous Integration environment）
DRONE=true      // 将当前环境标识为Drone Continuous Integration environment.
DRONE_BRANCH=master     // 为push或pull请求提供目标分支
```

build相关:

```shell
// 提供触发管道的操作
DRONE_BUILD_ACTION=sync
DRONE_BUILD_ACTION=open

// build创建、结束、开始时的时间戳
DRONE_BUILD_CREATED=915148800
DRONE_BUILD_FINISHED=915148800
DRONE_BUILD_STARTED=915148800

// 触发管道执行的事件
DRONE_BUILD_EVENT=push
DRONE_BUILD_EVENT=pull_request
DRONE_BUILD_EVENT=promote
DRONE_BUILD_EVENT=rollback
DRONE_BUILD_EVENT=tag

// 运行的build数
DRONE_BUILD_NUMBER=42

// 指定父
DRONE_BUILD_PARENT=42

// build状态
DRONE_BUILD_STATUS=success
DRONE_BUILD_STATUS=failure
```

commit相关:

```shell
// 当前运行的git commit sha
DRONE_COMMIT=bcdd4bf0245c82c060407b3b24b9b87301d15ac1
DRONE_COMMIT_AFTER=bcdd4bf0245c82c060407b3b24b9b87301d15ac1
DRONE_COMMIT_BEFORE=bcdd4bf0245c82c060407b3b24b9b87301d15ac1
DRONE_COMMIT_SHA=bcdd4bf0245c82c060407b3b24b9b87301d15ac1


DRONE_COMMIT_BRANCH=master
DRONE_COMMIT_LINK=https://github.com/octocat/hello-world/pull/42
DRONE_COMMIT_MESSAGE=Updated README.md


// 最后一次提交的用户名(如:github的用户名)
DRONE_COMMIT_AUTHOR=octocat
DRONE_COMMIT_AUTHOR_AVATAR=https://githubusercontent.com/u/...
DRONE_COMMIT_AUTHOR_EMAIL=octocat@github.com
DRONE_COMMIT_AUTHOR_NAME=The Octocat
```

git地址相关:

```shell
// 指定部署环境
DRONE_DEPLOY_TO=production
// 当前运行的buid失败stage的列表
DRONE_FAILED_STAGES=build,test
// 失败的step
DRONE_FAILED_STEPS=backend,frontend
// git地址（git+http）
DRONE_GIT_HTTP_URL=https://github.com/octocat/hello-world.git
// git地址（git+ssh）
DRONE_GIT_SSH_URL=git@github.com:octocat/hello-world.git
// 当前运行的pull请求数
DRONE_PULL_REQUEST=42
// 只用于后台兼容用
DRONE_REMOTE_URL=https://github.com/octocat/hello-world.git
```

repo相关:

```shell
DRONE_REPO=octocat/hello-world      // repository名
DRONE_REPO_NAME=hello-world
DRONE_REPO_NAMESPACE=octocat

DRONE_REPO_OWNER=octocat
DRONE_REPO_PRIVATE=false

DRONE_REPO_BRANCH=master
DRONE_REPO_LINK=https://github.com/octocat/hello-world

// 版本控制名
DRONE_REPO_SCM=git
DRONE_REPO_SCM=hg
DRONE_REPO_SCM=svn

DRONE_REPO_VISIBILITY=public
DRONE_REPO_VISIBILITY=private
DRONE_REPO_VISIBILITY=internal
```

semver:

```shell
// If the git tag is a valid semver string, provides the tag as a semver string.
DRONE_SEMVER=1.2.3-alpha.1

DRONE_SEMVER_SHORT=1.2.3
DRONE_SEMVER_PATCH=3
DRONE_SEMVER_MINOR=2
DRONE_SEMVER_MAJOR=1
DRONE_SEMVER_PRERELEASE=alpha.1

DRONE_SEMVER_BUILD=001
DRONE_SEMVER=1.2.3+001

// If the git tag is not a valid semver string
// this variable provides the semver parsing error.
DRONE_SEMVER_ERROR=
```

stage:

```shell
DRONE_STAGE_ARCH=386
DRONE_STAGE_ARCH=amd64
DRONE_STAGE_ARCH=arm64
DRONE_STAGE_ARCH=arm

DRONE_STAGE_OS=darwin
DRONE_STAGE_OS=dragonfly
DRONE_STAGE_OS=freebsd
DRONE_STAGE_OS=linux
DRONE_STAGE_OS=netbsd
DRONE_STAGE_OS=openbsd
DRONE_STAGE_OS=solaris
DRONE_STAGE_OS=windows

DRONE_STAGE_STATUS=success
DRONE_STAGE_STATUS=failure

DRONE_STAGE_TYPE=docker
// arm下专用
DRONE_STAGE_VARIANT=v7


DRONE_STAGE_DEPENDS_ON=backend,frontend
DRONE_STAGE_FINISHED=915148800
DRONE_STAGE_STARTED=915148800

DRONE_STAGE_KIND=pipeline
// 运行机器的host
DRONE_STAGE_MACHINE=ec2-203-0-113-25.compute-1.amazonaws.com
DRONE_STAGE_NAME=build
```

其他:

```shell
DRONE_SOURCE_BRANCH

DRONE_SOURCE_BRANCH=feature/develop
DRONE_TARGET_BRANCH=master

DRONE_TAG=v1.0.0
DRONE_SYSTEM_VERSION=1.2.3
DRONE_SYSTEM_PROTO=https
DRONE_SYSTEM_HOSTNAME=cloud.drone.io
DRONE_SYSTEM_HOST=cloud.drone.io
DRONE_STEP_NUMBER=1
DRONE_STEP_NAME=build
```

### github

```shell
DRONE_GITHUB_SERVER=https://github.com \
DRONE_GITHUB_CLIENT_ID=${DRONE_GITHUB_CLIENT_ID} \
DRONE_GITHUB_CLIENT_SECRET=${DRONE_GITHUB_CLIENT_SECRET} \
DRONE_GIT_ALWAYS_AUTH=false

DRONE_RPC_SECRET=${DRONE_RPC_SECRET} \

DRONE_SERVER_HOST=${DRONE_SERVER_HOST} \
DRONE_SERVER_PROTO=${DRONE_SERVER_PROTO} \
```

### Drone Autoscaler

Log:

```shell
DRONE_LOGS_DEBUG=false
DRONE_LOGS_PRETTY=true
DRONE_LOGS_COLOR=true
```

Pool:

```shell
默认1h
DRONE_POOL_MIN_AGE=24h
DRONE_POOL_MIN_AGE=60m
DRONE_POOL_MIN_AGE=30m
DRONE_POOL_MIN_AGE=15m

DRONE_POOL_MIN=2
DRONE_POOL_MAX=4

DRONE_INTERVAL=1h
```

Agent:

```shell
DRONE_AGENTS_ENABLED=true \
DRONE_AGENT_VOLUMES=/path/on/host:/path/in/container
DRONE_AGENT_TOKEN=f5064039f5
DRONE_AGENT_IMAGE=drone/agent:1
DRONE_AGENT_ENV_FILE=/path/to/file.env
DRONE_AGENT_ENVIRON=foo:bar,baz:qux
DRONE_AGENT_CONCURRENCY=2
```

