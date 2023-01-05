# Kubernetes 集群部署 NFS 网络存储

# **一、搭建 NFS 服务器**

Kubernetes 对 Pod 进行调度时，以当时集群中各节点的可用资源作为主要依据，自动选择某一个可用的节点，并将 Pod 分配到该节点上。在这种情况下，Pod 中容器数据的持久化如果存储在所在节点的磁盘上，就会产生不可预知的问题，例如，当 Pod 出现故障，Kubernetes 重新调度之后，Pod 所在的新节点上，并不存在上一次 Pod 运行时所在节点上的数据。

为了使 Pod 在任何节点上都能够使用同一份持久化存储数据，我们需要使用网络存储的解决方案为 Pod 提供数据卷。常用的网络存储方案有：NFS/cephfs/glusterfs。

本文介绍一种使用 Ubuntu16.04 搭建 NFS 服务的方法。此方法仅用于测试&开发目的，请根据您生产环境的实际情况，选择合适的 NFS 服务。

## **2、配置要求** 

|     主机名     | 角色   | 操作系统    | 配置    | 描述                                     |
| :------------: | ------ | ----------- | ------- | ---------------------------------------- |
|  k8s-master1   | master | ubuntu16.04 | 4G-50G  | 运行etcd、kube-apiserver、kube-scheduler |
|   k8s-node1    | worker | ubuntu16.04 | 4G-50G  | 运行etcd、应用工作负载                   |
|   k8s-node2    | worker | ubuntu16.04 | 4G-50G  | 运行etcd、应用工作负载                   |
| k8s-nfs-server | nfs    | ubuntu16.04 | 2G-500G | 提供持久化存储,磁盘建议500G以上          |

## **3、配置NFS服务器** 

### **3.1、配置环境**

> 本文中所有命令都以 root 身份执行

### 3.2、安装nfs server（k8s-nfs-server主机）

```shell
$ sudo apt-get update
$ sudo apt-get install -y nfs-kernel-server
```

### 3.3配置nfs server

配置 nfs 目录和读写权限相关配置。

```ruby
$ mkdir -p /nfs/data
$ vim /etc/exports
```

将下列内容添加进最后一行：

```shell
# 输入以下内容(格式：FS共享的目录 NFS客户端地址1(参数1,参数2,...) 客户端地址2(参数1,参数2,...))
/nfs/data *(rw,sync,no_root_squash,no_subtree_check)
```

- 常用选项：
  - ro：客户端挂载后，其权限为只读，默认选项；
  - rw:读写权限；
  - sync：同时将数据写入到内存与硬盘中；
  - async：异步，优先将数据保存到内存，然后再写入硬盘；
  - Secure：要求请求源的端口小于1024
- 用户映射：
  - root_squash:当NFS客户端使用root用户访问时，映射到NFS服务器的匿名用户；
  - no_root_squash:当NFS客户端使用root用户访问时，映射到NFS服务器的root用户；
  - all_squash:全部用户都映射为服务器端的匿名用户；
  - anonuid=UID：将客户端登录用户映射为此处指定的用户uid；
  - anongid=GID：将客户端登录用户映射为此处指定的用户gi

### **3.4、设置开机启动并启动**

执行以下命令，启动 nfs 服务:

```shell
$ sudo /etc/init.d/rpcbind restart
$ sudo /etc/init.d/nfs-kernel-server restart
$ sudo systemctl enable nfs-kernel-server
```

### **3.5、查看是否有可用的NFS地址**

检查配置是否生效：

```shell
showmount -e 127.0.0.1
```

## **4、客户端配置** 

- 本章节中所有命令都以 root 身份执行
- 服务器端防火墙开放111、662、875、892、2049的 tcp / udp 允许，否则远端客户无法连接。

### **4.1、nfs-common**和rpcbind

```shell
sudo apt-get install -y nfs-common
```

### **4.2、创建挂载的文件夹**

```shell
mkdir -p /nfs-data
```

### **4.3、挂载nfs**

执行以下命令挂载 nfs 服务器上的共享目录到本机路径`/nfs-data`

```shell
mkdir /nfs-data
mount -t nfs -o nolock,vers=4 192.168.31.61:/nfs/data /nfs-data
```

- 参数解释：
  - mount：挂载命令
  - o：挂载选项
  - nfs :使用的协议
  - nolock :不阻塞
  - vers : 使用的NFS版本号
  - IP : NFS服务器的IP（NFS服务器运行在哪个系统上，就是哪个系统的IP）
  - /nfs/data: 要挂载的目录（Ubuntu的目录）
  - /nfs-data : 要挂载到的目录（开发板上的目录，注意挂载成功后，/mnt下原有数据将会被隐藏，无法找到）

查看挂载：

```shell
df -h
```

卸载挂载：

```shell
umount /nfs-data
```

检查 nfs 服务器端是否有设置共享目录

```shell
# showmount -e $(nfs服务器的IP)
showmount -e 172.16.106.205

# 输出结果如下所示
Export list for 172.16.106.205:
/nfs *
```

查看nfs版本

```shell
# 查看nfs服务端信息(服务端执行)
nfsstat -s

# 查看nfs客户端信息（客户端执行）
nfsstat -c
```

## **5、写入一个测试文件** 

```javascript
echo "hello nfs server" > /nfs-data/test.txt
```

在 nfs 服务器上执行以下命令，验证文件写入成功：

```javascript
cat /nfs/test.txt
```

# **二、部署 NFS Provisioner 提供动态分配卷**

# **1、NFS Provisioner 简介**

`NFS Provisioner`是一个自动配置卷程序，它使用现有的和已配置的 NFS 服务器来支持通过持久卷声明动态配置 Kubernetes 持久卷。

