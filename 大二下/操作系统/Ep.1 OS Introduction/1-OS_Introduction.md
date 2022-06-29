# Ep.1 OS Introduction

## ⭐什么是操作系统

### Convenience

**操作系统关键词**：

* Program - 软件
* Interface - 接口
* Resource managemer - 资源管理器

### Efficiency

要做的事：

* 启动终止程序
* 管理内存
* 管理IO
* 多线程
* 网络
* 安全

从内部看操作系统：资源管理

### Ability to evolve

操作系统是动态的，需要跟进升级

* Hardware upgardes - 硬件升级
* New types of hardware - 新的硬件
* New services - 新的服务
* Fixes - 补丁

## 操作系统(计算机)演变历史

1. 串行(Serial Processing)  
   没有操作系统，用于解决算术问题。  
   问题在于任务要一个个手动输入，会使外部等待时间过长。
2. 批处理(Simple Batch Systems)  
   出现了监控程序(Monitor)，并将一批任务一起送进去，使得等待时间减少。
3. 单道(Uniprogramming)
4. **多道(Multiprogramming)**  
   问题：
   * 同步
   * 互斥
   * 不确定性
   * Deadlocks - 死锁：我要你的东西你要我的东西。
5. Time-Sharing System - 分时  
   专门优化于用户的感受，减小响应时间。
6. 其他更多现代操作系统

## 操作系统的服务

1. program execution
2. IO opeartuibs
3. file systems
4. communication

**System Calls - 系统调用**：系统低层的接口API。介于用户模式和内核模式之间的接口。

* Process control
* File management
* Communication
* Others

用户可以通过系统调用来调用内核的一些函数。

## 设计操作系统

目标：分为用户的目标和系统的目标。

⚠作业出现过“单体内核微内核的区别”。

* **Monolithic Kernel - 单体内核**  
  操作系统应提供的多数功能都由这个大内核提供。
* **Microkernel - 微内核**  
  只有一些最基本的功能，其他服务则由运行在用户模式且与其他应用程序类似的进程提供。
* 模块化内核：不是内核，需要加载到内核上。
