# 上传要分割的图像

在Pannel里设置两个按钮，一个是分割当前切片，一个是分割所有。  
点击后，会调用`DicomMetadataStore`，然后把相应的`UID`传到后端。
