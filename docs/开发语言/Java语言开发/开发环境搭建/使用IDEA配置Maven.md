# 使用IntelliJ IDEA 配置Maven

**1. 下载Maven**

官方地址：`https://maven.apache.org/download.cgi` 

![image-20221124181924045](./assets/使用IDEA配置Maven/1.png)

解压并新建一个本地仓库文件夹

![image-20221124182318329](./assets/使用IDEA配置Maven/2.png)

**2.配置maven**

配置jar包下载路径，路径指向自己的。

```shell
<localRepository>/opt/maven/repo</localRepository>
```



![image-20221124182509704](./assets/使用IDEA配置Maven/3.png)

![image-20221124182550053](./assets/使用IDEA配置Maven/4.png)

配置阿里镜像加速，默认是从中央仓库拉取。

```shell
<mirrors>
 <mirror>
   <id>alimaven</id>
   <name>aliyun maven</name>
   <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
   <mirrorOf>central</mirrorOf>        
 </mirror>
</mirrors>
```

![image-20221124182927411](./assets/使用IDEA配置Maven/5.png)

**3.配置maven环境变量**

![image-20221124183050001](./assets/使用IDEA配置Maven/6.png)

![image-20221124183128809](./assets/使用IDEA配置Maven/7.png)

![image-20221124183228945](./assets/使用IDEA配置Maven/8.png)

**4.在IntelliJ IDEA中配置maven**

打开-File-Settings，按照下图方式配置

![image-20221124183438912](./assets/使用IDEA配置Maven/9.png)