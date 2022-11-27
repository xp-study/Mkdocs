# JavaBean规范

## 参考文档

1. [腾讯云博客-JavaBean是什么](https://cloud.tencent.com/developer/article/1458361)
2. [谈谈实现Serializable接口的作用和必要性](https://www.jianshu.com/p/4935a87976e5)

## JavaBean的介绍

JavaBean简单来讲就是一个普通的Java类，但是需要满足如下要求：

1. 必须使用`public`进行修饰
2. 必须具有一个无参的构造函数
3. 只能提供使用`private`修饰的成员变量，为成员变量提供公共(使用`public`修饰的方法)的getter和setter方法
4. 实现Serializable接口

!!! note "Serializable接口介绍"
    首先解释"序列化"和"反序列化"的概念，序列化是指把数据按照某种规律写到文档中；反序列化是指把写入的字节数据翻译出来，翻译成对应的对象再使用。以JSON举例而言，当把一个Java对象转换成一个JSON字符串存储到磁盘叫序列化，把JSON字符串重新转换成JAVA对象使用的过程就叫反序列化。序列化其实可以看成是一种机制，按照一定的格式将Java对象的某状态转成介质可接受的形式，以方便存储或传输。

    1. 提供一种简单又可扩展的对象保存恢复机制。
    2. 对于远程调用，能方便对对象进行编码和解码，就像实现对象直接传输。
    3. 可以将对象持久化到介质中，就像实现对象直接存储。
    4. 允许对象自定义外部存储的格式。

    Serializable接口属于标志接口，这个接口没有任何的方法定义，它仅仅只是标记某个类能被序列化和反序列化。

    那什么时候需要实现Serializable接口？

    如果一个对象需要进行网络传输或者持久化，那么该对象就需要实现Serializable接口，为了防止反序列失败，该对象需提供一个默认的serialVersionUID（该值在反序列化的时候会进行校验校验失败并抛出InvalidClassException异常）。

JavaBean对象示例：

```java
import java.io.Serializable;

public class Student implements Serializable {
    // 实现序列号接口
    private static final long serialVersionUID = 799887342985222720L;

    // 提供私有修饰的成员变量
    private String name;
    private int age;

    // 提供公共无参的构造
    public Student() {
    }

    // 为成员变量提供公共getter和setter方法
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }
}
```

## JavaBean的作用

在了解JavaBean的写法之后，我们更需要知道为什么要使用JavaBean呢？

JavaBean的主要作用是为开发者提供了一种便捷的封装数据的方式，可以理解为数据的容器。
