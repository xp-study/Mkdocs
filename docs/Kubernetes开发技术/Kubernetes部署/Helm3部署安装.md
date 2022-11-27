一、新的功能
    1.版本以新格式存储

    2.没有群集内（tiller）组件

    3.Helm 3包括对新版Helm图表的支持（图表v2）

    4.Helm 3还支持库图表-图表主要用作其他图表的资源。

    5.用于在OCI注册表中存储Helm图表的实验支持（例如Docker Distribution）可以进行测试。

    6.现在在升级Kubernetes资源时将应用3向战略合并补丁。

    7.现在可以根据JSON模式验证图表提供的值

    8.为了使Helm更安全，可用和健壮，已进行了许多小的改进。

二、 Helm3的内部实现已从 Helm2发生了很大变化，使其与 Helm2不兼容该版本主要变化如下

1、最明显的变化是 Tiller的删除

2、Release 不再是全局资源，而是存储在各自命名空间内

3、Values 支持 JSON Schema校验器，自动检查所有输入的变量格式

4、移除了用于本地临时搭建 Chart Repository 的 helm serve 命令。

5、helm install 不再默认生成一个 Release 的名称，除非指定了 --generate-name。

6、Helm CLI 个别更名

```shell
helm delete更名为 helm uninstall
helm inspect更名为 helm show
helm fetch更名为 helm pull
```
但以上旧的命令当前仍能使用。

三、先决条件

要成功且正确地确保使用Helm，必须满足以下先决条件。

1.  Kubernetes集群
2.  确定要应用于安装的安全性配置（如果有）
3.  安装和配置Helm。

四、安装Kubernetes或有权访问集群
* 必须安装Kubernetes。对于Helm的最新版本，我们建议使用Kubernetes的最新稳定版本，在大多数情况下，它是第二最新的次要版本。
* 还应该具有的本地配置副本kubectl。
注意：1.6之前的Kubernetes版本对基于角色的访问控制（RBAC）的支持有限或不支持。

五、 使用二进制版本安装
每一个[版本](https://github.com/helm/helm/releases)
helm提供多种操作系统的二进制版本。这些二进制版本可以手动下载和安装。

1.  下载[所需版本]
https://github.com/helm/helm/releases
2. 打开包装
```shell
tar -zxvf helm-v3.0.0-linux-amd64.tgz
```
3.  helm在解压后的目录中找到二进制文件，然后将其移至所需的目标位置
```shell
mv linux-amd64/helm /usr/local/bin/helm
```
4. 在客户端运行：
```shell
helm help
```
5.配置国内Chart仓库
微软仓库（http://mirror.azure.cn/kubernetes/charts/） 这个仓库强烈推荐，基本上官网有的chart这里都有。

阿里云仓库（https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts ）

官方仓库（https://hub.kubeapps.com/charts/incubator） 官方chart仓库，国内有点不好使
6. 添加存储库：
```shell
helm repo add stable http://mirror.azure.cn/kubernetes/charts
helm repo add aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
helm repo update
```
7.查看配置的存储库：
```shell
helm repo list
helm search repo stable
```
一直在stable存储库中安装charts，你可以配置其他存储库。
8.删除存储库：
```shell
helm repo remove aliyu
```