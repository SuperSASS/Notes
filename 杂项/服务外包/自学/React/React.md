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

## 事件属性

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

## 属性 - props

属性可以理解为传递**静态**数据，是"React Component"提供给**外部**“传递数据给该组件”的接口。

父组件传给子组件，过后在子组件中**不能更改**！  
然后，父组件**更新**传递的该**值**后，若子组件不重新渲染（或父组件，父组件会带动子组件重新渲染），则子组件中**值不会改变**！

因此一般只用来：**渲染初始静态数据**，或者**初始化内部数据**。

## 状态 - state

类似于属性，是"React Component"提供给**内部**的功能，可以用来传递**动态**数据。

相当于组件内部的一个**私有变量**，  
不过如果传递的状态，在父组件中被更改，会导致父组件**重新渲染**，再导致子组件重新渲染，然后动态响应到子组件变化。

> 区别 - 状态与属性：
>
> * 属性：存在于子组件中，父组件在调用子组件时传过去。子组件中无法更改props
> * 状态：存在于**父组件**中。且！父组件中调用`setState()`后，会**重新渲染**！

使用`useState(...)`生成状态，  
参数为初始数据，  
返回两个值：

* 第一个：状态变量，只读，用来传递给子组件
* 第二个：setter，用来在父组件中更新状态（数据）

```js
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
                        setList(list.filter((x) => x.id !== item.id)); // 通过filter过滤，让这个item删除
                    }}
                />
            ))
        </div>
    )
}
/* 然后渲染根组件 */

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
```

## 副作用 - effect

### 1. 监听

*可以理解*为**监听**某数据发生变化后，执行某回调函数。【真正理解是有关“副作用”……

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
  * 不传：无限执行（每次刷新都执行）
  * 空数组`[]`：只在组件挂载的时候执行，即`componentDidMount`
  * 特定依赖项`[name]`：在依赖项发生变化（数据）或被调用（函数）后执行【注意：此时组件挂载时**仍会执行**！】  
    提醒：当逻辑处理函数中，**用到了组件的State数据**后，就最好**添加到“依赖数组”中**【就像数电里的`always`一样……、
    * 数据依赖项：数据改变时调用
    * 函数依赖项：当**监听函数被调用**时，调用该逻辑处理函数

### 2. 副作用操作

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
> * 甚至更抽象的，跳到外部的外部：比如发送网络API请求【但说实话，我不知道这个对当前系统会有什么副作用影响【因为请求一般都不会对该系统本身造成影响】，所以只能这么强制理解了orz……

在React中，副作用一般有两类：

* 调用浏览器的API：如事件监听函数、计时器函数、DOM函数、存储函数等
* 发起获取服务器数据的请求：如用`ajax`

举例：

* 设定定时器
* 修改DOM
* 存储(localstorage)
* 发送网络请求

#### (1) 发送网络请求

> 拓展 - JS发送网络请求的工具：
>
> * 底层 - 原生JS可用
>   * `fetch` - 一个请求函数
>   * `XMLHTTPRequest` - 一个请求对象
> * 封装
>   * `ajax` - `XMLHttpRequest`的封装 - 功能更多 - MVC
>   * `axios` - `ajax`的封装 - 功能更少【精简封装】，更常用 - MVVM

```js
useEffect(() => {
    async function loadData() {
        const res = await fetch(URL)
        return res;
    }

    data = loadData();
})
```

需要说明的一点：  
对于**异步**，需要按上面的方法，新建一个`async`异步函数，在里面调用`await`网络请求；然后再在逻辑代码里面调用这个函数。  
而不能直接在第一个参数外面加`async`，像下面那样是**错误的**。

```js
useEffect(async () => { await /* ... */; })
```

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

## 回调 - callback