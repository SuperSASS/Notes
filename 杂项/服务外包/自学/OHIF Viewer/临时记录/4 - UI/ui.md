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
  numRows: null, // Grids的行数
  numCols: null, // Grids的列数
  layoutType: 'grid', // 一般都是grid吧
  viewports: [
    {
      displaySetInstanceUIDs: [], // 正在展示的DisplaySet的UID（OHIF中的UID）？
      viewportOptions: {}, // 
      displaySetOptions: [{}],
      x: 0, // left
      y: 0, // top
      width: 100,
      height: 100,
      viewportLabel: null,
    },
  ],
  activeViewportIndex: 0, // 当前选中（就是被高亮）的Viewport Index
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

**调用示例：**

```js
// extensions/measurement-tracking/src/panels/PanelStudyBrowserTracking.tsx
//-------------------------------------------------------------------------
import { useViewportGrid } from '@ohif/ui';

function name() {
    const [
        { activeViewportIndex, viewports, numCols, numRows },
        viewportGridService,
    ] = useViewportGrid();
}
```

## 2. Segmentation Group Table

说明：

* `Segmentation` - 标签组
* `Segment` - 具体到某一个标签

具体UI组件：

* `SegmentationGroupTable` - 整个组件
  * `GetSegmentationConfig` - 上方的配置栏
  * `SegmentationGroup` - 一个标签组
  * AddSegmentation