/*1 生成连续编号*/
CREATE TABLE Digits
 (digit INTEGER PRIMARY KEY); 

INSERT INTO Digits VALUES (0);
INSERT INTO Digits VALUES (1);
INSERT INTO Digits VALUES (2);
INSERT INTO Digits VALUES (3);
INSERT INTO Digits VALUES (4);
INSERT INTO Digits VALUES (5);
INSERT INTO Digits VALUES (6);
INSERT INTO Digits VALUES (7);
INSERT INTO Digits VALUES (8);
INSERT INTO Digits VALUES (9);
/* 求连续编号（1）：求0到99的数 */
SELECT D1.digit + (D2.digit * 10)  AS seq
  FROM Digits D1, Digits D2
ORDER BY seq;
/* 求连续编号（2）：求1到542的数 */
SELECT D1.digit + (D2.digit * 10) + (D3.digit * 100) AS seq
  FROM Digits D1, Digits D2, Digits D3
 WHERE D1.digit + (D2.digit * 10) + (D3.digit * 100) BETWEEN 1 AND 542
ORDER BY seq;
/* 生成序列视图（包含0到999） */
CREATE VIEW Sequence (seq)
AS SELECT D1.digit + (D2.digit * 10) + (D3.digit * 100)
     FROM Digits D1, Digits D2, Digits D3;
/*2 求全部的缺失编号*/
CREATE TABLE SeqTbl
 (seq INTEGER PRIMARY KEY); 

INSERT INTO SeqTbl VALUES (1);
INSERT INTO SeqTbl VALUES (2);
INSERT INTO SeqTbl VALUES (4);
INSERT INTO SeqTbl VALUES (5);
INSERT INTO SeqTbl VALUES (6);
INSERT INTO SeqTbl VALUES (7);
INSERT INTO SeqTbl VALUES (8);
INSERT INTO SeqTbl VALUES (11);
INSERT INTO SeqTbl VALUES (12);
/* 求所有缺失编号：EXCEPT版 */
SELECT seq
  FROM Sequence
 WHERE seq BETWEEN 1 AND 12
EXCEPT
SELECT seq FROM SeqTbl;
/* 求所有缺失编号：NOT IN版 */
SELECT seq
  FROM Sequence
 WHERE seq BETWEEN 1 AND 12
   AND seq NOT IN (SELECT seq FROM SeqTbl);
/* 动态地指定连续编号范围的SQL语句 */
SELECT seq
  FROM Sequence
 WHERE seq BETWEEN (SELECT MIN(seq) FROM SeqTbl)
               AND (SELECT MAX(seq) FROM SeqTbl)
EXCEPT
SELECT seq FROM SeqTbl;

/*3 三个人能坐得下吗？*/
CREATE TABLE Seats
 ( seat   INTEGER NOT NULL  PRIMARY KEY,
   status CHAR(6) NOT NULL
     CHECK (status IN ('未预订', '已预订')) ); 

INSERT INTO Seats VALUES (1,  '已预订');
INSERT INTO Seats VALUES (2,  '已预订');
INSERT INTO Seats VALUES (3,  '未预订');
INSERT INTO Seats VALUES (4,  '未预订');
INSERT INTO Seats VALUES (5,  '未预订');
INSERT INTO Seats VALUES (6,  '已预订');
INSERT INTO Seats VALUES (7,  '未预订');
INSERT INTO Seats VALUES (8,  '未预订');
INSERT INTO Seats VALUES (9,  '未预订');
INSERT INTO Seats VALUES (10,  '未预订');
INSERT INTO Seats VALUES (11,  '未预订');
INSERT INTO Seats VALUES (12,  '已预订');
INSERT INTO Seats VALUES (13,  '已预订');
INSERT INTO Seats VALUES (14,  '未预订');
INSERT INTO Seats VALUES (15,  '未预订');
/* 找出需要的空位（1）：不考虑座位的换排 */
SELECT S1.seat   AS start_seat, '～' , S2.seat AS end_seat
  FROM Seats S1, Seats S2
 WHERE S2.seat = S1.seat + (:head_cnt -1)  /* 决定起点和终点 */
   AND NOT EXISTS
          (SELECT *
             FROM Seats S3
            WHERE S3.seat BETWEEN S1.seat AND S2.seat
              AND S3.status <> '未预订' )
ORDER BY start_seat;

--考虑座位的折返
CREATE TABLE Seats2
 ( seat   INTEGER NOT NULL  PRIMARY KEY,
   row_id CHAR(1) NOT NULL,
   status CHAR(6) NOT NULL
     CHECK (status IN ('未预订', '已预订')) ); 

