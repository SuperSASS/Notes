# Hugo语法

## 变量

定义变量与重新赋值。

```go
// 定义变量
{{- $var := ... -}}
// 重新赋值
{{- $var = ... -}}
```

变量存在作用域，因此在`if`中的变量无法在外部使用。  
方法：在外部定义变量，然后在作用域内部重新赋值（注意不是用`:=`，否则是定义）。

参考自[Hugo框架中文文档 Hugo模板导引](https://www.andbible.com/post/hugo-templates-introduction/#variables)。

## 有关列表

如果需要裁剪【比如只选择后面若干个】，可以使用`after`函数。  
作用是选择后面的元素。

比如：

```go
{{- with (after 2 .Ancestors.Reverse) -}}
    {{- range . -}}
        <a href="{{ .Permalink }}">{{ .Title }}</a> /
    {{- end -}}
{{- end -}}
```

*如果要选择前面的元素，数组中存在方法`.Reverse`，可以翻转。*
