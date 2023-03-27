# Extension - 插件相关

## 个人理解的一些点

Extension就像之前说的，提供了各种模块功能(Module)，供各种Mode使用，创建不同的工作流。

## 1. 插件骨架代码

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

## 2. 官方维护的插件

| Extension | Description | Modules |
| --- | --- | --- |
| [default](https://v3-docs.ohif.org/platform/extensions/) | 默认插件，提供默认的Viewer布局、Study/Series的浏览器，映射到DICOM服务器的后端 | `commandsModule`, `ContextModule`, `DataSourceModule`, `HangingProtocolModule`, `LayoutTemplateModule`, `PanelModule`, `SOPClassHandlerModule`, `ToolbarModule` |
| [cornerstone](https://v3-docs.ohif.org/platform/extensions/) | 提供2D/3D渲染函数 | `ViewportModule`, CommandsModule, UtilityModule |
| [dicom-pdf](https://v3-docs.ohif.org/platform/extensions/) | Renders PDFs for a [specific SopClassUID](https://github.com/OHIF/Viewers/blob/master/extensions/dicom-pdf/src/OHIFDicomPDFSopClassHandler.js#L4-L6). | Viewport, SopClassHandler |
| [dicom-video](https://v3-docs.ohif.org/platform/extensions/) | Renders DICOM Video files. | Viewport, SopClassHandler |
| [cornerstone-dicom-sr](https://v3-docs.ohif.org/platform/extensions/) | Maintained extensions for cornerstone and visualization of DICOM Structured Reports | ViewportModule, CommandsModule, SOPClassHandlerModule |
| [measurement-tracking](https://v3-docs.ohif.org/platform/extensions/) | 在测量面板最终测量 | ContextModule,PanelModule,ViewportModule,CommandsModule |

## 3. 插件注册

直接在`cli`中注册，然后在`platform/viewer/pluginConfig.json`里可以看到（不要手动操作这个文件）。  
当插件在Viewer中注册后，利用Extension的id，可让`ExtensionManager`找到该插件，  
其所有的功能模块Module，都能被Modes通过`ExtensionManager`用`id`来获取到。

## 4. 生命周期函数

插件可以注入三个生命周期函数：

* `preRegistration`  
  应该是在整个Viewer应用初始化时被调用。  
  用来初始化插件状态(State)、设置用户自定的扩展配置、为服务和命令建立扩展，并启动第三方库。
* `onModeEnter`  
  在每次进入有使用该插件的新模式，或者该模式的数据(data)/数据源(datasource)切换了后调用。
  可以用来初始化数据。
* `onModeExit`  
  *【一般是用来清理的吧？……*

## 5. Context

上下文，个人感觉就是用来区分不同“环境”的，  
然后让一些功能（特别是Command），在不同环境下有不同表现（不启用/有不同逻辑功能），  
因为特别是Command会用到上下文，故应该是由Command Manager管理，由一串字符串（如`TMTV:CORNERSTONE`）定义。

## 6. ⭐Modules

Modules是插件的核心部分，也就是用来组成的各种“块”。  
用来提供“定义”、组件(Component)、过滤(Filtering)/映射(Mapping)逻辑代，然后提供给Modes和Services使用。

### Panel - 侧边栏模组

#### 定义与编写

默认的`LayoutTemplate`有左侧和右侧两个侧边栏【但好像可以制作顶侧和底侧的栏】。
> 注释 - `LayoutTemplate`：
>
> 来自于每个Mode的`index.js`里的`modeFactory()`（该函数用于对这个Mode进行配置），用来描述页面的布局。  
> 其中的`routes`属性里 的列表里 的一个元素里，存在该属性`LayoutTemplate`。

通过`getPanelModule`注册这个模组。

**函数接收**：三个`Manager`。

**函数返回**：一个“列表”，有若干个“对象”。  
每个对象即为一个Panel，包含了对该Panel的"menuOptions"和`components`组件。

其中"menuOptions"应该就是对该Panel的一些定义，比如：

* `name` - 应当就是`id`
* `iconName` - 图标的名称（应当在ui中有）
* `iconLable` - 【暂时不知道干嘛的……
* *`isDisabled` - 在某些"studies"下，可能该Panel会禁用，为一个箭头函数`studies => {}`
* `lable` - 展示的名称

而`components`则是React组件，被用来直接展示的。

以"Measure"Panel举例：

```js
import PanelMeasurementTable from './PanelMeasurementTable.js';

function getPanelModule({
  commandsManager,
  extensionManager,
  servicesManager,
}) {
  const wrappedMeasurementPanel = () => { // 对component的提取
    return (
      <PanelMeasurementTable
        commandsManager={commandsManager}
        servicesManager={servicesManager}
      />
    );
  };

  return [ // 返回的列表
    {
      name: 'measure',
      iconName: 'list-bullets',
      iconLabel: 'Measure',
      label: 'Measurements',
      isDisabled: studies => {}, // 可选
      component: wrappedMeasurementPanel,
    },
  ];
}
```

#### 在Mode中使用Panel

插件只是提供了React组件，需要在模式中具体定义怎么用。  
就是在Mode的`index.js` 中的`modeFactory` 中的`routes.layoutTemplate.props` 中的 `leftPanels`/`rightPanels`来调用Panel。

Mode中可以在左/右侧添加**若干个**Panel，其接受一个`id`的数组（`id`的格式目前已知道，之后在学习Mode中可能会具体再说），  
默认如果一侧存在Panel，都是开启的，可以设置为默认关闭，使用`rightPanleDefaultClosed`。

Mode中的`servicesManager`中存在一个`panelService`，  
可以利用触发器(`Triggers`)，使得在监听到某些操作后，对Panel进行操作（如打开或关闭Panel），如下。

```js
    onModeEnter: ({ servicesManager }) => {
      const {
        measurementService,
        panelService,
      } = servicesManager.services; // 从服务管理器中解包出所需的服务

      _activatePanelTriggersSubscriptions = [ // 这个应该是该平台的一个触发器订阅管理数组
        ...panelService.addActivatePanelTriggers('@ohif/extension-measurement-tracking.panelModule.trackedMeasurements', [ // 对id(name)为"trackedMeasurements"的Panel添加触发器
          {
            sourcePubSubService: measurementService, // 触发器监听源服务
            sourceEvents: [ // 监听事件
              measurementService.EVENTS.MEASUREMENT_ADDED,
              measurementService.EVENTS.RAW_MEASUREMENT_ADDED,
            ],
          },
        ]),
      ];
    },
    onModeExit: () => { // 退出时，要清空触发器
      _activatePanelTriggersSubscriptions.forEach(sub => sub.unsubscribe());
      _activatePanelTriggersSubscriptions = [];
    },
```

*具体应该是"Service"里的内容，这里先只做了解。*

#### 利用cli新建时的模板

**模板**：

```js
  /**
   * PanelModule 应当提供有关panels的列表，从而让OHIF Viewer在 Mode 中进行引用和渲染
   * 每个panel应当至少由`{name, iconName, iconLabel, label, component}`对象定义
   * panel模组的例子见下面的代码块
   */
  getPanelModule: ({
    servicesManager,
    commandsManager,
    extensionManager,
  }) => {},
```

**例子**：

```js
const getPanelModule = () => {
  return [
    {
      name: 'exampleSidePanel', // id
      iconName: 'info-circle-o', // 图表名
      iconLabel: 'Example', // 还是不知道这个有什么用orz……
      label: 'Hello World', // 展示名
      isDisabled: studies => {}, // 可选
      component: ExamplePanelContentComponent,
    },
  ];
};
```

### Command - 命令模组

顾名思义，就是定义各种命令的，  
用来完成特定功能、激活工具、与服务器通信、打开弹窗(Modal)等等、以及其启用条件（或者复用）。

插件可以通过定义`getCommandModule`来定义命令，  
该模组许限定在特定Context下，注册若干个命令。

Command因为以下特性功能很强大：

* 同一命令允许有多种实现
* 根据应用的Context，只有正确的一种命令实现会被运行
* Command能被快捷键、工具栏按钮、渲染设置执行

有关commandModule，一般都是单独建一个文件`commandsModule.js`，在其中配置，  
很好的模板为：

```js
// extensions/myExtension/commandModule.js
// ---------------------------------------
/* 各种导入，除了核心包中的东西，还有各个工具类(./utils) */

const commandsModule = ({ /* 3个Manager */ }) => {
    /// 1. 定义常量部分：如所需服务
    const {
        /* 需要的各种服务，如SegementationService */
    } = servicesManager.services;

    /// 2. 定义内部函数：一般如以下两个
    
    function _getActiveViewportsEnabledElement() {
    }

    function _getMatchedViewportsToolGroupIds() {
    };

    // 3. 关键部分 - 定义返回所需的actions - 即所有命令函数
    const actions = {
        getSomething: ({ /* 需要的参数 */ }) => { /* 逻辑代码、返回结果 */ },
        setSomething: ({ /* 需要的参数 */ }) => { /* 逻辑代码、返回结果 */ },
        calculateSometing: ({ /* 需要的参数 */ }) => { /* 逻辑代码、返回结果 */ },
        exportSomething: ({ /* 需要的参数 */ }) => { /* 逻辑代码、返回结果 */ },
        // ...
    }

    // 4. 关键部分 - 根据上方的actions，定义所对应的definitions - 即所提到的command的基础结构
    const defin

    return toolGroupIds;
}
```

---

### Hanging Protocol

Hanging Protocol对于所有的放射影像浏览器都是非常必要的。OHIF用Hanging Protocol来将Images（已转化为了DisplaySet）安排到Viewport中。  
可能存在多个Protocol，会计算分数，分数最高者被应用。

可以做如下事：