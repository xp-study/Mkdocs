# 解决k8s命令tab不管用

* **暂时可以使用**

```shell
yum install -y bash-completion
source /usr/share/bash-completion/bash_completion
source  <(kubectl  completion  bash)
```



* **永久可以使用**

```shell
yum install -y bash-completion
source /usr/share/bash-completion/bash_completion
source  <(kubectl  completion  bash)

vim ~/.bashrc
#添加内容如下
source  <(kubectl  completion  bash)
#保存
source ~/.bashrc
```

```
apt install -y bash-completion
locate bash_completion
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)

```