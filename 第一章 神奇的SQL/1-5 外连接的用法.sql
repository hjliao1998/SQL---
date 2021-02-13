/*1 用外连接进行行列转换（1）（行→列）：制作交叉表 */
CREATE TABLE Courses
(name   VARCHAR(32), 
 course VARCHAR(32), 
 PRIMARY KEY(name, course));

INSERT INTO Courses VALUES('赤井', 'SQL入门');
INSERT INTO Courses VALUES('赤井', 'UNIX基础');
INSERT INTO Courses VALUES('铃木', 'SQL入门');
INSERT INTO Courses VALUES('工藤', 'SQL入门');
INSERT INTO Courses VALUES('工藤', 'Java中级');
INSERT INTO Courses VALUES('吉田', 'UNIX基础');
INSERT INTO Courses VALUES('渡边', 'SQL入门');
/* 水平展开求交叉表（1）：使用外连接 */
SELECT C0.name,
       CASE WHEN C1.name IS NOT NULL THEN '○' ELSE NULL END AS "SQL入门",
       CASE WHEN C2.name IS NOT NULL THEN '○' ELSE NULL END AS "UNIX基础",
       CASE WHEN C3.name IS NOT NULL THEN '○' ELSE NULL END AS "Java中级"
  FROM  (SELECT DISTINCT name FROM  Courses) C0
    LEFT OUTER JOIN
    (SELECT name FROM Courses WHERE course = 'SQL入门' ) C1
    ON  C0.name = C1.name
      LEFT OUTER JOIN
        (SELECT name FROM Courses WHERE course = 'UNIX基础' ) C2
        ON  C0.name = C2.name
          LEFT OUTER JOIN
            (SELECT name FROM Courses WHERE course = 'Java中级' ) C3
            ON  C0.name = C3.name;
/* 水平展开（2）：使用标量子查询 */
SELECT  C0.name,
  (SELECT '○'
     FROM Courses C1
    WHERE course = 'SQL入门'
      AND C1.name = C0.name) AS "SQL入门",
  (SELECT '○'
     FROM Courses C2
    WHERE course = 'UNIX基础'
      AND C2.name = C0.name) AS "UNIX基础",
  (SELECT '○'
     FROM Courses C3
    WHERE course = 'Java中级'
      AND C3.name = C0.name) AS "Java中级"
  FROM (SELECT DISTINCT name FROM Courses) C0;
/* 水平展开（3）：嵌套使用CASE表达式 */
SELECT  name,
        CASE WHEN SUM(CASE WHEN course = 'SQL入门' THEN 1 ELSE NULL END) >= 1
             THEN '○' ELSE NULL END AS "SQL入门",
        CASE WHEN SUM(CASE WHEN course = 'UNIX基础' THEN 1 ELSE NULL END) >= 1
             THEN '○' ELSE NULL END AS "UNIX基础",
        CASE WHEN SUM(CASE WHEN course = 'Java中级' THEN 1 ELSE NULL END) >= 1
             THEN '○' ELSE NULL END AS "Java中级"
  FROM Courses
 GROUP BY name;
/*2 用外连接进行行列转换（2）（列→行）：汇总重复项于一列 */
CREATE TABLE Personnel
 (employee   varchar(32), 
  child_1    varchar(32), 
  child_2    varchar(32), 
  child_3    varchar(32), 
  PRIMARY KEY(employee));

INSERT INTO Personnel VALUES('赤井', '一郎', '二郎', '三郎');
INSERT INTO Personnel VALUES('工藤', '春子', '夏子', NULL);
INSERT INTO Personnel VALUES('铃木', '夏子', NULL,   NULL);
INSERT INTO Personnel VALUES('吉田', NULL,   NULL,   NULL);
/* 列数据转换成行数据：使用UNION ALL */
SELECT employee, child_1 AS child FROM Personnel
UNION ALL
SELECT employee, child_2 AS child FROM Personnel
UNION ALL
SELECT employee, child_3 AS child FROM Personnel;
/* 孩子主表 */
CREATE VIEW Children(child)
AS SELECT child_1 FROM Personnel
   UNION
   SELECT child_2 FROM Personnel
   UNION
   SELECT child_3 FROM Personnel;
