# 第二节 SR锁存器

## 一、基本SR锁存器

### 1. 工作原理

![图 5](images/Latch%26Bistable-Multivibrator_2--11-16_12-04-35.png)  

加入了两个控制信号$S$、$R$。  
仍定义$Q$端为锁存器的输出状态。

是最简单的具有控制功能的锁存器。

---

**状态分析：**

注：$Q^n$表示现态，$Q^{n+1}$表示下一状态。

* 正常工作状态：
  1. $R=0, S=0$ - 为保持状态($Q^{n+1}=Q^n$)。  
     ![图 6](images/Latch%26Bistable-Multivibrator_2--11-16_12-08-51.png)
  2. $R=0, S=1$ - 为置$1$状态($Q^{n+1}=1$)。  
     ![图 7](images/Latch%26Bistable-Multivibrator_2--11-16_12-10-12.png)
  3. $R=0, S=0$ - 为复位状态($Q^{n+1}=0$)。  
     ![图 8](images/Latch%26Bistable-Multivibrator_2--11-16_12-12-03.png)
* 异常工作状态$R=1, S=1$：此时$Q=1, \overline{Q}=1$，不符合定义。$S,R$同时归$0$时，锁存器保持的状态也不确定。

为高电平有效（$S,R$处于高电平才会引起状态变化）。

故SR锁存器存在约束条件：
$$SR=0$$

> 应用 - 利用基本SR锁存器，消除开关触点振动的影响（去抖电路）：
>
> 对于开关，实际上操作时可能会短时间内往复抖动，导致电路不稳，  
> 利用SR锁存器，则可消除抖动的影响。
>
> ![图 10](images/Latch%26Bistable-Multivibrator_2--11-16_12-18-33.png)

---

**低电平有效的SR锁存器：**

![图 9](images/Latch%26Bistable-Multivibrator_2--11-16_12-17-47.png)  
