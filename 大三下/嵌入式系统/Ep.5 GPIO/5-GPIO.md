# Ep.5 GPIO

## 一、概述

GPIO端口内部是由一个个寄存器组成，一个引脚对应一个寄存器、或多个引脚对应一个多位的寄存器，  
**改变**寄存器中的**数据**，就可以**改变**外设的**工作方式**。

STM32有更多I/O引脚，功能更灵活强大。

## 二、STM32F103引脚图

有144个引脚，分为6大类：

* 电源引脚：$V_{DD}, V_{SS}, V_{REF+}, V_{REF-}, V_{DDA}, V_{SSA}, V_{BAT}$
* 晶振引脚：$PC14, PC15, OSC\_IN, OSC\_OUT$
* 复位引脚：$NRST$
* BOOT引脚：$BOOT0, BOOT1$
* 程序下载引脚：$PA13, PA14, PA14, PB3, PB4$
* GPIO引脚：有7组、每组16个
  * PA组：$PA0\sim PA15$
  * PB组
  * PC组
  * PD组
  * PE组
  * PF组
  * PG组

大多数引脚存在复用，除了IO外还有专用功能。

## 三、GPIO模块标准外设库接口函数

### 1. 函数内容

GPIO的模块标准外设库接口函数，在源文件"stm32f10x_gpio.c"中，  
对应的头文件声明了GPIO所有的库函数，共18种。

### 2. 应用举例

用单个GPIO引脚输出高低电平，控制发光二级管，并按一定时间间隔改变I/O口电平，实现**灯光闪烁**。

**流程：**

1. 初始化函数
2. 无限循环功能：不断把I/O口电平反置位

**代码实现：**

* "led.h"  
  存放函数声明。
* "led.c"  
  用于GPIO端口初始化操作，即硬件驱动程序的编写。
  ```c
  void LED_Init(void)
  {
    GPIO_InitTypeDef GPIO_InitStructure;
    // 启用时钟
    PCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
    PIO_InitStructure.GPIO_Pin = GPIO_Pin_5;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitSturcture.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOB, &GPIO_InitStructure);
  }
  ```
* "main.c"  
  就是主程序，先调用`LED_Init()`，然后`while (1)`，里面延时后置位复位。

---

## 输入模式

* 上拉电阻
* 下拉电阻
* 悬空
* 模拟输入模式  
  既不连接上拉电阻也不连接下拉电阻，直接接模拟量输入。

## 输出速度

输出速度不是指输出信号的速度，而是指**I/O口驱动电路的响应速度**。  

