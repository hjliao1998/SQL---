/*1 各队，全体点名！*/
CREATE TABLE Teams
(member  CHAR(12) NOT NULL PRIMARY KEY,
 team_id INTEGER  NOT NULL,
 status  CHAR(8)  NOT NULL);

INSERT INTO Teams VALUES('乔',     1, '待命');
INSERT INTO Teams VALUES('肯',     1, '出勤中');
INSERT INTO Teams VALUES('米克',   1, '待命');
INSERT INTO Teams VALUES('卡伦',   2, '出勤中');
INSERT INTO Teams VALUES('凯斯',   2, '休息');
INSERT INTO Teams VALUES('简',     3, '待命');
INSERT INTO Teams VALUES('哈特',   3, '待命');
INSERT INTO Teams VALUES('迪克',   3, '待命');
INSERT INTO Teams VALUES('贝斯',   4, '待命');
INSERT INTO Teams VALUES('阿伦',   5, '出勤中');
INSERT INTO Teams VALUES('罗伯特', 5, '休息');
INSERT INTO Teams VALUES('卡根',   5, '待命');
--查出可以出勤的队伍，即队伍里所有的成员都处于‘待命’状态
/* 用谓词表达全称量化命题 */
SELECT team_id, member
  FROM Teams T1
 WHERE NOT EXISTS
        (SELECT *
           FROM Teams T2
          WHERE T1.team_id = T2.team_id
            AND status <> '待命' );
--所有成员都处于待命状态即不存在不处于待命状态的队员
/* 用集合表达全称量化命题（1） */
SELECT team_id
  FROM Teams
 GROUP BY team_id
HAVING COUNT(*) = SUM(CASE WHEN status = '待命'
                           THEN 1
                           ELSE 0 END);
/* 用集合表达全称量化命题（2） */
SELECT team_id
  FROM Teams
 GROUP BY team_id
HAVING MAX(status) = '待命'
   AND MIN(status) = '待命';
/* 列表显示各个队伍是否所有队员都在待命 */
SELECT team_id,
       CASE WHEN MAX(status) = '待命' AND MIN(status) = '待命'
            THEN '全都在待命'
            ELSE '队长！人手不够' END AS status
  FROM Teams
 GROUP BY team_id;
/*2 单重集合与多重集合*/
CREATE TABLE Materials
(center         CHAR(12) NOT NULL,
 receive_date   DATE     NOT NULL,
 material       CHAR(12) NOT NULL,
 PRIMARY KEY(center, receive_date));

INSERT INTO Materials VALUES('东京'   ,'2007-4-01',   '锡');
INSERT INTO Materials VALUES('东京'   ,'2007-4-12',   '锌');
INSERT INTO Materials VALUES('东京'   ,'2007-5-17',   '铝');
INSERT INTO Materials VALUES('东京'   ,'2007-5-20',   '锌');
INSERT INTO Materials VALUES('大阪'   ,'2007-4-20',   '铜');
INSERT INTO Materials VALUES('大阪'   ,'2007-4-22',   '镍');
INSERT INTO Materials VALUES('大阪'   ,'2007-4-29',   '铅');
INSERT INTO Materials VALUES('名古屋', '2007-3-15',    '钛');
INSERT INTO Materials VALUES('名古屋', '2007-4-01',    '钢');
INSERT INTO Materials VALUES('名古屋', '2007-4-24',    '钢');
INSERT INTO Materials VALUES('名古屋', '2007-5-02',    '镁');
INSERT INTO Materials VALUES('名古屋', '2007-5-10',    '钛');
INSERT INTO Materials VALUES('福冈'   ,'2007-5-10',   '锌');
INSERT INTO Materials VALUES('福冈'   ,'2007-5-28',   '锡');
/* 选中材料存在重复的生产地 */
SELECT center
  FROM Materials
 GROUP BY center
HAVING COUNT(material) <> COUNT(DISTINCT material);
/* 列表显示是否存在重复 */
SELECT center,
       CASE WHEN COUNT(material) <> COUNT(DISTINCT material) 
            THEN '存在重复'
            ELSE '不存在重复' END AS status
  FROM Materials
 GROUP BY center;
/* 存在重复的集合：使用EXISTS */
SELECT center, material
  FROM Materials M1
 WHERE EXISTS
       (SELECT *
          FROM Materials M2
         WHERE M1.center = M2.center
           AND M1.receive_date <> M2.receive_date
           AND M1.material = M2.material);

