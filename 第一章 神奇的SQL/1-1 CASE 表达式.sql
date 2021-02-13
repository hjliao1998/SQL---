/*粗黑体：一级，黄体：二级*/
/*1.CASE 表达式概述*/
/*1.1 CASE 表达式的写法*/

-- 简单CASE表达式
CASE sex 
	WHEN '1' THEN '男'
	WHEN '2' THEN '女'
ELSE '其他' END;
-- 搜索CASE表达式
CASE WHEN sex = '1' THEN '男'
	WHEN sex = '2' THEN '女'
ELSE '其他' END;

/*1.2 剩余的 WHEN 子句被忽略的写法示例*/

-- 例如，这样写，结果不会出现"第二"
CASE WHEN col_1 IN ('a','b') THEN '第一'
	WHEN col_1 IN ('a') THEN '第二'
ELSE '其他' END;
-- 注意事项1：统一各分支返回的数据类型
-- 注意事项2：不要忘了写END
-- 注意事项3：养成写ELSE子句的习惯

/*2 将已有编号方式转换为新的方式并统计*/
/*2.1 统计数据源表Pop Tbl*/
-- 创建表并插入数据
CREATE TABLE PopTbl
(pref_name VARCHAR(32) PRIMARY KEY,
 population INTEGER NOT NULL);

INSERT INTO PopTbl VALUES('德岛', 100);
INSERT INTO PopTbl VALUES('香川', 200);
INSERT INTO PopTbl VALUES('爱媛', 150);
INSERT INTO PopTbl VALUES('高知', 200);
INSERT INTO PopTbl VALUES('福冈', 300);
INSERT INTO PopTbl VALUES('佐贺', 100);
INSERT INTO PopTbl VALUES('长崎', 200);
INSERT INTO PopTbl VALUES('东京', 400);
INSERT INTO PopTbl VALUES('群马', 50);

-- 把县编号转换成地区编号（1）
SELECT CASE pref_name
             WHEN '德岛' THEN '四国'
             WHEN '香川' THEN '四国'
             WHEN '爱媛' THEN '四国'
             WHEN '高知' THEN '四国'
             WHEN '福冈' THEN '九州'
             WHEN '佐贺' THEN '九州'
             WHEN '长崎' THEN '九州'
             ELSE '其他' END AS district,
       SUM(population)
  FROM PopTbl
 GROUP BY CASE pref_name
             WHEN '德岛' THEN '四国'
             WHEN '香川' THEN '四国'
             WHEN '爱媛' THEN '四国'
             WHEN '高知' THEN '四国'
             WHEN '福冈' THEN '九州'
             WHEN '佐贺' THEN '九州'
             WHEN '长崎' THEN '九州'
             ELSE '其他' END;

-- 按人口数量等级划分都道府县 
SELECT CASE WHEN population < 100 THEN '01'
            WHEN population >= 100 AND population < 200 THEN '02'
            WHEN population >= 200 AND population < 300 THEN '03'
            WHEN population >= 300 THEN '04'
            ELSE NULL END AS pop_class,
       COUNT(*) AS cnt
  FROM PopTbl
 GROUP BY CASE WHEN population < 100 THEN '01'
               WHEN population >= 100 AND population < 200 THEN '02'
               WHEN population >= 200 AND population < 300 THEN '03'
               WHEN population >= 300 THEN '04'
               ELSE NULL END;

-- 把县编号转换成地区编号(2)：将CASE表达式归纳到一处
SELECT CASE pref_name
              WHEN '德岛' THEN '四国'
              WHEN '香川' THEN '四国'
              WHEN '爱媛' THEN '四国'
              WHEN '高知' THEN '四国'
              WHEN '福冈' THEN '九州'
              WHEN '佐贺' THEN '九州'
              WHEN '长崎' THEN '九州'
              ELSE '其他' END AS district,
       SUM(population)
  FROM PopTbl
 GROUP BY district; --这里GROUP BY 子句里引用了SELECT子句中定义的别名

 /*3 用一条SQL语句进行不同条件的统计*/
 /*3.1 统计数据表Pop Tbl2*/
 
CREATE TABLE PopTbl2
(pref_name VARCHAR(32),
 sex CHAR(1) NOT NULL,
 population INTEGER NOT NULL,
    PRIMARY KEY(pref_name, sex));

INSERT INTO PopTbl2 VALUES('德岛', '1',	60 );
INSERT INTO PopTbl2 VALUES('德岛', '2',	40 );
INSERT INTO PopTbl2 VALUES('香川', '1',	100);
INSERT INTO PopTbl2 VALUES('香川', '2',	100);
INSERT INTO PopTbl2 VALUES('爱媛', '1',	100);
INSERT INTO PopTbl2 VALUES('爱媛', '2',	50 );
INSERT INTO PopTbl2 VALUES('高知', '1',	100);
INSERT INTO PopTbl2 VALUES('高知', '2',	100);
INSERT INTO PopTbl2 VALUES('福冈', '1',	100);
INSERT INTO PopTbl2 VALUES('福冈', '2',	200);
INSERT INTO PopTbl2 VALUES('佐贺', '1',	20 );
INSERT INTO PopTbl2 VALUES('佐贺', '2',	80 );
INSERT INTO PopTbl2 VALUES('长崎', '1',	125);
INSERT INTO PopTbl2 VALUES('长崎', '2',	125);
INSERT INTO PopTbl2 VALUES('东京', '1',	250);
INSERT INTO PopTbl2 VALUES('东京', '2',	150); 

