# Ep.3 8086的寻址方式与指令系统

1. 有哪些寻址方式？
2. 每一种寻址方式如何得到操作数的地址？

## 一、概述

### 1. 指令

指令包含两部分：

* 操作码
* 操作数：可以为真实的**数据**，也可以为数所在内存单元的**地址**。

格式：

* 无操作数指令
* 多操作数指令（两个操作数称为双操作数或二地址指令）

> 举例 - 指令格式：
>
> * 无操作数格式：`CLI` - 清IF位
> * 单操作数格式：`INC AX` - (AX)+1→AX
> * 双操作数格式：`MOV ES, BX` - (BX)→ES（ES是目的操作数，BX是源操作数）
> * 双操作数格式：`ADD AX, [BX]` - (DS:(BX))+(AX)→AX（BX是偏移地址，与DS搭配）

### 2. 寻址技术

寻址技术是通过数据寻址方式的设定，压缩指令长度，并且灵活的寻找操作数地址；是**操作数地址**表示的一种方式。

产生不同寻址技术的原因：

* 操作数地址**表示多样化**需要
* **压缩**操作数地址字段的长度

### 3. 语言

#### (1) 机器语言

由二进制代码组成，唯一能被 CPU 识别执行。  
每一条称为指令，所能识别的所有指令集合为指令系统。

指令是计算机能够执行的最小功能单位，程序就是由一条条指令按一定顺序组织起来的**指令序列**。

#### (2) 汇编语言

是一种符号语言，将机器语言的二进制数用符号替换表示。

汇编语言编制的程序为“汇编语言源程序”，计算机不能直接识别执行，  
需要翻译成机器语言，过程称为汇编，完成汇编工作的程序为汇编程序。
