/*1 增长、减少、维持现状*/
CREATE TABLE Sales
(year INTEGER NOT NULL , 
 sale INTEGER NOT NULL ,
 PRIMARY KEY (year));

INSERT INTO Sales VALUES (1990, 50);
INSERT INTO Sales VALUES (1991, 51);
INSERT INTO Sales VALUES (1992, 52);
INSERT INTO Sales VALUES (1993, 52);
INSERT INTO Sales VALUES (1994, 50);
INSERT INTO Sales VALUES (1995, 50);
INSERT INTO Sales VALUES (1996, 49);
INSERT INTO Sales VALUES (1997, 55);
/* 求与上一年营业额一样的年份（1）：使用关联子查询 */
SELECT year,sale
  FROM Sales S1
 WHERE sale = (SELECT sale
                 FROM Sales S2
                WHERE S2.year = S1.year - 1)--S1.year：今年;S2.year:去年
 ORDER BY year;
/* 求与上一年营业额一样的年份（2）：使用自连接 */
SELECT S1.year, S1.sale
  FROM Sales S1, 
       Sales S2
 WHERE S2.sale = S1.sale
   AND S2.year = S1.year - 1
 ORDER BY year;

/*2 用列表展示与上一年度的比较成果*/
/* 求出是增长了还是减少了，抑或是维持现状（1）：使用关联子查询 */
SELECT S1.year, S1.sale,
       CASE WHEN sale =
             (SELECT sale
                FROM Sales S2
               WHERE S2.year = S1.year - 1) THEN '→' /* 持平 */
            WHEN sale >
             (SELECT sale
                FROM Sales S2
               WHERE S2.year = S1.year - 1) THEN '↑' /* 增长 */
            WHEN sale <
             (SELECT sale
                FROM Sales S2
               WHERE S2.year = S1.year - 1) THEN '↓' /* 减少 */
       ELSE '—' END AS var
  FROM Sales S1
 ORDER BY year;
/* 求出是增长了还是减少了，抑或是维持现状（2）：使用自连接查询 */
SELECT S1.year, S1.sale,
       CASE WHEN S1.sale = S2.sale THEN '→' 
            WHEN S1.sale > S2.sale THEN '↑' 
            WHEN S1.sale < S2.sale THEN '↓' 
       ELSE '—' END AS var
  FROM Sales S1, Sales S2
 WHERE S2.year = S1.year-1
 ORDER BY year;
/*3 时间轴有间断时：和过去最临近的时间进行比较*/
CREATE TABLE Sales2
(year INTEGER NOT NULL , 
 sale INTEGER NOT NULL , 
 PRIMARY KEY (year));

INSERT INTO Sales2 VALUES (1990, 50);
INSERT INTO Sales2 VALUES (1992, 50);
INSERT INTO Sales2 VALUES (1993, 52);
INSERT INTO Sales2 VALUES (1994, 55);
INSERT INTO Sales2 VALUES (1997, 55);
/* 查询与过去最临近的年份营业额相同的年份 */
SELECT year, sale
  FROM Sales2 S1
 WHERE sale =
   (SELECT sale
      FROM Sales2 S2
     WHERE S2.year =
       (SELECT MAX(year)            /* 条件2：在满足条件1的年份中，年份最早的一个 */
          FROM Sales2 S3
         WHERE S1.year > S3.year))  /* 条件1：与该年份相比是过去的年份 */
 ORDER BY year;
/* 查询与过去最临近的年份营业额相同的年份：同时使用自连接 */
SELECT S1.year AS year,
       S1.sale AS sale
  FROM Sales2 S1, Sales2 S2
 WHERE S1.sale = S2.sale
   AND S2.year = (SELECT MAX(year)
                    FROM Sales2 S3
                   WHERE S1.year > S3.year)
 ORDER BY year;
