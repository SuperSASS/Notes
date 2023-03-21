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

## 属性 - props

属性代表**静态**数据，父组件传给子组件，过后**不能更改**！

## 状态 - state

类似于属性，不过是**动态**数据。  
相当于组件的一个私有变量，不过可以在父组件中更改，然后动态响应到子组件变化。

使用`useState(...)`生成状态，  
参数为初始数据，  
返回两个值：

* 第一个：状态变量，只读，用来传递给子组件
* 第二个：setter，用来在父组件中更新状态（数据）

```js
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
// 然后渲染根组件

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

## 监听 - effect

`useEffect`函数：

```js
useEffect(
    () => { /* 执行的逻辑代码 */ },
    [] // 监听对象，可不传
)
```

* 第一个参数：逻辑处理函数，当第二个参数中对象发生改变时，就会执行
* 第二个参数：要监听的对象
  * 不传：无限执行（每次刷新都执行）
  * 空数组`[]`：只在组件挂载的时候执行，即`componentDidMount`
  * 