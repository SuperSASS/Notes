# Manager - 容器（管理者）相关

Manager 是用来完成有关“**依赖注入**”、“注册服务”(Service Manager)、“聚合和暴露扩展功能”(Extension Manager)等目的的东西。

所有容器都在最开始就创建好了**一个实例**，所以后面只传这个全局实例就行。  
实例化代码在`platform/viewer/src/appInit.js`中：

```js
const commandsManager = new CommandsManager(commandsManagerConfig);
const servicesManager = new ServicesManager(commandsManager);
const hotkeysManager = new HotkeysManager(commandsManager, servicesManager);
const extensionManager = new ExtensionManager({
    commandsManager,
    servicesManager,
    hotkeysManager,
    appConfig,
});
```

可以看到主要就以下四类：

* Commands Manager - 注册有特殊上下文、并运行相应命令的Commands
* Services Manager - 注册所有的内置或外部服务
* Hotkeys Manager - 有关快捷键
* Extension Manager - 在App中聚合(Aggregating)、暴露(Exposing)模块(Modules)和功能(Features)

并且还存在相应依赖关系（初始化`servicesManager`需要`commandsManager`）。

## 1. Extension Manager - 插件容器

提供一些公有成员：

* `setActiveDataSource` - 设置应用当前激活的数据源(Data Source)
* `getDataSources` - 返回已注册的数据源
* `getActiveDataSources` - 返回当前激活的数据源
* `getModuleEntry` - 返回给定ID的Module(Extension.Module)

*【所以我不知道为什么是用“插件容器”来管理的数据源*……

> 解释 - 有关 DataSource：
>
> 数据源，指的是所有文件（影像/非影像）的来源，  
> 如对应"DICOM-Web"。
>
> 临时笔记#1有些记录。

### 访问Module

通过`getModuleEntry`，可以得到Module里的某一实体，  
如`extensionManager.getModuleEntry("@ohif/extension-measurement-tracking.panelModule.seriesList")`，  
可以访问：EMT插件→panelModule→seriesList，这个panel。

### 有关Data Sources

这是比较迷惑的地方，`dataSources`在这里管理。  
*【其应当作为一个服务的，比如在`DataSourcesService`中获得，但并不是orz……*

## 2. Services Manager - 服务容器

服务容器用来进行服务注册的。  
每个服务都需要一个`name`属性以区分各服务；一个`create()`方法以在容器中调用来实例化该服务。  
可在应用中通过`service`属性提供的服务容器，来访问各种注册的服务。

### 1. 服务容器的骨架

```js
export default class ServicesManager {
  constructor(commandsManager) {
    this._commandsManager = commandsManager;
    this.services = {}; // 服务实例列表
    this.registeredServiceNames = []; // 已注册的服务名列表
  }

  // 注册单个服务
  registerService(service, configuration = {}) {
    /** 有效性验证省略部分 **/

    this.services[service.name] = service.create({ // 调用传进来的service中create()方法，实例化该服务，并存储到服务列表中
      configuration,
      commandsManager: this._commandsManager,
    });
    // 用来追踪已注册服务
    this.registeredServiceNames.push(service.name);
  }

  // 注册多个服务
  registerServices(services) {
    /** ... **/
  }
}
```

### 2. 默认注册的服务

```js
// platform/viewer/src/appInit.js
// ------------------------------
servicesManager.registerServices([
  CustomizationService,
  UINotificationService,
  UIModalService,
  UIDialogService,
  UIViewportDialogService,
  MeasurementService,
  DisplaySetService,
  ToolBarService,
  ViewportGridService,
  HangingProtocolService,
  CineService,
]);
```

*具体的含义将在"Service"层次中讲到。*

### 3. 服务架构（服务的骨架）

看上面的骨架，就可以知道每个服务都需要暴露为拥有`name`属性和`create`方法的一个对象。

```js
// platform/core/src/services/ToolBarService/index.js
// --------------------------------------------------
import ToolBarService from './ToolBarService'; // 在这里面实现ToolBarService

// 导出Service
export default {
  name: 'ToolBarService',
  create: ({ configuration = {}, commandsManager }) => {
    return new ToolBarService(commandsManager);
  },
};
```

## 3. Command Manager - 命令容器

管理“上下文”(Context)和在对应上下文里的“命令”(Command/Function)。

Coomand Manager骨架如下：

```js
export class CommandsManager {
  constructor({ getActiveContexts } = {}) {
    this.contexts = {};
    this._getActiveContexts = getActiveContexts;
  }

  // 根据name，得到该上下文中的命令集
  getContext(contextName) {
    const context = this.contexts[contextName];
    return context;
  }

  /**...**/

  // 创建上下文
  createContext(contextName) {
      /** ... **/
    this.contexts[contextName] = {};
  }

  // 注册命令，就是在某上下文中放入该函数和相应选项(definition = command+option)
  registerCommand(contextName, commandName, definition) {
    /**...**/
    const context = this.getContext(contextName);
    /**...**/
    context[commandName] = definition;
  }

  // 运行命令
  runCommand(commandName, options = {}, contextName) {
    const definition = this.getCommand(commandName, contextName);
    /**...**/
    const { commandFn } = definition;
    const commandParams = Object.assign(
      {},
      definition.options, // "Command configuration" - 命令自带的选项
      options // "Time of call" info - 可能是调用时候的额外选项
    );
    /**...**/
    return commandFn(commandParams);
  }
  /**...**/
}
```

然后在App初始化文件`appInit.js`中初始化一个该实例：