/* 求每一年与过去最临近的年份之间的营业额之差（1）：结果里不包含最早的年份 */
SELECT S2.year AS pre_year,
       S1.year AS now_year,
       S2.sale AS pre_sale,
       S1.sale AS now_sale,
       S1.sale - S2.sale  AS diff
 FROM Sales2 S1, Sales2 S2
 WHERE S2.year = (SELECT MAX(year)
                    FROM Sales2 S3
                   WHERE S1.year > S3.year)
 ORDER BY now_year;
/* 求每一年与过去最临近的年份之间的营业额之差（2）：使用自外连接。结果里包含最早的年份 */
SELECT S2.year AS pre_year,
       S1.year AS now_year,
       S2.sale AS pre_sale,
       S1.sale AS now_sale,
       S1.sale - S2.sale AS diff
 FROM Sales2 S1 LEFT OUTER JOIN Sales2 S2
   ON S2.year = (SELECT MAX(year)
                   FROM Sales2 S3
                  WHERE S1.year > S3.year)
 ORDER BY now_year;
/*4 移动累计值和移动平均值*/
CREATE TABLE Accounts
(prc_date DATE NOT NULL , 
 prc_amt  INTEGER NOT NULL , 
 PRIMARY KEY (prc_date)) ;

INSERT INTO Accounts VALUES ('2006-10-26',  12000 );
INSERT INTO Accounts VALUES ('2006-10-28',   2500 );
INSERT INTO Accounts VALUES ('2006-10-31', -15000 );
INSERT INTO Accounts VALUES ('2006-11-03',  34000 );
INSERT INTO Accounts VALUES ('2006-11-04',  -5000 );
INSERT INTO Accounts VALUES ('2006-11-06',   7200 );
INSERT INTO Accounts VALUES ('2006-11-11',  11000 );
/* 求累计值：使用窗口函数 */
SELECT prc_date, prc_amt,
       SUM(prc_amt) OVER (ORDER BY prc_date) AS onhand_amt
  FROM Accounts;
/* 求累计值：使用冯·诺依曼型递归集合 */
SELECT prc_date, A1.prc_amt,
      (SELECT SUM(prc_amt)
         FROM Accounts A2
        WHERE A1.prc_date >= A2.prc_date ) AS onhand_amt
  FROM Accounts A1
 ORDER BY prc_date;
/* 求移动累计值（1）：使用窗口函数 */
--以3为单位偏移,求3这个单位区间的累计值
SELECT prc_date, prc_amt,
       SUM(prc_amt) OVER (ORDER BY prc_date
                           ROWS 2 PRECEDING) AS onhand_amt
  FROM Accounts;
/* 求移动累计值（2）：不满3行的时间区间也输出 */
SELECT prc_date, A1.prc_amt,
      (SELECT SUM(prc_amt)
         FROM Accounts A2
        WHERE A1.prc_date >= A2.prc_date
          AND (SELECT COUNT(*)
                 FROM Accounts A3
                WHERE A3.prc_date 
                  BETWEEN A2.prc_date AND A1.prc_date  ) <= 3 ) AS mvg_sum
  FROM Accounts A1
 ORDER BY prc_date;
/* 求移动累计值（3）：不满3行的区间按无效处理 */
SELECT prc_date, A1.prc_amt,
 (SELECT SUM(prc_amt)
    FROM Accounts A2
   WHERE A1.prc_date >= A2.prc_date
     AND (SELECT COUNT(*)
            FROM Accounts A3
           WHERE A3.prc_date 
             BETWEEN A2.prc_date AND A1.prc_date  ) <= 3
   HAVING  COUNT(*) =3) AS mvg_sum  /* 不满3行数据的不显示 */
  FROM  Accounts A1
 ORDER BY prc_date;
/*5 查询重叠的时间区间*/
--查询重叠的时间区间
CREATE TABLE Reservations
(reserver    VARCHAR(30) PRIMARY KEY,
 start_date  DATE  NOT NULL,
 end_date    DATE  NOT NULL);