/*3 寻找缺失的编号：升级版*/
CREATE TABLE SeqTbl
( seq INTEGER NOT NULL PRIMARY KEY);

--不存在缺失编号（起始值＝1）
DELETE FROM SeqTbl;
INSERT INTO SeqTbl VALUES(1);
INSERT INTO SeqTbl VALUES(2);
INSERT INTO SeqTbl VALUES(3);
INSERT INTO SeqTbl VALUES(4);
INSERT INTO SeqTbl VALUES(5);

--不存在缺失编号（起始值<>1）
DELETE FROM SeqTbl;
INSERT INTO SeqTbl VALUES(3);
INSERT INTO SeqTbl VALUES(4);
INSERT INTO SeqTbl VALUES(5);
INSERT INTO SeqTbl VALUES(6);
INSERT INTO SeqTbl VALUES(7);

--存在缺失编号（起始值<>1）
DELETE FROM SeqTbl;
INSERT INTO SeqTbl VALUES(3);
INSERT INTO SeqTbl VALUES(4);
INSERT INTO SeqTbl VALUES(7);
INSERT INTO SeqTbl VALUES(8);
INSERT INTO SeqTbl VALUES(10);

--存在缺失编号（起始值＝1）
DELETE FROM SeqTbl;
INSERT INTO SeqTbl VALUES(1);
INSERT INTO SeqTbl VALUES(2);
INSERT INTO SeqTbl VALUES(4);
INSERT INTO SeqTbl VALUES(5);
INSERT INTO SeqTbl VALUES(8);
/* 如果有查询结果，说明存在缺失的编号：只调查数列的连续性 */
SELECT '存在缺失的编号' AS gap
  FROM SeqTbl
HAVING COUNT(*) <> MAX(seq) - MIN(seq) + 1;
/* 不论是否存在缺失的编号都返回一行结果 */
SELECT CASE WHEN COUNT(*) = 0
               THEN '表为空'
            WHEN COUNT(*) <> MAX(seq) - MIN(seq) + 1
               THEN '存在缺失的编号'
            ELSE '连续' END AS gap
  FROM SeqTbl;
/* 查找最小的缺失编号：表中没有1时返回1 */
SELECT CASE WHEN MIN(seq) > 1          /* 最小值不是1时→返回1 */
            THEN 1
            ELSE (SELECT MIN(seq +1)  /* 最小值是1时→返回最小的缺失编号 */
                    FROM SeqTbl S1
                   WHERE NOT EXISTS
                        (SELECT * 
                           FROM SeqTbl S2 
                          WHERE S2.seq = S1.seq + 1))
             END AS min_gap
  FROM SeqTbl;
/*4 为集合设置详细的条件*/
CREATE TABLE TestResults
(student CHAR(12) NOT NULL PRIMARY KEY,
 class   CHAR(1)  NOT NULL,
 sex     CHAR(1)  NOT NULL,
 score   INTEGER  NOT NULL);

INSERT INTO TestResults VALUES('001', 'A', '男', 100);
INSERT INTO TestResults VALUES('002', 'A', '女', 100);
INSERT INTO TestResults VALUES('003', 'A', '女',  49);
INSERT INTO TestResults VALUES('004', 'A', '男',  30);
INSERT INTO TestResults VALUES('005', 'B', '女', 100);
INSERT INTO TestResults VALUES('006', 'B', '男',  92);
INSERT INTO TestResults VALUES('007', 'B', '男',  80);
INSERT INTO TestResults VALUES('008', 'B', '男',  80);
INSERT INTO TestResults VALUES('009', 'B', '女',  10);
INSERT INTO TestResults VALUES('010', 'C', '男',  92);
INSERT INTO TestResults VALUES('011', 'C', '男',  80);
INSERT INTO TestResults VALUES('012', 'C', '女',  21);
INSERT INTO TestResults VALUES('013', 'D', '女', 100);
INSERT INTO TestResults VALUES('014', 'D', '女',   0);
INSERT INTO TestResults VALUES('015', 'D', '女',   0);
/* 75%以上的学生分数都在80分以上的班级 */
SELECT class
  FROM TestResults 
GROUP BY class
HAVING COUNT(*) * 0.75 
         <= SUM(CASE WHEN score >= 80 
                     THEN 1
                     ELSE 0 END) ;
/* 分数在50分以上的男生的人数比分数在50分以上的女生的人数多的班级 */
SELECT class
  FROM TestResults 
