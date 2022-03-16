# Ep.2 类与对象

* 类：具有相同属性和行为的一组对象的集合。
* 抽象：对具体问题（对象）进行概括，抽出一类对象的公共性质并加以描述的过程。
  * 数据抽象：描述对象的属性，区别不同对象。
  * 代码抽象：描述对象的行为。
* 封装  
  把抽象得到的数据成员和代码成员相结合，成为一个有机整体。  
  C++中使用类(`class`)实现封装。
  * 组合：将一组相互关联的静态属性和动态方法组合在一起，构成一个对象。
  * 可访问性：对象内部的私有属性和方法对外不可见。  
    不仅可以实现私有成员的信息隐藏，还可以避免对象之间私有同名成员的干扰。
    * 隐藏：通过`private`和头文件(.h)实现。
    * 继承：通过`protected`实现。
    * 公开：通过`public`实现。
  * 交互性：对象必须可以接受外界消息并做出相应。  
    即设置接口，让对象至少包括一个外界可以访问的静态成员或动态成员。

> 区别 - 结构体`struct`与类`class`
>
> * `struct`默认的访问权限为`public`。
> * `class`默认的访问权限为`private`。

## 一、类的声明

```c++
class classStudent
{
//默认private
    int stuGrade;
 
public:
    int stuID;
    string stuName;

    classStudent() {}
    bool checkStuGrade() {}

private:
    void updateStuGrade() {}
};

int main()
{
    classStudent stu();
    stu.checkStuGrade();
    stu.updateStuGrade(); //非法
}
```
