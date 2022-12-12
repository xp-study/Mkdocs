# 1. Mysql使用

新建test数据库，person、place 表

```mysql
CREATE TABLE `person` (
    `user_id` int(11) NOT NULL AUTO_INCREMENT,
    `username` varchar(260) DEFAULT NULL,
    `sex` varchar(260) DEFAULT NULL,
    `email` varchar(260) DEFAULT NULL,
    PRIMARY KEY (`user_id`)
  ) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE place (
    country varchar(200),
    city varchar(200),
    telcode int
)ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
    mysql> desc person;
    +----------+--------------+------+-----+---------+----------------+
    | Field    | Type         | Null | Key | Default | Extra          |
    +----------+--------------+------+-----+---------+----------------+
    | user_id  | int(11)      | NO   | PRI | NULL    | auto_increment |
    | username | varchar(260) | YES  |     | NULL    |                |
    | sex      | varchar(260) | YES  |     | NULL    |                |
    | email    | varchar(260) | YES  |     | NULL    |                |
    +----------+--------------+------+-----+---------+----------------+
    4 rows in set (0.00 sec)

    mysql> desc place;
    +---------+--------------+------+-----+---------+-------+
    | Field   | Type         | Null | Key | Default | Extra |
    +---------+--------------+------+-----+---------+-------+
    | country | varchar(200) | YES  |     | NULL    |       |
    | city    | varchar(200) | YES  |     | NULL    |       |
    | telcode | int(11)      | YES  |     | NULL    |       |
    +---------+--------------+------+-----+---------+-------+
    3 rows in set (0.01 sec)
```

### 1.1.1. mysql使用

使用第三方开源的mysql库: github.com/go-sql-driver/mysql （mysql驱动） github.com/jmoiron/sqlx （基于mysql驱动的封装）

命令行输入 ：

```go
    go get github.com/go-sql-driver/mysql 
    go get github.com/jmoiron/sqlx
```

链接mysql

```go
    database, err := sqlx.Open("mysql", "root:XXXX@tcp(127.0.0.1:3306)/test")
    //database, err := sqlx.Open("数据库类型", "用户名:密码@tcp(地址:端口)/数据库名")
```