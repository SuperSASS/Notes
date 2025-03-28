# Cornerstone.js

## 有关Event

Cornerstone也存在各种事件，core和tools分别存在不同事件(Events)、管理器(eventTarget)。

```js
import { eventTarget, EVENTS } from '@cornerstonejs/core
```

该语句可引入事件管理器`eventTarget`和所有可订阅事件`EVENTS`。

evevtTarget的接口：

```ts
declare class CornerstoneEventTarget implements EventTarget {
    private listeners;
    constructor();
    reset(): void;
    addEventListener(type: any, callback: any): void;
    removeEventListener(type: any, callback: any): void;
    dispatchEvent(event: any): boolean;
}
```

Cornerstone内部会调用`dispatchEvent`发布事件，  
外部用`addEventListener`或remove可以订阅或TD。
