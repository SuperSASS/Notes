# 数字特征

与随机变量有关的某些数值，如“平均数”、“偏差值”等。

虽然不能完整地刻画随机变量，但能描述随机变量在某些方面的**重要特性**。

区别于分布：  

* 分布：完全刻画了随机变量的特征，但非常抽象且庞大、不好理解。
* 数字特征：部分刻画随机变量的特征，但很具体易于理解。

---

## 性质总结

* 期望：
  * 线性性质
    $E(aX+b)=aE(X)+b$
  * 加法性质  
    $E(X+Y)=E(X)+E(Y)$
  * 乘法性质
    * 一般：$E(XY)=E(X)E(Y)+\textrm{Cov}(X,Y)$
    * 独立：$E(XY)=E(X)E(Y)$

    注：还可以用函数的期望，$E(XY)=\int xy\cdot f(x,y)$计算。
  * 平方性质  
    $E(X^2)=E^2(X)+D(X)$
* 方差：
  * 计算方法：
    * 定义算：$D(X)=E\{[X-E(X)]^2\}$
    * **性质算：**$D(X)=E(X^2)-E^2(X)$

    对于$E(\cdots)$，采用函数期望算。
  * 线性性质  
    $D(aX+b)=a^2D(X)$
  * 加法性质
    * 一般：$D(X+Y)=D(X)+D(Y)+2\textrm{Cov}(X,Y)$
    * 独立：$D(X\pm Y)=D(X)+D(Y)$

  注：对于乘法，$D(XY)=E((XY)^2)-E^2(XY)$，独立拆开，不独立函数期望。  
* 协方差：
  * 三个计算
    * 定义：$\textrm{Cov}(X,Y)=E\{ [X-E(X)]\cdot[Y-E(Y)]\}$
    * **期望：**$E(XY)=E(X)E(Y)+\textrm{Cov}(X,Y)$
    * 方差：$D(X+Y)=D(X)+D(Y)+2\textrm{Cov}(X,Y)$
  * 与独立关系：$\textrm{独立} \Rightarrow \textrm{Cov}(X,Y)=0$，**反之不成立**。
  * 线性性质  
    $\textrm{Cov}(aX+b,cY+d)=ac\cdot\textrm{Cov}(X,Y)$
  * 加法性质  
    $\textrm{Cov}(X_1\pm X_2,Y)=\textrm{Cov}(X_1,Y)\pm\textrm{Cov}(X_2,Y)$
* 相关系数  
  $\rho(X,Y)=\frac{\textrm{Cov}(X,Y)}{\sqrt{D(X)}\sqrt{D(Y)}}$  
  协方差除两标准差。

| 分布                                         | 参数           | 数学期望            | 方差                    |
| -------------------------------------------- | -------------- | ------------------- | ----------------------- |
| 两点分布                                     | $0<p<1$        | $p$                 | $p(1-p)$                |
| 二项分布                                     | $n\ge1\\0<p<1$ | $np$                | $np(1-p)$               |
| 泊松分布：$e^{-\lambda}\frac{\lambda^x}{x!}$ | $\lambda>0$    | $\lambda$           | $\lambda$               |
| 均匀分布                                     | $a<b$          | $\frac{a+b}{2}$     | $\frac{(b-a)^2}{12}$    |
| 指数分布                                     | $\lambda>0$    | $\frac{1}{\lambda}$ | $(\frac{1}{\lambda})^2$ |
| 正态分布                                     | $\mu,\sigma>0$ | $\mu$               | $\sigma^2$              |