-- 用一条SQL语句进行不同条件的统计 
SELECT pref_name,
       -- 男性人口 
       SUM( CASE WHEN sex = '1' THEN population ELSE 0 END) AS cnt_m,
       -- 女性人口 
       SUM( CASE WHEN sex = '2' THEN population ELSE 0 END) AS cnt_f
  FROM PopTbl2
 GROUP BY pref_name; --除了SUM，COUNT、 AVG等聚合函数也都可以用于将行结构转换成列结构的数据

/*4 用CHECK约束定义多个列的条件关系*/
--女性员工工资必须在20万日元以下
/* 蕴含式 */
CONSTRAINT check_salary CHECK
( CASE WHEN sex = '2'
       THEN CASE WHEN salary <= 200000
                 THEN 1 ELSE 0 END
       ELSE 1 END = 1 );

/* 逻辑式 */
CONSTRAINT check_salary CHECK
( sex = '2' AND salary <= 200000 );

/*5 在UPDATE语句里进行条件分支*/

/*5.1 Salaries */
/* 员工工资信息表 */
CREATE TABLE Salaries
(name VARCHAR(32) PRIMARY KEY,
 salary INTEGER NOT NULL);

INSERT INTO Salaries VALUES('相田', 300000);
INSERT INTO Salaries VALUES('神崎', 270000);
INSERT INTO Salaries VALUES('木村', 220000);
INSERT INTO Salaries VALUES('齐藤', 290000);

/* 用CASE表达式写正确的更新操作 */
--1.对当前工资为30万日元以上的员工，降薪10%
--2.对当前工资为25万日元以上且不满28万日元的员工，加薪20%
UPDATE Salaries
   SET salary = CASE WHEN salary >= 300000
                     THEN salary * 0.9
                     WHEN salary >= 250000 AND salary < 280000
                     THEN salary * 1.2
                     ELSE salary END;

/*5.2 SomeTable*/
CREATE TABLE SomeTable
(p_key CHAR(1) PRIMARY KEY,
 col_1 INTEGER NOT NULL, 
 col_2 CHAR(2) NOT NULL);

INSERT INTO SomeTable VALUES('a', 1, '一');
INSERT INTO SomeTable VALUES('b', 2, '二');
INSERT INTO SomeTable VALUES('c', 3, '三');
/* 用CASE表达式调换主键值 */
UPDATE SomeTable
   SET p_key = CASE WHEN p_key = 'a'
                    THEN 'b'
                    WHEN p_key = 'b'
                    THEN 'a'
                    ELSE p_key END
 WHERE p_key IN ('a', 'b');

/*6 表之间的数据匹配 */
CREATE TABLE CourseMaster
(course_id   INTEGER PRIMARY KEY,
 course_name VARCHAR(32) NOT NULL);

INSERT INTO CourseMaster VALUES(1, '会计入门');
INSERT INTO CourseMaster VALUES(2, '财务知识');
INSERT INTO CourseMaster VALUES(3, '簿记考试');
INSERT INTO CourseMaster VALUES(4, '税务师');

CREATE TABLE OpenCourses
(month       INTEGER ,
 course_id   INTEGER ,
    PRIMARY KEY(month, course_id));

INSERT INTO OpenCourses VALUES(200706, 1);
INSERT INTO OpenCourses VALUES(200706, 3);
INSERT INTO OpenCourses VALUES(200706, 4);
INSERT INTO OpenCourses VALUES(200707, 4);
INSERT INTO OpenCourses VALUES(200708, 2);
INSERT INTO OpenCourses VALUES(200708, 4); 

/* 表的匹配：使用IN谓词 */
SELECT CM.course_name,
       CASE WHEN CM.course_id IN 
                    (SELECT course_id FROM OpenCourses 
                      WHERE month = 200706) THEN '○'
            ELSE '×' END AS "6月",
       CASE WHEN CM.course_id IN 
                    (SELECT course_id FROM OpenCourses
                      WHERE month = 200707) THEN '○'
            ELSE '×' END AS "7月",
       CASE WHEN CM.course_id IN 
                    (SELECT course_id FROM OpenCourses
                      WHERE month = 200708) THEN '○'
            ELSE '×' END  AS "8月"
  FROM CourseMaster CM;