/* 获取员工子女列表的SQL语句（没有孩子的员工也输出） */
SELECT EMP.employee, CHILDREN.child
  FROM Personnel EMP
       LEFT OUTER JOIN Children
    ON CHILDREN.child IN (EMP.child_1, EMP.child_2, EMP.child_3);


/* 获取员工子女列表的SQL语句（没有孩子的员工也输出） */
SELECT EMP.employee, CHILDREN.child
FROM   Personnel EMP
  LEFT OUTER JOIN
   (SELECT child_1 AS child FROM Personnel
    UNION
    SELECT child_2 AS child FROM Personnel
    UNION
    SELECT child_3 AS child FROM Personnel) CHILDREN
  ON CHILDREN.child IN (EMP.child_1, EMP.child_2, EMP.child_3);
/*3 在交叉表里制作嵌套式表侧栏 */
CREATE TABLE TblSex
(sex_cd   char(1), 
 sex varchar(5), 
 PRIMARY KEY(sex_cd));

CREATE TABLE TblAge 
(age_class char(1), 
 age_range varchar(30), 
 PRIMARY KEY(age_class));

CREATE TABLE TblPop 
(pref_name  varchar(30), 
 age_class  char(1), 
 sex_cd     char(1), 
 population integer, 
 PRIMARY KEY(pref_name, age_class,sex_cd));

INSERT INTO TblSex (sex_cd, sex ) VALUES('m',   '男');
INSERT INTO TblSex (sex_cd, sex ) VALUES('f',   '女');

INSERT INTO TblAge (age_class, age_range ) VALUES('1',  '21岁～30岁');
INSERT INTO TblAge (age_class, age_range ) VALUES('2',  '31岁～40岁');
INSERT INTO TblAge (age_class, age_range ) VALUES('3',  '41岁～50岁');

INSERT INTO TblPop VALUES('秋田', '1', 'm', 400 );
INSERT INTO TblPop VALUES('秋田', '3', 'm', 1000 );
INSERT INTO TblPop VALUES('秋田', '1', 'f', 800 );
INSERT INTO TblPop VALUES('秋田', '3', 'f', 1000 );
INSERT INTO TblPop VALUES('青森', '1', 'm', 700 );
INSERT INTO TblPop VALUES('青森', '1', 'f', 500 );
INSERT INTO TblPop VALUES('青森', '3', 'f', 800 );
INSERT INTO TblPop VALUES('东京', '1', 'm', 900 );
INSERT INTO TblPop VALUES('东京', '1', 'f', 1500 );
INSERT INTO TblPop VALUES('东京', '3', 'f', 1200 );
INSERT INTO TblPop VALUES('千叶', '1', 'm', 900 );
INSERT INTO TblPop VALUES('千叶', '1', 'f', 1000 );
INSERT INTO TblPop VALUES('千叶', '3', 'f', 900 );
/* 使用外连接生成嵌套式表侧栏：错误的SQL语句 */
SELECT MASTER1.age_class AS age_class,
       MASTER2.sex_cd AS sex_cd,
       DATA.pop_tohoku AS pop_tohoku,
       DATA.pop_kanto AS pop_kanto
  FROM (SELECT age_class, sex_cd,
               SUM(CASE WHEN pref_name IN ('青森', '秋田')
                        THEN population ELSE NULL END) AS pop_tohoku,
               SUM(CASE WHEN pref_name IN ('东京', '千叶')
                        THEN population ELSE NULL END) AS pop_kanto
          FROM TblPop
         GROUP BY age_class, sex_cd) DATA
        RIGHT OUTER JOIN TblAge MASTER1 /* 外连接1：和年龄层级主表进行外连接 */
           ON MASTER1.age_class = DATA.age_class
              RIGHT OUTER JOIN TblSex MASTER2 /* 外连接2：和性别主表进行外连接 */
                 ON MASTER2.sex_cd = DATA.sex_cd;
