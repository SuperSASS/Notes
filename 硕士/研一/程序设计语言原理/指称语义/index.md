# 指称语义

## 基础

### 基本域

* `Character` - 字符集
* `Integer` - 整数
* `Natural` - 自然数（正整数）
* `Truth-Value` - 只包含`true`, `false`
* `Unit` - 空元组`()`（暂时用不到）

### 有关存储

是负责数据的存储的，与“地址”和“存储值”有关。

#### 域定义

* 地址域 - `Location`, 元素`loc`(L)
* 可存储值 - `Storable`, 元素`stble`
* **存储域** - `Store`, 元素`sto`(S)
  `Store = Location → (stored Storable + undefined + unused)`  
  某时刻的存储$sto^n$是**一个函数**。  
  *注：`stored`是必须要带的前缀，代表已存储值；`Storable`是对应具体的存储的值`stble`*
  * 输入：一个位置loc
  * 输出：该位置的存储的值：
    * 类型为`Storable`的已存储值`stored`
    * 分配了但未定义的`undefined`
    * 未分配（未使用）`unused`

#### 辅助函数

* `empty_store`：直接返回一个空的`sto`，该`sto`所有位置都为`unused`
* `allocate`: `allocate(sto: Store): (sto: Store, loc: Location)`  
  输入一个`sto`，将该`sto`的**某一个**`unused`的位置变为`undefined`（分配），然后返回新的`sto'`和所分配的位置`loc`
* `deallocate`: `deallocate(sto: Store, loc: Location): Store`  
  将`sto`的`loc`处取消分配（变为`unused`）
* `update`: `update(sto: Store, loc: Location, stble: Storable): Store`  
  在`sto`的`loc`位置，以`stble`更新存储值
  ```c++
  update(sto, loc, stble) = sto[loc → stored stble] // 即对loc处的值，特殊映射为stble
  ```
* `fetch`：`fetch(sto Store, loc Location) : Storable`  
  获取`sto`的`loc`位置的存储值
  ```c++
  fetch(sto, loc) = 
    let stored_value(stored stble) = stble
        stored_value(undefined) = fail
        store_value(unused) = fail
    in
        store_value(sto(loc))
  ```

### 有关环境

#### 域定义

用于存储**变量**的束定（指向什么，可能是常数，可能是内存的地址`loc`）。

* 标识符域 - `ldentifier`, 元素`I`
* 可束定对象 - `Bindable`, 元素`bdble`
* **环境域** - `Environment`, 元素`env`  
  `Environment = Identifier → (bound Bindable + unbound)`  
  *注：同上，`bound`代表已绑定*  
  是一个函数：
  * 输入：一个标识符`I`
  * 输出：是否束定，如果束定则返回`bound bdble`（后者代表已经束定的对象）；否则返回`unbound`

环境可以理解为如下格式：

`env = {i → 2, j → 3}`

#### 辅助函数

* `empty_environ`: 返回空的`env`
* `bind`: `bind(I: Identifier, bdble: Bindable): Environment`
  说明：这个函数只返回一个新的环境，该环境只包含一个元素`{I → bdble}`，需要修改环境的话则搭配`overlay(env', env)`
* `overlay`: `overlay(env': Environment, env: Environment): Environment`  
  返回的环境，对于标识符`I`：如果新的环境`env'`存在，则返回新环境中的束定对象`env'(I)`；否则返回旧环境`env`的束定对象`env(I)`
  ```pascal
  overlay(env*, env) = 
      λ I. if env*(I) ≠ unbound then env*(I) else env(I) // 注意这代表一个环境函数，接受一个I，返回一个bound Bindable/unbound
  ```
* `find`: `find(env: Environment, I: Identifier): Bindable`  
  输入环境`env`和标识符`I`，返回可束定对象（如果束定了）或者空`fail`（如果没束定）
  ```js
  find(env, I) = 
      let bound_value(bound bdbld) = bdble
          bound_value(unbound) = fail
      in
          bound_value(env(I))
  ```

## IMP

### 基础域的定义

* `Storable = Value`  
  其中`Value = truth_value Truth_Value + integet Integer`，只包含真假和整数（实际上是正整数，可见下方语法）
* `Bindable = value Value + variable Location`  
  标识符只可束定为常量 / 存储的某一位置
* `Identfier` 应该任意

### 新的域和对应的语义函数

#### ① `Command` - 命令域  

只**可能**涉及对存储的更改。

**执行命令的语义函数** - `execute`：`execute: Command → (Environment → Store → Store)`  
可写为：`execute 【C】 env sto = sto'`，  
代表对存储进行更改（注意：执行命令不涉及更改束定）

#### ② `Expression` - 表达式域

**表达式求值的语义函数** - `evaluate`: `evaluate: Expression → (Environment → Store → Value)`  
可写为：`evaluaate 【E】 env sto = value`
不会改变状态（存储/环境），只根据当前状态进行求值

#### ③ `Declaration` - 声明域

**进行声明的语义函数** - `elaborate`: `elaborate: Declaration → (Environment → Store → Environment × Store)`  
可写为：`elaborate 【D】 env sto = env' sto'`  
肯定会改变环境（因为进行了新束定），同时**声明常量时还进行了赋值**，所以也可能改变了存储。

