# 第一节 数学期望

## 一、数学期望的概念

### 1. 离散型随机变量的数学期望

> 定义：
>
> 设离散型随机变量$X$的分布律为：  
> $P\{X=x_k\}=p_k\qquad (k=1,2,\cdots)$
>
> 若级数$\sum_{k=1}^\infty x_k\cdot p_k$**绝对收敛**，则称（若为条件收件，则级数的次序会改变求和结果）
> $$E(X)=\sum_{k=1}^\infty x_k\cdot p_k$$
> 称为$X$的数学期望，或称概率均值。  
> 简称均值或者期望。

可以知道：  
不是所有离散型随机变量都存在期望。（尤其是**无限个但可列**的离散型）

### 2. 连续型随机变量的数学期望

> 定义：
>
> 设连续型随机变量$X$的概率密度为：$f(x)$
>
> 若积分$\int_{-\infty}^{+\infty}x\cdot f(x)\textrm{d}x$绝对收敛，则称  
> $$E(x)=\int_{-\infty}^{+\infty}x\cdot f(x)\textrm{d}x$$
> 称为$X$的数学期望。
>
注：虽然$\int_{-\infty}^{+\infty}x\cdot f(x)\textrm{d}x$算出来感觉是加权求和，还没除总和。  
但$\because \int_{-\infty}^{+\infty}f(x)\textrm{d}x=1$，所以实际上除了的。

## 二、一维随机变量的函数的数学期望

### 1. 离散型

存在$X$的分布律为$P\{X=x_k\}=p$，  
则对于函数$g(x_k)$，  
若满足$\sum\limits_{k=1}^\infty g(x_k)\cdot p_k$绝对收敛，  
则函数$Y=g(x_k)$的期望为：
$$E(Y)=E[g(x)]=\sum\limits_{k=1}^\infty g(x_k)\cdot p_k$$

### 2. 连续型

连续型随机变量$X$的概率密度为$f(x)$，  
则对于函数$Y=g(X)$，  
若满足$\int_{-\infty}^{+\infty}g(x)\cdot f(x)$绝对收敛，  
则函数$Y=g(X)$的期望为：
$$E(Y)=E[g(x)]=\int_{-\infty}^{+\infty} g(x)\cdot f(x) d x$$

**总结：**  
就是将期望计算中“自身”$\times$“概率”中的“**自身**”，**替换为新的函数**。

* 离散：$x\cdot p_k \xrightarrow{x\rightarrow g(x)} g(x)\cdot p_k$
* 连续：$x\cdot f(x) \xrightarrow{x\rightarrow g(x)} g(x)\cdot f(x)$

## 三、二维随机变量的数学期望

二维随机变量$(X,Y)$，若$E(X)$、$E(Y)$都存在，  
则二维随机变量期望为：
$$
E(X)=\left\{\begin{array}{ll}
\sum_{i} \sum_{j} x_{i} p_{i j}, & \textrm{对于离散型 - }(X, Y) \textrm { 的概率分布为 } p_{i j} \\
\int_{-\infty}^{+\infty} \int_{-\infty}^{+\infty} x f(x, y) \mathrm{d} x\mathrm{d} y, & \textrm{对于连续型 - } (X, Y) \textrm { 的密度为 } f(x, y) .
\end{array}\right.
$$

因为$X$的边缘概率密度为：$f_X(x)=\int_{-\infty}^{+\infty}f(x,y)\textrm{d}y$，  
连续性还可以表示为：$E(X)=\int_{-\infty}^{+\infty} x f_X(x) \mathrm{d} x$

---

同理可得：
$$
E(Y)=\left\{\begin{array}{ll}
\sum_{i} \sum_{j} y_{i} p_{i j}, & \textrm{对于离散型 - }(X, Y) \textrm { 的概率分布为 } p_{i j} ; \\
\int_{-\infty}^{+\infty} \int_{-\infty}^{+\infty} y f(x, y) \mathrm{d} x \mathrm{~d} y, & \textrm{对于连续型 - } (X, Y) \textrm { 的密度为 } f(x, y) .
\end{array}\right.
$$

连续性还可以表示为：$E(Y)=\int_{-\infty}^{+\infty} y f_Y(y) \mathrm{d} y$

*对于二维随机变量的期望，也是单独对每一个变量求期望。即期望只是对一个变量而言的。*

## 四、二位随机变量的函数的期望

## 1. 离散型函数

$Z=f(x,y)$是关于二维离散型随机变量$X,Y$的函数，  
则$E(Z)$为：
$$E(Z)=\sum_i\sum_jf(x_i,y_j)p_{ij}$$
即为$z$的所有取值乘上它的概率之和。

## 2. 连续性函数

$Z=g(x,y)$是关于二维连续型随机变量$X,Y$的函数，  
则$E(Z)$为：
$$E(Z)=\int_{-\infty}^{+\infty}\int_{-\infty}^{+\infty} f(x,y)g(x,y)\textrm{d}x\textrm{d}y$$
跟离散型差不多，也是复合函数后的取值乘上它的概率求积。

*与求函数的概率密度不同，期望这个为全要求。*

> 例题 - 求最大值函数的期望：  
>
> 已知$X,Y$相互独立，概率密度：  
> $f_{X}(x)=\left\{\begin{array}{ll}e^{-x}, & x>0 \\
0, & x \leq 0
\end{array} \quad f_{Y} y=\left\{\begin{array}{c}
\frac{1}{2}, 0<y<2 \\
0, \quad \textrm{其他}
\end{array}\right.\right.$
> 即：$Z=\max(x,y)=x+y+|x-y|$，求$E(Z)$
>
> 分析：  
> 如果直接按公式求，对于绝对值函数不好处理。  
> 故可以先求$Z$分布函数，然后求$Z$的概率密度，再对$f_Z(z)$积分求$Z$的期望。
> 
> 

## 四、数学期望的简单性质

### 1. 线性法则

$$E(aX+b)=aE(x)+b$$

### 2. 加法法则

$$E(X+Y)=E(X)+E(Y)$$

推广：

* $E(\sum_{i=1}^na_iX_i)=\sum_{i=1}^na_iE(X_i)$

### 3. 乘法法则

### 4. 柯西-许瓦兹不等式

$$E(XY)^2\le E(X^2)\cdot E(Y^2)$$

> 证明：
>
> 利用高数性质：$|\int_a^bf(x)g(y)\textrm{d}x\textrm{d}y|^2\le \int_a^bf(x^2)\textrm{d}x\cdot\int_a^bg(y^2)\textrm{d}y$