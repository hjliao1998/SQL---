/*1 可重排列·排列·组合*/
CREATE TABLE Products
(name VARCHAR(16) PRIMARY KEY,
 price INTEGER NOT NULL);

--可重排列·排列·组合
INSERT INTO Products VALUES('苹果',	50);
INSERT INTO Products VALUES('橘子',	100);
INSERT INTO Products VALUES('香蕉',	80);

--排序
DELETE FROM Products;
INSERT INTO Products VALUES('苹果',	50);
INSERT INTO Products VALUES('橘子',	100);
INSERT INTO Products VALUES('葡萄',	50);
INSERT INTO Products VALUES('西瓜',	80);
INSERT INTO Products VALUES('柠檬',	30);
INSERT INTO Products VALUES('香蕉',	50);

--不聚合，查看集合的包含关系
DELETE FROM Products;
INSERT INTO Products VALUES('橘子',	100);
INSERT INTO Products VALUES('葡萄',	50);
INSERT INTO Products VALUES('西瓜',	80);
INSERT INTO Products VALUES('柠檬',	30);

/* 用于获取可重排列的SQL语句 */
SELECT P1.name AS name_1, P2.name AS name_2
  FROM Products P1, Products P2;
/* 用于获取排列的SQL语句 */
SELECT P1.name AS name_1, P2.name AS name_2
  FROM Products P1, Products P2
 WHERE P1.name <> P2.name;
/* 用于获取组合的SQL语句 */
SELECT P1.name AS name_1, P2.name AS name_2
FROM Products P1, Products P2
WHERE P1.name > P2.name;
/* 用于获取组合的SQL语句：扩展成3列时 */
SELECT P1.name AS name_1, P2.name AS name_2, P3.name AS name_3
  FROM Products P1, Products P2, Products P3
WHERE P1.name > P2.name
  AND P2.name > P3.name;

/*2 删除重复行*/
/* 用于删除重复行的SQL语句（1）：使用极值函数 */
DELETE FROM Products P1
 WHERE rowid < ( SELECT MAX(P2.rowid) --使用的是Oracle数据库的rowid
                   FROM Products P2
                  WHERE P1.name = P2. name
                    AND P1.price = P2.price ) ;
/* 用于删除重复行的SQL语句（2）：使用非等值连接 */
DELETE FROM Products P1
 WHERE EXISTS ( SELECT *
                  FROM Products P2
                 WHERE P1.name = P2.name
                   AND P1.price = P2.price
                   AND P1.rowid < P2.rowid );

/*3 查找局部不一致的列*/
CREATE TABLE Addresses
(name VARCHAR(32),
 family_id INTEGER,
 address VARCHAR(32),
 PRIMARY KEY(name, family_id));

INSERT INTO Addresses VALUES('前田义明', '100', '东京都港区虎之门3-2-29');
INSERT INTO Addresses VALUES('前田由美', '100', '东京都港区虎之门3-2-92');
INSERT INTO Addresses VALUES('加藤茶',   '200', '东京都新宿区西新宿2-8-1');
INSERT INTO Addresses VALUES('加藤胜',   '200', '东京都新宿区西新宿2-8-1');
INSERT INTO Addresses VALUES('福尔摩斯',  '300', '贝克街221B');
INSERT INTO Addresses VALUES('华生',  '400', '贝克街221B');

/* 用于查找是同一家人但住址却不同的记录的SQL语句 */
SELECT DISTINCT A1.name, A1.address
  FROM Addresses A1, Addresses A2
 WHERE A1.family_id = A2.family_id
   AND A1.address <> A2.address ;
/* 用于查找价格相等但商品名称不同的记录的SQL语句 */
--Products表类比
--家庭ID-->价格
--住址-->商品名称
SELECT DISTINCT P1.name, P1.price
  FROM Products P1, Products P2
 WHERE P1.price = P2.price
   AND P1.name <> P2.name;
/*4 排序*/
/* 排序：使用窗口函数 */
SELECT name, price,
       RANK() OVER (ORDER BY price DESC) AS rank_1,
       DENSE_RANK() OVER (ORDER BY price DESC) AS rank_2
  FROM Products;
/* 排序从1开始。如果已出现相同位次，则跳过之后的位次 */
SELECT P1.name,
       P1.price,
      (SELECT COUNT(P2.price)
         FROM Products P2
        WHERE P2.price > P1.price) + 1 AS rank_1
 FROM Products P1
 ORDER BY rank_1;
/* 排序：使用自连接 */
SELECT P1.name,
       MAX(P1.price) AS price,
       COUNT(P2.name) +1 AS rank_1
  FROM Products P1 LEFT OUTER JOIN Products P2
    ON P1.price < P2.price
 GROUP BY P1.name
 ORDER BY rank_1;
