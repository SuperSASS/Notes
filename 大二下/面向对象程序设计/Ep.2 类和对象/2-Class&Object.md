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
    //stu.updateStuGrade(); //非法 - 为private
}
```

## 二、类成员访问控制权限

类的成员抽象为“数据成员”和“函数成员”两种，  
分别描述问题的“属性”和“行为”。

类的数据成员与一般的变量相同，  
但区别在于可以控制访问权限。

权限如上所说，有三种：

1. `private` - 私有成员
2. `public` - 公有成员
3. `protected` - 受保护成员  
   与`private`差别在于继承的时候对衍生类影响不同。

## 三、类的成员函数定义

### 1. 内联模式与非内联模式

存在两种模式：

1. 内联模式：在类内声明和定义成员函数  
   此时函数自动声明为`inline`。
2. 非内联模式：类内声明成员函数、内外定义成员函数。  
   此时函数需要手动声明内联。

一般小型函数都采用第一种，大型函数采用第二种方法。

```cpp
//Student.h
#ifndef STUDENT_H
#define STUDENT_H
class Student
{
public:
  string stu_name;
  string stu_code;
private:
  double stu_score[3];

protected:
  int count_NoPass();
  double total_Score();
public:
  void set_stuInfo();
  bool is_better() { return score[1]>90 && score[2]>90 }; //内联模式，自动为inline
};
#endif
```

```c++
//Student.cpp
void Student::set_stuInfo()
{
  cin>>...;
}

inline bool Student::total_Score() // 需要手动加inline
{
  return score[1]+score[2];
}
```

### 2. 带默认值与重载

1. 默认值  
   在参数中直接附上值。  
   “警告”注意：带默认值的参数需要满足**从右至左连续性**！

   ```c++
   class A
   {
     int func(int a, int b, int c=1)
     {
       ...;
     }
   };
   ```

2. 重载  
   函数名相同，参数类型/个数/顺序不同。

## 四、对象

类定义后，只是一个概念，并不能直接使用。  
需要实例化为对象后才可访问。  
即像定义变量`int a`，用类定义个对象`Student stu`。

*【其他没什么难的，都会用.jpg*……
