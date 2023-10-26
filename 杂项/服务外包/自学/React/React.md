# React

## 组件 - Component

跟Vue的概念类似。

```js
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}
```

组件为一个函数，  
接收唯一参数`props`代表组件属性，可包含数据或方法（回调函数）；  
返回一个HTML标签（React元素）。

使用组件则像HTML标签一样

```js
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

ReactDOM.render(
  <Welcome name="Sara" />, // JSX语法，为Welcome组件，参数为{name: "Sara"}
  document.getElementById('root')
);
```

## 事件触发属性 - OnClick

在React中，要使用事件触发属性，如`onclick=""`之类的，方法如下：

```js
<div onClick={ /* 一个函数 */ }>
```

就是把HTML事件变为了驼峰命名法，  
然后，里面只能传**一个回调函数名**，故不加参数。

回调函数默认可接受事件`e`，如：

```js
const clickHandler = (e) => {};

return (
    <button onClick={clickHandler}> Click </button>
);
```

若要传参数，则可在属性中用箭头函数：

```js
const clickHandler = (msg, e) => {};

return (
    <button onClick={ (e) => clickHandler('Messages', e); }> Click with msg </button>
);
```

## 属性 - Props

属性可以理解为传递**静态**数据，是"React Component"提供给**外部**“传递数据给该组件”的接口。

父组件传给子组件，过后在子组件中**不能更改**！  
然后，父组件**更新**传递的该**值**后，若子组件不重新渲染（或父组件，父组件会带动子组件重新渲染），则子组件中**值不会改变**！

因此一般只用来：**渲染初始静态数据**，或者**初始化内部数据**。

### 子组件重渲

重渲就是把**组件函数重新执行一遍**（状态不会重置，但变量的初始化会执行），
只有重渲后才能显示组件变化。

* 对于**变量型** props 改变：如`let a`, `a = a + 1`，不会引起主动重渲。
* 对于**状态型** props 改变：**会进行重渲**【原因是因为状态改变会出发父组件重渲，接着会重渲依赖该状态的子组件

*仅通过初步测试。*

## 状态 Hook - State

### 记忆、重渲

状态是用来**记忆**的变量，在多次渲染时能记住某一状态的值。

> 区别 - 状态与局部变量：
>
> * 局部变量在多次渲染中**无法持久保存**，重渲时值会恢复初始化的值。
> * 更改局部变量**不会触发渲染**。
>
> 如果**不需要保存**信息（比如只是弹窗询问立即使用的话），就**不需要State**。

最重要作用：会**重新渲染**！  
对于定义的全局变量`let a = 1;`，**改变后不会重渲**。

```js
// 假设后端API返回的数据为
function apiGetResult() {
    return {
        code: 200,
        message: "成功",
        result: [
            {id: 1, name: "一", completed: false},
            {id: 2, name: "二", completed: true},
        ],
    }
}

// 单纯一个子组件（列表的每一项）而已，不用看
function ListItem(props) {
    return (
        <div>
            <input type="checkbox" defaultChecked="{props.completed}" />
            <h1> {props.name} </h1>
            <button onClick={props.onDelete}> 删除我 </button>
        </div>
    );
}

// 根组件
function App() {
    const [list, setList] = useState(apiGetResult());

    return (
        <div>
            list.result.map((item) => (
                <ListItem
                    name = {item.name}
                    completed = {item.completed}
                    onDelete = {() => {
                        // 运用setter，更改状态，达成动态数据
                        // 通过filter过滤，让这个item删除
                        setList(list.filter((x) => x.id !== item.id));
                    }}
                />
            ))
        </div>
    )
}
/* 然后渲染根组件 */
```

### 父子传递

类似于属性，是"React Component"提供给**内部**的功能，可以用来传递**动态**数据。

相当于组件内部的一个**私有变量**，  
不过如果传递的状态，在父组件中被更改，会导致父组件**重新渲染**，再导致子组件重新渲染，然后动态响应到子组件变化。  

> 区别 - 状态与属性：
>
> * 属性：存在于子组件中，父组件在调用子组件时传过去。子组件中无法更改props
> * 状态：存在于**父组件**中。且！父组件中调用`setState()`后，子组件会**重新渲染**！

### 快照特性

