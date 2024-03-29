# 第一节 热力学系统的描述

> 定义 - 热运动：
>
> 微观粒子都在做永不停歇的无规则运动，其剧烈程度由**温度**高低表现出来。

## 一、热力学与统计物理学

研究热运动有两种理论：

* 宏观理论 - 热力学
* 微观理论 - 统计物理学

由现象出发总结出原理性理论。

### 1. 热力学

从观测实验中归纳方法，得到热现象基本定律。

### 2. 统计物理学

研究物质的微观结构和粒子的热运动，通过统计方法计算平均结果，确定宏观量与微观量的联系，描述热现象的规律和本质。

由基本假设出发提出构造性理论。

### 3. 相互关系

*相当于经典力学和量子力学。*

## 二、宏观量与微观量

### 1. 热力学系统

大量微观粒子（$10^{23}$个）构成的有限的宏观物质体系。  
简称为“系统”。

与系统毗邻的环境，即与系统相关的一切物体成为“外界”。

* 开放系统：与外界有$m,E$交换。（如敞开的热水，会损失热量与水蒸气质量）
* **封闭系统**：与外界只有$E$交换，没有$m$交换。（如盖上的热水）
* 鼓励系统：与外界$m,E$均不交换。（如理想保温杯里的热水）

> 定义 - 热力学：
>
> 研究热力学系统的状态（$P,V,T,S$）以及状态变化（$\Delta$）。

### 2. 宏观量与微观量

* 宏观量：以**系统整体**为研究对象，  
  如：
  * $P$ - 压强
  * $T$ - 温度
  * $V$ - 体积
  * $\sum m_i$ - 质量
  * $c$ - 比热
* 微观量：以系统内**各子系统**为研究对象，表征子系个性特征的物理量。  
  如：
  * $\vec{p_i}$ - 各子系动量
  * $\vec{v_i}$ - 各子系速度
  * $m_i$ - 各子系质量
  * $E_i$ - 各子系能量

关系：宏观量是大量粒子运动的集体表现，是微观量的**统计平均值**。

### 3. 平衡态

> 定义 - 平衡态：
>
> 孤立系统不传热、不做功，内部无热核反应、化学反应等能量转换过程，  
> 经过足够长的时间，系统的各种**宏观性质**会处于不随时间变化的稳定状态。

⚠注意：微观系统可能会不断变化，为**热动平衡**。

### 4. 温度与温标

> 定律 - 热力学第零定律：
>
> 如果系统$A$与系统$C$，系统$B$与系统$C$的同一状态都处于热平衡，  
> 那么$A$与$B$也必定处于热平衡。

* 温度：描述系统的冷热程度。（**并不是个具体的物理量**）  
  **⭐温度相等是热平衡的充要条件**。
* 温标：温度的数值表示方法，定量测定温度。  
  *注意：平时说的$30\degree C$都指的温标，而不是温度！*
  * 摄氏温标：规定冰水混合物的平衡温度为$0\degree C$
  * 热力学温标（绝对温标）：与任何特定物质性质都无关的温标。

  $T(K)=t(\degree C)+273.16$

## 三、理想气体的物态方程

> 理想气体的模型：
>
> * 宏观模型：严格遵守三条实验定律（查理定律、盖吕萨克定律、玻意耳-马略特定律）。
> * 微观模型：无规运动的弹性质点的集合。
> * 近独立性：粒子相互作用能远小于粒子自身能量，$E\approx\sum E_i$

理想气体物态方程：
$$
⭐pV=\frac{m_g}{M}RT
$$

* $M$ - 气体的摩尔质量。
* $R$ - 普适气体常数。（$R=8.31 \textrm{J}\cdot \textrm{mol}^{-1}\cdot \textrm{K}^{-1}$）

变式：

* $pV=\frac{m_g}{M}RT=\frac{N}{N_A}RT$
* $p=\frac{N}{V}\frac{R}{N_A}T=n\cdot kT$
  * $n$ - 分子数密度。（⚠注意与物质浓度区分）
  * $K$ - 玻尔兹曼常数。（单位：$\textrm{J}\cdot \textrm{K}^{-1}$）
