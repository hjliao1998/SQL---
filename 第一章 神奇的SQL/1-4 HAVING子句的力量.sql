 /*1 寻找缺失的编号 */
CREATE TABLE SeqTbl
(seq  INTEGER PRIMARY KEY,
 name VARCHAR(16) NOT NULL);

INSERT INTO SeqTbl VALUES(1,	'迪克');
INSERT INTO SeqTbl VALUES(2,	'安');
INSERT INTO SeqTbl VALUES(3,	'莱露');
INSERT INTO SeqTbl VALUES(5,	'卡');
INSERT INTO SeqTbl VALUES(6,	'玛丽');
INSERT INTO SeqTbl VALUES(8,	'本');

/* 如果有查询结果，说明存在缺失的编号 */
SELECT '存在缺失的编号' AS gap
  FROM SeqTbl
HAVING COUNT(*) <> MAX(seq);
/* 查询缺失编号的最小值 */
SELECT MIN(seq + 1) AS gap
  FROM SeqTbl
 WHERE (seq+ 1) NOT IN ( SELECT seq FROM SeqTbl);

/*2 用HAVING子句进行子查询：求众数(求中位数时也用本代码) */
CREATE TABLE Graduates
(name   VARCHAR(16) PRIMARY KEY,
 income INTEGER NOT NULL);

INSERT INTO Graduates VALUES('桑普森', 400000);
INSERT INTO Graduates VALUES('迈克',     30000);
INSERT INTO Graduates VALUES('怀特',   20000);
INSERT INTO Graduates VALUES('阿诺德', 20000);
INSERT INTO Graduates VALUES('史密斯',     20000);
INSERT INTO Graduates VALUES('劳伦斯',   15000);
INSERT INTO Graduates VALUES('哈德逊',   15000);
INSERT INTO Graduates VALUES('肯特',     10000);
INSERT INTO Graduates VALUES('贝克',   10000);
INSERT INTO Graduates VALUES('斯科特',   10000);

/* 求众数的SQL语句（1）：使用谓词 */
SELECT income, COUNT(*) AS cnt
  FROM Graduates
 GROUP BY income
HAVING COUNT(*) >= ALL ( SELECT COUNT(*)
                             FROM Graduates
                         GROUP BY income);
/* 求众数的SQL语句(2)：使用极值函数 */
SELECT income, COUNT(*) AS cnt
  FROM Graduates
 GROUP BY income
HAVING COUNT(*) >=  ( SELECT MAX(cnt)
                        FROM ( SELECT COUNT(*) AS cnt
                                 FROM Graduates
                             GROUP BY income) TMP) ;

/*3 用HAVING子句进行自连接：求中位数*/
/* 求中位数的SQL语句：在HAVING子句中使用非等值自连接 */
SELECT AVG(DISTINCT income)
  FROM (SELECT T1.income
          FROM Graduates T1, Graduates T2
      GROUP BY T1.income
               /* S1的条件 */
        HAVING SUM(CASE WHEN T2.income >= T1.income THEN 1 ELSE 0 END) 
                   >= COUNT(*) / 2
               /* S2的条件 */
           AND SUM(CASE WHEN T2.income <= T1.income THEN 1 ELSE 0 END) 
                   >= COUNT(*) / 2 ) TMP;
/*4 查询不包含NULL的集合 */
CREATE TABLE Students
(student_id   INTEGER PRIMARY KEY,
 dpt          VARCHAR(16) NOT NULL,
 sbmt_date    DATE);

INSERT INTO Students VALUES(100,  '理学院',   '2005-10-10');
INSERT INTO Students VALUES(101,  '理学院',   '2005-09-22');
INSERT INTO Students VALUES(102,  '文学院',   NULL);
INSERT INTO Students VALUES(103,  '文学院',   '2005-09-10');
INSERT INTO Students VALUES(200,  '文学院',   '2005-09-22');
INSERT INTO Students VALUES(201,  '工学院',   NULL);
INSERT INTO Students VALUES(202,  '经济学院', '2005-09-25');
/* 查询“提交日期”列内不包含NULL的学院(1)：使用COUNT函数 */
SELECT dpt
  FROM Students
 GROUP BY dpt
HAVING COUNT(*) = COUNT(sbmt_date);
/* 查询“提交日期”列内不包含NULL的学院(2)：使用CASE表达式 */
SELECT dpt
  FROM Students
 GROUP BY dpt
