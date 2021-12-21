# 第二章 热力学第一定律

## 一、热力学第一定律

$$
Q=(E_2-E_1)+A
$$

系统从外界吸热=内能增量+系统对外界做功

物理意义：涉及热运动和机械运动的能量转换及守恒定律。

## 二、对理想气体的应用

利用$pV=nRT$分析，
分为四种过程：

### 1. 等体过程

等体过程$\textrm{d}V=0$($V=C$)：  

   1. ？
   2. 热力学第一定律的具体形式：
   见笔记

   $$
   \Delta E = Q = \frac{m}{M}C_V\Delta T
   $$
   **对一切过程适用**。  
   在等温线上找到一个点，其与另一状态体积相同，则$\Delta E$可由$\Delta T$算出。

   1. 等体摩尔热容
      $$
      C_V=\frac{i}{2}R
      $$

### 2. 等压过程

$\textrm{d}p=0(p=C)$：

   1. 
   $$
   \frac{V_1}{V_2}=\frac{T_1}{T_2}
   $$
   1. ？
   2. 等压摩尔热容
      $$
      C_p=\frac{i}{2}
      $$

### 2.5. 等体和等压关系

故可得$C_V$与$C_p$关系：
$$
C_p=C_V+R
$$
为迈耶公式

泊松比：$\gamma=\frac{i+2}{i}>1$，  
告诉泊松比，则可知道自由度，则可判断是什么类型的气体分子。

> 拓展 - 为什么$C_p>C_V$：
>
> * 对于等容：$V=c\Rightarrow A=0$，故$Q_1=\Delta E$
> * 对于等压：$p=c\Rightarrow\Delta V>0, A>0$，故$Q_2=\Delta E + A$
>
> 故$C_p>C_V$

### 3. 等温过程

$\textrm{d}T=0(T=C)$

1. 过程方程：  
   $p_1V_1=p_2V_2$
2. 热力学第一定律的具体表现形式：
   * $\Delta E=0$
   * 星星：$A=\frac{m}{M}RT\ln\frac{V_2}{V_1}$
   * $Q=A$（吸热全部用于对外做功）
3. *摩尔热容：*   
   $C_T=\infty$

### 4. 绝热过程

$\textrm{d}Q=0$，不吸热。

1. 过程方程：  
   $\textrm{d}Q=\textrm{d}E+\textrm{d}A=0$  
   对于$\textrm{d}E$和$\textrm{d}A$，有可能不是准静态过程。
   * 准静态：$\frac{m}{M}C_V\textrm{d}T+p\textrm{d}V=0$
   * 理想气体：$$

   得到如下三个公式：
   * $pV^\gamma=C$（等于恒量）
2. 绝热线：  
   * 等温线：$pV=C$，双曲线。
   * 绝热线：$pV^\gamma=C$，比**等温线陡峭**。
3. 热力学第一定律的具体表现形式：
   * $Q=0$
   * $\Delta E=\frac{m}{M}C_V\Delta T$
   * $A=-\Delta E = \frac{i}{2}(p_1V_1-p_2V_2)=\frac{p_1V_1-p_2V_2}{\gamma-1}$
4. 摩尔热容：  
   $C_{\textrm{绝热}}=0$

## 三、总结

### 1. 理想气体典型过程的主要公式

![理想气体典型过程的主要公式](image/summary_1.jpg)

### 2. 四个公式

* 气体物态方程：  
  $$
  pV=\frac{m}{M}RT
  $$
* 吸热/放热：
  $$
  Q=\Delta E+A
  $$
* 内能变化：
  $$
  \Delta E=\frac{m}{M} C_V\Delta T
  $$
  $C_V=\frac{i}{2}R$
* 对外做功：
  $$
  A=\int P\textrm{d}V
  $$
  大小反映为$p-V$相图中曲线的面积，  
  正负反映为曲线在$V$轴的方向。