INSERT INTO Seats2 VALUES (1, 'A', '已预订');
INSERT INTO Seats2 VALUES (2, 'A', '已预订');
INSERT INTO Seats2 VALUES (3, 'A', '未预订');
INSERT INTO Seats2 VALUES (4, 'A', '未预订');
INSERT INTO Seats2 VALUES (5, 'A', '未预订');
INSERT INTO Seats2 VALUES (6, 'B', '已预订');
INSERT INTO Seats2 VALUES (7, 'B', '已预订');
INSERT INTO Seats2 VALUES (8, 'B', '未预订');
INSERT INTO Seats2 VALUES (9, 'B', '未预订');
INSERT INTO Seats2 VALUES (10,'B', '未预订');
INSERT INTO Seats2 VALUES (11,'C', '未预订');
INSERT INTO Seats2 VALUES (12,'C', '未预订');
INSERT INTO Seats2 VALUES (13,'C', '未预订');
INSERT INTO Seats2 VALUES (14,'C', '已预订');
INSERT INTO Seats2 VALUES (15,'C', '未预订');
/* 找出需要的空位（2）：考虑座位的换排 */
SELECT S1.seat   AS start_seat, '～' , S2.seat AS end_seat
  FROM Seats2 S1, Seats2 S2
 WHERE S2.seat = S1.seat + (:head_cnt -1)  --决定起点和终点
   AND NOT EXISTS
          (SELECT *
             FROM Seats2 S3
            WHERE S3.seat BETWEEN S1.seat AND S2.seat
              AND (    S3.status <> '未预订'
                    OR S3.row_id <> S1.row_id))
ORDER BY start_seat;
/*4 最多能坐下多少人？*/
CREATE TABLE Seats3
 ( seat   INTEGER NOT NULL  PRIMARY KEY,
   status CHAR(6) NOT NULL
     CHECK (status IN ('未预订', '已预订')) ); 

INSERT INTO Seats3 VALUES (1,  '已预订');
INSERT INTO Seats3 VALUES (2,  '未预订');
INSERT INTO Seats3 VALUES (3,  '未预订');
INSERT INTO Seats3 VALUES (4,  '未预订');
INSERT INTO Seats3 VALUES (5,  '未预订');
INSERT INTO Seats3 VALUES (6,  '已预订');
INSERT INTO Seats3 VALUES (7,  '未预订');
INSERT INTO Seats3 VALUES (8,  '已预订');
INSERT INTO Seats3 VALUES (9,  '未预订');
INSERT INTO Seats3 VALUES (10, '未预订');
/* 第一阶段：生成存储了所有序列的视图 */
CREATE VIEW Sequences (start_seat, end_seat, seat_cnt) AS
SELECT S1.seat  AS start_seat,
       S2.seat  AS end_seat,
       S2.seat - S1.seat + 1 AS seat_cnt
  FROM Seats3 S1, Seats3 S2
 WHERE S1.seat <= S2.seat  /* 第一步：生成起点和终点的组合 */
   AND NOT EXISTS   /* 第二步：描述序列内所有点需要满足的条件 */
       (SELECT *
          FROM Seats3 S3
         WHERE (     S3.seat BETWEEN S1.seat AND S2.seat 
                 AND S3.status <> '未预订')                         /* 条件1的否定 */
            OR  (S3.seat = S2.seat + 1 AND S3.status = '未预订' )    /* 条件2的否定 */
            OR  (S3.seat = S1.seat - 1 AND S3.status = '未预订' ));  /* 条件3的否定 */
/* 第二阶段：求最长的序列 */
SELECT start_seat, '～', end_seat, seat_cnt
  FROM Sequences
 WHERE seat_cnt = (SELECT MAX(seat_cnt) FROM Sequences);
/*5 单调递增和单调递减*/
CREATE TABLE MyStock
 (deal_date  DATE PRIMARY KEY,
  price      INTEGER ); 