GROUP BY class
HAVING SUM(CASE WHEN score >= 50 AND sex = '男'
                THEN 1
                ELSE 0 END)
       > SUM(CASE WHEN score >= 50 AND sex = '女'
                  THEN 1
                  ELSE 0 END) ;
/* 比较男生和女生平均分的SQL语句（1）：对空集使用AVG后返回0 */
--女生平均分比男生平均分高的班级
SELECT class
  FROM TestResults
 GROUP BY class
HAVING AVG(CASE WHEN sex = '男'
                THEN score
                ELSE 0 END)
     < AVG(CASE WHEN sex = '女'
                THEN score
                ELSE 0 END) ;
/* 比较男生和女生平均分的SQL语句（2）：对空集求平均值后返回NULL */
SELECT class
  FROM TestResults
 GROUP BY class
HAVING AVG(CASE WHEN sex = '男'
                THEN score
                ELSE NULL END)
     < AVG(CASE WHEN sex = '女'
                THEN score
                ELSE NULL END);
/*练习题*/
/* 练习题1-10-1:单重集合与多重集合的一般化 */
CREATE TABLE Materials2
(center VARCHAR(32) NOT NULL,
 receive_date DATE  NOT NULL,
 material VARCHAR(32) NOT NULL,
 orgland  VARCHAR(32) NOT NULL,
 PRIMARY KEY(center, receive_date, material));

INSERT INTO Materials2 VALUES('东京',   '2007-04-01', '锡',    '智利');
INSERT INTO Materials2 VALUES('东京',   '2007-04-12', '锌',    '泰国');
INSERT INTO Materials2 VALUES('东京',   '2007-05-17', '铝',    '巴西');
INSERT INTO Materials2 VALUES('东京',   '2007-05-20', '锌',    '泰国');
INSERT INTO Materials2 VALUES('大阪',   '2007-04-20', '铜',    '澳大利亚');
INSERT INTO Materials2 VALUES('大阪',   '2007-04-22', '镍',    '南非');
INSERT INTO Materials2 VALUES('大阪',   '2007-04-29', '铅',    '印度');
INSERT INTO Materials2 VALUES('名古屋', '2007-03-15', '钛',     '玻利维亚');
INSERT INTO Materials2 VALUES('名古屋', '2007-04-01', '钢',     '智利');
INSERT INTO Materials2 VALUES('名古屋', '2007-04-24', '钢',     '阿根廷');
INSERT INTO Materials2 VALUES('名古屋', '2007-05-02', '镁',     '智利');
INSERT INTO Materials2 VALUES('名古屋', '2007-05-10', '钛',     '泰国');
INSERT INTO Materials2 VALUES('福冈',   '2007-05-10', '锌',    '美国');
INSERT INTO Materials2 VALUES('福冈',   '2007-05-28', '锡',    '俄罗斯');
/* 练习题1-10-1：单重集合与多重集合的一般化 
 选择（材料, 原产国）组合有重复的生产地 */
SELECT center
  FROM Materials2
 GROUP BY center
HAVING COUNT(material || orgland) <> COUNT(DISTINCT material || orgland);
/* 练习题1-10-2：多个条件的特征函数 */
CREATE TABLE TestScores
 (student_id INTEGER NOT NULL,
  subject    VARCHAR(16) NOT NULL,
  score      INTEGER NOT NULL,
    PRIMARY KEY (student_id, subject));

INSERT INTO TestScores VALUES(100, '数学', 100);
INSERT INTO TestScores VALUES(100, '语文', 80);
INSERT INTO TestScores VALUES(100, '理化', 80);
INSERT INTO TestScores VALUES(200, '数学', 80);
INSERT INTO TestScores VALUES(200, '语文', 95);
INSERT INTO TestScores VALUES(300, '数学', 40);
INSERT INTO TestScores VALUES(300, '语文', 50);
INSERT INTO TestScores VALUES(300, '社会', 55);
INSERT INTO TestScores VALUES(400, '数学', 80);
/* 练习题1-10-2：多个条件的特征函数 */
SELECT student_id
  FROM TestScores
 WHERE subject IN ('数学', '语文')
 GROUP BY student_id
HAVING SUM(CASE WHEN subject = '数学' AND score >= 80 THEN 1
                WHEN subject = '语文' AND score >= 50 THEN 1
                ELSE 0 END) = 2;