/* 停在第1个外连接处时：结果里包含年龄层级为2的数据 */
--错误的SQL语句：
SELECT MASTER1.age_class AS age_class,
       DATA.sex_cd AS sex_cd,
       DATA.pop_tohoku AS pop_tohoku,
       DATA.pop_kanto AS pop_kanto
  FROM (SELECT age_class, sex_cd,
               SUM(CASE WHEN pref_name IN ('青森', '秋田')
                        THEN population ELSE NULL END) AS pop_tohoku,
               SUM(CASE WHEN pref_name IN ('东京', '千叶')
                        THEN population ELSE NULL END) AS pop_kanto
          FROM TblPop
         GROUP BY age_class, sex_cd) DATA
        RIGHT OUTER JOIN TblAge MASTER1
           ON MASTER1.age_class = DATA.age_class;
/* 使用外连接生成嵌套式表侧栏：正确的SQL语句 */
SELECT
  MASTER.age_class AS age_class,
  MASTER.sex_cd    AS sex_cd,
  DATA.pop_tohoku  AS pop_tohoku,
  DATA.pop_kanto   AS pop_kanto
FROM
  (SELECT
     age_class,
     sex_cd,
     SUM(CASE WHEN pref_name IN ('青森', '秋田')
              THEN population ELSE NULL END) AS pop_tohoku,
     SUM(CASE WHEN pref_name IN ('东京', '千叶')
              THEN population ELSE NULL END) AS pop_kanto
   FROM TblPop
   GROUP BY age_class, sex_cd) DATA
     RIGHT OUTER JOIN
       (SELECT age_class, sex_cd
          FROM TblAge 
                CROSS JOIN
               TblSex ) MASTER
     ON  MASTER.age_class = DATA.age_class
    AND  MASTER.sex_cd    = DATA.sex_cd;
/*4 作为乘法运算的连接 */
CREATE TABLE Items
 (item_no INTEGER PRIMARY KEY,
  item    VARCHAR(32) NOT NULL);

INSERT INTO Items VALUES(10, 'FD');
INSERT INTO Items VALUES(20, 'CD-R');
INSERT INTO Items VALUES(30, 'MO');
INSERT INTO Items VALUES(40, 'DVD');

CREATE TABLE SalesHistory
 (sale_date DATE NOT NULL,
  item_no   INTEGER NOT NULL,
  quantity  INTEGER NOT NULL,
  PRIMARY KEY(sale_date, item_no));

INSERT INTO SalesHistory VALUES('2007-10-01',  10,  4);
INSERT INTO SalesHistory VALUES('2007-10-01',  20, 10);
INSERT INTO SalesHistory VALUES('2007-10-01',  30,  3);
INSERT INTO SalesHistory VALUES('2007-10-03',  10, 32);
INSERT INTO SalesHistory VALUES('2007-10-03',  30, 12);
INSERT INTO SalesHistory VALUES('2007-10-04',  20, 22);
INSERT INTO SalesHistory VALUES('2007-10-04',  30,  7);
/* 解答（1）：通过在连接前聚合来创建一对一的关系 */
SELECT I.item_no, SH.total_qty
  FROM Items I LEFT OUTER JOIN
       (SELECT item_no, SUM(quantity) AS total_qty
          FROM SalesHistory
         GROUP BY item_no) SH
    ON I.item_no = SH.item_no;
/* 解答(2)：先进行一对多的连接再聚合 */
SELECT I.item_no, SUM(SH.quantity) AS total_qty
  FROM Items I LEFT OUTER JOIN SalesHistory SH
    ON I.item_no = SH.item_no /* 一对多的连接 */
 GROUP BY I.item_no;

/*5 全外连接 */
CREATE TABLE Class_A
(id char(1), 
 name varchar(30), 
 PRIMARY KEY(id));

CREATE TABLE Class_B
(id   char(1), 
 name varchar(30), 
 PRIMARY KEY(id));

INSERT INTO Class_A (id, name) VALUES('1', '田中');
INSERT INTO Class_A (id, name) VALUES('2', '铃木');
INSERT INTO Class_A (id, name) VALUES('3', '伊集院');