State 存在“快照”特性，即可以把每次网页渲染看成一次快照，  
**当前快照的 State 不能变**，只能改变下一个快照（渲染）的 State。

如下代码：

```js
// number 是一个状态，初值为0
setNumber(number + 5);
setTimeout(() => {
  alert(number);
}, 3000);
```

尽管执行并渲染后（时间远小于3s）`number`已经是5，但这是3s后的快照，  
对于`alert`记录的是3s之前的快照，即**显示的还是0**。

可以用“**代替法**”来验证快照属性，即把 State 都代替为当前值。

### 使用方法

使用`useState(...)`生成状态，  
**参数为初始数据**，  
**返回两个值**：

* 第一个：状态变量，只读，用来传递给子组件
* 第二个：setter，用来在父组件中更新状态（数据）  
  存在**两种调用方法，具有不同效果**：
  * 传函数`(state) => {}`：会将函数 push 入“**更新队列**”，**最后依次执行**。其中传入**当前**状态值（在这之前有`setState`，传改变过后的值）到`state`。
  * 直接赋值`x`：相当于`setState(State => x)`，如果只有直接赋值的话，只**执行最后的叠加效果**，可以用**代替法**检验（如多次`setNumber(number + 1)`，但每次`number`都是`0`，而且只执行最后的`setNumber`，故均为`1`）

```js
// number = 0
setNumber(number + 5);
setNumber(number + 5);
setNumber(n => n + 1);
setNumber(42);
```

最后答案是42，经过变化：5`(set(5))`→5`(set(5))`→6`(set(5+1))`→42`set(42)`。

按照以下逻辑：

```js
for (work of queue) { // queue为set队列
    if (typeof work === typeof baseState) // 传入set的为直接赋值
      finalState = work;
    else // 传入set的为函数赋值
      finalState = work(finalState);
}
```

使用**传函数赋值法**，最常见在于统一处理逻辑（回调函数中）**存在延时**(`await`)。

### 特性 - 状态的销毁重置

当所存在的组件移除了 DOM 中，即不被显示后，**状态会销毁**并不再记录。  
当被隐藏的组件重新显示后，**状态会重置**。

