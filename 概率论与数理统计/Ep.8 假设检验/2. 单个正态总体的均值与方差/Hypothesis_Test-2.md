# 第二节 单个正态总体

* 总体：$X\sim N(\mu,\sigma^2)$
* 样本：$(X_1,X_2,\cdots,X_n)$

## 一、期望

1. 检验：$H_0: \mu=\mu_0\qquad H_1:\mu\ne\mu_0$  
   拒绝域：$|A|>A_{\frac{\alpha}{2}}$
2. 检验：$H_0: \mu>\mu_0\qquad H_1:\mu\le\mu_0$  
   拒绝域：$$
3. 检验：$H_0: \mu>\mu_0 \qquad H_1:\mu>\mu_0$  
   拒绝域：$$

### 2. 方差已知 - u检验

$U=\frac{\bar X-\mu_0}{\sigma/\sqrt{n}}$

### 1. 方差未知 - t检验

$T=\frac{\bar{X}-\mu_0}{S/\sqrt{n}}\sim t(n-1)$

当$n$很大时，近似为正态分布，  
$t(n-1)\rightarrow Z()$

## 二、方差

*直接用$\mu$未知的。*

1. 检验：$H_0: \sigma^2=\sigma^2_0\qquad H_1:\sigma^2\ne\sigma^2_0$  
   拒绝域：$A>A_{\frac{\alpha}{2}}$
2. 检验：$H_0: \sigma^2>\sigma^2_0\qquad H_1:\sigma^2\le\sigma^2_0$  
   拒绝域：$A>A_\alpha$
3. 检验：$H_0: \sigma^2>\sigma^2_0 \qquad H_1:\sigma^2>\sigma^2_0$  
   拒绝域：$A<A_{1-\alpha}$

## 1. 期望未知

$A=\frac{(n-1)S_n^2}{\sigma^2}\sim\chi^2(n-1)$

e.g. $H_0: \sigma^2=\sigma_0^2$  
检验为：$\frac{(n-1)S_n^2}{\sigma^2}>\chi_{\frac{\alpha}{2}}^2(n-1)$
