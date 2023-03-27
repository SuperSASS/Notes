# OHIF-UI

OHIF-UI可能还有一些定义好的、获取上下文的命令。

## 1. 有关ViewportGrid - 获得上下文

**导入：**

```js
import { useViewportGrid } from '@ohif/ui';
```

**获得上下文：**

* `viewportState` - 有关Viewport的当前状态
* `viewportGridService` - 有关Viewport的服务（API）

具体可见下方：

```js
const DEFAULT_STATE = {
  numRows: null,
  numCols: null,
  layoutType: 'grid',
  viewports: [
    {
      displaySetInstanceUIDs: [],
      viewportOptions: {},
      displaySetOptions: [{}],
      x: 0, // left
      y: 0, // top
      width: 100,
      height: 100,
      viewportLabel: null,
    },
  ],
  activeViewportIndex: 0,
  cachedLayout: {},
};

const api = {
  getState,
  setActiveViewportIndex: index => service.setActiveViewportIndex(index), // run it through the service itself since we want to publish events
  setDisplaySetsForViewport,
  setDisplaySetsForViewports,
  setLayout,
  setCachedLayout,
  restoreCachedLayout,
  reset,
  set,
}; // 有些类似于Service中的Viewport Grid Service，但也有一点区别
```

> 调用示例：
>
> ```js
> // extensions/measurement-tracking/src/panels/PanelStudyBrowserTracking.tsx
> //-------------------------------------------------------------------------
> import { useViewportGrid } from '@ohif/ui';
>
> function name() {
>     const [
>         { activeViewportIndex, viewports, numCols, numRows },
>         viewportGridService,
>     ] = useViewportGrid();
> }
> ```
