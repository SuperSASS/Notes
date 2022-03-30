# Ep.2 算法效率分析

分为两类：

* 时间复杂度
* 空间复杂度

但空间复杂度目前关注度不再那么高，  
而重点关注时间复杂度。

## 一、时间效率

设输入的元素个数为$n$，执行该算法的第$i$步为$op_i$，该步骤的执行时间为$C_{op_i}$，该步骤执行的次数为$C_i(n)$，  
则该算法总执行时间为：
$$
T(n)=\sum_i C_{op_i}*C_i(n)
$$

> 例 - 线性：
>
> ```c++
> void calc()
> {
>   int a=1,b=0; // 1次
>   for (int i=1; i<=n; i++) //n次
>     for (int j=1; j<=i; j++) //n(n+1)/2次
>       b++; //n(n+1)/2次
> }
> ```
>
> $T(n)=C_1+C_2*i+C_3*\frac{n(n+1)}{2}+C_4*\frac{n(n+1)}{2}$
>
> ---
>
> 例 - 递归：
>
> ```c++
> int Hanoi(int n, int A, int B, int C)
> {
>   if (n==1) MoveOne(n,A,C); //C_1
>   else
>   {
>     Hanoi(n-1,A,C,B);
>     MoveOne(n,A,C); //C_1
>     Hanoi(n-1,B,A,C);
>   }
> }
> ```
>
> $T(1)=C_1$  
> $T(n)=2*T(n-1)+C_1$  
> 得：$T(n)=2*(2^n-1)*C_1$

## 二、渐进符号

由于对于$T(n)$的计算过于困难，同时每个步骤的执行时间$C_i$也不好确定，  
所以一般用渐进近似值来代替。

分别是：$O()$、$\Omega()$、$\Theta()$。  
三者都表示**函数的集合**。

### 1. Theta符号

> 定义 - $\Theta$符号
>
> 对于一个函数$g(n)$，存在三个常数$c1,c2,n_0$,  
> 使得：
> $$
> 0<c_1g(n)\le f(n)\le c_2g(n) (n\ge n_0)
> $$
>
> 则可以记：
> $$
> f(n)=\Theta(g(n))
> $$

其中的$g(n)$为一个多项式，  
如$g(n)=n^2+3n$，则可以记函数运行时间$T(n)$为$\Theta(n^2+3n)$。

确定一个$g(n)$后，三个常数可以任取，关键是要存在。

### 2. O函数

反应算法**最坏情况**下的时间（上界函数）。

对于一个函数$g(n)$，存在两个常数$c,n_0$,  
使得：
$$
0\le f(n) \le cg(n) (n\ge n_0)
$$

则：
$$
f(n)=O(g(n))
$$

### 3. Omega函数

反应算法**最好情况**下的时间（下界函数）。

对于一个函数$g(n)$，存在两个常数$c,n_0$,  
使得：
$$
0\le cg(n) \le f(n) (n\ge n_0)
$$

则：
$$
f(n)=\Omega(g(n))
$$

## 四、性质

1. 对于两函数$f(n),g(n)$，  
   只有在$f(n)=O(g(n))$且$f(n)=\Omega(g(n))$，  
   $f(n)=\Theta(g(n))$才成立。
2. 若$f_1(n)=O(g_1(n))$、$f_2(n)=O(g_2(n))$，  
   则$f_1(n)+f_2(n)=O(\max(g_1(n),g_2(n)))$。  
   同样对$\Theta,\Omega$适用。
3. 若$f_1(n)=O(g_1(n))$、$f_2(n)=O(g_2(n))$，  
   则$f_1(n)*f_2(n)=O(g_1(n)*g_2(n))$。  
   同样对$\Theta,\Omega$适用。
4. 还可以用极限来算：
   $$
   A=\lim_{n\to0}\frac{t(n)}{g(n)}
   $$

   * $A=0$：$O(g(n))=t(n)$
   * $A=C$：$\Theta(g(n))=t(n)$
   * $A=\infty$：$\Omega(g(n))=t(n)$

## 四、计算方法

假设一个基本函数形式，再确定参数。

---

对另一些递归式可以用该式求解。

$$
T(x)=\sum_{i=1}^{k} a_{i} T\left(b_{i} x+h_{i}(x)\right)+f(x) (\text { for } x \geq x_{0})
$$

满足：

* 所有的$i$，$a_i>0$，$0<b_i<1$（为真分数）。
* $|f(x)|\in O(x^c)$（$c$为常数）。  
  即$f(x)$要为$x^c$的形式。
* 所有的$i$，$|h_i(x)|\in O(\frac{x}{(\log x)^2})$。
* $x_0$为一个常数。  
  一般表述为：$T(n)$，$n$是一个很大的数。

则：
$$
T(n)=O(x^P(1+\int_1^x\frac{g(u)}{u^{P+1}}\textrm{d}u))
$$

其中$p$满足：
$$
\sum_{i=1}^ka_ib_i^P=1
$$

光看可能不懂，看下例：
> 例1：
> $$
> T(n)=\frac{7}{4} T\left(\frac{1}{2} n\right)+T\left(\frac{3}{4} n\right)+n^{2}, \text { for } n \geq 3
> $$
>
> 解：  
>
> 先解$P$：$\frac{7}{4}*(\frac{1}{2})^P+(\frac{3}{4})^P=1\Rightarrow P=2$  
> 然后直接套：
> $$
> \begin{aligned}
> T(n) & =O(x^2(1+\int_1^x\frac{n^2}{n^3}\textrm{d}u))\\
> & =O(x^2+x^2\ln x) \\
> & =O(x^2\log x)
> \end{aligned}
> $$
>
> ---
>
> 例2：
> $$
> T(n)=\frac{1}{4} T\left(\frac{3}{4} n\right)+\frac{3}{4} T\left(\frac{1}{4} n\right)+1
> $$
>
> 解：
> 先解$P$：$\frac{1}{4}*(\frac{3}{4})^P+\frac{3}{4}*(\frac{1}{4})^P=1\Rightarrow P=0$  
> 然后直接套：
> $$
> \begin{aligned}
> T(n) & =O(x^0(1+\int_1^x\frac{1}{n^1}\textrm{d}u))\\
> & =O(1+\ln x) \\
> & =O(\log x)
> \end{aligned}
> $$
