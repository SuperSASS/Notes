# 第三节 协方差

> 引例 - 求不独立的二维随机变量相加的方差
>
> 若不满足独立：
>
> $\begin{aligned}D(X+Y) &=E\left[(X+Y)^{2}\right]-E^{2}(X+Y) \\&=E\left(X^{2}+2 X Y+Y^{2}\right)-[E(X)+E(Y)]^2\\&=E(X^2)+2E(XY)+E(Y^2)-E^2(X)-2E(X)E(Y)-E^2(Y) \\&=\left[E\left(X^{2}\right)-E^{2}(X)\right]+\left[E\left(Y^{2}\right)-E^{2}(Y)\right]+2[E(X Y)-E(X) E(Y)] \\&=D(X)+D(Y)+2 \operatorname{Cov}(X, Y)\end{aligned}$  
> 注意**为$2$倍**！

## 一、协方差的概念

### 1. 定义

> 定义 - 协方差：
>
> $$\textrm{Cov}(X,Y)=E\{ [X-E(X)]\cdot[Y-E(Y)]\}$$
> 称为$X,Y$的协方差。

可以理解为：

* $X$的方差$D(X)=E\{[X-E(X)]^2\}$
* $Y$的方差$D(Y)=E\{[Y-E(Y)]^2\}$
* 综合考虑即为协方差$\textrm{Cov}(X,Y)=E\{[X-E(X)][Y-E(Y)]\}$

称：$\left(\begin{array}{cc}D(X) & \operatorname{Cov}(X, Y) \\\operatorname{Cov}(Y, X) & D(Y)\end{array}\right)$为协方差矩阵。

### 2. 意义

$X,Y$的协方差是刻画随机变量之间的**线性关系**（相关系数）的量。

若$X,Y$相互独立$\Rightarrow \textrm{Cov}(X,Y)=0$。  
但**反之不成立**！
> 区别 - 期望、方差、协方差与独立性：
>
> * $X,Y$相互独立$\Leftrightarrow  E(XY)=E(X)E(Y)$（而加法一直满足）
> * $X,Y$相互独立$\Leftrightarrow  D(X+Y)=D(X)+D(Y)$
> * $X,Y$相互独立$\Rightarrow \textrm{Cov}(X,Y)=0$

## 二、计算方法

*一般不按定义算，而采用引例中推到的式子来算（也可以由定义式推导得出）。*

$$\textrm{Cov}(X,Y)=E(XY)-E(X)E(Y)$$

> 呼应 - 期望中乘法原理：
>
> 如果两变量不独立，则：  
> $E(XY)=E(X)E(Y)+\textrm{Cov}(X,Y)$

## 三、性质

### 0. 基本性质

* 对称性：$\textrm{Cov}(X,Y)=\textrm{Cov}(Y,X)$
* 自乘性：$\textrm{Cov}(X,X)=D(X)$  
  > 呼应 - $E(X^2)=E^2(X)+D(X)$。
* 非独立性：若$X,Y$相互独立，则$\textrm{Cov}=0$

### 1. 线性性质

$$\textrm{Cov}(aX+b,cY+d)=ac\cdot\textrm{Cov}(X,Y)$$

### 2.加法性质

$$\textrm{Cov}(X_1\pm X_2,Y)=\textrm{Cov}(X_1,Y)\pm\textrm{Cov}(X_2,Y)$$

拓展：$\textrm{Cov}(A+B,C+D)=\textrm{Cov}(A,C)+\textrm{Cov}(A,D)+\textrm{Cov}(B,C)+\textrm{Cov}(B,D)$

### 3. 柯西-许瓦兹不等式

$$|\textrm{Cov}(X,Y)|\le \sqrt{D(X)}\sqrt{D(Y)}$$

## ⭐四、相关系数

### 1. 相关系数定义

因为协方差算出来带有单位，不好准确刻画关系，  
所以考虑将单位消除，则可以准确刻画。

$$\rho(X,Y)=\frac{\textrm{Cov}(X,Y)}{\sqrt{D(X)}\sqrt{D(Y)}}$$

### 2. 相关系数性质

1. $|\rho_{XY}|\le1$
2. $|\rho_{XY}|$越大，$X,Y$线性相关程度越高；反之越低。
3. 若$X,Y$相互独立，则$\rho_{XY}=0$，即$X,Y$**没有线性相关**性质。  
   注意：**独立不等价于不相关。** 即如果$X,Y$不相关，不能说$X,Y$独立。
   **独立判断方式：联合=边缘乘积。**
