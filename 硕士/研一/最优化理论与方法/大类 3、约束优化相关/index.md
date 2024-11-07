# 大类 2、约束优化相关

这一大类考虑有约束的优化问题。

---

回顾数学规划问题 MP 的定义：

$$
\begin{array}{cl}
\underset{\boldsymbol{x} \in X}{\operatorname{minimize}} & f(\boldsymbol{x}) \\
\text { subject to } & h_{i}(\boldsymbol{x})=0, i=1, \cdots, m \\
& g_{j}(\boldsymbol{x}) \leq 0, j=1, \cdots, p
\end{array}
$$
其中：

* $\boldsymbol{x}=(x_1,\cdots,x_n)$是 MP 的**决策**/优化/设计**变量**
* $f$是 MP 的**目标函数**
* $h_i(\boldsymbol{x})=0$和$g_j(\boldsymbol{x})\le0$分别是 MP 的**等式/不等式约束**
* $X$是 MP 的**简单集合约束**（可以与等式约束、不等式约束相互转换）

可以将等式/不等式约束，记为下面向量函数的形式：

$$
\begin{array}{cl}
\underset{\boldsymbol{x} \in X}{\operatorname{minimize}} & f(\boldsymbol{x}) \\
\text { subject to } & \boldsymbol{h}(\boldsymbol{x})=0 \\
& \boldsymbol{g}(\boldsymbol{x}) \leq 0
\end{array}
$$
其中：$\boldsymbol{h}:\R^n\to\R^m,\boldsymbol{g}:\R^n\to\R^p$

## 总结

### 约束品性

就是在使用 KKT 条件的一些前置条件。  
当问题满足任意一个约束品性时，则当问题不满足任意一个约束品性时，则不能使用 KKT 条件。

性质：局部极小点$\Rightarrow$KKT 点

### 凸规划

* 要求：
  * 目标函数$f$是凸函数
  * 简单集合约束$X$是凸集
  * 不等式约束$g_i(\boldsymbol{x})$均为凸函数
  * 等式约束$h_i(\boldsymbol{x})$均只能为仿射函数$\boldsymbol{a}_i^T\boldsymbol{x}-b_i=0$  
    *因为只有仿射函数所代表的几何图形为凸集（其它如圆圈$x^2+y^2=1$不为凸集）*
* 性质：局部极小点$\Leftrightarrow$全局极小点。

### KKT 条件、KKT 点

满足 KKT 条件的叫 KKT 点。

KKT 条件可以看作约束优化的“一阶必要条件”；KKT 点可以看作约束优化中的“驻点”。  
故：KKT 点不一定是局部极小点。  
但

* 一阶必要条件