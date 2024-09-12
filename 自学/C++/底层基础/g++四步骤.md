# g++ 编译过程

## 四步骤

**若干(n)个**`.h`、`.cpp`（以及其他`.hpp`等文件），最后通过`g++`变成**一个**`a.out`，一共有四个步骤：

以如下源文件为例：

```c++
// vector.h
#ifndef _VECTOR_H_
#define _VECTOR_H_

struct Vector
{
    int x, y;
    int sum();
};

#endif
```

```c++
// vector.cpp
#include "vector.h"

int Vector::sum() { return x + y; }
```

```c++
// f.h
#ifndef _F_H_
#define _F_H_

#include "vector.h"

int call_sum(Vector v);

#endif
```

```c++
// f.cpp
#include "f.h"

int call_sum(Vector v) { return v.sum(); }
```

```c++
// main.cpp
#include "vector.h"
#include "f.h"

int main()
{
    Vector v{1, 2};
    auto result = call_sum(v);
}
```

编译命令：`g++ vector.cpp main.cpp f.cpp`

其中，三个`.cpp`文件，说明本次编译含有三个**编译单元**。

### 1. 预处理 - n个编译单元 -> n个文件（单独处理） - 检查预处理指令错误和部分语法错误

预处理步骤处理源代码文件中的**预处理指令**，如 #include、#define 和 #ifdef 等**各种用`#`开头的指令**。  
这个步骤最基础的操作为：展开所有的宏定义，处理所有的条件编译指令，并且包含所有必要的头文件内容。

在这一步会检查预处理指令的错误，然后会检查部分语法错误（如没有加`;`）。

对应的分解命令是：

```bash
g++ -E vector.cpp -o vector.i
g++ -E f.cpp -o f.i
g++ -E main.cpp -o main.i
```

* 注：直接使用 -E 的话，还会生成一些用于表明源代码来源的 #line 指令，使用 -P 可以去掉这些。

---

需要了解`#include`的底层原理——就是**直接复制文件的所有内容**。

在这个步骤中展现了“包含保护宏”(`#ifndef #define #endif`)的重要性，因为`#include`可能因间接包含导致重复定义（`f.h`包含了`vector.h`，当`main.cpp`包含了`f.h`后便间接包含了`vector.h`，如果`main.cpp`再包含`vector.h`就会导致重复定义）。  
通过包含保护宏，在间接包含某头文件后，会使得以后再次包含该头文件时，因为定义了宏不满足`#ifndef`，故不会进行复制导致重复定义。

---

**生成文件**：

* 注：以下用`//`写的注释内容为个人添加，并非生成内容

```c++
// vector.i
# 0 "vector.cpp"
# 0 "<built-in>"
# 0 "<command-line>"

# 1 "vector.cpp"

# 1 "vector.h" 1
struct Vector
{
    int x, y;
    int sum();
};

# 2 "vector.cpp" 2
int Vector::sum() { return x + y; }

```

```c++
// f.i
# 0 "f.cpp"
# 0 "<built-in>"
# 0 "<command-line>"

# 1 "f.cpp"

# 1 "f.h" 1

# 1 "vector.h" 1
struct Vector
{
    int x, y;
    int sum();
};

# 5 "f.h" 2
int call_sum(Vector v);

# 2 "f.cpp" 2
int call_sum(Vector v) { return v.sum(); }
```

```c++
// main.i
# 0 "main.cpp"
# 0 "<built-in>"
# 0 "<command-line>"

# 1 "main.cpp"

# 1 "vector.h" 1 // 对应原本的 #include "vector.h"
struct Vector
{
    int x, y;
    int sum();
};
// 在完成了 #include "vector.h" 的替换后，通过 #define _VECTOR_H_ 定义了这个包含保护宏
# 2 "main.cpp" 2

# 1 "f.h" 1 // 对应原本的 #include "f.h"
// 注意：虽然 f.h 的第一行有 #include "vector.h"，但此时有 _VECTOR_H_ 宏定义，不满足 #ifndef _VECTOR_H_ ，故不会再进行复制！
int call_sum(Vector v);

# 3 "main.cpp" 2
int main()
{
    Vector v{1, 2};
    auto result = call_sum(v);
}
```

---

如果没有包含保护宏，则`main.i`的内容为：

```c++
# 0 "main.cpp"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "main.cpp"
# 1 "vector.h" 1

struct Vector
{
    int x, y;
    int sum();
};
# 2 "main.cpp" 2
# 1 "f.h" 1

# 1 "vector.h" 1

struct Vector // 可以看到 Vector 在 main.i 中定义了两次
{
    int x, y;
    int sum();
};
# 3 "f.h" 2

int call_sum(Vector v);
# 3 "main.cpp" 2

int main()
{
    Vector v{1, 2};
    auto result = call_sum(v);
}
```

