# 第一节 估计

需要知道属于在参数统计的范围之内，  
与之区别的是非参数统计。

* 总体参数：对于总体服从的分布（正态、泊松等）的参数（正态就是$\mu,\sigma$）。

---

本章的问题则是根据样本，**估计总体的参数$\theta$**。

估计的方法：

1. 点估计
2. 区间估计

## 一、点估计

> 构造一个有关样本统计量的函数，  
> 使得通过样本，估计出总体参数。
>
> 即为：$\hat{\theta}=f(X_1,X_2,\cdots,X_n)$，  
> $\hat{\theta}$为$\theta$的点估计量。

方法：

1. 矩估计
2. 极大似然估计
3. 最小二乘估计
4. 贝叶斯估计
5. 极大极小估计

### 1. 矩估计

用样本的矩来代替总体的矩。

> 定义 - 矩的概念：
>
> ...

1. 原点矩  
   理论（总体）：
   $$
   E\left(X^{k}\right)=\left\{\begin{array}{l}
   \sum\left(x_{i}\right)^{k} p( x_{i}) \\
   \int_{-\infty}^{+\infty} x^{k} f(x) \textrm{d} x
   \end{array}\right.
   $$
   样本：
   $$
   \frac{1}{n} \sum x_{i}^{k}
   $$
   即为$\overline{X}$
2. 中心矩  
   理论（总体）：
   $$
   E(X-EX)^{k}=\left\{\begin{array}{l}
   \sum\left(x_{i}-EX)^{k} p\left(x_{i}\right)\right. \\
   \int_{-\infty}^{+\infty}\left(x-EX)^{2} f(x) \textrm{d} x\right.
   \end{array}\right.
   $$
   样本：
   $$
   \frac{1}{n} \sum\left(x_{i}-\bar{x}\right)^{k}
   $$
   记作：$S_n^{*k}$

   对于不同的$k$：

   * $k=1$
   * $k=2$
   * $k=3$ - 偏度
   * $k=4$ - 峰度

   偏度和峰度刻画分布。

即矩估计：
$$
EX=\overline{X} \\
DX=S_n^{*2}
$$

有几个参数，取多少个$k$。  
注意如果不为关于参数的函数（如算出来为参数），需要取不同的$k$。

---

性质：

矩估计复合函数后，仍为复合后的矩估计。  
如$S_n^{*2}$为总体方差$D(X)$的矩估计量，  
这$\sqrt{S_n^{*2}}=S_n^*$为标准差$\sqrt{D(X)}$的矩估计量。

### 2. 极大似然估计

找似然函数的极大值。

* 极大 - 求极大值
* 似然 - 为一个函数
  * 自变量：样本的观察值$x_1,x_2,\cdots,x_n$
  * 因变量：样本的参数$\theta=(\theta_1,\cdots)^T$
  * 法则：
    $$
    ...
    $$

    为了使得极大值（求导）好求，通常采用对数似然函数。

---

步骤：

1. 求似然函数：$L(x_1,\cdots;\theta_1,\cdots)$
2. 求对数：$\ln L(x_1,\cdots;\theta_1,\cdots)$
3. 对参数求偏导：$\frac{\textrm{d}(\ln L(\cdots))}{\textrm{d}\theta}$  
   对不同的$\theta_i$求偏导，解出来的$n$个极大值即为$\theta$的极大似然估计。

---

性质：极大似然估计的函数仍是其极大似然估计。

## ？、 对矩估计的评价

### 1. 无偏性

总体参数的真值：$\theta=(\theta_1,\theta_2,\cdots)^T$  
总体参数的估计量：$\hat{\theta}=(\hat{\theta}_1,\hat{\theta}_2,\cdots)^T$

若$E\hat(\theta)=\theta$，则称无偏估计。

1. 期望：$EX=\mu$，为无偏
2. 方差：$ES_n^{*2}=\frac{n-1}{n}\sigma^2\ne\sigma^2$，为有偏估计。  
   因此对于$S_n^2=\frac{1}{n-1}\sum (X_i-\overline{X})^2$，才为无偏估计。

### 2. 有效性

在无偏的前提下，计算$\hat\theta$的方差，  
方差越小越有效。