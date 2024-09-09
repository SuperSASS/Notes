# 第四章 SQL语言及其操作

分为三个子语言：

1. DDL
2. DML
3. DCL

DCL与安全性相关，在第五章讲解。

特点：

* 功能一体化
* 语言非过程化  
  只需要告诉“做什么”，不需要定义“怎么做”。
* 交互式与嵌入式使用
* 标准化与易移植性  
  只要是RDBMS（关系型数据库）都遵守这个标准，可移植性好。
* 简单易学  
  核心功能只用九个英语动词。  
  DDL3个、DML4个、DCL2个。

---

其他有关语句的说明：

* `CASE`和`IF`的区别：  
  * `CASE` - 可用于**查询语句**`SELECT`中（最核心的作用）

    语法：

    ```sql
    CASE <属性>
      WHEN <表达式A/值A/布尔表达式A> THEN <结果A>
      WHEN <表达式B/值B/布尔表达式B> THEN <结果B>
      [,...]
      ELSE <默认结果>
    END
    ```

   对于`THEN`的结果，可提供给`SELECT`子句，  
   因此可以用于把属性的值改写为另一个值（属性为`1`则返回`'是'`），  
   也可用于计数（属性`IS NOT NULL`则返回`1`）。

   ```sql
   /* 属性值的改写 */
   ```

* 向视图创建索引：要在`CREATE()`后加`WITH SCHEMABINDING`。  
  变为：

  ```sql
  CREATE VIEW [...]
  (
    ...
  )
  WITH SCHEMABINDING
  AS
      SELECT ... FROM ... WHERE ...
  ```