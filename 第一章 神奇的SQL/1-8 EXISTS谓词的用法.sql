/*1 理论篇*/
--谓词是一种特殊的函数，返回值是真值。返回值都是true、false或者unknown
/*在EXISTS的子查询里，SELECT子句的列表可以有下面这三种写法：
1.通配符：SELECT *
2.常量：SELECT '这里的内容任意'
3.列名：SELECT col
*/
--注意：EXISTS的输入值是行数据的集合;而EXISTS以外的谓词(像 <、>、=、 LIKE、 BETWEEN 、IN 等)的输入值是一行数据

/*2 实践篇*/
/*2.1 查询表中“不”存在的数据 */
CREATE TABLE Meetings
(meeting CHAR(32) NOT NULL,
 person  CHAR(32) NOT NULL,
 PRIMARY KEY (meeting, person));

INSERT INTO Meetings VALUES('第1次', '伊藤');
INSERT INTO Meetings VALUES('第1次', '水岛');
INSERT INTO Meetings VALUES('第1次', '坂东');
INSERT INTO Meetings VALUES('第2次', '伊藤');
INSERT INTO Meetings VALUES('第2次', '宫田');
INSERT INTO Meetings VALUES('第3次', '坂东');
INSERT INTO Meetings VALUES('第3次', '水岛');
INSERT INTO Meetings VALUES('第3次', '宫田');
/* 用于求出缺席者的SQL语句（1）：存在量化的应用 */
SELECT DISTINCT M1.meeting, M2.person
  FROM Meetings M1 CROSS JOIN Meetings M2
 WHERE NOT EXISTS
        (SELECT *
           FROM Meetings M3
          WHERE M1.meeting = M3.meeting
            AND M2.person = M3.person);
/* 用于求出缺席者的SQL语句（2）：使用差集运算 */
SELECT M1.meeting, M2.person
  FROM Meetings M1, Meetings M2
EXCEPT
SELECT meeting, person
  FROM Meetings;
/*2.2 全称量化（1）：习惯“肯定<＝>双重否定”之间的转换 */
CREATE TABLE TestScores
(student_id INTEGER,
 subject    VARCHAR(32) ,
 score      INTEGER,
  PRIMARY KEY(student_id, subject));

INSERT INTO TestScores VALUES(100, '数学',100);
INSERT INTO TestScores VALUES(100, '语文',80);
INSERT INTO TestScores VALUES(100, '理化',80);
INSERT INTO TestScores VALUES(200, '数学',80);
INSERT INTO TestScores VALUES(200, '语文',95);
INSERT INTO TestScores VALUES(300, '数学',40);
INSERT INTO TestScores VALUES(300, '语文',90);
INSERT INTO TestScores VALUES(300, '社会',55);
INSERT INTO TestScores VALUES(400, '数学',80);
/* 全称量化（1）：习惯“肯定<＝>双重否定”之间的转换 */
SELECT DISTINCT student_id
  FROM TestScores TS1
 WHERE subject IN ('数学', '语文')
   AND NOT EXISTS
        (SELECT *
           FROM TestScores TS2
          WHERE TS2.student_id = TS1.student_id
            AND 1 = CASE WHEN subject = '数学' AND score < 80 THEN 1
                         WHEN subject = '语文' AND score < 50 THEN 1
                         ELSE 0 END);
/* 全称量化（1）：习惯“肯定<＝>双重否定”之间的转换 */
SELECT student_id
  FROM TestScores TS1
 WHERE subject IN ('数学', '语文')
   AND NOT EXISTS
        (SELECT *
           FROM TestScores TS2
          WHERE TS2.student_id = TS1.student_id
            AND 1 = CASE WHEN subject = '数学' AND score < 80 THEN 1
                         WHEN subject = '语文' AND score < 50 THEN 1
                         ELSE 0 END)
 GROUP BY student_id
HAVING COUNT(*) = 2; /* 必须两门科目都有分数 */
/*2.3 全称量化（2）：集合VS谓词——哪个更强大？ */
CREATE TABLE Projects
(project_id VARCHAR(32),
 step_nbr   INTEGER ,
 status     VARCHAR(32),
  PRIMARY KEY(project_id, step_nbr));

