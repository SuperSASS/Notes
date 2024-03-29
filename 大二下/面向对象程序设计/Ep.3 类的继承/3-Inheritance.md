# 第三节 类的继承

子类具有父类的一些特征。

## 一、继承和派生

* 继承：新类从已有类获取已有类的特征。
* 派生：已有类产生新类的过程。

类根据继承状态分为一般类（父类、基类）和特殊类（子类、派生类）

* 特殊类对象具有一般类对象的全部属性和行为，为继承。
* 特殊类对象相对于一般类对象有自己的新特性，为派生。

父类即一般性的抽象化的类，子类则为特殊的具体化的类。

> e.g.
>
> * 父类：学校员工；子类：教师、后勤人员、管理人员……
> * 父类：大学学生；子类：本科生、研究生……

派生类同样可以作为基类，形成新的派生类。

**特点：**

* 形成了层次结构
* 子类继承父类的属性和方法。

**优点：**

* 父类的属性和方法可以用于子类
* 轻松地定义子类
* 代码具有可重用性
* 代码的开发更简单。

> 区别 - 与封闭类的区别：
>
> * 封闭类：has a
> * 派生类：is a

## 二、语法实现

```c++
//class "子类名称":"继承方式" "父类名称"(, "多个父类")
class son1:public father1
{
  ...
}
class son2:public father1, private father2
{
  ...
}
class son_of_son: son2//默认 private son2
{
  ...
}
```

继承个数：

* 单继承：一个派生类只有一个基类的情况。
* 多继承：一个派生类同时有多个基类。

多层继承形成“类族”。

继承方式：

* 公有继承
* 保护继承
* 私有继承（默认）

## 三、生成过程

1. 吸收基类成员
2. 改造基类成员
3. 添加新的成员

继承和派生机制，主要目的是实现代码的**重用和扩充**。  
上面第一步则为重用，第二步则为扩充。

### 1. 吸收基类成员

成员（属性和方法）全部吸收。  
注意：构造和析构函数不吸收。

### 2. 改造基类成员

两个方面：

* 基类成员的**访问控制**问题。
* 对基类数据或函数成员的**覆盖**。  
  若声明一个与基类成员同名的新成员，则会覆盖。

### 3. 添加新的成员

派生类诞生的目的就是与基类相比有新的成员【*如果完全一样为什么不用基类呢.jpg……*

因此需要根据实际需要，适当添加所需的新成员。  
同时还要添加自身的构造析构函数。

## 四、继承方式（访问属性）

规定如何访问从基类继承的成员。  
即设定了派生类成员以及类外对象，**对于**基类**继承来的成员如何访问**。
*派生类成员：派生类自己特有的（新定义）的成员。*

### 1. 三种继承方式

* 公有继承`public`
  * 基类 - 公有成员 → 派生类 - 公有成员
  * 基类 - 保护成员 → 派生类 - 保护成员
  * 基类 - 私有成员 → 派生类 - *不可访问*

  ```c++
  class Employee
  {
  protected:
    string m_ID;
    void setInfo();
  private:
    string m_Name;
    int m_Age;
  public:
    void retire();
  }

  class Worker: public Employee
  {
  private:
    string Level;
  public:
    void salary();

  //继承的基类成员相当于：
  //protected:
  //  string m_ID;
  //  void setInfo();
  //public:
  //  void retire();
  }
  ```

* 保护继承`protect`
  * 基类 - 公有成员 → 派生类 - 保护成员
  * 基类 - 保护成员 → 派生类 - 保护成员
  * 基类 - 私有成员 → 派生类 - *不可访问*
* 私有继承`private`（默认方式）
  * 基类 - 公有成员 → 派生类 - 私有成员
  * 基类 - 保护成员 → 派生类 - 私有成员
  * 基类 - 私有成员 → 派生类 - *不可访问*

### 2. 私有继承与聚合

派生类私有继承基类，一般是为了“使用基类的功能来实现它自己的功能”，  
相当于聚合，形成一个“封闭类”。

```c++
class engine
{
private:
  int gang;
public:
  void OnFire();
  void OffFire();
}

//Enclosing Class - 封闭类
class car1
{
private:
  engine e;
public:
  void Start() { e.Onfire(); }
}

//私有继承基类，相当于聚合、形成封闭类
class car2: private engine
{
public:
  void Start() { e.Onfire(); }
}
```
