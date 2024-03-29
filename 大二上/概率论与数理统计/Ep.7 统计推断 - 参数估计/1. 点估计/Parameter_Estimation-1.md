# 第一节 点估计

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

## 一、矩估计

用样本的矩来估计（代替）总体的矩。

### 1. 矩的概念

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
   \frac{1}{n} \sum\left(x_{i}-\overline{X}\right)^{k}
   $$
   记作：$S_n^{*k}$，为$k$阶中心矩

   对于不同的$k$：

   * $k=1$
   * $k=2$
   * $k=3$ - 偏度
   * $k=4$ - 峰度

   偏度和峰度刻画分布。

   *记忆：中心矩，记为与中心的偏差，所以为$\sum (x_i-\overline{X})^k$*

*虽然需要的矩个数会根据参数个数增多而增多，但实际做题最多只用两个矩。*

### 2. 矩估计方法

矩估计则是：  
样本的一阶矩$A_1$等于总体的一阶矩$EX$，  
样本的二阶矩$A_2$等于总体的二阶矩$EX^2$；  
样本的$k$阶矩$A_k$等于总体的k阶矩$EX^k$。

但一般分布的参数只有一个或两个，所以最多到二阶矩。

* 一个参数的分布：只用到一阶矩$\theta_1=A_1=\overline{X}$。
* 两个参数的分布：用到一二阶矩，如下，  
  $\left\{\begin{array}{ll}
  E X&\Leftarrow A_1&=\frac{1}{n}\sum x_i&=\overline{X} \\
  E X^{2}=E^{2} X+D X&\Leftarrow A_2&=\frac{1}{n}\sum x_i^2
  \end{array}\right.$  
  其中$EX$、$EX^2$可以用两个参数的估计值表示。  
  > e.g.
  >
  > * 正态：$EX=\hat\mu$，$EX^2=\hat\mu^2+\hat\sigma^2$
  > * 泊松：$EX=\hat\lambda$，$EX^2=\hat\lambda+\hat\lambda^2$
  > * 任意$f_X(x)$：  
  >   $EX=\int (x\cdot f_X(x)) \textrm{d}x$  
  >   $EX^2=E^2X+DX$*（但$DX$可能很难计算，故一般只有一个参数用一阶）*

对于估计值，需要在头上加一个^，  
**代表这个是估计值$\hat{\theta}$**，区别于准确值$\theta$。

---

⭐总结 - 即矩估计：
$$
EX=\overline{X} \\
EX^2=A_2 \\
DX=S_n^{*2}
$$
其中$S_n^{*2}=\frac{1}{n} \sum\left(x_{i}-\overline{x}\right)^{2}$，为样本二节中心矩

* 总体均值估计量：样本均值
* 总体方差估计量：样本二阶中心矩

有几个参数，取多少个$k$。  
注意如果不为关于参数的函数（如算出来为参数），需要取不同的$k$。

⚠注意：  
矩估计不仅能估计参数，还能估计概率，  
就是把估计的参数带到概率密度里。  
如求$P\{X=0\}$的矩估计，则把$\hat{\theta}$带到$f_X(0)$。

### 3. 矩估计性质

矩估计复合函数后，仍为复合后的矩估计。  
如$S_n^{*2}$为总体方差$D(X)$的矩估计量，  
这$\sqrt{S_n^{*2}}=S_n^*$为标准差$\sqrt{D(X)}$的矩估计量。

### 4. 对矩估计的评价

*本部分不考。*

#### ① 无偏性

总体参数的真值：$\theta=(\theta_1,\theta_2,\cdots)^T$  
总体参数的估计量：$\hat{\theta}=(\hat{\theta}_1,\hat{\theta}_2,\cdots)^T$

若$E\hat(\theta)=\theta$，则称无偏估计。

1. 期望：$EX=\mu$，为无偏
2. 方差：$ES_n^{*2}=\frac{n-1}{n}\sigma^2\ne\sigma^2$，为有偏估计。  
   因此对于$S_n^2=\frac{1}{n-1}\sum (X_i-\overline{X})^2$，才为无偏估计。

#### ② 有效性

在无偏的前提下，计算$\hat\theta$的方差，  
方差越小越有效。

## 二、极大似然估计

基于原理：**小概率事件**在**一次观测**中**不可能发生**。  
那么反之，如果在一次观测中某一事件发生了，那么这个事件的可能性就很大。
> e.g.
>
> 一个箱子A有1个白球99个黑球，另一个箱子B有99个白球1个黑球，  
> 现在知道某位同学摸了一次，摸到了一个白球（**一次观测**）。
>
> 那么估计：这个同学是从B箱里摸的。  
> 因为A箱白球很少（**小概率事件**），在这一次摸的情况下几乎不可能是A箱摸到的（**不可能发生**）。

基于这一原理，得到了总体的某个样本（一次观测），那么取样得到这个样本的可能性就很大，  
因此就要**调整各个参数**$\theta_i$（也就是估计参数），满足**这个样本出现的可能性很大**。

自然想到**构造**关于这个**样本与各参数的一个函数**，代表这个样本出现的概率，  
然后**求这个函数的极大值**，来确定各个参数。  
这个函数即叫“似然函数”。

---

似然函数的构造：

* 参数 - 确定部分：样本集的$n$个样本观察值$X_n=(x_1,x_2,\cdots,x_n)^T$（向量表示）
* 自变量 - 估计（求解）部分：总体的$k$个参数$\Theta_k=(\theta_1,\theta_2,\cdots,\theta_k)^T$
* 因变量 - 这个样本集合的出现概率
* 法则：  
  通常**各个样本独立**，故出现概率就是**概率的连乘**。
  $$
  f(X_n,\Theta_n)=P\{X=x_1,\Theta_n\}\times P\{X=x_2,\Theta_n\} \times \cdots \times P\{X=x_n,\Theta_n\}
  $$
  就是各个取值，在某种参数集下的**概率连乘**。  
  离散型中为分布律，连续型中为概率密度。

*以上部分为个人总结，符号仅供参考，不是标准的表示。*

通常将似然函数记为：$L(x_1,\cdots;\theta_1,\cdots)$  

离散型为连乘运算，连续型为积分运算，  
故两种方法求似然函数的处理方式不同。

得到似然函数后$L(X_n,\Theta_n)$，  
为了使得极大值（求偏导为$0$）好求，通常采用取对的方法，  
既能将连乘变为连加，并且求导更好求。

求完对数后，对各参数$\theta_1,\cdots$分别求偏导等于$0$，  
解$n$个方程组完成。

---

### 1. 连续型步骤

1. 求似然函数$L(X,\Theta)$  
   **各个概率的乘积。**
   * 离散：$L=\Pi p(X=x_i,\Theta)$
   * 连续：$L=\Pi f(X=x_i,\Theta)$
2. 求对数：$\ln L(x_1,\cdots;\theta_1,\cdots)$
3. 对参数求偏导：$\frac{\textrm{d}(\ln L(\cdots))}{\textrm{d}\theta}$  
   对不同的$\theta_i$求偏导，解出来的$n$个极大值即为$\theta$的极大似然估计。

### 2. 离散型步骤

1. 求似然函数$L(X,\Theta)$  
   * 若分布律不能以一个函数表达（表格给出的分布律）  
     * 如果告诉了这一次样本$(x_1,\cdots)$：  
       那就非常简单：直接利用表格，将样本集各取值的概率相乘；  
     如果没有告诉样本，就要引入计数函数
     > 计数函数$I(x_i=k)$：
     >
     > 代表某一个样本$x_i$，其是否等于$k$，  
     > 等于则为$1$，
   * 若分布律可以用一个函数表达（各种离散分布）：  
     那就跟连续型一样，带入相乘即可。

### 3. 特殊 - 导数/驻点不存在

离散型是肯定有驻点的，  
但连续性可能不存在，  
或者说导数恒大于或小于零。
*一般用于均匀分布。*

还是要使得$L$尽量大，  
因为导数恒大于或小于零，即$L$单增或单减，  
所以就让$\theta$尽量大或小即可。

引入“顺序统计量”$X_{(1)},X_{(n)}$  
根据$\theta$的范围，如$\theta<x$，  
则$\hat\theta=X_{(1)}$

### 4. 其他似然函数

注意，上面似然函数构造，基于的是：  
$P\{X_1=x_1,X-2=x_2,\cdots,X_n=x_n\}$这一个观测值。

有时候题目可能告诉其他观测方法，  
如：样本的观测值$(x_1,x_2,\cdots,x_{2016})$中有$57$个值为$0$。  
又知$f_X(0)=e^{\theta}$，记为$p$  
便可构造：
$$
L(\theta)=C_{2016}^{57}p^{57}(1-p)^{2016-57}
$$

$\ln L=57\theta+1959\ln(1-e^\theta)$

### 4. 性质

1. 极大大似然估计的函数仍是其极大似然估计。
2. **正态分布**的极大似然估计 - **与矩估计一样**  
   $\hat\mu_\textrm{极大}=\hat\mu_\textrm{矩}=\overline{X}$
3. 泊松分布的极大似然估计 - **与矩估计一样**  
   $\hat\lambda_\textrm{极大}=\hat\lambda_\textrm{矩}=\overline{X}$
