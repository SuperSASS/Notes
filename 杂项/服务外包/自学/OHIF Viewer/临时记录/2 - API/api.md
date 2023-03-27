# API

## DICOM-Web Client

```js
// 路径
// node_modules/dicomweb-client/src/api.js
```

这个框架里，有关DICOM-Web服务封装的API调用客户端……

顺序（可能是中途的顺序）：

1. 调用各个请求，如`_httpGet`/`_httpPost`等
2. 函数里会生成一个函数`_httpRequest`，里面就是进行具体的HTTP请求的函数。  
   会传最终的几个参数：
   * `url` - 最终的请求URL
   * 方法 - 如`post`/`get`
   * `headers` - 头
   * `{}` - 暂时不知道是啥
3. 函数生成后，就会进行执行，并返回结果

所以之前SEG加载不出来的关键原因在于URL出错。