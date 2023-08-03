# Content目录

## 页面(Page)属性

Content中每个`.md`文件，都会对应一个Page（页面），  
有两种页面，分别为“叶子页面”和“分支页面（非叶子页面）”。

|                  | 叶子页面                                                 | 分支页面                                                      |
| ---------------- | ------------------------------------------------------------ | ----------------------------------------------------------------- |
| 作用           | 单个页面的内容（index.md里的东西）和附件（各种其他文件）集合 | Section页面的附件集合（Section包括home, section, taxonomy, term） |
| **索引文件名** | `index.md`                                                   | `_index.md`                                                       |
| 允许的资源  | 页面(page)和非页面类型（如图片、pdf、zip、exe等各种类型） | 只允许非页面资源                                          |
| 资源存放位置 | 在该叶子页面目录下的任意文件夹内             | 只允许跟分支页面在同一级目录下（也就是`_index.md`文件所在目录） |
| Layout(布局)类型 | "single"                                                     | "list"                                                            |
| 嵌套           | 不允许再嵌套任何页面【都已经是叶子了…… | 可以再嵌套分子页面或叶子页面【再建文件夹就可以…… |
| 有关非页面文件 | 只能作为Page resources访问                             | 只能作为Regular pages访问                                   |
| 文件举例     | `content/posts/my-post-article/index.md`                     | `content/posts/_index.md`                                         |

存在以下属性：

* `kind` - 页面类别
  * `home` - `content/index.md`
  * `page` - 某一个`index.md`（除首页外）
  * `section` - 某一个`_index.md`
  * `taxonomy` - 某种大的分类方法，比如categories、tags
  * `term` - "taxonomy"下的某种类别

## 有关Section

对应于`content`目录下各个文件夹的层次结构，Hugo会为其生成Section Tree。  
但需要某一目录下有`_index.md`文件，才会作为Section。

默认情况下，`content/`目录下的所有一级目录，都会形成一个Section（根Section），只要它们构成了分支页面（就是有`_index.md`）。  
就算是一级目录，但如果只有叶子页面（就是没有`_index.md`），也不会形成Section。

如果需要更深层级，就再新建个文件夹，并且建立`_index.md`即可。

**需注意**：Section的名字（作用于展示为url上的）只与目录文件名有关，且无法更改【我觉得这个设定有点蠢orz……

## 有关 Taxonomy

是用来进行分类的，  
不仅是用目录(categories)分类，还可以用标签(tags)分类。

相当于对于一堆东西，对其某一属性(taxonomy)来分类，属性会有不同取值，每一个取值下对对应某些东西。  
> 比如：
>
> 一堆游戏(Left 4 Dead 2, CS:GO, FF14, Marfusha)，
> 根据游戏类型(taxonomy = gametype)来分类：
>
> * 对于FPS游戏(term = FPS)有："Left 4 Dead 2"、"CS:GO"、"Marfusha"；
> * 对于RPG游戏(term = RPG)有："FF14"、"Marfusha"；
>
> 可以看到对于同一个东西，可能同时分到不同term中，不是互斥的。  
> 然后还可以根据好玩程度(taxonomy = like)来分类。

Hugo默认开启的就是上面两个：categories、tags，  
可以根据需要关闭，可见["Taxonomies"](https://gohugo.io/content-management/taxonomies/)。

## 渲染方式

每个页面，都由`baseof.html`开始，一般在里面申明各种`block`，然后再其他类别中定义。

* single(单页面) - page  
  由"layout"中的`single.html`渲染
* list(列表页) - home, section, taxonomy, term  
  由"layout"中的`list.html`渲染

不过针对本主题，以下layout：

* 主页(home) - `layout/index.html`
* 归档(archives) - `layout/_default/archives.html`
* 搜索 - `layout/page/search.html`

*“关于”页面是单页面、“友链”页面是列表页。*

---

对于每个Page，可以在Front Matter中自定义使用的`layout`，  
比如这里就把各个子目录`_index.md`的渲染方式定成了跟"archives"一样的。

## 杂项

### 添加Diagrams(Mermaid)

以后要用的话可见[Diagrams](https://gohugo.io/content-management/diagrams/)。
