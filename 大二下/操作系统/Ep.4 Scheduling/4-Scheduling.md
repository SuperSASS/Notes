# Ep.4 Scheduling - 调度

内存中存在多个进程，  
每个进程要么在处理器上运行(Running)，要么在等待处理器运行或某事件发生(Not running)。  
因此需要研究处理器对进程的调度方法。

**目的**：  
让进程以系统任务要求的方式，被处理器安排执行，  
比如响应时间要求(Response time)、吞吐率(Throughput)、处理器效率(Processor efficiency)等。

## 一、Types of Processor Scheduling - 处理器调度的类型

根据处理器执行某功能（状态切换）时的相对时间比例(Relative time scales)，分为以下三类：

* Long-term scheduling - 长程调度  
  为进程创建(New → Ready(R/S))的调度。
* Medium-term scheduling - 中程调度  
  为换入换出内存(Ready(Blocked) ⇌ R/S(B/S))的调度。
* Short-term scheduling - 短程调度  
  为就绪态转入运行态(Ready → Running)的调度。
* *I/O scheduling - I/O调度  
  为可用I/O设备决定处理哪个进程的I/O请求时的调度。

![调度与状态图对应](images/4-Scheduling--03-15_20-10-52.png)

前三种属于处理器调度(Processor scheduling)，  
第四种将在后面第十一章着重讲解。

长程调度与中程调度属于系统并发度有关，于第三章有讲，  
因此本章主要讨论短程调度。  
且只考虑简单的单处理器系统的调度情况。

### 1. Long-term Scheduling - 长程调度

长程调度为被调度作业或用户程序**创建进程**、**分配**必要的系统**资源**、并将新创建的进程**插入Ready队列**。  
对于支持交换操作（换入换出）的系统来说，新加载的进程可能会进入Ready/Suspend队列。

决定以下事项：

* **Which** programs are **admitted** to the system for processing?  
  决定**哪些**程序被**加载**到系统中变为进程从而执行。  
  取决于调度算法。
* **How many** programs are admitted to the system?  
  决定多少个程度被加载。  
  取决于系统并发度(Degree of multiprogramming)。
* **When** does the scheduler be invoked?  
  决定该调度算法何时执行。
  * 当有进程终止退出(Terminate)时。
  * 当处理器空闲(Idle)超过一定时间(Threshold, 阈)时。

### 2. Medium-term Scheduling - 中程调度

中程调度为换出到磁盘的进程进入内存准备执行，或者反之。

* 配合“对换技术”使用。
* 目的是提高内存的利用率和系统吞吐量。

### 3. Short-term scheduling - 短程调度

也称"Dispatcher"（分派程序）。

* 决定内存中哪一个进程被处理器执行。
* 执行频率最高，且快速。

当当前进程阻塞，或需要抢占(Preempt)当前进程时，执行短程调度
常见发生短程调度的时机如下：

* Clock interrupts - 时钟中断
* I/O interrupts - I/O终端
* Operating system calls - 操作系统调用
* Signals - 信号发生

## 二、Criteria & Policies of Scheduling - 调度算法的规则与策略

### 1. Short-term Scheduling Criteria - 短程调度算法规则

需要对各种短程调度策略建立评判规则，  
通常有两种维度的划分分为“面向用户”和“面向系统”两个维度。

* 面向维度
  * User-oriented - 面向用户的规则：如响应时间(Response time)。
  * System-oriented - 面向系统的规则：如吞吐量(Throughput)。
  
  面向用户的规则对所有系统都很重要；  
  面向系统的规则在单用户系统(Single-user systems)中重要性较低。
* 性能维度
  * Performance-related - 与性能相关的规则：定量的，如响应时间和吞吐量。
  * Non-performance related - 与性能无关的规则：定性的，如可预测性(Predictability)。

各种调度规则如下图：

![调度规则](images/4-Scheduling--03-15_20-49-45.png)  
![Scheduling Criteria](images/4-Scheduling--03-15_20-50-11.png)

### 2. Priorities of Processes - 进程的优先级

当OS对进程分配了不同的优先级(Priority)时，  
则执行调度时需要考虑优先级。

可用排队模型表示存在优先级的调度方式：  
![优先级排队模型](images/4-Scheduling--03-15_20-56-59.png)
其中简化了多个阻塞队列，并省略了挂起队列。

用$RQ$代表不同优先级队列，  
队列按照优先级递减的顺序排列，即$[RQ_i]>[RQ_j] (i>j)$。
*需注意：在UNIX中，值越大代表的优先级越小，与上述规则反之。*

则执行短期调度时：

* 若高优先级队列($RQ_0$里存在进程，则从高优先级队列中选取进程。
  * 对于高优先级队列内部的进程，根据具体的短程调度决策(Scheduling policy)
* 若高优先级队列为空，则从下一级优先级队列($RQ_1$)中选取进程。

存在的问题为：  
处于低优先级的进程可能长期处于饥饿状态(Starvation, 指得不到处理器资源的分配)，  
若不希望该情况出现，可以让优先级随时间(age)或执行历史(execution history)而变化。

### 3. Alternative Scheduling Policies - 可选择的调度策略

#### (1) Selection Function - 选择函数

选择在Ready中的哪一个进程，转到Running执行。

$$
f(w,e,s)
$$

* $w$ - 到达时间：在Ready中等待了多长时间。
* $e$ - 执行时间：此刻位置该进程执行了多少时间。
* $s$ - 服务时间：一个进程以及它所需的服务需要多少时间。

但十分简陋，是考虑了时间，  
因此不满足评价指标中的内存指标等。

#### (2) Decision Mode - 决策模式

* 存在抢占
* 不抢占

#### (3) Turnaround Time (TAT) - 周转时间

* 普通周转时间：$TAT=w+s$
* 归一化周转时间：$nTAT=TAT/s$

## 四、调度算法

1. 什么时候做决策（什么时候计算选择函数）
2. 怎么做决策（怎么算选择函数）

### 1. First-Come-First-Serverd (FCFS) - 先到先服务

$$
f()=\max(w)
$$

公平性好（谁先来就谁先执行），非抢占  
更偏向长进程(processor-bound processes)，对短进程(I/O bound processes)不友好。

### 2. Round Robin (RR) - 轮转

是对FCFS针对短进程不友好现象的改进。

增加了一个时间片(Time slice)的限制$q$，  
当进程执行时间$e>q$时，则**抢占**(interrupt)进程。

对于$q$的选取：

* 由于进程切换、调度等都需要额外开销，所以$q$不能太小
* $q$太大，则退化为FCFS

一般将$q$定为略大于一次典型交互的时间。

> 拓展 - 虚拟轮转法 (Virtual Round Robin, VRR)

### 3. Shortest Process Next (SPN) - 最短进程优先

$$
f()=\min(s)
$$

选择服务时间最短的执行直至完成。  
不存在抢占。

对短进程友好。

### 4. Shortest Remain Time (SRT) - 最短剩余时间

$$
f()=\min(s-e)
$$

就是SPN的抢占版。

对短进程更加友好。

---

一般都用前两个（FCFS、RR），  
因为$w$（等待时间）完全可以确定，多久到就是多久，  
但对于$s$（服务时间）不能完全确定，只能估计。

#### (1) 服务时间s的估计

1. 简单算术平均
2. 指数平均

### 5. 最高响应比优先

$$
f()=\max(\frac{w+s}{s})
$$