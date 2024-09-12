# 核心代码和node_module修改

## node_module

根目录下：

1. `react-vtkjs-viewport` -> `dist/index.umd.js`  
   `vtk.js/Sources`全局替换成`@kitware/vtk.js`。
2. 一样  
   找到`var orthogonalizedDirection =`，将其后面的替换为`direction`

## 核心代码

1. "interleaveTopToButton.ts"  
   将53行到55行代码注释了。
2. "DicomWebDataSource"(extensions\default\src\DicomWebDataSource\index.js)里  
   加了一个外部接口：473行`retrieveStudyMetadata`  
   配套的："IWebApiDataSource.js"(platform\core\src\DataSources\IWebApiDataSource.js)  
   也在24、70行加了`retrieveStudyMetadatas`申明