/* 表的匹配：使用EXISTS谓词 */
SELECT CM.course_name,
       CASE WHEN EXISTS
                    (SELECT course_id FROM OpenCourses OC
                      WHERE month = 200706
                        AND CM.course_id = OC.course_id) THEN '○'
            ELSE '×' END AS "6月",
       CASE WHEN EXISTS
                    (SELECT course_id FROM OpenCourses OC
                      WHERE month = 200707
                        AND CM.course_id = OC.course_id) THEN '○'
            ELSE '×' END AS "7月",
       CASE WHEN EXISTS
                    (SELECT course_id FROM OpenCourses OC
                      WHERE month = 200708
                        AND CM.course_id = OC.course_id) THEN '○'
            ELSE '×' END  AS "8月"
  FROM CourseMaster CM;

/*7 在CASE表达式中使用聚合函数 */
CREATE TABLE StudentClub
(std_id  INTEGER,
 club_id INTEGER,
 club_name VARCHAR(32),
 main_club_flg CHAR(1),
 PRIMARY KEY (std_id, club_id));

INSERT INTO StudentClub VALUES(100, 1, '棒球',       'Y');
INSERT INTO StudentClub VALUES(100, 2, '管弦乐',     'N');
INSERT INTO StudentClub VALUES(200, 2, '管弦乐',     'N');
INSERT INTO StudentClub VALUES(200, 3, '羽毛球',		 'Y');
INSERT INTO StudentClub VALUES(200, 4, '足球',    	 'N');
INSERT INTO StudentClub VALUES(300, 4, '足球',    	 'N');
INSERT INTO StudentClub VALUES(400, 5, '游泳',       'N');
INSERT INTO StudentClub VALUES(500, 6, '围棋',       'N');
/*查询条件：
1.获取只加入了一个社团的学生的社团ID
2.获取加入了多个社团的学生的主社团ID
*/  
SELECT std_id,
       CASE WHEN COUNT(*) = 1 /* 只加入了一个社团的学生 */
            THEN MAX(club_id)
            ELSE MAX(CASE WHEN main_club_flg = 'Y'
                          THEN club_id
                          ELSE NULL END)
        END AS main_club
  FROM StudentClub
 GROUP BY std_id;

 /*练习题*/
 /* 练习题1-1-1：多列数据的最大值（练习题1-1-3也会用到） */
CREATE TABLE Greatests
(key CHAR(1) PRIMARY KEY,
 x   INTEGER NOT NULL,
 y   INTEGER NOT NULL,
 z   INTEGER NOT NULL);

INSERT INTO Greatests VALUES('A', 1, 2, 3);
INSERT INTO Greatests VALUES('B', 5, 5, 2);
INSERT INTO Greatests VALUES('C', 4, 7, 1);
INSERT INTO Greatests VALUES('D', 3, 3, 8);
/* 求x和y二者中较大的值 */
SELECT key,
       CASE WHEN x < y THEN y
            ELSE x END AS greatest
  FROM Greatests;
/* 求x、y和z中的最大值 */
SELECT key,
       CASE WHEN CASE WHEN x < y THEN y ELSE x END < z
            THEN z
            ELSE CASE WHEN x < y THEN y ELSE x END
        END AS greatest
  FROM Greatests;
/* 转换成行格式后使用MAX函数 */
SELECT key, MAX(col) AS greatest
  FROM (SELECT key, x AS col FROM Greatests
        UNION ALL
        SELECT key, y AS col FROM Greatests
        UNION ALL
        SELECT key, z AS col FROM Greatests) TMP
 GROUP BY key;
/* 仅适用于Oracle和MySQL */
SELECT key, GREATEST(GREATEST(x,y), z) AS greatest
  FROM Greatests;
/*练习题1-1-2： 转换行列——在表头里加入汇总和再揭(p.287) */
--使用PopTbl2表
SELECT sex,
       SUM(population) AS total,
       SUM(CASE WHEN pref_name = '德岛' THEN population ELSE 0 END) AS col_1,
       SUM(CASE WHEN pref_name = '香川' THEN population ELSE 0 END) AS col_2,
       SUM(CASE WHEN pref_name = '爱媛' THEN population ELSE 0 END) AS col_3,
       SUM(CASE WHEN pref_name = '高知' THEN population ELSE 0 END) AS col_4,
       SUM(CASE WHEN pref_name IN ('德岛', '香川', '爱媛', '高知')
                THEN population ELSE 0 END) AS zaijie
  FROM PopTbl2
 GROUP BY sex;
/*练习题1-1-3： 用ORDER BY生成“排序”列 */
SELECT key
  FROM Greatests
 ORDER BY CASE key
            WHEN 'B' THEN 1
            WHEN 'A' THEN 2
            WHEN 'D' THEN 3
            WHEN 'C' THEN 4
            ELSE NULL END;

/* 把“排序”列也包括在结果中(p.288) */
SELECT key,
       CASE key
         WHEN 'B' THEN 1
         WHEN 'A' THEN 2
         WHEN 'D' THEN 3
         WHEN 'C' THEN 4
         ELSE NULL END AS sort_col
  FROM Greatests
 ORDER BY sort_col;