如果要保留状态，常用方法是“状态提升（到父组件）”  
其它可以看[为被移除的组件保留 state](https://react.docschina.org/learn/preserving-and-resetting-state#preserving-state-for-removed-components)

### 实践 - 对象状态看作只读

需要把所有存放在 state 中的 JavaScript 对象都视为**只读**的。【虽然可以改，但不会重渲】  
也就是说如设置了`object`的 state，不能`object.a = 10`这样直接更改，  
而是要**先拷贝**，再**更改拷贝**，再**赋值**。

## 关键字、组件强绑定关系 - key

`key`在 React 中是一个非常重要的属性，  
其决定了**组件的顺序**，从而决定了组件是相同还是不同的，  
再从而决定**更改属性或状态时是否销毁重置或继续显示**。

具体的若干关于`key`的练习和影响可以看[对 state 进行保留和重置中的练习](https://react.docschina.org/learn/preserving-and-resetting-state#challenges)。

## 副作用 Hook - Effect

### 1. 监听

*可以理解*为**监听**某数据发生变化后，执行某回调函数。
**注意**：如果只是为了防止反复计算而想用这个，请用`useMemo`。  
【真正理解是有关“副作用”……

`useEffect`函数：

```js
useEffect(
    () => { /* 执行的逻辑代码 */ },
    [] // 监听对象，可不传
)
```

* 第一个参数：逻辑处理函数，当第二个参数中对象发生改变时，就会执行  
  *应该*不接受参数，  
  可选**返回一个函数**，在组件被销毁时执行，常用来[清除副作用](#3-清除副作用)。
* 第二个参数：要监听的对象
  * 不传：无限执行（每次重渲都执行）
  * 空数组`[]`：只在组件挂载的时候执行，即`componentDidMount`
  * 特定依赖项`[name]`：在依赖项发生变化（数据）或被调用（函数）后执行【注意：此时组件挂载后**仍会执行**！】  
    提醒：当逻辑处理函数中，**用到了组件的Prop, State数据**后，就最好**添加到“依赖数组”中**【就像 Verilog 里的`always`一样……
    * 数据依赖项：数据改变时调用【目前感觉支持 Prop、State 和 context 的监听，而对于组件外部的变量【比如某全局变量】则不能监听
    * 函数依赖项：当**监听函数被调用**时，调用该逻辑处理函数【存疑：如果内部会调用该函数呢？……  
      ![图 1](images/React--03-30_03-48-04.png)

均是在**重渲完成页面展现**后执行。

### 2. 副作用操作（主要使用方式）

> 理解 - 什么是副作用：
>
> 函数一般就是为了作为一个独立的模块/黑箱，  
> 因此外部（调用者）在调用的时候，只需要在内部**做好内部的操作**，然后返回外部所需的结果（数据）即可。
>
> 都是这么希望的，但显然大多数函数并没有这么乖，会去影响外部的东西，  
> 因此如果被调用函数内部，影响了外部的东西的话，就会给外部带来不可估计的影响，边称为“副作用”。
>
> 比如：
>
> * 参数传引用，然后修改了参数
> * 修改了外部（全局）变量
> * 调用外部系统接口：比如发送网络API请求  
>   【但说实话，我不知道这个对当前系统会有什么副作用影响【因为请求一般都不会对该系统本身造成影响】，所以只能这么强制理解了orz……  
>   【个人再理解：副作用对应于纯函数（纯粹），要求每次相同输入（运行）会得到同样结果，而对于调 API，这个完全取决于服务器端，相同输入也不一定得到相同结果，所以不纯粹，归类为有副作用。

在React中，副作用一般有两类：

* 调用浏览器的API：如事件监听函数、计时器函数、DOM函数、存储函数等
* 发起获取服务器数据的请求：如用`ajax`

**举例**：

* 设定定时器
* 修改DOM
* 存储(localstorage)
* 发送网络请求

故⚠**使用注意**：

Effect 通常用于**暂时“跳出” React 代码**并**与一些 外部 系统进行同步**。这包括**浏览器 API、第三方小部件，以及网络等等**。  
如果你想用 Effect 仅**根据其他状态调整某些状态**，那么 你可能不需要 Effect。

### 3. 清除副作用

组件产生的副作用很可能是周期的、一直存在的，  
如果组件在销毁后，不清除这些副作用，会导致问题。

> *大致*说明 - 组件销毁：
>
> 一般就是父组件不再渲染该子组件后，子组件自动销毁。  
> 比如：
>
> ```js
> return (
>     <div>
>         { flag ? <Son /> : null }
>     </div>
> )
> ```
>
> 当`flag`在`true`和`false`中反复横跳时，`Son`子组件就会反复生死。

常见的就是**消除定时器**。

**方法：**

在逻辑处理代码的最后中，返回一个*应当是无参*的箭头函数：

```js
useEffect(
    () => {
        // 逻辑代码
        // 为了体现清楚副作用的必要，在这里设置一个定时器
        let timer = setInterval(() => { /* 周期执行的代码 */ }, 1000);

        // 组件销毁后，执行的代码
        // 这里用于清除定时器
        return () => { clearInterval(timer); }
    }
)
```

### 4. 举例

需要**时刻注意清除副作用**！

#### (1) 发送网络请求（获取数据）

> 拓展 - JS发送网络请求的工具：
>
> * 底层 - 原生JS可用
>   * `fetch` - 一个请求函数
>   * `XMLHTTPRequest` - 一个请求对象
> * 封装
>   * `ajax` - `XMLHttpRequest`的封装 - 功能更多 - MVC
>   * `axios` - `ajax`的封装 - 功能更少【精简封装】，更常用 - MVVM

在这里也需要注意清楚副作用：  
如果中止获取数据，虽然不能中止网络请求，但是需要**阻止获取的数据进行系统内状态更改**。

```js
useEffect(() => {
    let abort = false;
    async function loadData() {
        const result = await fetch(URL)
        !abort ? setData(result);
    }

    loadData();

    return () => { abort = true; } // 当中止获取后，标记 abort
})
```

需要说明的一点：  
对于**异步**，需要按上面的方法，新建一个`async`异步函数，在里面调用`await`网络请求；然后再在逻辑代码里面调用这个函数。  
而不能直接在第一个参数外面加`async`，像下面那样是**错误的**。

```js
useEffect(async () => { await /* ... */; })
```

#### (2) 控制非 React 组件（调用非 React API）

比如一个地图组件：

```js
useEffect(() => {
  const map = mapRef.current;
  map.setZoomLevel(zoomLevel);
}, [zoomLevel]);
```

#### (3) 订阅事件

```js
useEffect(() => {
  function handleScroll(e) {
    console.log(window.scrollX, window.scrollY);
  }
  window.addEventListener('scroll', handleScroll);
  return () => window.removeEventListener('scroll', handleScroll);
}, []);
```

### 5. 不用 Effect 的情况

#### (1) 进行 UI 渲染计算

*注意区分“计算”（纯函数）和“处理”（由副作用、会进行更改）。*

如果想只根据根据 `props` 和 `state` 的组合处理更新 UI：

1. 可以直接在渲染时定义`const`来得到计算后的 UI。
2. 如果计算代价昂贵、可以使用`useMemo`，而不是贪图`useEffect`的监听重调用。

#### (2) props 更改后重置所有 / 部分 States

可能想到用`useEffect`，但很不好很低效！

```js
// 要把对于不同userId，要把comment重置
export default function ProfilePage({ userId }) {
  const [comment, setComment] = useState('');

  // 🔴 避免：当 prop 变化时，在 Effect 中重置 state
  useEffect(() => {
    setComment('');
  }, [userId]);
  // ...
}
```

回想起`key`的作用：当`key`变化时，组件就会重新加载，以**重置所有 State**  
因此改用：

```js
export default function ProfilePage({ userId }) {
  return (
    <Profile
      userId={userId}
      key={userId}
    />
  );
}

function Profile({ userId }) {
  // ✅ 当 key 变化时，该组件内的 comment 或其他 state 会自动被重置
  const [comment, setComment] = useState('');
  // ...
}
```

如果只重置部分 State，可以考虑**把该 State 变为计算属性**。

## 上下文 Hook - Context

* 创建上下文 - `const MyContext = createContext(defaultValue)`  
  注意：`defaultValue`指的时，当不处于上下文环境（子组件在组件树中，没搜索到该名字的Context），默认返回该值。
* 提供上下文 - 父组件中要用`<MyContext.Provider value={...}>`，将要使用这个上下文的子组件给包裹住。
* 使用上下文 - `const ctx = useContext(MyContext)`，  
  子组件会不断往父级搜索，直到找到**最近的`Provider`**（所以存在`Provider`覆盖）；没找到则用`defaultValue`。
  一般写作`const useMyContext = () => useContext(MyContext);`，  
  然后就可以像hook一样用`useMyContext()`得到上下文了。

个人理解：就是可以用`createContext()`创建一个全局上下文；  
一般是**父层**创建Context，然后用Provider给所有子组件；  
然后自组件可以用`useContext()`获取上下文的值。

```ts
// 父组件.jsx
//-----------
const initContext = 0;
const MyContext = createContext(); // 这里一般不传参，上下文要在Provider中指定数据，一般用state或reducer指定
// 因此MyContext更多地只是像个名字

const ParentComponent = () => {
    const [someVarSonWillUse, setSomeVarSonWillUse] = useState(initContext); // 用状态存context

    return (
        <div>
            <MyContext.Provider value={someVarSonWillUse}> // 在这里的Provider中，才利用上下文进行传值
                <SonComponent /> // 只有在这里面的组件可以用该上下文，类似于C#
            </MyContext.Provider>
        </div>
    )
}
```

```ts
// 子组件.tsx
//-----------
const SonComponent = () => {
    const iWantUseContext = useContext(MyContext); // 可以看到，父方标签为MyContext，这里只是作用名字，最后获得的是Provider.value

    // 拿到父组件中的值后的逻辑代码
}
```

## 高级状态 Hook - Reducer

### 一般用法

与state一样，都是**存状态**的，  
但`reducer`更适合复杂状态（比如对象）、以及更新逻辑复杂（指的是`setState()`，对同一状态可能有不同的更新逻辑（CURD）。

> 原因 - 为何取名为`reduce`：
>
> 来源于数组函数`arr.reduce`，会遍历数组进行**累积操作**，  
> 该函数基本用法如下：
>
> ```js
> // 数组求和
> const arr = [1, 2, 3, 4, 5];
> const sum = arr.reduce((result, number) => result + number); 
> // 一般记作：(prev, cur) => {...}，prev则代表累积值，cur则代表当前遍历值
> // 执行效果：1 + 2 + 3 + 4 + 5 = 15
> ```
>
> `arr.reduce`会接受“**目前累积的结果**”(`prev`)和“**当前的值**”(`cur`)，然后返回(`return`)**下一个结果**，  
> 而 React 的 Reducer 也一样：接受“**目前的状态**”和“**状态改变行动**(`action`)”，然后返回“**下一个状态**”。这样，**action 会随着时间推移累积到状态中**。

格式：

```js
const [stateObj, stateObjDispatch] = useReducer(reducer, initStateObj);
```

* `initStateObj` - 初始状态  
  因为为复杂状态，一般都是对象，会初始化赋给`stateObj`。
* `reducer` - reducer 函数  
  用来处理状态变化逻辑（不是直接调用的），以形成`dispatch`在之后用于改状态，  
  之后调用`dispatch`时传入“操作”，则根据`reducer`，派发到相应`action`处理逻辑  
  **接受两个参数**：
  * `state` - 就是要更改的状态  
    *会**自动**根据用`useReducer`使得`dispatch`绑定的`stateObj`**赋值***
  * `action` - 代表对这个状态的各种操作  
    一般用`switch`表示分支，每个分支**最好返回一个值**作为新状态值，否则会继续下一个`case`。  
    ⚠注意：只能返回一个新值，**不能直接修改状态**。
  
  ```js
  const someStateReducer = (someState, action) => {
    switch (action.type) {
        case 'action1_Add' : {return newState}
        case 'action2_Sub' : {return newState}
        default: {throw Error("未定义操作");}
    }
  };
  ```

* `stateObjDispatch` - 就用来触发`reducer()`的，根据其函数计算的返回值得到新`stateObj`  
  虽然`reducer()`有两个参数，但`state`是自动传进去的，也就是说**只用传`action`。**  
  `action`是对象，最好有一个属性为`type`，定义更新状态的方式。

  调用该方法时一般用如下形式：

  ```js
  stateObjDispatch({
    type: 'action1_Add', // 根据规范一般第一个都是type
    // 往后随便加，相当于参数
    args: ['args1', 'args2']
  })
  ```

* `stateObj` - 类比于`useState`得到的`state`【不过这里一般复杂，故为对象】

因此，综合运用：

```js
const initialState = {count: 0};

const reducer = (state, action) => {
  switch (action.type) {
    case 'inc':
      return {count: state.count + action.val};
    case 'dec':
      return {count: state.count - action.val};
    default:
      throw new Error();
  }
};

function CounterComponent() {
  const [state, dispatch] = useReducer(reducer, initialState);
  return (
    <div>
      Count: {state.count}
      {/* 以下都调用reducer里对应的type方法 */}
      <button onClick={() => dispatch({type: 'dec', val: 1})}> 减1 </button>
      <button onClick={() => dispatch({type: 'inc', val: 1})}> 加1 </button>
      <button onClick={() => dispatch({type: 'inc', val: 5})}> 加5 </button>
      {/* 调用了未定义的type，会报错，方便调试 */}
      <button onClick={() => dispatch({type: 'mul', val: 5})}> 乘5 </button>
    </div>
  );
}
```

### 与 State 区别

来自于[对比 useState 和 useReducer](https://react.docschina.org/learn/extracting-state-logic-into-a-reducer#comparing-usestate-and-usereducer)

Reducers 并非没有缺点！以下是比较它们的几种方法：

* 代码体积：  
  通常，在使用 useState 时，一开始只需要编写少量代码；而 useReducer 必须提前编写 reducer 函数和需要调度的 actions。  
  但是，当多个事件处理程序**以相似的方式修改 state** 时，useReducer 可以减少代码量。
* 可读性：  
  当状态更新逻辑足够简单时，useState 的可读性还行；但是，一旦逻辑变得复杂起来，它们会使组件变得臃肿且难以阅读。  
  在这种情况下，useReducer 允许你将**状态更新逻辑**与**事件处理程序**分离开来。
* 可调试性：  
  当使用 useState 出现问题时, 你很难发现具体原因以及为什么。  
  而使用 useReducer 时， 你可以在 **reducer 函数中通过打印日志**的方式来观察每个状态的更新，以及为什么要更新（来自哪个 action）。 如果所有 action 都没问题，你就知道问题出在了 reducer 本身的逻辑中。  
  然而，与使用 useState 相比，你必须单步执行更多的代码。
* 可测试性：  
  reducer 是一个不依赖于组件的纯函数。这就意味着你可以单独对它进行测试。一般来说，我们最好是在真实环境中测试组件，但对于复杂的状态更新逻辑，针对特定的初始状态和 action，断言 reducer 返回的特定状态会很有帮助。
* 个人偏好：  
  并不是所有人都喜欢用 reducer，没关系，这是个人偏好问题。你可以随时在 useState 和 useReducer 之间切换，它们能做的事情是一样的！

如果你在修改某些组件状态时经常出现问题或者想给组件添加更多逻辑时，我们建议你还是使用 reducer。  
当然，你也不必整个项目都用 reducer，这是可以自由搭配的。你甚至可以在一个组件中同时使用 useState 和 useReducer。

### Reducer 编写指南

* `reducers`必须是纯粹的（纯函数）  
  与状态更新函数(`setState(() => {})`)相似。  
  故**不应该包含异步请求、定时器或者任何副作用**（对组件外部有影响的操作）。  
  它们应该以**不可变值的方式**去更新“对象”和“数组”（即新建副本并用`set`改）。
* 每个`action`（调`dispatcher`传的参）都描述了一个单一的用户交互  
  比如重置一个表单，应该设置一个`reset`，而不是调用若干个`set`重置。

因为`reducers`必须纯粹，不能直接修改`state`，有点麻烦，  
所以可以用下面的`Immer`，在每个`case`中通过**直接修改`draft`即可**，也**不用返回值**。  
详见[使用 Immer 简化 reducers](https://react.docschina.org/learn/extracting-state-logic-into-a-reducer#writing-concise-reducers-with-immer)

### 高级/规格用法 - 搭配context实现状态管理

```js
DEFAULT_STATE = {
    name: 'Super SASS',
    sex: 'qwq',
    x: 0,
    ifClosed: true,
    numbers: [1, 3, 5],
    response: {
        code: 200,
        data: {}
    },
    objs: [
        {},
        {}
    ]
}

const SuperSASSContext = createContext(DEFAULT_STATE); // 注意哈，这个只是个名字，

export default ComplexComponent() {
    // 定义Reducer
    /// 1. 判断action类型(action.type)
    /// 2. 根据不同类型，以及参数(action.payload, 跟state格式大致一致)，执行不同逻辑代码
    /// 3. 每个case返回的时候，都用{ ...state, ...{...} }的格式
    const SuperSASSReducer = (state, action) => {
        switch (action.type) {
            case 'CHANGE_SEX': {
                return { ...state, ...{ sex: action.payload } };
            }
            case 'CHANGE_objs':{
                const payload = action.payload;
                const { newObjs } = payload; // 如[ {obj1arr1:1, obj1arr2:2}, {obj2arr1:3, obj2arr2:4} ]
                const objs = newObjs;
                return { ...state, ...{ objs } } // 会将objs属性覆盖为新数组
            }
            // Other case
            default:
                return action.payload;
        }
    };

    // 根据Reducer和初始状态，定义状态变量State和设置方法Dispatch
    const [SuperSASSState, SuperSASSDispatch] = useReducer(SuperSASSReducer, DEFAULT_STATE);

    // 定义一些状态修改方法
    const setSex = useCallback(
        sex => SuperSASSDispatch({ type:'CHANGE_SEX', payload: {sex} }),
        [SuperSASSDispatch] // 使得每次在setSex被调用后，调用Dispatch后，才会进行重渲
    )

    // 返回该父组件，调用子组件并传递上下文
    return (
        <SuperSASSContext.Provider value={/* 任意想传递的东西，就比如状态 */SuperSASSState}>
            {children}
        </SuperSASSContext.Provider>
    )
}
```

## 记录 / 引用 Hook - Ref

### 记录（不推荐常用）

因为在组件中用`let`申明的局部变量**不具备“记忆”功能**（每次重渲会被初始化），  
如果希望**组件“记住”某些信息**，但又**不想让这些信息的更新导致触发新的渲染**时，就可以使用`ref`。

`useRef`与`useState`具有非常相似的关系，  
`state`几乎完全可以代替`ref`（反之不行），`ref`在这种情况可以看作对`state`不重渲的优化，  
以下是具体区别：

| `ref`                                                   | `state`                                                                                    |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `useRef(initialValue)`返回 `{ current: initialValue }`  | `useState(initialValue)` 返回 `state` 变量的当前值和一个 `state` 设置函数 (`[value, setValue]`) |
| 更改时**不会触发**重新渲染                     | 更改时**触发重新渲染**                                                           |
| 可变 —— 你可以在渲染过程之外修改和更新 `current` 的值。 | “不可变” —— 你必须使用 setter 函数来修改 `state` 变量，从而排队重新渲染。 |
| 你不应在渲染期间（可理解为组件`return`里）读取/写入 `current` 值。 | 你可以随时读取 `state`。但是，每次渲染都有自己不变的 `state` 快照。 |

---

* 定义方法：`const varRef = useRef(initVal);`
* 使用（读/写）方法：`varRef.current`
* **使用时机**
  * 存储`timeout ID`（一些token，比如计时器取消token等）
  * 存储操作 DOM 元素（见下）  
    通常用在聚焦、滚动等非破坏性操作（不会直接更改 DOM）
  * 存储不需要被用来计算 JSX（渲染逻辑） 的其他对象，  
    即需要存储一些值，但不影响渲染逻辑（**否则更新的时候不会重渲**）。

### 引用 HTML DOM

```js
/* 定义 Ref */
const ref = useRef();
const inputRef = useRef<HTMLInputElement>(null);

/* 绑定到 DOM 上 */
return (
  <div ref={ref}>
    <input ref={inputRef}>输入框：</input>
  </div>
)
// 然后可以通过 ref.current 访问 DOM 元素（但不要直接更改，因为没有用，只是引用）
```

只是单方面用来引用HTML元素的（单方面绑定），  
而不是用来直接改变，然后影响HTML元素的（但应该可以调用其元素的方法来影响），因为更改`ref.current`不会重渲。

*如果要绑定不确定个数的列表 DOM，可参考[如何使用 ref 回调管理 ref 列表](https://react.docschina.org/learn/manipulating-the-dom-with-refs)。*

### 引用 React 组件

为了安全性，默认 React 组件不可被 Ref 引用（`current`会为`null`）（因为直接操作 DOM 本身就是很脆弱的操作），  
如果需要，在定义的时候要使用`fowardRef`，如下：

```js
/* 原本 */
function MyInput(props) {
  return <input {...props} />;
}

/* 修改 */
const MyInput = forwardRef((props, ref) => {
  return <input {...props} ref={ref} />;
});
```

还可以搭配`useImperativeHandle`，使得**只暴露部分操作**：

```js
const MyInput = forwardRef((props, ref) => {
  // 新增：
  const realInputRef = useRef(null);
  useImperativeHandle(ref, () => ({
    focus() { // 只暴露 focus，没有别的
      realInputRef.current.focus();
    },
  }));
  return <input {...props} ref={realInputRef} />;
});
```

## 其它非主流 Hook

### 嵌套对象 / 数组型 State 优化 Hook - Immer

* 存在于库：`import { useImmer } from 'use-immer';`
* 构建方法：与`useState`相同
  
  ```js
  const [person, updatePerson] = useImmer({
    name: 'Niki de Saint Phalle',
    artwork: {
      title: 'Blue Nana',
      city: 'Hamburg',
      image: 'https://i.imgur.com/Sd1AgUOm.jpg',
    }
  });
  ```

* 更新方法：

  ```js
  function handleNameChange(e) {
    updatePerson(draft => { // 类似于setState，不过可以用函数赋值
      // 会把原对象作为参数传进来，要求返回新赋值对象
      draft.name = e.target.value;
    });
  }
  ```

### 生成唯一 ID - Id

在组件的顶层使用`useId()`，可以生成唯一的 ID 。

一个组件中可以调用多次`usdId()`，生成不同的唯一 ID ，
同一组件即便被复用多次，每个组件之间的 ID 也不同。

**用途**：

* 可以作为无障碍属性的 ID  
  `<input aria-describedby={inputHint}>`和`<p id={inputHint}>`
* 可以用作若干相关组件的 ID  
  `<label htmlFor={id}>`和`<input id={id}>`

### UI 优化

#### 回调 Hook - Callback

就可以理解为创建一个回调函数。

如果用普通地方法创建回调(`const comHandler = () => {}`)，然后传入子组件props后，  
每当父组件刷新，不仅会重新创建函数实例（虽然花销小），更重要的是，会让子组件props变化，从而重新渲染。

因此可以用`callback`创建一个回调函数，  
使得父组件重新渲染时，该回调函数不会重新生成（或根据依赖项判断是否重新生成），  
从而使得子组件不重新渲染（或根据依赖判断是否因重新生成而重新渲染）。

```js
const commandHandler = useCallback((/* params */) => {
        /* Logics */
    },
    [/* deps */]
)
```

* 第一个参数 - 回调函数，正常的写即可
* 第二个参数 - 依赖项（跟`useEffect()`类似）
  * 不传：每次刷新都新建函数
  * 空数组`[]`：只在组件挂载的时候新建函数，即`componentDidMount`
  * 特定依赖项`[name]`：在依赖项发生变化（数据）或被调用（函数）后新建函数【注意：此时组件挂载时**仍会执行**！】  
    * 数据依赖项
    * 函数依赖项

#### 非阻塞 UI 更新状态 - Transition

在顶层声明一个`Transition`：

```js
import { useTransition } from 'react';

function TabContainer() {
  const [isPending, startTransition] = useTransition();
  // ……
}
```

之后就可以使用该`Transition`，进行不阻塞 UI 线程的状态更新（`setState`），如：

```js
  // ……
  function selectTab(nextTab) { // 加载一个选项页，需要耗时很久（如带await）
    startTransition(() => {
      setTab(nextTab);
    });
  }
```

#### 使用延迟旧值 - useDeferredValue

当异步更改某值时，所该值需要长时间才能更新好，可以用`useDeferredValue`保存旧值，用来呈现到 UI 上稳定用户。

```js
import { useState, useDeferredValue } from 'react';

function SearchPage() {
  const [query, setQuery] = useState('');
  const deferredQuery = useDeferredValue(query); // 当 query 长时间忙时，该变量存储旧值
  // ...
}
```

在返回的组件中：

```js
    const isStale = query !== deferredQuery; // 当值还没更新完成，该值为true

      <Suspense fallback={<h2>Loading...</h2>}>
        {/* 用 CSS 表示还没更新完成 */}
        <div style={{
          opacity: isStale ? 0.5 : 1,
          transition: isStale ? 'opacity 0.2s 0.2s linear' : 'opacity 0s 0s linear'
        }}>
          <SearchResults query={deferredQuery} /> {/* 主要是这里，要使用defer值 */}
        </div>
      </Suspense>
```

#### 记忆（缓存）重渲计算值 - Memo

```js
import { useMemo } from 'react';

function TodoList({ todos, tab, theme }) {
  const visibleTodos = useMemo(
    () => filterTodos(todos, tab), // 纯函数计算函数：没有参数，返回任意值。用作变量的计算值，在初次渲染会被调用得到初值
    [todos, tab] // 依赖列表，在初次渲染后，若依赖列表的所有项均没变化，则不重算值（确保计算所用的都在依赖列表，类似 Verilog 的`always @(*)`）
  );
  // ...
}
```

## React 自带组件

### 加载前展示 - Suspense

```tsx
<Suspense fallback={<Loading />}>
  <SomeComponent />
</Suspense>
```

* `{children}`：为真正的 UI 渲染内容
* `fallback`：真正的 UI 未渲染完成时**代替其渲染**的备用 UI，一般是轻量的骨架图(Glimmer)  

## 一些总结辨析

### 1. React 组件的三种逻辑类型

1. 渲染逻辑代码（`return`）  
   就是对应渲染的组件，接收 `props` 和 `state`，计算（注意不是处理改变）后，得到屏幕上看到的 JSX。  
   故渲染逻辑代码必须是纯粹的，只计算，不修改其它外部状态。
2. （用户）事件处理程序（`handle`）  
   对应**特定用户操作**进行处理，会引起副作用，改变程序状态。  
   比如点击。
3. （渲染）副作用处理程序（`effect`）  
   **不由用户（而由渲染本身）引起的事件**进行处理，会引起副作用，改变程序状态。  
   比如加载页面后要自动连接到服务器