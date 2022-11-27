### 参考文档

1. [ubuntu安装最新版node和npm](https://www.jianshu.com/p/f2592d106aac)

### 开发环境介绍

* 操作系统：Ubuntu16.04-64bit

#### 安装node&npm

```bash
apt install nodejs-legacy
apt install npm
```

#### 切换node版本

在进行node版本切换之前需要先安装node版本管理模块[n](https://www.npmjs.com/package/n)

n是一个node.js版本管理工具，详见[使用帮助](https://www.npmjs.com/package/n#installingactivating-node-versions)

!!! note "注意事项"
    n版本工具暂时不支持Windows版本

```bash
# 注意必须通过-g选项安装到系统才能正常使用
npm install n -g

# 查询所有可用的node版本
n ls

# 查询node最新版本
n --latest

# 查询node最新LTS版本
n --lts

# 将node升级到最新版本
n latest

# 将node升级到最新的LTS版本 [推荐使用]
n lts

# 将node升级到指定版本(示例中的版本为v10.10.0，请根据实际情况指定版本)
n v10.10.0
```

#### 确认版本

**建议重启命令行终端后进行版本确认**

```bash
# 确定node是否安装正确版本
node -v

# 确定npm是否安装正确版本
npm -v
```

#### 安装cnpm

cnpm为国内镜像源，下载速度较快，推荐使用cnpm进行node依赖包安装

```bash
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

执行如下命令确定cnpm版本是否安装

```bash
cnpm -v
```
