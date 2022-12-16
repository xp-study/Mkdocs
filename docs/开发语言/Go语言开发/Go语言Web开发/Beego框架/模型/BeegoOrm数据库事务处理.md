# Beego orm数据库事务处理

通常在一些订单交易业务都会涉及多个表的更新/插入操作，这个时候就需要数据库事务处理了，下面介绍beego orm如何处理mysql事务。

## 手动处理事务

```go
// 创建orm对象
o := orm.NewOrm()

//  开始事务
tx, err := o.Begin()

// 开始执行各种sql语句，更新数据库，这里可以使用beego orm支持任何一种方式操作数据库

// 例如,更新订单状态
_, err1 := tx.QueryTable("orders").Filter("Id", 1001).Update(orm.Params{
		"Status": "SUCCESS",
	})

// 给用户加积分
_, err2 := tx.Raw("update users set points = points + ? where username=?", "tizi365", 100).Exec()

// 检测事务执行状态
if err1 != nil || err2 != nil {
	// 如果执行失败，回滚事务
	tx.Rollback()
} else {
	// 任务执行成功，提交事务
	tx.Commit()
}
```

## 自动处理事务

在一个闭包函数内执行事务处理，如果函数返回error则回滚事务。

```go
// 创建orm对象
o := orm.NewOrm()
// 在闭包内执行事务处理
err := o.DoTx(func(ctx context.Context, txOrm orm.TxOrmer) error {
    // 准备数据
    user := new(User)
    user.Name = "test_transaction"

    // 插入数据
    // 使用txOrm执行SQL
    _, e := txOrm.Insert(user)
    return e
})
```