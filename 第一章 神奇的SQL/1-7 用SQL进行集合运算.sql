/*1 导入篇:集合运算的几个注意事项*/
/*注意事项1：SQL能操作具有重复行的集合，可以通过可选项ALL来支持*/
--如果不加ALL,将默认删除重复行
/*注意事项2：集合运算符有优先级*/
--标准SQL规定：INTERSECT比UNION和EXCEPT优先级更高，但可以使用括号明确指定运算顺序
/*注意事项3：各个DBMS提供商在集合运算的实现程度参差不齐*/
/*注意事项4：除法运算没有标准定义*/
--四则运算里的和(UNION)、差(EXCEPT)、积(CROSS JOIN)都被引入了标准的SQL,但商(DIVIDE BY)因为各种原因不能标准化.




/*2 比较表和表：检查集合相等性之基础篇 */
--名字不同但内容相同的两张表
CREATE TABLE Tbl_A
 (keycol  CHAR(1) PRIMARY KEY,
  col_1   INTEGER, 
  col_2   INTEGER, 
  col_3   INTEGER);

CREATE TABLE Tbl_B
 (keycol  CHAR(1) PRIMARY KEY,
  col_1   INTEGER, 
  col_2   INTEGER, 
  col_3   INTEGER);

/* 表相等的情况 */
DELETE FROM Tbl_A;
INSERT INTO Tbl_A VALUES('A', 2, 3, 4);
INSERT INTO Tbl_A VALUES('B', 0, 7, 9);
INSERT INTO Tbl_A VALUES('C', 5, 1, 6);

DELETE FROM Tbl_B;
INSERT INTO Tbl_B VALUES('A', 2, 3, 4);
INSERT INTO Tbl_B VALUES('B', 0, 7, 9);
INSERT INTO Tbl_B VALUES('C', 5, 1, 6);
/* 比较表和表：基础篇 */
--如果这个查询的结果与tbl_A及tbl_B的行数一致，则两张表是相等的
SELECT COUNT(*) AS row_cnt
  FROM ( SELECT * 
           FROM   tbl_A 
         UNION
         SELECT * 
           FROM   tbl_B ) TMP;

/* B行不同的情况 */
DELETE FROM Tbl_A;
INSERT INTO Tbl_A VALUES('A', 2, 3, 4);
INSERT INTO Tbl_A VALUES('B', 0, 7, 9);
INSERT INTO Tbl_A VALUES('C', 5, 1, 6);

DELETE FROM Tbl_B;
INSERT INTO Tbl_B VALUES('A', 2, 3, 4);
INSERT INTO Tbl_B VALUES('B', 0, 7, 8);
INSERT INTO Tbl_B VALUES('C', 5, 1, 6);--如果这个查询的结果与tbl_A及tbl_B的行数不一致，则两张表是不相等的

/* 包含NULL的情况（相等） */
DELETE FROM Tbl_A;
INSERT INTO Tbl_A VALUES('A', NULL, 3, 4);
INSERT INTO Tbl_A VALUES('B', 0, 7, 9);
INSERT INTO Tbl_A VALUES('C', NULL, NULL, NULL);

DELETE FROM Tbl_B;
INSERT INTO Tbl_B VALUES('A', NULL, 3, 4);
INSERT INTO Tbl_B VALUES('B', 0, 7, 9);
INSERT INTO Tbl_B VALUES('C', NULL, NULL, NULL);
--同一个集合无论加多少次结果都相同(幂等性:S UNION S =S),默认去重。

/*3 比较表和表：检查集合相等性之进阶篇*/
/* 比较表和表：进阶篇（在Oracle中无法运行） */
SELECT DISTINCT CASE WHEN COUNT(*) = 0 
                     THEN '相等'
                     ELSE '不相等' END AS result
  FROM ((SELECT * FROM  tbl_A
         UNION
         SELECT * FROM  tbl_B) 
         EXCEPT
        (SELECT * FROM  tbl_A
         INTERSECT 
         SELECT * FROM  tbl_B)) TMP;--UNION：联集,INTERSECT:交集;EXCEPT:差
/* 用于比较表与表的diff：求异或集 */
(SELECT * FROM  tbl_A
   EXCEPT
 SELECT * FROM  tbl_B)
 UNION ALL
(SELECT * FROM  tbl_B
   EXCEPT
 SELECT * FROM  tbl_A);--如果返回空值就说A=B.

/*4 用差集实现关系除法运算 */
--进行除法运算比较有代表性的是以下三个:
--1.嵌套使用NOT EXISTS
--2.使用HAVING子句转换成一对一关系
--3.把除法变成减法
CREATE TABLE Skills 
(skill VARCHAR(32),
 PRIMARY KEY(skill));

CREATE TABLE EmpSkills 
(emp   VARCHAR(32), 
 skill VARCHAR(32),
 PRIMARY KEY(emp, skill));

INSERT INTO Skills VALUES('Oracle');
INSERT INTO Skills VALUES('UNIX');
INSERT INTO Skills VALUES('Java');

