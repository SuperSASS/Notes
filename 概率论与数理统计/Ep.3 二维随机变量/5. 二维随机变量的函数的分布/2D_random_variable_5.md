# ⭐第五节 二维连续型随机变量的函数的分布

* 对于离散型：  
  *简简单单滴离散型，啥也不用说，直接算。*  
  每个概率复合上函数，然后**值相同的合并**，再写出分布律。

故下面只讲连续型的函数的分布。

## 一、两随机变量之和的分布

若$(X,Y)$的概率密度为$f(x,y)$，则$Z=X+Y$的概率密度为：
> $$f_Z(z)=\int_{-\infty}^{+\infty}f(x,z-x)\textrm{d}x$$
*注意此时$z-x$相当于$f(x,y)$中的$y$。*

或者为$f_Z(z)=\int_{-\infty}^{+\infty}f(z-y,y)\textrm{d}x$  
称为“卷积函数”。

*不推导、直接用。*

---

若$X,Y$相互独立，则可化为：  
$f_Z(z)=\int_{-\infty}^{+\infty}f_X(x)f_Y(z-x)\textrm{d}x$  
$f_Z(z)=\int_{-\infty}^{+\infty}f_X(z-y)f_Y(y)\textrm{d}x$

> 例题 1 - 两变量独立：
>
> $X,Y$独立，均服从均匀分布$U(0,1)$，  
> 求$Z=X+Y$概率密度。
>
> **解：**
>
> 两变量独立，用以下步骤。
>
> 1. 算出两变量边缘概率密度  
>    $f_{X}(x)=\left\{\begin{array}{cc}1 & 0<x<1 \\0 & \textrm { 其它 }\end{array} \quad f_{Y}(y)=\left\{\begin{array}{cc}1 & 0<y<1 \\0 & \textrm { 其它 }\end{array}\right.\right.$
> 2. 求$\int f(x,z-x)\textrm{d}x$的分段积分区域$x$  
>    $\left\{\begin{array}{c}0<x<1 &\rightarrow& 0<x<1 \\0<(y=)z-x<1 &\rightarrow& z-1<x<z\end{array}\right.$，求其交集。  
>
>    **方法：**“左右相等，分段求交”
>
>    > $\left\{\begin{array}{c}z-1=0, & z-1=1\\z=0, & z=1\end{array}\right.$  
>    > 三个解：$z=0$、$z=1$、$z=2$。  
>    > 得到四段：$\left\{\begin{array}{l}z<0 \\ 0\le z < 1 \\ 1\le z <2 \\ 2\le z\end{array}\right.$  
>    > 带回到右侧的关于$x$的两不等式。
>    >
>    > 1. $z<0$时，交集为空。
>    > 2. $0\le z<1$时，交集为$0<x<z$
>    > 3. $1\le z<2$时，交集为$z-1<x<1$  
>    > 4. $z\ge2$时，交集为空。
>
> 3. 根据分段，求定积分
>    1. $z<0$时：$f_Z(z)=\int\limits_{\varnothing}\textrm{d}x=0$
>    2. $0\le z<1$时：$f_Z(z)=\int_0^z(1\cdot 1)\textrm{d}x=z$
>    3. $1\le z<2$时：$f_Z(z)=\int_{z-1}^1\textrm{d}x=2-z$
>    4. $z\ge2$时：$f_Z(z)=\int\limits_{\varnothing}\textrm{d}x=0$
>
> 综上：……

---

> 例题 2 - 两变量不独立：
>
> $f(x, y)=\left\{\begin{array}{cc}24(1-x) y & 0<x<1,0<y<x \\0 & \textrm { 其它 }\end{array}\right.$
>
> 直接上公式：$f_Z(z)=\int_{-\infty}^{+\infty}f(x,z-x)\textrm{d}x$  
> 然后仍是求范围，再分类讨论。
>
> 解：
>
> $f_Z(z)=\int_{-\infty}^{+\infty}f(x,z-x)\textrm{d}x$  
> 需要满足：$\left\{\begin{array}{l} 0<x<1\\0<(y=)z-x<x \end{array}\right.\rightarrow\left\{\begin{array}{l} 0<x<1\\\frac{z}{2}<x<z \end{array}\right.$
>
> 同样：$\frac{z}{2}=0,\quad \frac{z}{2}=1,\quad z=0,\quad z=1$，  
> 最后得四个分段范围：  
> $f_{Z}(z)\overset{y=z-x}{=} \left\{\begin{array}{cc}0 & z<0 \textrm { 或 } z>2 \\\int_{\frac{z}{2}}^{z} 24(1-x)(z-x) d x & 0 \leq z \leq 1 \\\int_{\frac{z}{2}}^{1} 24(1-x)(z-x) d x & 1 \leq z<2\end{array}\right.$  
> 求积即可。

[123](#二两随机变量极值的分布)

## 二、两随机变量极值的分布

设$X,Y$是**两个相互独立**的随机变量，其概率密度为$f_X(x),f_Y(y)$，  
记：$M=\max\{X,Y\}$为最大值变量，$N=\min\{X,Y\}$为最小值变量。  
统称为极值变量。

前提 - 相互独立。

> 分析 1 - 对于最大值变量的分布函数：
>
> $\begin{aligned}F_{M}(z) &= P(M \leq z) \\&= P(\max (X, Y) \leq z) \\&= P(X \leq z, Y \leq z) \\\xrightarrow{\textrm { 由于相互独立 }} &= F_{X}(z) F_{Y}(z)\end{aligned}$
>
> 分析 2 - 对于最小值变量的分布函数：
>
> $\begin{aligned}F_{N}(z) &=P(M\le z) \\&=P(\min (X, Y) \le z) \\&=1-P(\min (X, Y)>z) \\&=1-P(X>z, Y>z) \\\xrightarrow{\textrm { 由于相互独立 }}&=1-\left(1-F_{X}(z)\right)\left(1-F_{Y}(z)\right)\end{aligned}$

综上（相互独立时）：

$$F_M(z)=F_X(z)F_Y(z)$$
$$F_N(z)=1-(1-F_X(z))(1-F_Y(z))$$

对分布函数求导，得概率密度：

* $f_M(z)=f_X(z)F_Y(z)+F_X(z)f_Y(z)$  
* $F_M(z)=f_X(z)(1-F_Y(z)) + (1-F_X(z))f_Y(z)$

---

可以推广到$n$个：  
$X_1\sim X_n$相互独立，$X_i$的分布函数为$F_I(x_i)$，  
则$M=\max\{X_1,X_2,\cdots,X_n\}的分布函数为$：  
$F_M(z)=F_1(z)F_2(z)\cdots F_n(z)$  
最小值同理。

> 拓展 - 任意函数的分布：
>
> 主要通过先求分布函数，再求导得概率密度。
>
> 方法 - 分布函数法：  
> $(X,Y)$为二维随机变量，概率密度为$f(x,y)$，  
> 若一函数$Z=g(X,Y)$，则其**分布函数$F_Z(z)$**：
> $$F_Z(z)=P(Z\le z)\overset{\textrm{带入}}{=}P\{g(X,Y)\le z\}=\iint\limits_{g(x,y)\le z}f(x,y)\textrm{d}x\textrm{d}y$$

## 三、结论

* 离散型要求：
  1. 正态分布 - 正态分布的和一定是**线性正态分布**  
     > $X_1\sim X_n$独立且服从$N(\mu_i,\sigma_i^2)$，则：
     > $$a_1X_1+a_2X_2+\cdots+a_nX_n=\sum a_iX_i\sim N(\sum a_iX_i, \sum a_i^2\sigma_i^2)$$
  2. 泊松分布 - 泊松分布的和一定是**线性泊松分布**  
     > $X_i\sim \pi(\lambda_i)$，则：  
     > $$X_1+X_2 \sim \pi(\lambda_1+\lambda_2)$$
  3. 二项分布 - 等概率的二项分布和一定是**线性二项分布**
     > $X_i\sim B(n_i,p)$，则：
     > $$X_1+X_2\sim B(n_1+n_2,p)$$
  4. 0-1分布 - 等概率的0-1分布和一定是**线性二项分布**  
     > $X_i\sim B(1,p)$。则：
     > $$X_1+\cdots+X_n = \sum X_i \sim B(n,p)$$
* 连续型要求：
  1. $X+Y$的和。
  2. **相互独立**$X,Y$的极值。
