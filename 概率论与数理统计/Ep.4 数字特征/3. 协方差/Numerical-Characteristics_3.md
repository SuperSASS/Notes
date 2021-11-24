# 第三节 协方差

> 引例 - 求不独立的二维随机变量的方差
>
> 若不满足独立：
>
> $\begin{aligned}D(X+Y) &=E\left[(X+Y)^{2}\right]-[E(X+Y)]^{2} \\&=E\left(X^{2}+2 X Y+Y^{2}\right)-\left[E(X)^{2}+E(Y)^2]\right.\\&=\cdots \\&=\left[E\left(X^{2}\right)-[1 x)^{2}\right]+\left[E\left(Y^{2}\right)-E(Y)^{2}\right]+2[E(X Y)-E(X) E(Y)] \\&=P(X)+P(Y)+2 \operatorname{Cov}(X, Y)\end{aligned}$
> 

## 一、概念

> 定义 - 协方差：
>
> $$\textrm{Cov}(X,Y)=E\{ [X-E(X)]\cdot[Y-E(Y)]\}$$
> 称为$X,Y$的协方差。

称：$\left(\begin{array}{cc}D(X) & \operatorname{Cov}(X, Y) \\\operatorname{Cov}(Y, X) & D(Y)\end{array}\right)$为协方差矩阵。

$X,Y$的协方差是刻画随机变量之间的**线性关系**的量。

若$X,Y$相互独立$\Rightarrow \textrm{Cov}(X,Y)=0$。  
但**反之不成立**！
> 区别 - 期望、方差、协方差与独立性：
>
> * $X,Y$相互独立$\Leftrightarrow  E(XY)=E(X)E(Y)$
> * $X,Y$相互独立$\Leftrightarrow  D(X+Y)=D(X)+D(Y)$
> * $X,Y$相互独立$\Rightarrow \textrm{Cov}(X,Y)=0$

## 二、计算方法

$$\textrm{Cov}(X,Y)=E(XY)-E(X)E(Y)$$

## 三、性质

### 0. 基本性质

* 对称性：$\textrm{Cov}(X,Y)=\textrm{Cov}(Y,X)$
* 自乘性：$\textrm{Cov}(X,X)=D(X)$

### 1. 线性性质

$$\textrm{Cov}(aX+b,cY+d)=ac\cdot\textrm{Cov}(X,Y)$$

### 2.加法性质

$$\textrm{Cov}(X_1\pm X_2,Y)=\textrm{Cov}(X_1,Y)+\textrm{Cov}(X_2,Y）$$

### 3. 柯西-许瓦兹不等式

$$|\textrm{Cov}(X,Y)|\le \sqrt{D(X)}\sqrt{D(Y)}$$

## ⭐四、相关系数

因为协方差算出来带有单位，不好准确刻画关系，  
所以将单位消除，则可以准确刻画。

$$\rho(X,Y)=\frac{\textrm{Cov}(X,Y)}{\sqrt{D(X)}\sqrt{D(Y)}}$$

### 2. 相关系数性质

1. $|\rho_{XY}|\le1$
2. 2
3. 若$X,Y$相互独立，则$\rho_{XY}=0$，即$X,Y$**没有线性相关**性质。  
   注意：**独立不等于不相关。**  
   独立判断方式：联合=边缘乘积。