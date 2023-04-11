# JavaScript

## 1. 扩展运算符

`...`的用法：  
用于取出参数对象的所有**可遍历属性**，然后**拷贝到当前对象**之中。

一般来说用于数组或对象，  

* 对于对象，会把对象**解包**，然后把所有属性拷贝到当前对象；  
  在对象的**多重解包**时，会把**变量名作为key**，所以必须为**有名字的变量**！
* 对于数组，会把数组遍历，然后按`0`开始的数组key拷贝【原理是因为数组是特殊的对象，key自动从`0`开始  
  虽然key默认为数字，因此不用变量名，但对于多个数组扩展**会覆盖**！

```js
// 定义
let obj1 = {a:'1', b:'2'},
    obj2 = {c:'3', d:'4', e:'5'};
let arr1 = [1, 2],
    arr2 = [3, 4, 5];
let arrObj = [obj1, obj2];
```

则：

```js
// 正确用法
{...{a:'1', b:'2'}}; // {a:'1', b:'2'}
{...obj1};           // {a:'1', b:'2'}
{...{obj1}};         // {obj1:{a:'1', b:'2'}}

{...arr2}; // {0:3, 1:4, 2:5}
{...[[[1,2], {a:1, b:2}], 3]}; // {0:[内部内容], 1:3}

{...obj2, ...arr1}; // {c:'3', d:'4', 0:1, 1:2}
{...obj2, ...arr2, obj1, ...arr1}; // {0: 1, 1: 2, 2: 5, c: '3', d: '4', obj1: {…}}
{...obj1, ...arr1, obj2, ...arr2}; // {0: 3, 1: 4, 2: 5, a: '1', b: '2', obj2: {…}}

//------------------

// 错误用法
{...{ {a:'1', b:'2'} }}; // 多重解包时，内部的{a:'1', b:'2'}没名字
{...{ {obj1} }}; // 一样没名字哈
```

## 2. yeild & 生成器函数(function*, Generator)

> 补充 - 异步编程历史：
>
> 最开始是用各种回调函数（就是把函数作为另一个函数的参数，然后在**一定时机被调用**），  
> 会出现喜闻乐见的“回调地狱”，就是指这种回调函数**内嵌**很多层：
>
> ```js
> $.get('/api/data', function(data) {
>     console.log(data);
>     $.get('/api/user', function(user) {
>         console.log(user);
>         $.get('/api/products', function(products) {
>             console.log(products)
>         });
>     });
> });
> ```
>
> ---
>
> 这个问题，关键就在于内嵌，理逻辑很反人类，所以主要是先要把它变成并列形的，让**嵌套变为链式**  
> 于是最开始出现`Promise`解决方法：
>
> ```js
> let data, user;
> $.get('/api/data')
> .then(function(_data) {
>     data = _data; // console.log(data);
>     return $.get('/api/user/?data=' + data);
> })
> .then(function(_user) {
>     user = _user; // console.log(user);
>     return $.get('/api/products/?data=' + data + '&user' + user);
> })
> .then(function(products) {
>     console.log(products);
> });
> ```
>
> 但这个也只是变为链式而已，逻辑还是有些复杂。
>
> ---
>
> 再到后来，还有`async + await`方法（ES7出现，目的就是为了解决异步流程控制）：
>
> ```js
> const data = await $.get('/api/data');
> // console.log(data);
> const user = await $.get('/api/user/?data=' + data);
> // console.log(user);
> const products = await $.get('/api/products/?data=' + data + '&user=' + user);
> console.log(products);
> ```
>
> ---
>
> 包括`function* + yeild(*)`方法，也一定程度解决了这个问题。  
> （ES6出现，本质并不是为了异步，详细可见[js之yeild](https://article.itxueyuan.com/LbKwn)）

*其实有些类似于`async + await`，每次`yeild`就会停下。*

"Generator"就是一个用`function*`定义的生成器函数，会产生"Iterator"类型，可进行迭代（如用`.next`），  
在`function*`中，使用`yeild`类似于`return`，不过只是会**暂停**下面的代码，每次迭代时则继续下面的代码并再次返回。

直接看OHIF里的代码：

```js
class DicomLoaderService{
  // getLocalData(...)
  // getDataByImageType(...)
  // getDataByDatasetType(...)
  // 这三个函数，在满足一定条件后，会返回非空的东西

  *getLoaderIterator(dataset, studies, headers) { // Generator函数，里面搭配yeild，实现遍历(用for of，或for + .next()）的时候可以中途返回。
    yield this.getLocalData(dataset, studies);
    yield this.getDataByImageType(dataset);
    yield this.getDataByDatasetType(dataset);
  }

  findDicomDataPromise(dataset, studies, headers) {
    const loaderIterator = this.getLoaderIterator(dataset, studies);

    // 利用for of，对iterator进行遍历（会自动调用.next()）
    for (const loader of loaderIterator) {
      // 此时loader就相当于每次yeild后返回的东西
      if (loader) {
        return loader;
      }
    }
  }
}
```

还有些用法可以见[js-function*](https://zhuanlan.zhihu.com/p/387328357)或补充里面的文章。

## 3. bind函数

对于一个`function`，可以通过`bind`来更改其上下文对象(`this`)和绑定参数(`args`)。

需要注意，绑定参数是按从左到右的顺序，**被绑定的参数就不能再被赋值**了！【应该……

```js
const obj = {
  attr1: 233,
  attr2: "改变上下文到这个obj里了"
}

function func(arg1, arg2) { console.log(this.attr2 + ", " + arg1 + ", " + arg2); }
func("没有bind");
// underfind, 没有bind, underfind

const func_1 = func.bind(obj, "我是arg1的默认参数");
func_1();
// 改变上下文到这个obj里了, 我是arg1的默认参数, undefined
func_1("我想赋值到arg1，结果却到了arg2");
// 改变上下文到这个obj里了, 我是arg1的默认参数, 我想赋值到arg1，结果却到了arg2
```

这个bind：第一个参数会将该函数绑定到一个对象（相当于改函数内部的this），第二个参数按顺序作为被bind函数的参数