INSERT INTO MyStock VALUES ('2007-01-06', 1000);
INSERT INTO MyStock VALUES ('2007-01-08', 1050);
INSERT INTO MyStock VALUES ('2007-01-09', 1050);
INSERT INTO MyStock VALUES ('2007-01-12', 900);
INSERT INTO MyStock VALUES ('2007-01-13', 880);
INSERT INTO MyStock VALUES ('2007-01-14', 870);
INSERT INTO MyStock VALUES ('2007-01-16', 920);
INSERT INTO MyStock VALUES ('2007-01-17', 1000);
/* 求单调递增的区间的SQL语句：子集也输出 */
SELECT S1.deal_date   AS start_date,
       S2.deal_date   AS end_date
  FROM MyStock S1, MyStock S2
 WHERE S1.deal_date < S2.deal_date  /* 第一步：生成起点和终点的组合 */
   AND  NOT EXISTS                  /* 第二步：描述区间内所有日期需要满足的条件 */
           ( SELECT *
               FROM MyStock S3, MyStock S4
              WHERE S3.deal_date BETWEEN S1.deal_date AND S2.deal_date
                AND S4.deal_date BETWEEN S1.deal_date AND S2.deal_date
                AND S3.deal_date < S4.deal_date
                AND S3.price >= S4.price)
ORDER BY start_date, end_date;
--排除掉子集，只取最长的时间区间
SELECT MIN(start_date) AS start_date,          /* 最大限度地向前延伸起点 */
       end_date
  FROM  (SELECT S1.deal_date AS start_date,
                MAX(S2.deal_date) AS end_date  /* 最大限度地向后延伸终点 */
           FROM MyStock S1, MyStock S2
          WHERE S1.deal_date < S2.deal_date
            AND NOT EXISTS
             (SELECT *
                FROM MyStock S3, MyStock S4
               WHERE S3.deal_date BETWEEN S1.deal_date AND S2.deal_date
                 AND S4.deal_date BETWEEN S1.deal_date AND S2.deal_date
                 AND S3.deal_date < S4.deal_date
                 AND S3.price >= S4.price)
         GROUP BY S1.deal_date) TMP
GROUP BY end_date
ORDER BY start_date;
/*练习题*/
/* 练习题1-9-1：求所有的缺失编号——NOT EXISTS和外连接 
   NOT EXISTS版  */
SELECT seq
  FROM Sequence N
 WHERE seq BETWEEN 1 AND 12
   AND NOT EXISTS
        (SELECT *
           FROM SeqTbl S
          WHERE N.seq = S.seq );
/* 练习题1-9-1：求所有的缺失编号——NOT EXISTS和外连接 
   NOT EXISTS版  */
SELECT N.seq
  FROM Sequence N LEFT OUTER JOIN SeqTbl S
    ON N.seq = S.seq
 WHERE N.seq BETWEEN 1 AND 12
   AND S.seq IS NULL;

/* 练习题1-9-2：求序列——面向集合的思想 */
SELECT S1.seat AS start_seat, '～' , S2.seat AS end_seat
  FROM Seats S1, Seats S2, Seats S3
 WHERE S2.seat = S1.seat + (:head_cnt -1)
   AND S3.seat BETWEEN S1.seat AND S2.seat
 GROUP BY S1.seat, S2.seat
HAVING COUNT(*) = SUM(CASE WHEN S3.status = '未预订' THEN 1 ELSE 0 END);
/* 坐位有换排时 */
SELECT S1.seat AS start_seat, ' ～ ' , S2.seat AS end_seat
  FROM Seats2 S1, Seats2 S2, Seats2 S3
 WHERE S2.seat = S1.seat + (:head_cnt -1)
   AND S3.seat BETWEEN S1.seat AND S2.seat
 GROUP BY S1.seat, S2.seat
HAVING COUNT(*) = SUM(CASE WHEN S3.status = '未预订'
                            AND S3.row_id = S1.row_id THEN 1 ELSE 0 END);

/* 练习题1-9-3：求所有的序列——面向集合的思想 */
SELECT S1.seat AS start_seat,
       S2.seat AS end_seat,
       S2.seat - S1.seat + 1 AS seat_cnt
  FROM Seats3 S1, Seats3 S2, Seats3 S3
 WHERE S1.seat <= S2.seat /* 第一步：生成起点和终点的组合 */
   AND S3.seat BETWEEN S1.seat - 1 AND S2.seat + 1
 GROUP BY S1.seat, S2.seat
HAVING COUNT(*) = SUM(CASE WHEN S3.seat BETWEEN S1.seat AND S2.seat
                            AND S3.status = '未预订' THEN 1 /* 条件1 */
                           WHEN S3.seat = S2.seat + 1 AND S3.status = '已预订' THEN 1 /* 条件2 */
                           WHEN S3.seat = S1.seat - 1 AND S3.status = '已预订' THEN 1 /* 条件3 */
                           ELSE 0 END);