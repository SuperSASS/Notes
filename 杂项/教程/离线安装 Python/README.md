# 离线安装 Python

## 信息

* 操作系统: Windows 7（具体版本未知） / Linux (Kylin V10)
* Python版本: 3.8.10

## 步骤

1. 在`install`目录使用安装包安装 Python
2. 解压`pip.zip`，到目录`pip`下打开 cmd，输入`python setup.py install`安装 pip
3. 到目录`basic packages`下打开 cmd，输入`pip install --no-index --find-links=packages -r requirements.txt`安装所需包

*参考自[离线安装python、pip和python的第三方库](https://blog.csdn.net/qq_43816599/article/details/130847906)。*  
*注：其中导出 requirements 的命令应为`pip list --format=freeze > requirements.txt`*

## 其它问题

1. 对于 Windows 7 系统，如果提示如下错误：  
   > One or more issues caused the setup to fail.Please fix the issues and then retry setup. For more information see the log file. Windows 7 Service Pack 1 and all applicable updates are required to install Python 3.7.7(32-bit). Please update your machine and then restart the installation

   则需要安装以下系统补丁：
   * `windows6.0-kb2533623`
   * `windows6.1-kb976932`
   * `windows6.1-kb2533552`
2. 对于 Windows 7 系统，如果在使用`matplotlib`时报错如下：  
   > ImportError: DLL load failed while importing _cext

   则需要安装`VC_redist`。
