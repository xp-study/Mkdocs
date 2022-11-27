# nginx使用说明

## 参考文档

1. [死磕nginx系列-nginx日志配置](https://www.cnblogs.com/biglittleant/p/8979856.html)
2. [Nginx配置Json格式日志](https://www.cnblogs.com/cnskylee/p/11302219.html)
3. [编写Telegraf Input插件](https://www.jianshu.com/p/5694ff483ea6)
4. [在Ubuntu上快速安装单机版Kubernetes](https://segmentfault.com/a/1190000016144782)
5. [Kubernetes单机安装部署](https://www.cnblogs.com/edisonxiang/p/6911994.html)
6. [一键单机部署kubernetes，三分钟上手](http://www.zijin.net/news/tech/168846.html)

## nginx环境搭建

### nginx日志配置

#### access_log日志配置

#### log_format 定义日志格式

#### 常见的日志变量

* $remote_addr, $http_x_forwarded_for 记录客户端IP地址
* $remote_user记录客户端用户名称
* $request记录请求的URL和HTTP协议(GET,POST,DEL,等)
* $status记录请求状态
* $body_bytes_sent发送给客户端的字节数，不包括响应头的大小； 该变量与Apache模块mod_log_config里的“%B”参数兼容。
* $bytes_sent发送给客户端的总字节数。
* $connection连接的序列号。
* $connection_requests 当前通过一个连接获得的请求数量。
* $msec 日志写入时间。单位为秒，精度是毫秒。
* $pipe如果请求是通过HTTP流水线(pipelined)发送，pipe值为“p”，否则为“.”
* $http_referer 记录从哪个页面链接访问过来的
* $http_user_agent记录客户端浏览器相关信息
* $request_length请求的长度（包括请求行，请求头和请求正文）。
* $request_time 请求处理时间，单位为秒，精度毫秒； 从读入客户端的第一个字节开始，直到把最后一个字符发送给客户端后进行日志写入为止。
* $time_iso8601 ISO8601标准格式下的本地时间。
* $time_local通用日志格式下的本地时间。

#### open_log_file_cache

* max:设置缓存中的最大文件描述符数量，如果缓存被占满，采用LRU算法将描述符关闭。
* inactive:设置存活时间，默认是10s
* min_uses:设置在inactive时间段内，日志文件最少使用多少次后，该日志文件描述符记入缓存中，默认是1次
* valid:设置检查频率，默认60s
* off：禁用缓存
