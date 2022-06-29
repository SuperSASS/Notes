# Ep.5 模板

## 定义

函数模板、类模板。  
`template <typename/class T1, int T2, ...>`

* 模板参数表：就是上面模板中`<...>`的内容，是在定义时的各种“模板形参”。
* 模板函数实参表：是在调用模板函数时的`(...)`的内容，是调用时的各种“模板实参”。

> 解释 - 模板形参和模板实参：
>
> 在这里跟函数形参和函数实参的意义差不多，  
> 形参就是在定义时的表示，代表一种名字、代号；  
> 实参就是在调用时的表示，代表一种真实的参数。
>
> 在函数中区别可能不明显，但在模板中就有很大区别。
>
> * 模板形参：定义时的参数，如上面的`typename T`。
> * 模板实参：调用时的具体参数，分为显示和隐式
>   * 显示：如用`sum<int>(a)`，这里`<>`里的`int`就是显示模板实参，指定了第一个模板参数。
>   * 隐式：如用`double a[5]; sum(a);`，则隐式实参为`a`的类型`double`；`int a[5]; sum(a)`则实参为`int`。

模板参数表里面可以有两种参数：

* 虚拟类型参数：即`typename/class T1`，代表一种类型。  
  在这里的`typename`和`class`可以认为没区别，完全可以互相替换（注：有些标准下可能有区别，`typename`需要显示指定类型，即调用为`func<int>(a);`）（注注：实际区别见[这篇文章](https://blog.csdn.net/Function_Dou/article/details/84644963)）
* 常规参数：即`int T2`，代表一种参数（就像Verilog里的那种模块参数那样）

以上两个都可以跟函数参数一样，**带默认值**，如下：

```c++
template <int rows = 0, typename T = int, typename TResult = int>
TResult sum(T data[]) // 默认是int sum(int data[])，然后不执行累加，因为rows为0（其中data的类型跟模板实参保持一致，下面解释）
{
    T result = 0;
    for (int i = 0; i < rows; i++)
        result += data[i];
    return result;
}
```

但实际上对会出现在“模板函数实参表”的默认值几乎没有意义，  
因为只要调用了，都会变成模板实参的类型，如下：

```c++
int main()
{
    double d[5] = {1.1, 2.1, 3.1, 4.1, 5.1};
    cout << sum(d) << endl; // 因为“模板函数实参表”里的类型是double，所以调用的是"int sum(double data[])"而不是默认的"int sum(int data[])"
    // 输出：0
    cout << sum<3>(d) << endl; // 调用的是"int sum(double data[])"，然后for里是累加前3项
    // 输出：6
    cout << sum<4, double, double>(d) << endl; // 调用""double sum(double data[])"，累加前4项
    // 输出：10.4

    return 0;
}
```

因此第二个`typename T`放在中间其实没用，会自动跟随“模板函数实参表”里的模板实参类型，  
可以放在最后，这样在指定`TResult`的时候就不用指定`T`了。

## 省略情况