#### ④ `Type_denoter` - 类型

### 语法

BNF 范式

#### ① Command

* 跳过 - `Skip`
* 赋值 - `Identifier := Expression`
* let - `let Declaration in Command`  
  在接下来的`Command`，声明常量或变量，用于**指定`Command`的环境（上下文）**  
  注意：这个命令相当于一个`begin end`块；声明的变量只在该块中的Commands（多个Command，可见下面“多命令”）可使用。
* 多命令 - `Command; Command`  
  连续执行两条命令（是递归定义，因此一个`Command`可包含多个子`Command`）  
* 判断 - `if Expression then Command else Command`
* 循环 - `while Expression do Command`

#### ② Expression

* 基础
  * 逻辑 - `true`, `false`
  * 正整数 - `Numeral`
  * 标识符（变量） - `Identifier`
* 运算
  * 加法 - `Expression + Expression`
  * 小于 - `Expression < Expression`
  * 非 - `not Expression`

#### ③ Declaration

* 常量 - `const Identifier = Expression`  
  常量不用存储，I直接束定到常值，故只改变环境
* 变量 - `var Identifier : Type_denoter`  
  声明变量，需要进行存储，故要分配（unused→undefined），改变环境和存储

#### ④ Type_denoter 

* 布尔 - `bool`
* 整数 - `Integer`（实际上只能是正整数）

### 语义

#### ① 各个命令的 execute 实现

实现：`execute 【C】 env sto = sto'`

只返回`sto`。

##### 1. `Skip`

##### 2. `Identifier := Expression`

首先找到变量（标识符）`I`的存储位置`loc`（束定的对象），运用环境的辅助函数`find(env: Environment, I: Identifier): Bindable`；  
然后更改`loc`的存储，运用存储的辅助函数`update(sto: Store, loc: Location, stble: Storable): Store`

```c++
execute 【I := E】 env sto =
  let val = (evaluate E env sto) in // 表达式求值
                                    // 注意，这里的let与Command中的let不一样，这里的let是λ演算里的let x = c in λx.E，相当于(λx.E)(c)，将E中的x替换为c。（下同）
    let variable loc = find(env, I) in // 可以看到，这里的 variable 还相当于一个限定词，如果find找到的是 value Value，则无法匹配，会出错
      update(sto, loc, val)
```

##### 3. `let Declaration in Command`

```c++
execute 【let D in C】 env sto = 
    let (env', sto') = elaborate D env sto in // 对接下来的 Commands 基于声明改变环境env'和存储sto'（如果声明的是变量）
                                              // 但这里只是得到了声明后的新环境，还需要进行覆写
      execute C (overlay(env', env)) sto' // 这里对环境进行了覆写
```

#### ② 各个表达式的 evaluate 实现

实现：`evaluaate 【E】 env sto = value`

##### 1. 

#### ③ 各个声明的 elaborate 实现

实现：`elaborate 【D】 env sto = env' sto'`

主要使用环境的`bind`辅助函数（`bind(I: Identifier, bdble: Bindable): Environment`）

##### 1. `const Identifier = Expression`

```c++
elaborate 【I = E】 env sto = 
    let val = evaluate E env sto in // 首先对表达式求值
      (bind(I, value val), sto) // 直接把 I 束定到 value val 这个常值Bindable上，不改变存储
```

只返回包含一个束定的环境`{I → val}`，用于let表达式（见下临时理解）

##### 2. `var Identifier : Type_denoter`

因为变量，

```c++
elaborate 【var I : T】 env sto =
    let (sto', loc) = allocate sto in // 对 sto 分配一个存储单元，得到分配后的sto'和分配的位置loc
      (bind(I, variable loc), sto') // 将 I 束定到 variable loc 这个变量Bindable上，改变了存储
```

### 实例

```pascal
// 刚开始，env = {}, sto = {}
let var i : Integer in  // 在这里，声明 i 分配了内存{0 → undefined}；创建了环境{i → variable 0(代表loc)}，然后覆写到现在的env = {}，
                        // 因此后续的env = {i → 0}，sto = {0 → undefined}
  i := 1; // 这里
  let var i : Integer in
    i := 3;
    if i < 2 then
      ...;
    else
      ...;
    ;
  ;
  

```

## 个人临时理解

* 整个程序只能写各种`Command`
* 声明`Declaration`应该只能出现在`Command`当中的let表达式  
  所以声明的实现，只返回

## 作业

增加了：

* 声明`Declaration`：
  * `*Identifier = Expression`（指针变量）
* 表达式
  * `*Identifier`：取变量的值
  * `&Identifier`: 取变量的地址

即要写以下语义：

* `elaborate 【*I = E】 env sto = ...`，返回`env', sto'`
* `evaluate 【*I】 env sto = ...`，返回`value`
* `evaluate 【&I】 env sto = ...`，返回`value`

**回答**

```c++
elaborate 【*I = E】 env sto = 
    let val = evaluate E env sto in
      let loc = 
``