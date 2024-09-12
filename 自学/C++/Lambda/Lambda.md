# Lambda

## 本质

Lambda 实际上是用一个类来表示 Lambda 函数，如下一个简单的 Lambda 函数：

```c++
int y, z;
const int a = 0, b = 0;
auto f = [y, &z, a, &b](int x) { z = x * y; };
```

会编译为：

```c++
class __lambda_7_12 // 这个类名是随机的，不能通过 decltype 获取并使用
{
  public: 
  inline /*constexpr */ void operator()(int x) const
  {
    z = (x * y);
  }
  
  private: 
  int y;
  int & z;
  const int a;
  const int & b;
  
  public:
  __lambda_7_12(int & _y, int & _z, const int & _a, const int & _b) : y{_y}, z{_z}, a{_a}, b{_b} {}
};
```

这样的话，在之后调用`f(x)`的时候，实际上是调用的`f.operator()(x)`。

## 捕获

捕获`[]`，就是把外部的局部变量存在 Lambda 类中进行调用。  
存在两种方式：

* 值捕获
* 引用捕获

如果捕获的`x`不是常量(const / constexpr)而是变量：

* 对于值捕获`[x]`: 相当于在类中创建了`int x`变量；  
* 对于引用捕获`[&x]`: 相当于在类中创建了`int &x`变量。

【如果捕获的`x`是常量的话，则相当于在类中创建的变量前加了个`const`（故此时限定了这些捕获变量完全不能修改。

---

两者还有一个主要区别：

* 值捕获: 捕获的值为在该 Lambda **定义前**最终的值（是一个快照），后面捕获的变量变化，Lambda 之中该变量的值不会变化。
* 引用捕获：捕获的值会为该 Lambda **调用时**具体的值（就是这个变量本身）。

如：

```c++
int x = 3, y = 3;
x = 4, y = 4;
auto f = [x, &y]() { std::cout << x << "," << y; }
x = 5, y = 5;

std::cout << f(); // 输出 4,5（而非 5,5）
```

因此引用捕获可能导致错误，因为实际调用时所捕获的变量可能被销毁了，如下情况：

```c++
auto gemerate_lambda = []()
{
    std::string x = "123";
    auto f = [&x]()
    { return x; };
    return f;
}; // 这个 Lambda 函数用来生成一个 Lambda 函数

auto lambda = gemerate_lambda();
cout << lambda(); // 出错：此时对于 [&x]() { return x; } 这个 Lambda， x 生命周期已经结束。
```

相比之下，值捕获更稳定，快照始终存在，因此**一般情况推荐使用值捕获**。

---

可以看到，对于“值捕获”，其会将值进行拷贝(`y{_y}`)；而“引用捕获”则只会传引用(`z{_z}`)。  
因此如果捕获的是一个复杂的对象，则**可利用引用捕获可以避免拷贝带来的消耗**。  
【但这样 Lambda 函数体可能会修改该对象的值，如果不希望这样的误操作，可以将外部对象设置为`const`。

## Mutable

上方提到，对于值捕获的变量不能修改，但有时候又需要进行修改，  
则可以使用`mutable`关键词。

```c++
int x = 0;
auto f = [x]() mutable
{
    x++; // 可以修改
    return x;
};
```

对应生成的类，即将`operator() const`这个常函数的`const`删去，变为普通成员函数，即为：

```c++
class __lambda_7_10
{
  public: 
  inline /*constexpr */ void operator()()
  {
    x++;
  }
  
  private: 
  int x;
  
  public:
  __lambda_7_10(int & _x)
  : x{_x}
  {}
  
};
```

但此时需要注意，修改的操作会进行存储（副作用会累计），  
即调用一次`f()`时，返回的是`1`；再调用一次，返回的则是`2`。

## 函数体

函数体对应生成的类中`operator()`函数，默认是“常函数”，  
故对于值捕获`[x]`，则不能进行修改（因为不能修改其对应的`int x`）。

但是对于引用捕获`[&x]`，其对应的“引用成员变量”`int &x`，即便是常函数也是可以修改的。  
【具体原因可见「[c++，const修饰的对象中引用类型为什么可以被修改，难道是因为其引用所绑定的变量不属于类的成员？](https://www.zhihu.com/question/520365632)或」「[Modifying reference member from const member function in C++](https://stackoverflow.com/questions/2431596/modifying-reference-member-from-const-member-function-in-c)」

故上方“本质”中的例子`z`是可以被修改的，即便按常理（特别是拥有`mutable`这个选项）来说不应该修改。  
【但是可以将外部变量变为`const`，如`const T b`，这样在 Lambda 函数体中就不能被修改了。

如：

```c++
class ComplexClass
{
    // ...
};


ComplexClass x;

const ComplexClass &x_wrapper = x;

auto f = [&x = x_wrapper]() {};
```

---

*参考于「[C++11 lambda表达式使用及解析](https://zhuanlan.zhihu.com/p/468616999)」*
