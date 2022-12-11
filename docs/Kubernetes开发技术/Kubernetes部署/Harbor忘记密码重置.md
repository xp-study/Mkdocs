# harbor忘记密码重置

### Harbor忘记密码，密码重置、密码修改 、admin密码重置

#### 一、找到harbor-db的容器，进入容器

```shell
docker exec -it harbor-db /bin/bash
```

#### 二、进入postgresql命令行

```shell
psql -h postgresql -d postgres -U postgres
```

默认密码`root123`

#### 三、切换到harbor所在的数据库

`\c registry`

```shell
postgres=# \c registry
You are now connected to database "registry" as user "postgres".
```

#### 四、查看harbor_user表

```shell
registry=# select * from harbor_user;
 user_id | username  | email |             password             |    realname    |    comment     | deleted | reset_uuid |               salt               | sysadmin_flag |       creatio
n_time        |        update_time         | password_version 
---------+-----------+-------+----------------------------------+----------------+----------------+---------+------------+----------------------------------+---------------+--------------
--------------+----------------------------+------------------
       2 | anonymous |       |                                  | anonymous user | anonymous user | t       |            |                                  | f             | 2022-03-02 09
:50:01.274432 | 2022-03-02 09:50:01.378737 | sha1
       1 | admin     |       | 2848dc68148add8626b1c45b2a83546d | system admin   | admin user     | f       |            | JTsJakoSdKXsdulCTUgdZMfFgqMUs4qL | t             | 2022-03-02 09
:50:01.274432 | 2022-03-02 10:04:26.87987  | sha256
(2 rows)
```

#### 五、重置密码

修改admin的密码，修改为初始化密码Harbor12345 ，修改好了之后登录web ui上再修改

```shell
registry=# update harbor_user set password='2848dc68148add8626b1c45b2a83546d', salt='JTsJakoSdKXsdulCTUgdZMfFgqMUs4qL' where username='admin';
UPDATE 1
```

