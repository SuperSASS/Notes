# JavaScript

## Object

JS 中，一个 Object 是由“属性(Property)”组成的。（区别于 C++ 对象有属性和方法，而 JS 里只有属性）  
属性值可以是任意类型（包括一个函数）。

属性有两种类型：

* 数据属性（Data Property）：用于存储普通的值
* 访问器属性（Accessor Property）通过 get / set 函数来控制读取/写入

对于某个对象的属性，有“描述符(Property descriptor)”来描述“属性的特性”：

* `configurable`：布尔，是否可配置（主要是不能被`delete`删除）
* `enumerable`：布尔，是否可枚举
* 对于数据属性
  * `writable`：布尔值，是否可写
  * `value`：值
* 对于访问器属性
  * `get`
  * `set`

## 全局对象、全局词法环境(Global Lexical Environment)

在 ES6 之前，所有全局变量（ES6 之前只能`var`）都保存在全局对象中。  
在浏览器中为`window`，在 Node.js 中为`global`。

```js
var x = 3; // 会在 window 中添加属性 x = 3，且 configurable 为 false
window.y = 3; // 相比于上面，configurable 为 true，可以 delete y(delete window.y) 删除
```

但 ES6 之后，多了“全局词法环境”以及`let`, `const`，  
`let`, `const`定义的变量存在于全局词法环境。

在控制台中，存在一个局部作用域“临时交互作用域(REPL)”，通过`let, const`定义的变量存在其中，刷新后消失。

在控制台输入`y`时，会：

1. 