HAVING COUNT(*) = SUM(CASE WHEN sbmt_date IS NOT NULL
                           THEN 1
                           ELSE 0 END);
/*5 用关系除法运算进行购物篮分析 */
CREATE TABLE Items
(item VARCHAR(16) PRIMARY KEY);
 
CREATE TABLE ShopItems
(shop VARCHAR(16),
 item VARCHAR(16),
    PRIMARY KEY(shop, item));

INSERT INTO Items VALUES('啤酒');
INSERT INTO Items VALUES('纸尿裤');
INSERT INTO Items VALUES('自行车');

INSERT INTO ShopItems VALUES('仙台',  '啤酒');
INSERT INTO ShopItems VALUES('仙台',  '纸尿裤');
INSERT INTO ShopItems VALUES('仙台',  '自行车');
INSERT INTO ShopItems VALUES('仙台',  '窗帘');
INSERT INTO ShopItems VALUES('东京',  '啤酒');
INSERT INTO ShopItems VALUES('东京',  '纸尿裤');
INSERT INTO ShopItems VALUES('东京',  '自行车');
INSERT INTO ShopItems VALUES('大阪',  '电视');
INSERT INTO ShopItems VALUES('大阪',  '纸尿裤');
INSERT INTO ShopItems VALUES('大阪',  '自行车');
/* 查询啤酒、纸尿裤和自行车同时在库的店铺：错误的SQL语句 */
SELECT DISTINCT shop
  FROM ShopItems
 WHERE item IN (SELECT item FROM Items);
/* 查询啤酒、纸尿裤和自行车同时在库的店铺：正确的SQL语句 */
SELECT SI.shop
  FROM ShopItems SI, Items I
 WHERE SI.item = I.item
 GROUP BY SI.shop
HAVING COUNT(SI.item) = (SELECT COUNT(item) FROM Items);
/* COUNT(I.item)的值已经不一定是3了 */ 
SELECT SI.shop, COUNT(SI.item), COUNT(I.item)
  FROM ShopItems SI, Items I
 WHERE SI.item = I.item
 GROUP BY SI.shop;--错误做法
/* 精确关系除法运算：使用外连接和COUNT函数 */
  SELECT SI.shop
    FROM ShopItems AS SI LEFT OUTER JOIN Items AS I
      ON SI.item=I.item
GROUP BY SI.shop
  HAVING COUNT(SI.item) = (SELECT COUNT(item) FROM Items)   /* 条件1 */
     AND COUNT(I.item)  = (SELECT COUNT(item) FROM Items);  /* 条件2 */

/*练习题*/
/* 练习题1-4-1：修改编号缺失的检查逻辑，使结果总是返回一行数据 */
--解法1：
SELECT ' 存在缺失的编号' AS gap
  FROM SeqTbl
HAVING COUNT(*) <> MAX(seq)
UNION ALL
SELECT ' 不存在缺少的编号' AS gap
  FROM SeqTbl
HAVING COUNT(*) = MAX(seq);
/* 练习题1-4-1：修改编号缺失的检查逻辑，使结果总是返回一行数据 */
--解法2：
SELECT CASE WHEN COUNT(*) <> MAX(seq)
            THEN '存在缺失的编号'
            ELSE '不存在缺失的编号' END AS gap
  FROM SeqTbl;

/* 练习题1-4-2：练习“特征函数” 
   查找所有学生都在9月份提交完成的学院（1）：使用BETWEEN谓词 */
--解法1：
SELECT dpt
  FROM Students
 GROUP BY dpt
HAVING COUNT(*) = SUM(CASE WHEN sbmt_date BETWEEN '2005-09-01' AND '2005-09-30'
                           THEN 1 ELSE 0 END);
/* 练习题1-4-2：练习“特征函数” 
   查找所有学生都在9月份提交完成的学院（2）：使用EXTRACT函数 */
--解法2：
SELECT dpt
  FROM Students
 GROUP BY dpt
HAVING COUNT(*) = SUM(CASE WHEN EXTRACT (YEAR FROM sbmt_date) = 2005
                            AND EXTRACT (MONTH FROM sbmt_date) = 09
                           THEN 1 ELSE 0 END);
/* 练习题1-4-3：购物篮分析问题的一般化 */
SELECT SI.shop,
       COUNT(SI.item) AS my_item_cnt,
       (SELECT COUNT(item) FROM Items) - COUNT(SI.item) AS diff_cnt
  FROM ShopItems SI, Items I
 WHERE SI.item = I.item
 GROUP BY SI.shop;