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
│   └── basic-dev-mode       # basic viewer with Cornerstone (a developer focused mode)
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

## Configuration - 配置

### 1. Configuration Files - 配置文件

Viewer的特性、注册的插件的特性，都被放在配置文件中。

配置文件存放在`<root>/platform/viewer/public/config`，可以看到有很多配置文件，  
使用的配置文件根据环境变量`APP_CONFIG`决定，默认是`APP_CONFIG`。

## OHIF CLI - OHIF手脚架

用来“创建/删除/安装/卸载”各种“扩展/模式”的工具。

输入`yarn run cli --help`可以看到帮助列表。

### 1. create-(mode/extension)

用来创建新的Mode（模板）或Extension（插件）。

注意这个与实际项目无关，这里创建的是一个通用的Mode，  
所以需要输入绝对路径，需要添加到该项目时使用`link-mode`。

### 2. (link/unlink)-(mode/extension)

将本地(local)的mode或extension，链接或取消链接到这个Viewer中。

暂时不清楚在部署时的作用等，先放着。

### 3. (add/remove)-(mode/extension)

`add`将在线发布(存在于npm中)的mode或extension，安装到本项目中，  
安装mode时，会自动安装依赖的extension。  
直接安装发布的插件也可以。

官网上有个例子，[安装提供的`mode-clock`的示例mode](https://v3-docs.ohif.org/development/ohif-cli#add-mode)。

`remove`就是移出，移出mode时会自动移出依赖的包。

### 4. list / search

`list`展示已安装(`add`)的mode和extension（不清楚是否会展示链接进来的）；  
`search`搜索已发布的npm包（mode和extension），还可以加上`--verbose`获得更多详细信息。

### 5. 其他

* 有关`PluginConfig.json`，存放在`platform/viewer/PluginConfig.json`，手脚架自动管理，不需要手动修改
* [有关npm的私有仓库，如果需要用到可以参考](https://v3-docs.ohif.org/development/ohif-cli/#private-npm-repos)

## 插件开发方法

在[Contributing](https://v3-docs.ohif.org/development/contributing#when-changes-impact-multiple-repositories)中展示了，在本地开发插件的方法。

## Platform - 整个平台

### Scope of Project - 项目范围

「图」

"Viewer"平台只保有了很少的私有数据，范围仅局限于缓存用户偏好项、以前的查询参数等内容，  
因此"Viewer"本身是高度可配置的，通用的，能通过任何可以通过Web访问的数据源访问（Image）数据。

OHIF本身是HTML+CSS+JS的集合，是静态的资源，所以只要放在能存放展示静态资源的网站上即可。  
其类似于PWA(Progressive Web Application, 渐进式网页应用)。

> 拓展 - PWA：
>
> 是谷歌提出的新时代的Web应用方式，让网页变为类似于手机的原生App应用，  
> 可以像App一样“安装”在手机上，以某种程度离线使用，拥有通知推送，以及就像原生App而非Web运行（有应用图表、打开没有地址栏等）。  
> 就类似于Chrome中“添加到桌面上”，以及Chromebook中各种网页应用。
>
> 核心原理是Servive Worker，内部的Cache技术让其可以离线使用，Web App Manifest允许定义应用的metadata，使其类似于App。

因此"Viewer"只是个**不提供任何Image数据的浏览器**，  
所有的studies, series, images, imageframes, metadata都要来自于外部的数据源，有许多方式来提供这些数据，  
"OHIF Viewer"提供对受 *OpenID-Connect* 保护的服务的配置和支持。

*OpenID-Connect的概念在之后再做了解。*

### Theming - 主题

跟**CSS**相关的，本项目采用的是“Tailwind CSS”，  
简单理解用法的话，就是直接在HTML标签的`class`属性里，加上对应样式的值，从而应用各种样式。

在本项目应该配置了一些Tailwind CSS属性，部分代码如下：

```js
module.exports = {
  prefix: '',
  important: false,
  separator: ':',
  theme: {
    screens: {
      sm: '640px',
      md: '768px',
      lg: '1024px',
      xl: '1280px',
    },
    colors: {
      overlay: 'rgba(0, 0, 0, 0.8)',
      transparent: 'transparent',
      black: '#000',
      white: '#fff',
      initial: 'initial',
      inherit: 'inherit',

……
```

需要自定义的时候可以去改改看。

同时，最后举了一个设置“White Labeling”（相当于项目logo）的教程，  
直接在所使用的配置文件`default.json`中，按照教程修改即可。

其中用到了React的`createElement()`，来创建HTML元素，简单解释一下：  
三个参数：

* 第一个 - 标签名，字符串，如`'a'`
* 第二个 - 各类标签属性，对象，如`{className: 'w-8 h-8', href: '/'}`
* 之后若干个（可选） - 若干子元素，每个使用`React.createElement()`创建。

### Internationalization - 国际化

*之后有需要再补充……*

### 四个重要层次

很重要的四个层次：

* Extension - 插件
  * Modules - 模块
* Mode - 模式
* Service - 服务
* Managers - 管理容器

## Extension - 插件相关

### 个人理解的一些点

插件就像之前说的，提供了各种模块功能(Module)，供各种Mode使用，创建不同的工作流。

### 1. 插件骨架代码

```js
export default {
  /**
   * 必要属性，每个插件不同。
   * 一般都是有个"id.js"，里面id来源于"package.json"里的"name"
   * 然后index.ts(x)中直接`import { id } from './id'`
   */
  id,

  // Lifecyle - 生命周期函数
  preRegistration() { /* */ },
  onModeEnter() { /* */ },
  onModeExit() { /* */ },

  // Modules - **所有的**模块
  /// 目前个人理解的是：**只能**有这些模块，然后提供给服务（目前作用不明确）和模式使用
  /// 每个模块最终返回的都是一个固定格式的字典（python的概念）的列表（但还没看到有多个的情况），大致为`return [ {name: '...', component: ..., ...}, ... ]`
  /// 特别是Mode中使用，在声明的时候，格式为：`插件id.模块名(下面的去掉get, 首字母小写).返回的name`
  getLayoutTemplateModule() { /* */ },
  getDataSourcesModule() { /* */ },
  getSopClassHandlerModule() { /* */ },
  getPanelModule() { /* */ },
  getViewportModule() { /* */ },
  getCommandsModule() { /* */ },
  getContextModule() { /* */ },
  getToolbarModule() { /* */ },
  getHangingProtocolModule() { /* */ }, // 模块名字为去掉get，即HangingProtocolModule
  getUtilityModule() { /* */ }, // 模块名字为UtilityModule
}
```

### 2. 官方维护的插件

| Extension | Description | Modules |
| --- | --- | --- |
| [default](https://v3-docs.ohif.org/platform/extensions/) | 默认插件，提供默认的Viewer布局、Study/Series的浏览器，映射到DICOM服务器的后端 | `commandsModule`, `ContextModule`, `DataSourceModule`, `HangingProtocolModule`, `LayoutTemplateModule`, `PanelModule`, `SOPClassHandlerModule`, `ToolbarModule` |
| [cornerstone](https://v3-docs.ohif.org/platform/extensions/) | 提供2D/3D渲染函数 | `ViewportModule`, CommandsModule, UtilityModule |
| [dicom-pdf](https://v3-docs.ohif.org/platform/extensions/) | Renders PDFs for a [specific SopClassUID](https://github.com/OHIF/Viewers/blob/master/extensions/dicom-pdf/src/OHIFDicomPDFSopClassHandler.js#L4-L6). | Viewport, SopClassHandler |
| [dicom-video](https://v3-docs.ohif.org/platform/extensions/) | Renders DICOM Video files. | Viewport, SopClassHandler |
| [cornerstone-dicom-sr](https://v3-docs.ohif.org/platform/extensions/) | Maintained extensions for cornerstone and visualization of DICOM Structured Reports | ViewportModule, CommandsModule, SOPClassHandlerModule |
| [measurement-tracking](https://v3-docs.ohif.org/platform/extensions/) | 在测量面板最终测量 | ContextModule,PanelModule,ViewportModule,CommandsModule |

### 3. 插件注册

直接在`cli`中注册，然后在`platform/viewer/pluginConfig.json`里可以看到（不要手动操作这个文件）。  
当插件在Viewer中注册后，利用Extension的id，可让`ExtensionManager`找到该插件，  
其所有的功能模块Module，都能被Modes通过`ExtensionManager`用`id`来获取到。

### 4. 生命周期函数

插件可以注入三个生命周期函数：

* `preRegistration`  
  应该是在整个Viewer应用初始化时被调用。  
  用来初始化插件状态(State)、设置用户自定的扩展配置、为服务和命令建立扩展，并启动第三方库。
* `onModeEnter`  
  在每次进入有使用该插件的新模式，或者该模式的数据(data)/数据源(datasource)切换了后调用。
  可以用来初始化数据。
* `onModeExit`  
  *【一般是用来清理的吧？……*

### 5. Modules

Modules是插件的核心部分，也就是用来组成的各种“块”。  
用来提供“定义”、组件(Component)、过滤(Filtering)/映射(Mapping)逻辑代，然后提供给Modes和Services使用。

---

## 杂项

### 插件开发

* 插件开发（不一定适用）  
  在[Contributing](https://v3-docs.ohif.org/development/contributing#when-changes-impact-multiple-repositories)中展示了，在本地开发插件的方法。
