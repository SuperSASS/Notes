# Ep.2 算法效率分析

分为两类：

* 时间复杂度
* 空间复杂度

但空间复杂度目前关注度不再那么高，  
而重点关注时间复杂度。

## 一、时间效率T(n)

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

## 二、渐进符号（界函数）

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
> 0<c_1g(n)\le f(n)\le c_2g(n)\qquad(n\ge n_0)
> $$
>
> 则可以记：
> $$
> f(n)=\Theta(g(n))
> $$

其中的$g(n)$为一个多项式，  
如$g(n)=n^2+3n$，则可以记函数运行时间$T(n)$为$\Theta(n^2+3n)$。

确定一个$g(n)$后，三个常数可以任取，关键是要存在。

### 2. O符号

> 定义 - $O$符号：
>
> 对于一个函数$g(n)$，存在两个常数$c,n_0$,  
> 使得：
> $$
> 0\le f(n) \le cg(n) (n\ge n_0)
> $$
>
> 则：
> $$
> f(n)=O(g(n))
> $$

反应算法**最坏情况**下的时间（上界函数）。

对于$O(g(n))$中的$g(n)$，习惯上以**最小的单位项**表示，  
最小指函数最接近$f(n)$（即同阶），单位项指只有一项且系数为一。
> 对于$f(n)=3n^3+n^2+6$，则通常记$f(n)=O(n^3)$，  
> 而不是$f(n)=O(n^4)$或$f(n)=O(2n^3)$（虽然这两个完全没错）。

可以证明若找到$f(n)=\Theta(g(n))$，则$g(n)$为上面所说的最小单位项，  
即$f(n)=\Theta(g(n))\Rightarrow f(n)=O(g(n))$。

### 3. Omega符号

> 定义 - $\Omega$符号：
>
> 对于一个函数$g(n)$，存在两个常数$c,n_0$,  
> 使得：
> $$
> 0\le cg(n) \le f(n) (n\ge n_0)
> $$
>
> 则：
> $$
> f(n)=\Omega(g(n))
> $$

反应算法**最好情况**下的时间（下界函数）。

## 四、渐进符号性质

一般来说对于渐进函数的求解不用定义计算，而是通过下面的几条性质求得。

1. **加法性质**：  
   > 若$f_1(n)=O(g_1(n))$、$f_2(n)=O(g_2(n))$，  
   > 则：
   > $$
   > f_1(n)+f_2(n)=O(\max(g_1(n),g_2(n)))
   > $$
   >
   > 同样对$\Theta,\Omega$适用。

   说明：两个时间复杂度的函数相加时，主要的贡献来自于**变化最显著**的那部分。
2. **乘法性质**：  
   > 若$f_1(n)=O(g_1(n))$、$f_2(n)=O(g_2(n))$，  
   > 则：
   > $$
   > f_1(n)*f_2(n)=O(g_1(n)*g_2(n))
   > $$
   >
   > 同样对$\Theta,\Omega$适用。

   说明：两个时间复杂度的函数相乘时，各自贡献各自的阶，结果就是**二者阶的乘积**。
3. 对于两函数$f(n),g(n)$，  
   只有在$f(n)=O(g(n))$且$f(n)=\Omega(g(n))$，  
   $f(n)=\Theta(g(n))$才成立。  
   （也就是说$g(n)$既可以作为$f(n)$的上界，也可以作为$f(n)$下界，此时证明同阶）
4. 两函数变化显著的判断方法，可以采用极限比值法：
   $$
   A=\lim_{n\to\infty}\frac{f(n)}{g(n)}
   $$

   * $A=0 \qquad\Rightarrow\qquad f(n)=O(g(n))$  
     $g(n)$变化更显著，是$f(n)$的上界。
   * $A=C\qquad\Rightarrow\qquad f(n)=\Theta(g(n))$  
     $f(n)$与$g(n)$同阶，所以可以互相作为上下界。【此时也可写作$f(n)=O(g(n))$
   * $A=\infty\qquad\Rightarrow\qquad f(n)=\Omega(g(n))$  
     $f(n)$变化更显著，$g(n)$为其下界。

   故看$f(n)=O(g(n))$对不对，则判断$\lim_{n\to\infty}\frac{f(n)}{g(n)}$是否为$0$或常数。
