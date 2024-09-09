# 第二节 不确定关系

无论用什么方法，想要了解某种物体的某种性质，都必须要同那个物体发生相互作用，  
但这种相互作用，又会**改变所测定的那种性质**本身。  
又称“测不准原理”
> 比如用仪器测量微观粒子的长度，但测量的时候其长度就会发生变化。

## 一、位置与动量的不确定关系

> 以电子束单缝衍射为例：
>
> 考虑中央明纹：
>
> 1. 位置不确定$\Delta x$：不确定是从缝宽为$a$狭缝的哪点射出。  
>    $\Delta x=a$
> 2. 动量不确定$\Delta p$：速度的角度不确定，会影响速度，从而影响动量。  
>    水平方向：$p_{x\min}=0$；边缘方向：$p_{x\max}=p\sin\varphi$，  
>    $\Delta p=p\sin\varphi=\frac{h}{\lambda}\cdot\frac{\lambda}{a}=\frac{h}{a}$
>
> 发现：
> $$\Delta x\cdot\Delta p_x=h$$
>
> 但电子不可能只落在中央明纹，只是概率较大，$\Delta p_x$还可以变大。  
> 即：$\Delta x\cdot\Delta p_x\ge h$
>
> 用量子力学理论推到得到：
> $\Delta x\cdot\Delta p_x\ge \frac{h}{4\pi}$

两者数学形式相同，且数量级相当，  
故作数量级估算时，采用简化公式：

$$
\Delta \cdot \Delta p \geqslant \hbar\left\{\begin{array}{l}
\Delta x \cdot \Delta P_{x} \geqslant \hbar \\
\Delta y \cdot \Delta P_{y} \geqslant \hbar \\
\Delta z \cdot \Delta P_{z} \geqslant \hbar
\end{array}\right.
$$
其中$\hbar=\frac{h}{2\pi}$

## 二、能量与时间的不确定关系

粒子**能量与其寿命**的不确定度相互制约。  
*寿命指在能级中稳定存在的时间。*

$$\Delta E\cdot \Delta t \ge \frac{\hbar}{2}$$

> 基态$E_1$ - 稳定：  
> $\Delta t\to\infty,\Delta E\to0$，  
> 故$E_1$确定。
>
> 激发态$E_2$ - 不稳定：  
> $\Delta t\ne0, \Delta E\ge \frac{h}{\Delta t}$  
> 故$E_2$波长范围不确定。

## 三、不确定关系的物理意义

1. 不确定关系
   * 当粒子的位置完全确定时，动量分量完全不确定。
   * 当粒子的动量分量完全确定时，位置完全不确定。

   *波尔的轨道理论完全失去意义，采用“电子云”来代替。*
2. 存在零点能，绝对零度永远不能达到。  
   $E=(n+\frac{1}{2})h\nu$
3. 不确定关系是量子力学过渡到经典力学的一种渠道。
4. 不确定关系不是因为实验仪器或者理论的缺陷导致的。

## 四、互补原理（哥本哈根精神）

测量——反映着客体、仪器和观察者的相互作用。  
宏观世界中可以忽略，而微观世界不能不计这种相互作用。

我们用什么探测方法，就探测出一方面的性质。