```js
// platform/viewer/src/appInit.js
// ---------------------------------
const commandsManagerConfig = {
  getAppState: () => {}, // 这个好像在v3里没有实现

  /** Used by commands to determine active context */
  // 应当是默认激活的上下文
  // getActiveContexts: () => [
  //   'VIEWER',
  //   'DEFAULT',
  //   'ACTIVE_VIEWPORT::CORNERSTONE',
  // ],
  // 注：最新版本中好像删去了这部分
};

const commandsManager = new CommandsManager(commandsManagerConfig);
```

### 命令/上下文注册与管理

一般来说，Extension Manager会根据插件，自动处理上下文创建和命令注册，所以一般不需要手动注册所有命令，  
只需要在个人的插件中，创建一个`commandsModule`，就能自动在提供的上下文中进行注册。

```js
export default class ExtensionManager {
  constructor({ commandsManager }) {
    this._commandsManager = commandsManager
  }

  /** ... **/

  // 这个是私有的，所以会自动进行注册插件
  registerExtension = (extension, configuration = {}, dataSources = []) => {
    let extensionId = extension.id
    /** ... **/

    // Register Modules provided by the extension
    // 注册插件所提供的所有模组
    moduleTypeNames.forEach((moduleType) => {
      const extensionModule = this._getExtensionModule(
        moduleType,
        extension,
        extensionId,
        configuration
      )

      // 如果模组类别是`commandsModule`，则会初始化commandsModule，自动进行上下文和命令的配置
      if (moduleType === 'commandsModule') {
        this._initCommandsModule(extensionModule)
      }

      /** 注册其他模组 **/
    })
  }

  _initCommandsModule = (extensionModule) => {
    let { definitions, defaultContext } = extensionModule
    defaultContext = defaultContext || 'VIEWER' // 选择默认上下文

    // 自动创建上下文
    if (!this._commandsManager.getContext(defaultContext)) {
      this._commandsManager.createContext(defaultContext)
    }

    // 自动注册所有命令
    Object.keys(definitions).forEach((commandName) => {
      const commandDefinition = definitions[commandName]
      const commandHasContextThatDoesNotExist =
        commandDefinition.context &&
        !this._commandsManager.getContext(commandDefinition.context)

      if (commandHasContextThatDoesNotExist) {
        this._commandsManager.createContext(commandDefinition.context)
      }

      this._commandsManager.registerCommand(
        commandDefinition.context || defaultContext,
        commandName,
        commandDefinition
      )
    })
  }
}
```

【所以就不管手动创建注册了！……

### API

```js
// 运行一个command，这会运行在所有context里的所有叫"speak"的command
// 传参只能是一个object，里面包含了所有要传的参数
commandsManager.runCommand('speak', { command: 'hello' });

// 运行一个command，但只针对"DEFAULT"上下文里的"speak"
// 传参只能是一个object，里面包含了所有要传的参数
commandsManager.runCommand('speak', { command: 'hello' }, ['DEFAULT']);

// 返回指定上下文里的所有commands
commandsManager.getContext('string');
```

### Command的用处

* 对于工具(Tool)，其只能运行一个个Command  
  所以所有的工具逻辑都要写在并调用Command才行。

### 记录一下目前的Command

有三种上下文：

* `default` - default插件里的commandModule
* `CORNERSTONE` - cornerstone插件
* `TMTV:CORNERSTONE` - tmtv插件

#### default

#### CORNERSTONE

* `setToolActive` - 设置激活选中Tool
  * 参数：`{ toolName, toolGroupId = null }`  
    当`toolGroupId`不给予时，会自动获取为当前激活选中的Viewport的GroupId。

## 4. Hotkeys Manager

就纯粹管理快捷键的，添加、设置、启用、禁用……

**API：**

* `setHotkeys`: 最重要的方法，将按键(keys)和命令(commands)绑定在一起
* `setDefaultHotKeys`: 设置默认快捷键属性  
  注意这个方法并不会绑定所提供的快捷键，但当`restoreDefaultBindings`被调用时，提供的默认快捷键会被绑定
* `destory`: 重设HotkeysManager，清除所设置的快捷键，清空默认快捷键

**快捷键定义的结构：**  
需要有以下属性：

* `commandName` - 要绑定的命令名
* `commandOptions` - 给这个命令的参数（选项）
* `keys` - 被绑定的按键
* `lable` - 在“快捷键设置”面板显示的名字
* `isEditable` - 这个快捷键是否能被用户在快捷键面板上编辑

如：

```js
// platform/core/src/defaults/hotkeyBindings.js
// --------------------------------------------
export default [
  /**..**/
  {
    commandName: 'setToolActive', // 让工具激活（被选中）
    commandOptions: { toolName: 'Zoom' }, // 参数：缩放工具
    label: 'Zoom',
    keys: ['z'],
    isEditable: true,
  },
  {
    commandName: 'flipViewportHorizontal', // 水平翻转视窗
    label: 'Flip Vertically',
    keys: ['v'],
    isEditable: true,
  },
  /**..**/
]
```

幕后工作：当`setHotkeys`后，相应的在Command Manager中注册的command，将在按键按下后被运行。

补充：  
在配置文件中，如`default.js`里，也存在着快捷键设置，如下：

```js
hotkeys: [
    {
      commandName: 'incrementActiveViewport',
      label: 'Next Viewport',
      keys: ['right'],
    },
    {
      commandName: 'decrementActiveViewport',
      label: 'Previous Viewport',
      keys: ['left'],
    },
    /* …… */
    {
      commandName: 'windowLevelPreset9',
      label: 'W/L Preset 9',
      keys: ['9'],
    },
  ],
```
