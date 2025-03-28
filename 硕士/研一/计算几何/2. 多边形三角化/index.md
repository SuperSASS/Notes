# 多边形三角化

问题来源：监控问题。  
对于房间内，用多少个监控（三角形监控区域）能监控到。

抽象为：  
对于$n$顶点的简单三角形（没有洞、不自相交、但可能形状复杂），怎么划分为若干个三角形。  
故划分的三角形一定有上界：用$n-3$条对角线、分为$n-2$个三角。

## 证明：多边形一定可三角化

*证明之后，也就是三角化的构造算法。*

分两种情况讨论：

* 线段$uv$落在$P$内部：那就直接连
* 线段$uv$穿出了$P$：作$uv$平行线，向左移，找到最远的点，然后连接左点。

## 更小的上界

上述的上界只是最大的上界，但监控可以放在顶点上、处理更多个三角形，所以还可以减少。

结论：至少$\lfloor n/3 \rfloor$个。

证明方法：利用三角化的对偶图（三角形中心点相连、形成树），对各个三角的三顶点进行三色着色。

## 将复杂的简单三角形，划分为单调多边形——多边形单调化分解算法

对简单三角形再简单化——单调多边形。  
可以沿$x$或$y$单调，如$y$：则从上往下走，线段也都是向下走的。

可以用扫描线思想来判定：

* 相邻点都比当前点高
  * start vertex：区域在其下方
  * split vertex：区域在其上方（扫描线再往下走，则会分为两个区域，故 split）
* 相邻点都比当前点底
  * end vertex：区域在其上方
  * merge vertex：区域在其下方
* 一高一低
  * regular vertex

则充要：单调多边形不含 split, merge vertex。

故划分为单调多边形方法，则是处理 split, merge vertex：

* split vertex：朝上与某顶点连线
* merge vertex：朝下与某顶点连线

利用扫描线的方法，知道该怎么向上/下连。  
扫描线记录可连点的信息（称为 helper 点），各个点都使用这个信息、也需要设置这个信息。

每个事件点处理时，既使用 helper 点、又设置 helper 点。

**算法**：扫描线算法 + 对五种点的`Handle`处理。