持久卷被配置为：namespace−{pvcName}-

# **2、创建 NFS 服务端**

本文是具体介绍如何部署 NFS 动态卷分配应用 “NFS Provisioner”，所以部署前请确认已经存在 NFS 服务端

这里 NFS 服务端环境为：

- IP地址：192.168.31.61
- 存储目录：/nfs/data

# **3、部署 NFS Provisioner**

## **3.1、创建 ServiceAccount** 

现在的 Kubernetes 集群大部分是基于 RBAC 的权限控制，所以创建一个一定权限的 ServiceAccount 与后面要创建的 “NFS Provisioner” 绑定，赋予一定的权限。

```yaml
kind: ServiceAccount
apiVersion: v1
metadata:
  name: nfs-client-provisioner
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: kube-system      #替换成你要部署NFS Provisioner的 Namespace
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: kube-system     #替换成你要部署NFS Provisioner的 Namespace
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io
```

创建 RBAC：

```shell
# -n: 指定应用部署的 Namespace
kubectl apply -f nfs-rbac.yaml -n kube-system 
```

## **3.2、部署 NFS Provisioner** 

创建 NFS Provisioner 部署文件，这里将其部署到 “kube-system” Namespace 中。

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nfs-client-provisioner
  labels:
    app: nfs-client-provisioner
spec:
  replicas: 1
  strategy:
    type: Recreate      #---设置升级策略为删除再创建(默认为滚动更新)
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: nfs-client     #--- nfs-provisioner的名称，以后设置的storageclass要和这个保持一致
            - name: NFS_SERVER
              value: 192.168.31.61  #---NFS服务器地址，和 valumes 保持一致
            - name: NFS_PATH
              value: /nfs/data      #---NFS服务器目录，和 valumes 保持一致
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.31.61    #---NFS服务器地址
            path: /nfs/data         #---NFS服务器目录
```

创建 NFS Provisioner：

```shell
# -n: 指定应用部署的 Namespace
kubectl apply -f nfs-provisioner-deploy.yaml -n kube-system 
```

## **3.3、创建 NFS SotageClass**

创建一个 StoageClass，声明 NFS 动态卷提供者名称为 “nfs-storage”。

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true" #---设置为默认的storageclass
provisioner: nfs-client    #---动态卷分配者名称，必须和上面创建的"provisioner"变量中设置的Name一致
parameters:
  archiveOnDelete: "true"  #---设置为"false"时删除PVC不会保留数据,"true"则保留数据
```

创建 StorageClass：

```shell
kubectl apply -f nfs-storage.yaml
```

## **3.4、创建 PVC 和 Pod 进行测试** 

### **3.4.1、创建测试 PVC**

在 Namespace 下创建一个测试用的 PVC 并观察是否自动创建是 PV 与其绑定。

```ya
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-pvc
spec:
  storageClassName: nfs-storage #---需要与上面创建的storageclass的名称一致
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Mi
```

创建 PVC：

```shell
kubectl create namespace nfs
# -n：指定创建 PVC 的 Namespace
kubectl apply -f test-pvc.yaml -n nfs
```

查看 PVC 状态是否与 PV 绑定 利用 Kubectl 命令获取 pvc 资源，查看 STATUS 状态是否为 “Bound”。

```shell
$ kubectl get pvc test-pvc -n nfs
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
test-pvc   Bound    pvc-105a5f32-e4dd-4b1d-943b-c4f2ca498f60   1Mi        RWO            nfs-storage-new   45m
```

### **3.4.2、创建测试 Pod 并绑定 PVC**

创建一个测试用的 Pod，指定存储为上面创建的 PVC，然后创建一个文件在挂载的 PVC 目录中，然后进入 NFS 服务器下查看该文件是否存入其中。

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: test-pod
spec:
  containers:
  - name: test-pod
    image: busybox:latest
    command:
      - "/bin/sh"
    args:
      - "-c"
      - "touch /mnt/SUCCESS && exit 0 || exit 1"  #创建一个名称为"SUCCESS"的文件
    volumeMounts:
      - name: nfs-pvc
        mountPath: "/mnt"
  restartPolicy: "Never"
  volumes:
    - name: nfs-pvc
      persistentVolumeClaim:
        claimName: test-pvc
```

创建 Pod：

```shell
# -n：指定创建 Pod 的 Namespace
kubectl apply -f test-pod.yaml -n nfs
# 注意所有的k8s 工作节点都需要安装 nfs-common
# 若pod一直处于containercreating，可使用 kubectl describe pod 排查错误
```

# **4、进入 NFS 服务器验证是否创建对应文件**

进入 NFS 服务器的 NFS 挂载目录，查看是否存在 Pod 中创建的文件：

```shell
$ cd /nfs/data/
$ ls -l
total 0
drwxrwxrwx 2 root root 21 Aug 24 15:14 kube-public-test-pvc-pvc-105a5f32-e4dd-4b1d-943b-c4f2ca498f60

$ cd kube-public-test-pvc-pvc-105a5f32-e4dd-4b1d-943b-c4f2ca498f60/
$ ls -l
total 0
-rw-r--r-- 1 root root 0 Aug 24 15:14 SUCCESS
```

可以看到已经生成 SUCCESS 该文件，并且可知通过 NFS Provisioner 创建的目录命名方式为`“namespace名称-pvc名称-pv名称”`，pv 名称是随机字符串，所以每次只要不删除 PVC，那么 Kubernetes 中的与存储绑定将不会丢失，要是删除 PVC 也就意味着删除了绑定的文件夹，下次就算重新创建相同名称的 PVC，生成的文件夹名称也不会一致，因为 PV 名是随机生成的字符串，而文件夹命名又跟 PV 有关,所以**删除 PVC 需谨慎**。