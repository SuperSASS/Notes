# LeftPanel 有关左侧Series栏的流程

对于基本模式(longitudinal)的左侧栏，地址为：  
`extensions/measurement-tracking/src/panels/PanelStudyBrowserTracking`

在双击Series的时候（包括Image和NonImage），流程如下：

1. 调用`onDoubleClickThumbnailHandler()`函数（因为绑定了组件的`onDoubleClickThumbnail`）  
   *并且可以看到上方的单击事件是空的*
2. 在其中，调用`HangingProtocolService`的`getViewportsRequireUpdate()`，获得更新后的Viewport  
   函数定义在`platform/core/src/services/HangingProtocolServices`里。  
   但有些诡异的是，对于单Viewport还好；多Viewport（多窗口）的话，会找不到下面各种东西，直接返回。
   参数传递：
   * `viewportIndex` - 来自于activeViewportIndex（这里是从UI获得的，我觉得可以从**服务**里的`getState().activeViewportIndex`得到）
   * `displaySetInstanceUID`（来自于这个`StudyBrowser`*UI组件传的参数*？？）  
     `onDoubleClickThumbnail={onDoubleClickThumbnailHandler}`
3. 最后，调用`viewportGridService`的`setDisplaySetsForViewports()`，更改Viewport的DisplaySet  
   参数是`getViewportsRequireUpdate()`返回的。
