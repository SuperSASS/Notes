# CGAL

## 基础知识

### 1. 仿函数 functor

优点：

* 相比普通函数，functor 内部可以**保存状态**（如统计调用次数）
* 相比函数指针，可能会被编译器优化（内联）

### 2. traits, concept, model

...

### 3. CRTP - 编译期多态

在编译期解决多态问题。  
而不用虚函数（运行期解决，会带来开销）。

是 C++ 设计模式

```c++
template <class T>
class Shape
{
public:
    void baseDraw()
    {
        return static_cast<T *>(this)->Draw();
    }
}；

class Triangle : public Shape<Triangle>
{
public:
    void Drwa() { ... }
}

int main()
{
    Shape* s = new Triangle();
    s->baseDraw(); // 调用 Triangle::Draw
}
```

## 目标与实现

* Q1: Adaptable and extensible  
  模板编程
* Q2: 可靠性  
  精确构造、精确运算。且自确定。
* Q3: 效率  
  CRTP

## 框架

* Kernel  
  收集各种类型、操作
* Kernel 的各种类型、操作在别的文件里实现。  
  为了获取当前可用类型，也要传入`Kernel`模板