INSERT INTO Reservations VALUES('木村', '2006-10-26', '2006-10-27');
INSERT INTO Reservations VALUES('荒木', '2006-10-28', '2006-10-31');
INSERT INTO Reservations VALUES('堀',   '2006-10-31', '2006-11-01');
INSERT INTO Reservations VALUES('山本', '2006-11-03', '2006-11-04');
INSERT INTO Reservations VALUES('内田', '2006-11-03', '2006-11-05');
INSERT INTO Reservations VALUES('水谷', '2006-11-06', '2006-11-06');

--山本的入住日期为4日时
DELETE FROM Reservations WHERE reserver = '山本';
INSERT INTO Reservations VALUES('山本', '2006-11-04', '2006-11-04');
/* 求重叠的住宿期间 */
SELECT reserver, start_date, end_date
  FROM Reservations R1
 WHERE EXISTS
       (SELECT *
          FROM Reservations R2
         WHERE R1.reserver <> R2.reserver  /* 与自己以外的客人进行比较 */
           AND ( R1.start_date BETWEEN R2.start_date AND R2.end_date    /* 条件（1）：自己的入住日期在他人的住宿期间内 */
              OR R1.end_date  BETWEEN R2.start_date AND R2.end_date));  /* 条件（2）：自己的离店日期在他人的住宿期间内 */
/* 升级版：把完全包含别人的住宿期间的情况也输出 */
SELECT reserver, start_date, end_date
 FROM Reservations R1
WHERE EXISTS
       (SELECT *
          FROM Reservations R2
         WHERE R1.reserver <> R2.reserver
           AND (  (     R1.start_date BETWEEN R2.start_date AND R2.end_date
                     OR R1.end_date   BETWEEN R2.start_date AND R2.end_date)
                OR (    R2.start_date BETWEEN R1.start_date AND R1.end_date
                    AND R2.end_date   BETWEEN R1.start_date AND R1.end_date))); 
/*练习题*/
/* 练习题1-6-1：简化多行数据的比较*/
SELECT S1.year, S1.sale,
       CASE SIGN(sale -
              (SELECT sale
                 FROM Sales S2
                WHERE S2.year = S1.year - 1) )
            WHEN 0  THEN '→'  /* 持平 */
            WHEN 1  THEN '↑'  /* 增长   */
            WHEN -1 THEN '↓'  /* 减少   */
            ELSE '—' END AS var
  FROM Sales S1
 ORDER BY year;
/* 练习题1-6-2：使用OVERLAPS查询重叠的时间区间 */
SELECT reserver, start_date, end_date
  FROM Reservations R1
 WHERE EXISTS
        (SELECT *
           FROM Reservations R2
          WHERE R1.reserver <> R2.reserver /* 与除自己以外的客人进行比较 */
            AND (R1.start_date, R1.end_date) OVERLAPS (R2.start_date, R2.end_date));
/* 练习题1-6-2：使用OVERLAPS查询重叠的时间区间 */
SELECT R1.reserver, R1.start_date, R1.end_date
  FROM Reservations R1, Reservations R2
 WHERE R1.reserver <> R2.reserver /* 与除自己以外的客人进行比较 */
   AND (R1.start_date, R1.end_date) OVERLAPS (R2.start_date, R2.end_date);
/* 练习题1-6-3：SUM函数可以计算出累计值,那么MAX、MIN、AVG可以计算出什么？*/
--任何聚合函数都可以开窗
--窗口函数版：
SELECT prc_date,prc_amt,
    MAX(prc_amt) OVER (ORDER BY prc_date) AS onhand_max
    FROM Accounts;
--关联子查询版
SELECT prc_date,A1.prc_amt,
    (SELECT MAX(prc_amt)
        FROM Accounts A2
        WHERE A1.prc_date >=A2.prc_date) AS onhand_max
   FROM Accounts A1
  ORDER BY prc_date;    