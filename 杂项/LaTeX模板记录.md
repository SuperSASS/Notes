# LaTeX设计模板记录

## 1. 为什么每行后面要加一个%

[为什么在定义 LaTeX 命令时，很多时候都会在行尾加上百分号 %？](https://www.zhihu.com/question/53430828)

TeX 中单个**换行符等同**于一个**空格**，加上`%`可以把这个换行符造成的空格去掉。  
若该行结束是用“字母构成的命令”，则可以不加，如：

```tex
\newcommand\bar{%
  \bfseries
  \centering
}
```

还可以使用`LaTeX 3`，或者用以下方法避免加`%`：

```tex
% 将下面一行加在最前面
\endlinechar \m@ne %m@ne就是-1

% 将下面一行加在最后面
\endlinechar `\^^M %\^^M就是换行符
```

*具体原因要见TeX中的[分类码](https://www.latexstudio.net/archives/12375)。*

## 2. 有关模板(Class)的选项(Option)

```latex
\DeclareOption{}{}
```

## 3. 字体

LaTeX中有三种字体族：

* 衬线体`textrm` - 适合正文，代表为宋体
* 无衬线体`textsf` - 适合题目，代表为黑体
* 等宽字体`texttt` - 适合代码

四种基本字体效果：

* **粗体**`textbf`
* **斜体**`textit`
* 伪斜体`textsl`
* 小型大写`textsc`

> 区别 - 粗体和伪粗体/斜体和伪斜体：
>
> 两者的区别在于前者是人工设计的，拥有一个真正的字体库；  
> 后者是软件实现的，如伪粗体就是字重(笔画粗细)加粗、伪斜体就是字体错切，因此效果比前者肯定低。
>
> 在中文环境中与英文存在区别：正常为“宋体”，而粗体会变为“黑体”、斜体会变为“楷体”，会造成**字体的改变**，  
> 而在一般软件中，加粗、倾斜指的实际上是伪粗体、伪斜体，与日常习惯有区别。

## 4. 一些命令

* `\noindent` - 设置首行不缩进