INSERT INTO Projects VALUES('AA100', 0, '完成');
INSERT INTO Projects VALUES('AA100', 1, '等待');
INSERT INTO Projects VALUES('AA100', 2, '等待');
INSERT INTO Projects VALUES('B200',  0, '等待');
INSERT INTO Projects VALUES('B200',  1, '等待');
INSERT INTO Projects VALUES('CS300', 0, '完成');
INSERT INTO Projects VALUES('CS300', 1, '完成');
INSERT INTO Projects VALUES('CS300', 2, '等待');
INSERT INTO Projects VALUES('CS300', 3, '等待');
INSERT INTO Projects VALUES('DY400', 0, '完成');
INSERT INTO Projects VALUES('DY400', 1, '完成');
INSERT INTO Projects VALUES('DY400', 2, '完成');
/* 查询完成到了工程1的项目：面向集合的解法 */
SELECT project_id
  FROM Projects
 GROUP BY project_id
HAVING COUNT(*) = SUM(CASE WHEN step_nbr <= 1 AND status = '完成' THEN 1
                           WHEN step_nbr > 1 AND status = '等待' THEN 1
                           ELSE 0 END);
/* 查询完成到了工程1的项目：谓词逻辑的解法 */
SELECT *
  FROM Projects P1
 WHERE NOT EXISTS
        (SELECT status
           FROM Projects P2
          WHERE P1.project_id = P2. project_id  /* 以项目为单位进行条件判断 */
            AND status <> CASE WHEN step_nbr <= 1 /* 使用双重否定来表达全称量化命题 */
                               THEN '完成'
                               ELSE '等待' END);
/*2.4 对列进行量化：查询全是1的行 */
CREATE TABLE ArrayTbl
 (keycol CHAR(1) PRIMARY KEY,
  col1  INTEGER,
  col2  INTEGER,
  col3  INTEGER,
  col4  INTEGER,
  col5  INTEGER,
  col6  INTEGER,
  col7  INTEGER,
  col8  INTEGER,
  col9  INTEGER,
  col10 INTEGER);

