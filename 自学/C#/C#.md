# C-Sharp

## 接口作为返回类型

使用接口作为返回类型，可以返回任意实现该接口的类型。

比如 API 中经常这样写：

```c#
public IActionResult Get()
{
    if ()
        return File();
    else
        return StatusCode(500, "");
}
```