### 2. 编译 - n个文件 -> n个文件（单独处理） - 检查其余语法错误

编译步骤将预处理后的文件转换为汇编语言(asm)代码。  
在这一步，编译器**将检查语法错误**，并生成对应的汇编代码。

在这一步会进一步检查语法错误，如重复定义。  
在此阶段还会**处理内联**（直接将代码替换到对应位置，不会产生“定义”（变量的内存分配、函数的代码段）。

对应的分解命令是：

```bash
g++ -S vector.i -o vector.s
g++ -S f.i -o f.s
g++ -S main.i -o main.s
```

由于汇编代码一般不会看，只展示`main.s`的内容作为示例

```asm
    .file   "main.cpp"
    .text
    .def    __main;    .scl    2;    .type    32;    .endef
    .globl    main
    .def    main;    .scl    2;    .type    32;    .endef
    .seh_proc    main
main:
.LFB0:
    pushq   %rbp
    .seh_pushreg    %rbp
    movq    %rsp, %rbp
    .seh_setframe    %rbp, 0
    subq    $48, %rsp
    .seh_stackalloc    48
    .seh_endprologue
    call    __main
    movl    $1, -12(%rbp)
    movl    $2, -8(%rbp)
    movq    -12(%rbp), %rax
    movq    %rax, %rcx
    call    _Z8call_sum6Vector
    movl    %eax, -4(%rbp)
    movl    $0, %eax
    addq    $48, %rsp
    popq    %rbp
    ret
    .seh_endproc
    .ident    "GCC: (x86_64-posix-seh-rev1, Built by MinGW-Builds project) 13.2.0"
    .def    _Z8call_sum6Vector;    .scl    2;    .type    32;    .endef
```

对应上面的没有包含保护宏导致的重复定义错误，此时对于`vector.i`和`f.i`并没有语法问题，会成功进行编译生成文件`vector.s`和`f.s`，  
但对于`main.i`，因为有重复定义`Vector`，会导致语法错误而无法编译。

### 3. 汇编 - n个文件 -> n个文件（单独处理） - 检查汇编代码错误

汇编步骤将汇编语言代码转换为机器可执行的二进制指令（通常是目标代码文件）。这是准备链接的最后一步。

在这一步会检查汇编代码是否出错，但如果正常按照`-P`和`-S`得到的汇编文件，**一般不报错误**。  
这个阶段一般很简单，就是“汇编代码 -> 机器代码”。

### 4. 链接 - n个文件 -> 1个文件（合并处理）

链接步骤将一个或多个目标文件与库和运行时代码一起合并，生成最终的可执行文件。  
在这一步，链接器**解析所有的符号引用**，确保所有函数和变量的引用都能**找到相应的定义**。

可以看到，之前在`main.i`中，只有对`call_sum`的声明，而没有定义，  
在这一步中，链接器通过所有目标代码文件(`.o`)和库文件(`.lib/.so/.dll`)等，找到声明对应的定义，故为“链接”。

## 一次定义原则(One Definition Rule, ODR)

一次定义规则是C++中的一个重要概念，应用在编译阶段，会对链接阶段造成影响。  
其规定了：

* 非内联函数、变量、类的每个实例必须在整个程序（**所有目标代码文件**，即`g++`中所有的`.cpp`文件）中有且只有**一处定义**，
* 但可以在**不同的文件**中**多次声明**（同一文件内不能多次申明，因此如果）。

如果在链接时发现有多个目标代码文件都存在对同一事物的定义，则肯定无法进行正确的链接。

> 举例：
>
> * 链接前面的阶段是制定若干个任务（对应若干个目标代码）的任务名单，只知道这个任务有哪些特工去做（一个代号对应一个特工，多个任务可以同时让一个特工来做）、但不知道这个特工具体是谁；  
> * 链接阶段则是对一个个任务点名，要将某个任务中的一个代号与具体的一个特工对应，如果点一个代号发现有多个特工同时应答，则肯定就不知道让哪个特工去参加。

**特例 - 内联操作**：

但对于进行了内联操作的事物（函数或变量(C++ 17)）来说，其在“编译”阶段会进行“内联替换”，  
对应到上面的例子，就是有些特工特别出名优秀，所以安排任务的时候直接指定了是哪位特工，而不是用代号来指定，不用在点名的时候再确定代号指的是哪位特工。