5. 根据换底公式，$\log_a(n)=O(\log_2(n))$，  
   故用渐进时间复杂度时，对数的底数不写（默认为$2$）。【[来自OI-Wiki](https://oi-wiki.org/basic/complexity/#_7)】  
   *但注意指数的底数不能省略，$O(3^n)$就是$O(3^n)$。*

## 四、计算方法

给出时间效率$T(n)$与之前项$T(n-k)$的关系式，求解$T(n)$。

### 1. 直接法

将递推公式直接展开。

$$
\begin{aligned}
T(n) &=n+T(n-1) \\
&=n+(n-1)+T(n-2) \\
&=n+(n-1)+(n-2)+\cdots \cdot+2+1+T(0) \\
&=n+(n-1)+(n-2)+\cdots \cdot+2+1+0 \\
&=\frac{1}{2} n(n+1) \\
&=O\left(n^{2}\right)
\end{aligned}
$$

### 2. 估值法

假设一个基本函数形式，再确定参数。

若$T(n)=T(n-1)+T(n-2)$，其中$T(0)=0，T(1)=1$  
则可设：$T(n)=c^n$

$$
\begin{aligned}
c^{n} &=c^{n-1}+c^{n-2} \\
c^{2} &=c+1 \\
c^{2}-c-1 &=0 \\
c_{1,2} &=\frac{1}{2} \pm \sqrt{\left(\frac{1}{2}\right)^{2}+1}
\end{aligned}
$$

得：
$$\left\{\begin{array}{l}
c_{1}=\frac{1}{2}(1+\sqrt{5}) \\
c_{2}=\frac{1}{2}(1-\sqrt{5})
\end{array}\right.
$$

再设$T(n)=a\cdot c_1^n+b\cdot c_2^n$  
则：
$$
\left\{\begin{array}{l}
0=a+b &(n=0)\\
1=\frac{a}{2}(1+\sqrt{5})+\frac{b}{2}(1-\sqrt{5})&(n=1)
\end{array}\right.
$$

解得：
$$
\left\{\begin{array}{l}
a=+\frac{1}{5} \sqrt{5} \\
b=-\frac{1}{5} \sqrt{5}
\end{array}\right.
$$

最终可得：
$$
T(n)=\frac{1}{5} \sqrt{5}\left[\left(\frac{1+\sqrt{5}}{2}\right)^{n}-\left(\frac{1-\sqrt{5}}{2}\right)^{n}\right]=O(2^n)
$$

### 3. 公式法

#### (1) Master theorem - 主定理

针对一些递归算法的快速求解方法。

形如以下表达式的时间复杂度可用公式求解：
$$
T(n)=a\cdot T(\frac{n}{b}) + O(n^d)
$$
其中$a\ge1, b>1, d\ge0$（$\Theta(n^d)$代表形如$n^d$一类的式子）。

则存在以下定理：
$$
T(n)=\left\{\begin{array}{ll}
O\left(n^{d}\right) & \text { if } d>\log _{b} a(a<d^b) \\
O\left(n^{d} \log n\right) & \text { if } d=\log_{b} a(a=d^b) \\
O\left(n^{\log _{b} a}\right) & \text { if } d<\log_{b} a(a>b^d)
\end{array}\right.
$$

> 上面为主定理(Master theorem)的简化版，  
> 将$T(n)=a\cdot T(\frac{n}{b}) + f(n)$的$f(n)$简化为了$n^d$的形式。
>
> 对于$f(n)=n\log n$的情况，则不能用上述简化版做。
>
> 真正的主定理可以查看【[主定理（Master theorem）与Akra–Bazzi定理](https://my.oschina.net/u/4324616/blog/4778589)】这篇文章。

---

> 例 - 求$T(n)=T(\frac{2}{3}n)+1$
>
> 套用式子：$a=1,b=\frac{3}{2},d=0$，  
> $\because a=b^d$，$\therefore T(n)=O(n^0\log n)=O(\log n)$

#### (2) Akra–Bazzi定理

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