INSERT INTO Class_B (id, name) VALUES('1', '田中');
INSERT INTO Class_B (id, name) VALUES('2', '铃木');
INSERT INTO Class_B (id, name) VALUES('4', '西园寺');
/* 全外连接保留全部信息 */
SELECT COALESCE(A.id, B.id) AS id,
       A.name AS A_name,
       B.name AS B_name
FROM Class_A  A  FULL OUTER JOIN Class_B  B
  ON A.id = B.id;
/* 数据库不支持全外连接时的替代方案 */
SELECT A.id AS id, A.name, B.name
  FROM Class_A  A   LEFT OUTER JOIN Class_B  B
    ON A.id = B.id
UNION
SELECT B.id AS id, A.name, B.name
  FROM Class_A  A  RIGHT OUTER JOIN Class_B  B
    ON A.id = B.id;

/*6 用外连接进行集合运算*/
/* 用外连接求差集：A－B */
SELECT A.id AS id,  A.name AS A_name
  FROM Class_A  A LEFT OUTER JOIN Class_B B
    ON A.id = B.id
 WHERE B.name IS NULL;
/* 用外连接求差集：B－A */
SELECT B.id AS id, B.name AS B_name
  FROM Class_A  A  RIGHT OUTER JOIN Class_B B
    ON A.id = B.id
 WHERE A.name IS NULL;
/* 用全外连接求异或集 */
SELECT COALESCE(A.id, B.id) AS id,
       COALESCE(A.name , B.name ) AS name
  FROM Class_A  A  FULL OUTER JOIN Class_B  B
    ON A.id = B.id
 WHERE A.name IS NULL 
    OR B.name IS NULL;
/* 用外连接进行关系除法运算：差集的应用 */
SELECT DISTINCT shop
  FROM ShopItems SI1
WHERE NOT EXISTS
      (SELECT I.item 
         FROM Items I LEFT OUTER JOIN ShopItems SI2
           ON SI1.shop = SI2.shop
          AND I.item   = SI2.item 
        WHERE SI2.item IS NULL) ;
/*练习*/
/* 练习题1-5-1：先连接还是先聚合 
   去掉一个内联视图后的修正版 */
SELECT MASTER.age_class AS age_class,
       MASTER.sex_cd AS sex_cd,
       SUM(CASE WHEN pref_name IN ('青森', '秋田')
                THEN population ELSE NULL END) AS pop_tohoku,
       SUM(CASE WHEN pref_name IN ('东京', '千叶')
                THEN population ELSE NULL END) AS pop_kanto
  FROM (SELECT age_class, sex_cd
          FROM TblAge CROSS JOIN TblSex) MASTER
        LEFT OUTER JOIN TblPop DATA      /* 关键在于理解DATA其实就是TblPop */
    ON MASTER.age_class = DATA.age_class
   AND MASTER.sex_cd = DATA.sex_cd
 GROUP BY MASTER.age_class, MASTER.sex_cd;
/* 练习题1-5-2：请留意孩子的人数 */
SELECT EMP.employee, COUNT(*) AS child_cnt /* 不能使用COUNT(*)！ */
  FROM Personnel EMP
       LEFT OUTER JOIN Children
    ON CHILDREN.child IN (EMP.child_1, EMP.child_2, EMP.child_3)
 GROUP BY EMP.employee;
/* 练习题1-5-2：请留意孩子的人数 */
SELECT EMP.employee, COUNT(CHILDREN.child) AS child_cnt
  FROM Personnel EMP
       LEFT OUTER JOIN Children
    ON CHILDREN.child IN (EMP.child_1, EMP.child_2, EMP.child_3)
 GROUP BY EMP.employee;
/* 练习题1-5-3：全外连接和MERGE运算符 */
MERGE INTO Class_A A
    USING (SELECT *
             FROM Class_B ) B
      ON (A.id = B.id)
    WHEN MATCHED THEN
        UPDATE SET A.name = B.name
    WHEN NOT MATCHED THEN
        INSERT (id, name) VALUES (B.id, B.name);
