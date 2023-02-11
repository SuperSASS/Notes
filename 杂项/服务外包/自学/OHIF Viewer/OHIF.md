# OHIF Viewer

## Architecture - 项目架构

```t
│
├── extensions                # 其他各类插件，比如Cornerstone的东西
│   ├── _example              # Skeleton of example extension
│   ├── default               # default functionalities
│   ├── cornerstone           # 2D/3D images w/ Cornerstonejs
│   ├── cornerstone-dicom-sr  # Structured reports
│   ├── measurement-tracking  # measurement tracking
│   └── dicom-pdf             # View DICOM wrapped PDFs in viewport
│
├── modes                    # 包含一系列工作流，可注册于OHIF的路由中的“模式”
│   └── longitudinal         # longitudinal measurement tracking mode
|   └── basic-dev-mode       # basic viewer with Cornerstone (a developer focused mode)
│
├── platform                 # 由OHIF提供的基本框架，即平台
│   ├── core                 # Business Logic
│   ├── i18n                 # Internationalization Support
│   ├── ui                   # React component library
│   └── viewer               # Connects platform and extension projects
│
├── ...                      # misc. shared configuration
├── lerna.json               # MonoRepo (Lerna) settings
├── package.json             # Shared devDependencies and commands
└── README.md
```

### Extensions

`extensions`目录包含了许多提供必要功能的包，如渲染图像、Study/Serial浏览器、测量追踪，  
这些可被Modes使用以创建特定的工作流

OHIF提供了许多基本的Extensions：

| Extension名称        | 描述                                                                                                                            | Modules                                                                                                                                                         |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `default`              | 基本插件，提供默认的Viewer Layout(影像查看器), Study/Series Browser(Study/Serial浏览器), 配置映射到"DICOMWeb服务器后端"的数据源。 | `commandsModule`, `ContextModule`, `DataSourceModule`, `HangingProtocolModule`, `LayoutTemplateModule`, `PanelModule`, `SOPClassHandlerModule`, `ToolbarModule` |
| `cornerstone`          | 提供2D/3D渲染功能                                                                                                           | `ViewportModule`, `CommandsModule`, `UtilityModule`                                                                                                             |
| `dicom-pdf`            | Renders PDFs for a specific SopClassUID.【暂时不懂……                                                                     | `Viewport`, `SopClassHandler`                                                                                                                                   |
| `dicom-video`          | 渲染"DICOM Video"文件.                                                                                                        | `Viewport`, `SopClassHandler`                                                                                                                                   |
| `cornerstone-dicom-sr` | 提供"Cornerstone"的插件，可视化"DICOM Structured Reports"(DICOM结构化报告文件)                                    | `ViewportModule`, `CommandsModule`, `SOPClassHandlerModule`                                                                                                     |
| `measurement-tracking` | 在右侧的"Measurement"栏中，追踪"Measurements"(即批注, Annotations)                                                    | `ContextModule`, `PanelModule`, `ViewportModule`, `CommandsModule`                                                                                              |

### Modes

一旦用户打开了`viewer`的注册的路由，这些Mode就会被使用。

> Modes与Extensions的关系：
>
> 插件提供各种功能，用来构建自己的Viewer，但面对医疗影像，我们经常有一些特殊需求，需要我们用一些核心功能、增加特殊的UI、使用自己的工作流。  
> 对于现在的`OHIF-v3`，引入了Modes的概念，通过重用来自Extension的核心功能，来构建这样的工作流。
>
> 一些典型的工作流如：
>
> * 对病变的追踪测量(Measuerment)
> * 对大脑异常的分割(Segmentation)
> * 使用AI探针(Probe)来探测前列腺癌
>
> 在上面这些工作流中，都会共享同样来自`defalut`Extension提供的核心渲染Module，但是，只有分割模式需要分割工具(Segmentation Tools)。  
> 所以，Modes是Extensions的上层，你可以自己配置来达成不同的工作流。

### Platform

#### @ohif/viewer

是有关Modes,Extensions和构建应用的核心库。  
Extensions可以传送到应用配置中，并被应用在需要的时候初始化和使用。  

在初始化时，Viewer会配置好Extensions和Modes，并构建相应路由，可以在Study List【注：就是首页】使用，或直接通过URL参数使用。  
在发布时，Modes会根据配置(Configuration)添加到应用中。

#### @ohif/core

这个库里维护并测试了基于Web的医疗影像相关的功能和类，包括在Viewer应用中用到的Managers和Services。

#### @ohif/ui

一个UI组件(Components)库，包含了所有用来构建自己的Viewer的组件，所有组件对于任意的逻辑都可以被复用。  
可以更快捷地开发一个OHIF应用，但并不是一定要使用这些组件。

### 其他问题

* 可以用Vue.js/Angular.js，但比如核心业务逻辑`@ohif/core`可直接用，但组件库`@ohif/ui`需要自己重构。

## OHIF CLI - OHIF手脚架

用来“创建/删除/安装/卸载”各种“扩展/模式”的工具。

输入`yarn run cli --help`可以看到帮助列表。

1. `create-mode` - 用来创建新的Mode模板  
   注意这个与实际项目无关，所以需要输入绝对路径，需要添加到该项目时使用`line-mode`