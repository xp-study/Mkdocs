## 为Ubuntu系统导入根证书

公司里面通常都会为了信息安全而要求个人电脑通过公司的根证书访问SSL加密的链接，如果系统里面没有根证书不管是浏览器还是需要访问SSL加密网络的系统命令都会出现证书相关错误。虽然这些证书错误都可以通过其他一些设置绕过去，但还是直接设置一下系统根证书更方便，一劳永逸（自己公司，忽略安全性）。
例如当系统缺失公司证书运行docker search centos命令可能会出现以下证书错误：
```shell
Error response from daemon: Get https://index.docker.io/v1/search...
```
curl到https网站可能会出现以下命令:
```shell
Peer certificate cannot be authenticated with known CA certificates
```
浏览器通常可以通过在相关设置中导入，windows下面可以直接双击后导入。所以这里只针对Linux操作系统。验证环境为Ubuntu16.04。

### 准备证书文件
导入的文件需要是pem格式(后缀通常为crt或者pem)，公司提供的通常是ca证书（后缀通常为cer），如果系统是公司已经安装好的操作系统，可以通过IE-设置(Internet Options)-内容(Content)-证书(Certificates)中找到受信任的根证书机构（Trusted Root Certification Authorities）中找到你的公司名字，选择导出后就可以被导出为ca证书了。如果是Firefox浏览器，可以直接导出为pem格式的证书，所以如果你不想使用下面的命令行，也可以将CA证书导入到Firefox之后再导出，Firefox支持ca证书的导入。
ca证书转为pem证书的命令如下：
```shell
openssl x509 -inform der -in /path/to/ca.cer -out /path/to/foo.crt
```
### 导入证书
1.  在目录/usr/share/ca-certificates创建一个存放自己额外证书的文件夹:
```shell
sudo mkdir /usr/share/ca-certificates/extra
```
2.  将pem证书拷贝到证书文件夹：
```shell
sudo cp foo.crt /usr/share/ca-certificates/extra/foo.crt
```
3.  运行以下命令将/usr/share/ca-Certificates文件夹下的.crt文件添加到证书配置文件/etc/ca-certificates.conf文件中：
```shell
sudo dpkg-reconfigure ca-certificates
```
该命令会让用户选择是否将刚才拷贝到extra子文件夹下的crt文件添加到配置文件，然后会自动使证书生效。
也可以直接手动在/etc/ca-certificates.conf文件中添加一行extra/foo.crt。然后运行以下命令更新系统根证书：
```shell
sudo update-ca-certificates
```
导入证书后那些在导入证书前就已经运行服务需要将相应服务重启后才能使用系统新证书，例如docker，当然可以直接重启下系统