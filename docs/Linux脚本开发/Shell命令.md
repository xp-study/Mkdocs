### 参考文档

### 系统状态类命令

#### free命令

手动清理缓存的方法

```bash
echo 1 > /proc/sys/vm/drop_caches
echo 2 > /proc/sys/vm/drop_caches
echo 3 > /proc/sys/vm/drop_caches
```

#### top命令

top命令是Linux常用的性能分析工具，能够实时显示系统运行进程的各位状态，下面介绍一些常用的启动参数