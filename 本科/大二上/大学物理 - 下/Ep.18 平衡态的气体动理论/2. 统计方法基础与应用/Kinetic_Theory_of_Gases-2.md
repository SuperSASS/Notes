# 第二节 统计方法基础与应用

## 一、统计方法基础

气体分子热运动具有无序性，  
因为频繁碰撞，分子速度和方向不断变化，表现为一种无序和随机运动。

气体分子热运动可以得出统计规律，  
故引入统计方法。

要点：

1. 基本概念
   * 统计规律
   * 概率
   * 概率密度和分布函数
   * 统计平均值
   * 涨落
2. 推导理想气体$P,T$的公式

### 1. 统计规律

统计规律为：大量偶然事件整体所遵从的规律。

* 偶然 - 单次实验结果不能预测。
* 整体 - 多次重复实验结果呈现明显规律。

特点：

1. 群体规律：只能表示**大量偶然事件**的整体效果。  
   对少数事件不适用。
2. 量变到质变：整体特征占主导地位。  
   **不是**个体粒子运动规律的**简单叠加**。
3. 与系统所处的宏观条件相关。
4. 伴有涨落：每一次测量的实际结果与统计平均值的偏差，称为涨落，也称起伏。

### 2. 概率理论

> 定义 - 概率
>
> $$
> W_A=\lim_{N\to\infty}\frac{N_A}{N}
> $$

*物理中将$P$记为$W$。*

* $N_A$ - 结果$A$出现的次数。
* $N$ - 实验总次数。

用于描述事物出现可能性的大小。

性质：

1. 叠加定律  
   对于**互斥事件**$A,B$，其**和事件**$W_{A+B}=W_A+W_B$

   这种划分的所有互斥事件，其满足归一化条件：$\int \textrm{d}W=1$
2. 乘法定律  
   对于**独立事件**$A,B$，其**积事件**$W_{AB}=W_A\times W_B$

### 3. 基本概念

1. 概率密度：$\frac{N_i}{N\Delta x}$  
   强调**单位长度**内的概率。
2. 分布函数：$\frac{N_i}{N\Delta x}$是$x$的函数，则称$f(x)=\frac{N_i}{N\Delta x}$为分布函数。  
   > ⚠注意 - 跟概率论中的分布函数不同：  
   > 概率论的分布函数是负无穷到$x$的和，而这里的就是某点概率，只是指函数。

   转化成微分的形式可写成：
   $$
   f(x)=\frac{\textrm{d}N}{N\textrm{d}x}
   $$
3. 统计平均值：  
   $$
   \bar{g}=\sum xf(x)=\int x f(x) \textrm{d}x
   $$

## 二、理想气体的压强公式的推导

### 1. 提出理想气体分子的微观模型

为无规则运动的自由弹性质点的集合。

* 为质点 — 不计大小
* 为自由质点 — 不计重量
* 除碰撞瞬间外无相互作用。
* 碰撞为完全弹性碰撞。
* 遵循经典力学定理。

### 2. 统计性假设

提出以下统计性假设：

1. 分子处于容器内任意位置处的概率相同。  
   则分子数密度$n$：$n=\frac{N}{V}$
2. 分子沿各方向运动的概率相同。  
   $\bar{v_x^2}=\bar{v_y^2}=\bar{v_z^2}=\frac{1}{3}\bar{v^2}$

### 3. 公式推导

> 压强等于器壁单位时间内，单位面积上所受的平均冲量。  
> 即：$\vec{P}=\frac{\sum \vec{I_i}}{\Delta t \Delta S}$
>
> 1. 考虑一个分子对器壁一次碰撞产生的冲量：  
>    $y,z$轴上速度不变，$x$轴上速度相反。  
>    $I_i=2mv_{ix}$
> 2. 该速度区间内（$\vec{v_i}\sim\vec{v_i}+\textrm{d}\vec{v_i}$）所有分子在$\textrm{d}t$时间内给予器> 壁的总冲量：  
>    分子数密度$n_i$（满足$\sum n_i=n$）  
>    相撞分子数：$n_iv_{ix}\textrm{d}t\textrm{d}S$  
>    则这一区间的分子总冲量：$I_{\Delta i}=I_i\cdot n_{\Delta i} =2mv_{ix} n_i v_{ix}\textrm{d}t\textrm{d}S$
>
>    由于只有$v_{ix}>0$才能撞到器壁，故对所有$v_{ix}>0$的分子求冲量和：  
>    $\sum I_i=\frac{1}{2}\sum 2mv_{ix}^2n_i\textrm{d}t\textrm{d}s$
> 3. 得到理想气体压强公式：  
>    $\begin{aligned}P&=\frac{\sum I_i}{\textrm{d}s\textrm{d}t}\\&=\sum_i mv_{ix}^2n_i\\&=\frac{n m\sum_i v_{ix}^2n_i}{n}\\&=nm\bar{v_x^2} \\& =\frac{1}{3}nm\bar{v^2}\end{aligned}$

综上：

$$
⭐P=\frac{1}{3}nm\bar{v^2}=\frac{2}{3}n\bar{\epsilon_t}
$$
其中：  
$n=\frac{N}{V}$，为**分子数密度**，单位：$\textrm{个}/m^3$  
$\bar{\epsilon_t}=\frac{1}{2}m\bar{v^2}$，为分子的**平均平动动能**。

> 补充 - 道尔顿分压定律：
>
> $P=P_1+P_2+\cdots$  
> 总压强等于各种气体**单独充满容器**时**压强之和**。

### 4. 宏观量的微观实质

* 观测时间足够长
* $\textrm{d}S$足够大
* 分子数足够多

宏观量是微观量的统计平均值。

## 三、理想气体的温度公式

> 由两个公式推导：
>
> * 理想气体状态方程：$p=nkT$
> * 理想气体压强公式：$p=\frac{2}{3}n\bar\epsilon_t$
>
> 得到：$\bar\epsilon_t=\frac{3}{2}kT$  
> 即为理想气体的温度公式。

$$
⭐\bar{\epsilon_t}=\frac{3}{2}kT
$$

描述了温度与运动状态（平均平动动能）的关系。  
可以看出：理想气体**温度**$T$是分子**平均平动动能的量度**，是分子**热运动剧烈程度的标志**。  
且呈正相关的关系，  
$\bar\epsilon_t\propto T$，与气体种类无关。

> 推论 - 为什么绝对零度无法达到：
>
> $T=0 \Rightarrow \bar{\epsilon}=0$，  
> 而热运动不可能停止，故只能逼近不能达到。

温度是大量分子热运动的集体表现，是统计性概念，  
对**单个分子没有温度**可言。
