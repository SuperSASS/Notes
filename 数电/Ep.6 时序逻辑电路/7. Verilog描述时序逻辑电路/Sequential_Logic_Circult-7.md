# 第七节 Verilog描述时序逻辑电路

## 一、移位寄存器

* 74HC194

```verilog
module shift74x194(S1,S0,Dsl,Dsr,Q,CP,CR);
    input
    output reg [3:0]Q;

    always @(posedge CP or negedge CR)
        if (~CR) Q<=4b'0000;
        else
            case ({S1,S0})
                //保持
                Q <= {Q[2:0], Dsr} //右移
                Q <= {Dsl, Q[3:1]} //左移
                //并行输入
            endcase
endmodule
```

## 二、计数器

### 1. 同步二进制计数器

```verilog
//Behavior
module counter74x161()
    input
    output

    wire CE; //中间变量
    assign CE=CEP & CET;    //CE=1时，才开始计数
    assign TC=CET & PE & (Q=4'b1111); //进位信号

    always @ (posedge CP or negedge CR)
        if (~CR) Q <= 0;          //CR=0,清零
        else if (~PE) Q <= D;     //PE=0,预置数据
        else if (CE) Q <= Q+1b'1; //计数
        else Q <= Q;              //保持
endmodule
```

### 2. 异步二进制计数器

```verilog
module D_FF(output reg Q, input D,CP,CR) //计数器的D触发器
//由于为子模块，定义写在里面
    always @(posedge CP or negedge CR)
        if (~CP) Q <= 1b'0;
        else
            Q <= D;
endmodule

module counter(...) //计数器
    input CP,CR;
    output Q0,Q1,Q2,Q3;

    D_FF FF0(Q0, ~Q0, CP, ~CR)

    
endmodule
```

### 3. 非二进制计数器

```verilog
module counter_10(...);
    input CP,CR,PE; // PE为使能
    output reg [3:0]Q;

    always @(posedge CP or negedge CR)
        if (~CR) Q <= 4b'0000;  //清零
        else if (PE)
        begin
            if (Q >= 4'b1001) Q <= 4‘b0000; //超过10,归零
            else Q <= Q+1b'1;
        end
        else Q <= Q;
```

## 三、分频器

*所谓的分频就是降低时钟信号的频率的意思。*

```verilog
module Divider50MHz(...);
//实现思路：通过计数器，计数范围为0~24999999，记到最大值信号翻转，完成频率调整。
    parameter CLK_f = 50000000;
    parameter OUT_f = 1;

    input CR,CLK_50MHz_in;
    output reg CLK_1Hz_out;

    reg[24:0] count_div; //2^25 = 33554432 > 24999999

    always @ (posedge CLK_50MHz_in or negedge CR)
        if (!CR)
            begin CLK_50MHz_in <= 0; count_div <= 0; end //清零
        else
            if (count_div < CLK_f / 2 * OUT_f) //计数器未满，继续计数
                count_div <= count_div + 1b'1;
            else //计数器已满，翻转
            begin
                count_div <= 0;
                CLK_1Hz_out <= ~CLK_1Hz_out; //翻转语句
            end
endmodule
```

## 四、对状态图的描述

* 对于穆尔（输出只与状态有关）：  
  因为状态改变只在时序电路中，所以只用时序部分，  
  只有一个`always @(posedge CP or negedge CR)`描述时序。
* 对于米利（输出与状态和输入有关）：  
  状态改变在时序电路中，而**输入改变**是在**组合逻辑电路**中，  
  故要分为“时序”和“组合”两部分。  
  用两个`always`：
  * 时序：`always @(posedge CP or negedge CR)`  
    只用来改变现态`State_cur <= State_next`。
  * 组合：`always @(A or State_cur)`  
    用来计算次态和输出`State_next <= ...; Y <= ...;`
  
  注：因为输入变量$A$是随时都可以改的，改了之后输出$Y$也会变，  
  随时都改用“组合”，  
  时序中虽然也可以重新确定下一状态，  
  但在组合里已经算出来下一状态了，故直接赋值简单。

步骤：

1. 利用参数定义`parameter`各状态名称。
2. `always`控制同步时序逻辑部分，实现状态的存储。
3. `always`和`case`控制组合逻辑部分，实现状态转换逻辑。
4. 描述状态机的输出逻辑。