/* 排序：改为内连接 */
SELECT P1.name,
       MAX(P1.price) AS price,
       COUNT(P2.name) +1 AS rank_1
  FROM Products P1 INNER JOIN Products P2
    ON P1.price < P2.price
 GROUP BY P1.name
 ORDER BY rank_1;

/*练习题*/
/* 练习题1-2-1：可重组合 */
SELECT P1.name AS name_1, P2.name AS name_2
  FROM Products P1, Products P2
 WHERE P1.name >= P2.name;
/* 练习题1-2-2：分地区排序 */
CREATE TABLE DistrictProducts
(district  VARCHAR(16) NOT NULL,
 name      VARCHAR(16) NOT NULL,
 price     INTEGER NOT NULL,
 PRIMARY KEY(district, name, price));

INSERT INTO DistrictProducts VALUES('东北', '橘子',	100);
INSERT INTO DistrictProducts VALUES('东北', '苹果',	50);
INSERT INTO DistrictProducts VALUES('东北', '葡萄',	50);
INSERT INTO DistrictProducts VALUES('东北', '柠檬',	30);
INSERT INTO DistrictProducts VALUES('关东', '柠檬',	100);
INSERT INTO DistrictProducts VALUES('关东', '菠萝',	100);
INSERT INTO DistrictProducts VALUES('关东', '苹果',	100);
INSERT INTO DistrictProducts VALUES('关东', '葡萄',	70);
INSERT INTO DistrictProducts VALUES('关西', '柠檬',	70);
INSERT INTO DistrictProducts VALUES('关西', '西瓜',	30);
INSERT INTO DistrictProducts VALUES('关西', '苹果',	20);
/* 练习题1-2-2 分地区排序 */
--解法1：
SELECT district, name, price,
          RANK() OVER(PARTITION BY district 
                      ORDER BY price DESC) AS rank_1
  FROM DistrictProducts;
/* 练习题1-2-2：关联子查询 */
--解法2：
SELECT P1.district, P1.name,
       P1.price,
       (SELECT COUNT(P2.price)
          FROM DistrictProducts P2
         WHERE P1.district = P2.district    /* 在同一个地区内进行比较 */
           AND P2.price > P1.price) + 1 AS rank_1
  FROM DistrictProducts P1;
/* 练习题1-2-2：自连接 */
--解法3：
SELECT P1.district, P1.name,
       MAX(P1.price) AS price, 
       COUNT(P2.name) +1 AS rank_1
  FROM DistrictProducts P1 LEFT OUTER JOIN DistrictProducts P2
    ON  P1.district = P2.district
   AND P1.price < P2.price
 GROUP BY P1.district, P1.name;
/* 练习题1-2-3：更新位次 */
CREATE TABLE DistrictProducts2
(district  VARCHAR(16) NOT NULL,
 name      VARCHAR(16) NOT NULL,
 price     INTEGER NOT NULL,
 ranking   INTEGER,
 PRIMARY KEY(district, name));

INSERT INTO DistrictProducts2 VALUES('东北', '橘子',	100, NULL);
INSERT INTO DistrictProducts2 VALUES('东北', '苹果',	50 , NULL);
INSERT INTO DistrictProducts2 VALUES('东北', '葡萄',	50 , NULL);
INSERT INTO DistrictProducts2 VALUES('东北', '柠檬',	30 , NULL);
INSERT INTO DistrictProducts2 VALUES('关东', '柠檬',	100, NULL);
INSERT INTO DistrictProducts2 VALUES('关东', '菠萝',	100, NULL);
INSERT INTO DistrictProducts2 VALUES('关东', '苹果',	100, NULL);
INSERT INTO DistrictProducts2 VALUES('关东', '葡萄',	70 , NULL);
INSERT INTO DistrictProducts2 VALUES('关西', '柠檬',	70 , NULL);
INSERT INTO DistrictProducts2 VALUES('关西', '西瓜',	30 , NULL);
INSERT INTO DistrictProducts2 VALUES('关西', '苹果',	20 , NULL);
/* 练习题1-2-3：更新位次 */
--解法1：
UPDATE DistrictProducts2 P1
   SET ranking = (SELECT COUNT(P2.price) + 1
                    FROM DistrictProducts2 P2
                   WHERE P1.district = P2.district
                     AND P2.price > P1.price);
/* 练习题1-2-3：仅可用于DB2 */
--解法2：
UPDATE DistrictProducts2
   SET ranking = RANK() OVER(PARTITION BY district
                             ORDER BY price DESC);
/* 练习题1-2-3：可用于Oracle、SQL Server、PostgreSQL */
--解法3：
UPDATE DistrictProducts2
   SET ranking =
         (SELECT P1.ranking
            FROM (SELECT district , name ,
                         RANK() OVER(PARTITION BY district
                                     ORDER BY price DESC) AS ranking
                    FROM DistrictProducts2) P1
                   WHERE P1.district = DistrictProducts2.district
                     AND P1.name = DistrictProducts2.name);