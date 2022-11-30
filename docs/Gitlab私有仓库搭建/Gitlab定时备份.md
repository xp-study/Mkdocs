## 一、准备工作

```shell
本地默认备份路径：/var/opt/gitlab/backups
gitlab备份命令：gitlab-rake gitlab:backup:create
gitlab恢复命令：gitlab-rake gitlab:backup:restore BACKUP=备份包名
gitlab备份配置修改：/etc/gitlab/gitlab.rb
```

## 二、修改gitlab配置参数

- 进入配置参数

```shell
vim /etc/gitlab/gitlab.rb
```

- 修改以下字段参数，保存退出。

```shell
gitlab_rails['manage_backup_path']=true
gitlab_rails['backup_path']="/var/opt/gitlab/backups" # gitlab备份目录
gitlab_rails['backup_archive_permissions']=0644 # 生成的备份文件权限
gitlab_rails['backup_keep_time'] = 315360000 # 备份保留天数，秒计算(十年)
```

## 三、更新使gitlab配置生效

```shell
gitlab-ctl reconfigure
```

## 四、使用命令 crontab -e，将定时任务添加后保存：crontab -e

- 我这里设置每天凌晨两点备份文件

```shell
crontab -e 
0 2 * * * /opt/gitlab/bin/gitlab-rake gitlab:backup:create
```

- 查看定时任务：`crontab -l`
- 设置`cron`服务开机使能：`systemctl enable crond.service`
- 修改后重启`cron`服务：`systemctl restart crond`