--全为NULL
INSERT INTO ArrayTbl VALUES('A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO ArrayTbl VALUES('B', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
--全为1
INSERT INTO ArrayTbl VALUES('C', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
--至少有一个9
INSERT INTO ArrayTbl VALUES('D', NULL, NULL, 9, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO ArrayTbl VALUES('E', NULL, 3, NULL, 1, 9, NULL, NULL, 9, NULL, NULL);
/* “列方向”的全称量化：不优雅的解答 */
SELECT *
  FROM ArrayTbl
 WHERE col1 = 1
   AND col2 = 1
   AND col3 = 1
   AND col4 = 1
   AND col5 = 1
   AND col6 = 1
   AND col7 = 1
   AND col8 = 1
   AND col9 = 1
   AND col10 = 1;
/* “列方向”的全称量化：优雅的解答 */
SELECT *
  FROM ArrayTbl
 WHERE 1 = ALL (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);


/*译者注：上面的代码在PostgreSQL中运行时会报错。将代码改为下面这样即可成功运行*/
SELECT *
  FROM ArrayTbl
 WHERE 1 = ALL (values (col1), (col2), (col3), (col4), (col5), (col6), (col7), (col8), (col9), (col10));
/* “列方向”的存在量化（1） */
SELECT *
  FROM ArrayTbl
 WHERE 9 = ANY (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);

/*译者注：上面的代码在PostgreSQL中运行时会报错。将代码改为下面这样即可成功运行*/
SELECT *
  FROM ArrayTbl
 WHERE 9 = ANY (values (col1), (col2), (col3), (col4), (col5), (col6), (col7), (col8), (col9), (col10));
/* “列方向”的存在量化（2） */
SELECT *
  FROM ArrayTbl
 WHERE 9 IN (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);
/* 查询全是NULL的行：错误的解法 */
SELECT *
  FROM ArrayTbl
 WHERE NULL = ALL (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);


/*译者注：上面的代码在PostgreSQL中运行时会报错。将代码改为下面这样即可成功运行*/
SELECT *
  FROM ArrayTbl
 WHERE NULL = ALL (values (col1), (col2), (col3), (col4), (col5), (col6), (col7), (col8), (col9), (col10));
/* 查询全是NULL的行：正确的解法 */
SELECT *
  FROM ArrayTbl
 WHERE COALESCE(col1, col2, col3, col4, col5, col6, col7, col8, col9, col10) IS NULL;

/*练习题*/
/* 练习题1-8-1:数组表——行结构表的情况 */
CREATE TABLE ArrayTbl2
 (key   CHAR(1) NOT NULL,
    i   INTEGER NOT NULL,
  val   INTEGER,
  PRIMARY KEY (key, i));

/* A全为NULL、B仅有一个为非NULL、C全为非NULL */
INSERT INTO ArrayTbl2 VALUES('A', 1, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 2, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 3, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 4, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 5, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 6, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 7, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 8, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 9, NULL);
INSERT INTO ArrayTbl2 VALUES('A',10, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 1, 3);
INSERT INTO ArrayTbl2 VALUES('B', 2, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 3, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 4, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 5, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 6, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 7, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 8, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 9, NULL);
INSERT INTO ArrayTbl2 VALUES('B',10, NULL);
INSERT INTO ArrayTbl2 VALUES('C', 1, 1);
INSERT INTO ArrayTbl2 VALUES('C', 2, 1);
INSERT INTO ArrayTbl2 VALUES('C', 3, 1);
INSERT INTO ArrayTbl2 VALUES('C', 4, 1);
INSERT INTO ArrayTbl2 VALUES('C', 5, 1);
INSERT INTO ArrayTbl2 VALUES('C', 6, 1);
INSERT INTO ArrayTbl2 VALUES('C', 7, 1);
INSERT INTO ArrayTbl2 VALUES('C', 8, 1);
INSERT INTO ArrayTbl2 VALUES('C', 9, 1);
INSERT INTO ArrayTbl2 VALUES('C',10, 1);
/* 练习题1-8-1：数组表——行结构表的情况 
   错误的结果 */
SELECT DISTINCT key
  FROM ArrayTbl2 AT1
 WHERE NOT EXISTS
        (SELECT *
           FROM ArrayTbl2 AT2
          WHERE AT1.key = AT2.key
            AND AT2.val <> 1);
/* 正确解法 */
SELECT DISTINCT key
  FROM ArrayTbl2 A1
 WHERE NOT EXISTS
        (SELECT *
           FROM ArrayTbl2 A2
          WHERE A1.key = A2.key
            AND (A2.val <> 1 OR A2.val IS NULL));
/* 其他解法1：使用ALL谓词 */
SELECT DISTINCT key
  FROM ArrayTbl2 A1
 WHERE 1 = ALL
          (SELECT val
             FROM ArrayTbl2 A2
            WHERE A1.key = A2.key);
/* 其他解法2：使用HAVING子句 */
SELECT key
  FROM ArrayTbl2
 GROUP BY key
HAVING SUM(CASE WHEN val = 1 THEN 1 ELSE 0 END) = 10;
/* 其他解法3：在HAVING子句中使用极值函数 */
SELECT key
  FROM ArrayTbl2
 GROUP BY key
HAVING MAX(val) = 1
   AND MIN(val) = 1;
/* 练习题1-8-2：使用ALL谓词进行全称量化
   查找已经完成到工程1的项目：使用ALL谓词解答 */
SELECT *
  FROM Projects P1
 WHERE '○' = ALL
             (SELECT CASE WHEN step_nbr <= 1 AND status = '完成' THEN '○'
                          WHEN step_nbr > 1  AND status = '等待' THEN '○'
                          ELSE '×' END
                FROM Projects P2
               WHERE P1.project_id = P2. project_id);
/* 练习题1-8-3：求质数 */
SELECT num AS prime
  FROM Numbers Dividend
 WHERE num > 1
   AND NOT EXISTS
        (SELECT *
           FROM Numbers Divisor
          WHERE Divisor.num <= Dividend.num / 2 /* 除了自身之外的约数必定小于等于自身值的一半 */
            AND Divisor.num <> 1 /* 约数中不包含1 */
            AND MOD(Dividend.num, Divisor.num) = 0)  /*“除不尽”的否定条件是“除尽” */
ORDER BY prime;