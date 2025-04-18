# Ep.1 概述

## 一、定义

> 定义 - 嵌入式：
>
> 嵌入式系统是控制、监视或辅助设备、机器和车间运行的装置。

行业内认为嵌入式：

* 以应用为中心
* 计算机技术为基础
* 软硬件可裁剪
* 适合应用系统对功能、可靠性、成本、体积、功耗等严格要求的专用计算机系统

嵌入式的共性：

* 特定的使用场合或工作环境，是大型系统的一部分，完成具体的功能，专用性强
* 功耗低，要求高实时性、高可靠性
* 系统程序固化在内存中
* 功能单一，模块设计和实现简单
* 开发时有上位机（接受数据、发送指令）和下位机（直接控制设备）、主机和目标机的概念：主机用于程序开发；目标机作为最终的执行机
* 人际交互界面简单

## 二、区别

|          | PC                                   | 嵌入式系统                             |
| -------- | ------------------------------------ | ------------------------------------------- |
| 硬件   | 主机(CPU, 主板, 内存条, 显卡)+显示器 | MCU(CPU, ROM, RAM, 定时器, I/O接口)+(显示屏) |
| 软件   | 相对独立，可安装/拆卸      | 集成/固化在芯片中，用户不能更改（称为固件） |
| 操作系统 | Windows, Linux, iOS                  | uC/OS-II, Linux, winCE                      |

嵌入式的处理器**MCU就相当于一个计算机**，可以集成很多功能模块（如ARM芯片上加内存、蓝牙、WiFi等）。

## 三、相关概念

### 1. MCU、MPU、ARM、FPGA、DSP概念

* MCU(Micro Control Unit)：嵌入式微**控制**器（单片机），把CPU、RAM、ROM、I/O、中断系统、定时器/计时器、各种功能外设集成到一个芯片上的微型计算机系统，侧重于多功能。  
  典型的芯片：80C51系列（低端）、Atmel公司AVR单片机、ST公司的STM32系列（中端）。  
  发展：8位机（51单片机）、16位机（MSP430）、高性能的32位机（STM32）
* MPU(Micro Process Unit)：嵌入式微**处理**器，就可以理解为增强版CPU，即**不带外围功能器件**，侧重于算。  
  嵌入式微处理器系统，需要在MPU的基础上，加上外围电路和外设才能构成。
* ARM：可以指一家公司、也可以指技术（授权）、也可以指该技术下的芯片。  
  目前主要授权三个系列的芯片：ARM9、ARM11、Cortex，设计MCU、MPU等更高端产品。
* DSP(Digital Signal Processor)：数字信号处理器，用于专门处理数字信号，将数字信号处理算法用具体器件实现，相当于软件硬化。  
  有专门的硬件乘法器，专用的DSP指令，程序和数据分开存储的哈佛体系结构，支持流水线，允许同时取指令和执行指令，效率非常高。
* FPGA(Field-Programmable Gate Array)：现场可编程门阵列，相当于软件硬化，把算法固化在硬件上。

### 2. MCU开发与ARM-Linux开发的区别

* MCU开发偏向硬件，需要知道体系结构接口、各种外设
* ARM-Linux开发偏向软件，需要知道Linux内核、开发编程技术。

ARM应用开发有两种方式：

* 直接在ARM芯片上进行应用开发：不采用操作系统，称为裸机编程，应用于低端ARM，开发过程类似单片机，用轮询、简单中断的方式。  
* 在ARM芯片上运行操作系统：有一个真正的操作系统

|           | 硬件                                             | 开发方式                                                               | 开发环境                  | 启动方式                                           | 场合、行业                                                |
| --------- | -------------------------------------------------- | -------------------------------------------------------------------------- | ----------------------------- | ------------------------------------------------------ | -------------------------------------------------------------- |
| MCU开发 | 开发板（下位机）、仿真器、USB线+USB转串口线 | 直接裸机开发，处理能力有限                                    | 集成开发环境/软件(uVsion) | 上电后程序直接跳到程序入口处、实现系统启动 | 工控领域、中低端家电、可穿戴设备等（智能手环、微波炉、血糖仪） |
| ARM-Linux | 开发板（下位机）、网线、串口线、串口调试工具、SD卡 | 需外部电路，处理能力很强，通过外部电路可实现各种复杂功能，基于操作系统开发 | 集成开发环境/软件(Eclipse/QT) | 一般包括BIOS、Bootloader、内核启动、应用启动等几个阶段 | 消费电子、高端应用（智能手机、平板电脑、相机） |

### 3. 开源硬件 - Arduino和树莓派

Arduino是一款优秀的硬件开发平台，主要用于教育领域，开发方式简单，有效降低学习难度，缩短开发周期，  
很多第三发商家为Arduino设计了很多图形化编程工具，进一步降低难度。

树莓派就是一个小型的计算机，专门为学习计算机编程教育设计的一种微型电脑，尺寸小、价格便宜、性能较好，  
集成了CPU、内存、以太网接口、USB、HDMI、电视输出接口，系统基于Linux。

## 四、嵌入式系统开发流程

**嵌入式系统开发总体流程**：

* 系统总体开发
* 嵌入式软硬件开发
* 系统测试

**细分**：

1. 需求分析
2. 系统总体设计
   1. 系统总体构型
   2. 软硬件划分：什么是硬件部分、什么是软件部分
   3. 微处理器选型：选择合适级别（算力）的MCU，尽量避免算力盈余
   4. 嵌入式操作系统选择：移动端 - **安卓**/iOS；产品端 - Linux（实时性差，可改用RTLiunx, VxWorks/机器人操作系统ROS）
   5. 软硬件开发平台选择：就是开发工具/语言等
3. 系统硬件设计
   1. 硬件结构设计
   2. 绘制原理图及PCB图
   3. 硬件制作
   4. 硬件测试：Bootloader（对标电脑的BIOS）
4. 系统软件设计
   1. 软件结构设计：轮询、中断（实时性要求高，有前后台）
   2. 算法设计
   3. 代码编写
   4. 软件测试
5. 系统软硬件测试
   1. 软硬件联调测试
   2. 现场测试

### 1. 需求分析

* 功能性需求：系统是做什么目的、完成什么功能
* 分功能性需求：系统的其他属性，如物理尺寸、价格、功耗、设计时间、可靠性等

### 2. 系统总体设计

从器件选型、外设接口、成本、性能、开发周期、开发难度等多方面进行考虑。

* 嵌入式微处理器的选择
* 软硬件开发平台选择
* 嵌入式操作系统的选择
* 传感器的选择：可能需要通过算法算的较准确的测量值
* *显示设备的选择
* 是否具备联网功能
* 电源设计及其他
* 系统的可靠性：抗干扰能力、电磁干扰

**嵌入式微处理器的选型需要考虑的**：

* 基本原则：能满足具体功能性和非功能性指标的需求、市场应用广泛、软硬件配置合理
* 方法：参考选择手册、各项性能指标满足需求的MCU，从功耗、成本、体积、可靠性、速度、处理能力、接口数量、电磁兼容等方面考虑（*但对于偏软件的来说，不一定需要自己来选择*）

比如：

* 简单的智能仪器仪表设计 - 8位的8051系列
* 数字信号处理领域 - TI公司的TMx320x系列的DSP芯片
* 通信领域 - Motorola的68K系列
* 高性能、消费电子领域 - ARM

