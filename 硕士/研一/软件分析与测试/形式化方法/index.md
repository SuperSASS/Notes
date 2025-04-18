# 形式化方法测试

给予严格数学语义对软件功能规格和非功能性质进行推理证明：

* 形式化规约
  * 软件系统的数学模型
  * 软件功能需求规格/非功能需求性质（对应测试用例）
* 形式化验证：验证工具  
  算法：搜索/逻辑推理
* 判断结果

## 方法

### 1. 形式规约

用形式化语言构建，以刻画系统不同抽象层次的模型和性质。

有不同的模型语言，如：

* 面向对象的 Z 语言
* 同步数据流 Petri 网  
  侧重于表达系统的控制流
* 状态机
* SCADE 模型（同步数据流语言）

*以前的 UML 不一定是形式化语言（早期的 UML 是有二义性的），而现在 UML 2.0 消除了二义性，则是形式化语言。*

形式模型是系统某一个层次的抽象即可，不一定是系统的全部语义的表达。  
*比如关注控制流，则只抽象控制流即可。*

**针对模型（系统）规约的语言**：

1. 代数规约语言：提供“函数式编程”范式
2. 结构化规约语言：如 Z Notation、B、Event-B、rCOS
   跟写代码类似，多了特殊的数学符号/量词。  
   在计算方面不强，但在逻辑/结构表达上很强
3. 进程代数（演算）：为了并发和分布式系统，描述并发/异步/非确定的系统行为。  
   以进程为核心，定义进程与进程间交互的行为。
4. 基于迁移系统的规约：利用状态机表示，如 Petri 网  
   很广泛，很多系统本质都是状态机

**性质规约**：

只说明系统的要求，是说明性的，逻辑约束往往是最小必要的，不进行实现。

分为：

* 安全性质(safety)：不好事情不能发生（如发生死锁）
* 活性(liveness)：好的事情终究会发生（如可结束性）

**方法有**：

* Floyd-Hoare 逻辑：$\{Pre\}P\{Post\}$。如$\{x+1=43\}y:=x+1\{y=43\}$。  
  如果$\{Post\}$不满足，则$P$出错。  
  称$\{Pre\}$为 Assume；$\{Post\}$为 Assert。  
  有一些推理规则，从而进行推理，如顺序规则。
* 其他各类逻辑
  * **线性时序逻辑(LTL)**：关注某事件/状态，随着线性时间发展，其会怎么变化  
    不允许有分支（只能线性逻辑）

### 2. 形式化开发

一边开发，一边证明。  
*程序综合可看作形式化开发。*

如基于 Event-B 的形式化开发。  
将需求转换为系统 Machine（变量、不变式、事件）和上下文 Context（约束、公理定理），并不断精化(Refinement)，生成最后的代码。

### 3. 形式证明

* 交互式半自动化证明：人参与，用辅助定理证明工具  
  比较复杂，需要编写大量脚本（如`int`在数学上不存在，需要用脚本去定义）
* 自动定理证明
  如微软的 SMT Solver：可将 C 语言自动翻译，然后自动用方法求解。  
  虽然自动，但求解能力有限。

在证明不下去时，可采用“抽象解释（代码分析）”的方法，即将具体的问题域、抽象为更简单的抽象域去证明。

## 模型检验

支持并发、要求是状态有限的。

* 优点：全自动、出问题时可以给出反例。
* 缺点：会状态爆炸。

最开始提出时实用性较弱，  
后续提出了"Binary Decision Diagrams(BBD)"，能极大程度压缩状态空间，取得重大突破。  
基于此有工具“Symbolic Model Checking(SMV)”等工作。

**工具**：

* 微软 SLAM
* UPPAAL