INSERT INTO EmpSkills VALUES('相田', 'Oracle');
INSERT INTO EmpSkills VALUES('相田', 'UNIX');
INSERT INTO EmpSkills VALUES('相田', 'Java');
INSERT INTO EmpSkills VALUES('相田', 'C#');
INSERT INTO EmpSkills VALUES('神崎', 'Oracle');
INSERT INTO EmpSkills VALUES('神崎', 'UNIX');
INSERT INTO EmpSkills VALUES('神崎', 'Java');
INSERT INTO EmpSkills VALUES('平井', 'UNIX');
INSERT INTO EmpSkills VALUES('平井', 'Oracle');
INSERT INTO EmpSkills VALUES('平井', 'PHP');
INSERT INTO EmpSkills VALUES('平井', 'Perl');
INSERT INTO EmpSkills VALUES('平井', 'C++');
INSERT INTO EmpSkills VALUES('若田部', 'Perl');
INSERT INTO EmpSkills VALUES('渡来', 'Oracle');
/*4.1 用求差集的方法进行关系除法运算（有余数） */
SELECT DISTINCT emp
  FROM EmpSkills ES1
 WHERE NOT EXISTS
        (SELECT skill
           FROM Skills
         EXCEPT
         SELECT skill
           FROM EmpSkills ES2
          WHERE ES1.emp = ES2.emp);
/*4.2 寻找相等的子集 */
--条件1:两个供应商都经营同种类型的零件
--条件2:两个供应商经营的零件种类数相同(即存在一一映射)
CREATE TABLE SupParts
(sup  CHAR(32) NOT NULL,
 part CHAR(32) NOT NULL,
 PRIMARY KEY(sup, part));

INSERT INTO SupParts VALUES('A',  '螺丝');
INSERT INTO SupParts VALUES('A',  '螺母');
INSERT INTO SupParts VALUES('A',  '管子');
INSERT INTO SupParts VALUES('B',  '螺丝');
INSERT INTO SupParts VALUES('B',  '管子');
INSERT INTO SupParts VALUES('C',  '螺丝');
INSERT INTO SupParts VALUES('C',  '螺母');
INSERT INTO SupParts VALUES('C',  '管子');
INSERT INTO SupParts VALUES('D',  '螺丝');
INSERT INTO SupParts VALUES('D',  '管子');
INSERT INTO SupParts VALUES('E',  '保险丝');
INSERT INTO SupParts VALUES('E',  '螺母');
INSERT INTO SupParts VALUES('E',  '管子');
INSERT INTO SupParts VALUES('F',  '保险丝');
--
SELECT SP1.sup, SP2.sup
  FROM SupParts SP1, SupParts SP2 
 WHERE SP1.sup < SP2.sup              /* 生成供应商的全部组合 */
   AND SP1.part = SP2.part            /* 条件1：经营同种类型的零件 */
GROUP BY SP1.sup, SP2.sup 
HAVING COUNT(*) = (SELECT COUNT(*)    /* 条件2：经营的零件种类数相同 */
                     FROM SupParts SP3 
                    WHERE SP3.sup = SP1.sup)
   AND COUNT(*) = (SELECT COUNT(*) 
                     FROM SupParts SP4 
                    WHERE SP4.sup = SP2.sup);
/* 5.用于删除重复行的高效SQL */
/* 在PostgreSQL中，需要把“with oids”添加到CREATE TABLE语句的最后 */
CREATE TABLE Products
(name  CHAR(16),
 price INTEGER);

INSERT INTO Products VALUES('苹果',  50);
INSERT INTO Products VALUES('橘子', 100);
INSERT INTO Products VALUES('橘子', 100);
INSERT INTO Products VALUES('橘子', 100);
INSERT INTO Products VALUES('香蕉',  80);
--加入(rowid)列：
--alter table tableName add columnName varchar(30) NULL;
ALTER TABLE Products ADD rowid INT NOT NULL;

/*删除重复行:使用关联子查询(低效SQL语句)*/
DELETE FROM Products
 WHERE rowid <(SELECT MAX(P2.rowid)
				FROM  Products P2 
				WHERE Products.name = P2.name
				AND Products.price = P2.price);

/* 用于删除重复行的高效SQL语句（1）：通过EXCEPT求补集 */
DELETE FROM Products
 WHERE rowid IN ( SELECT rowid      --全部rowid
                    FROM Products 
                  EXCEPT            --减去
                  SELECT MAX(rowid) --要留下的
                    FROM Products 
                   GROUP BY name, price);
 									--得到要删除的
/* 删除重复行的高效SQL语句（2）：通过NOT IN求补集 */
DELETE FROM Products 
 WHERE rowid NOT IN ( SELECT MAX(rowid)
                        FROM Products 
                       GROUP BY name, price);

/*练习题*/
/* 练习题1-7-1：改进“只使用UNION的比较” */
SELECT CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM tbl_A )
             AND COUNT(*) = (SELECT COUNT(*) FROM tbl_B )
            THEN '相等'
            ELSE '不相等' END AS result
  FROM ( SELECT * FROM tbl_A
         UNION
         SELECT * FROM tbl_B ) TMP;
/* 练习题1-7-2：精确关系除法运算 */
--解法1：
SELECT DISTINCT emp
  FROM EmpSkills ES1
 WHERE NOT EXISTS
        (SELECT skill
           FROM Skills
         EXCEPT
         SELECT skill
           FROM EmpSkills ES2
          WHERE ES1.emp = ES2.emp)
  AND NOT EXISTS
        (SELECT skill
           FROM EmpSkills ES3
          WHERE ES1.emp = ES3.emp
         EXCEPT
         SELECT skill
           FROM Skills );
/* 练习题1-7-2：精确关系除法运算 */
--解法2：
SELECT emp
  FROM EmpSkills ES1
 WHERE NOT EXISTS
        (SELECT skill
           FROM Skills
         EXCEPT
         SELECT skill
           FROM EmpSkills ES2
          WHERE ES1.emp = ES2.emp)
 GROUP BY emp
HAVING COUNT(*) = (SELECT COUNT(*) FROM Skills);
