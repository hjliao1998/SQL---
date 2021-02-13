/* 1.比较谓词和NULL（1）：排中律不成立 */
CREATE TABLE Students
(name VARCHAR(16) PRIMARY KEY,
 age  INTEGER );

INSERT INTO Students VALUES('布朗', 22);
INSERT INTO Students VALUES('拉里',   19);
INSERT INTO Students VALUES('约翰',   NULL);
INSERT INTO Students VALUES('伯杰', 21);
/* 查询年龄是20岁或者不是20岁的学生 */
SELECT *
  FROM Students
 WHERE age = 20
    OR age <> 20;--查询不到约翰

/* 添加第3个条件：年龄是20岁，或者不是20岁，或者年龄未知 */
SELECT *
  FROM Students
 WHERE age = 20
    OR age <> 20
    OR age IS NULL;--可以查询约翰

/*2 比较谓词和NULL(2):CASE表达式和NULL*/
--col_1为1时返回O、为NULL时返回x的CASE表达式？
CASE col_1
    WHEN '1' THEN 'o'
    WHEN NULL THEN 'x' --col_1=null的真值永远为unknown,所以永远不会返回'x'
END;
--改为下式，可以返回'x'
CASE WHEN col_1 = 1 THEN 'O'
    WHEN col_1 IS NULL THEN 'x'
  END;

/* 3.NOT IN和NOT EXISTS不是等价的 */
CREATE TABLE Class_A
(name VARCHAR(16) PRIMARY KEY,
 age  INTEGER,
 city VARCHAR(16) NOT NULL );

CREATE TABLE Class_B
(name VARCHAR(16) PRIMARY KEY,
 age  INTEGER,
 city VARCHAR(16) NOT NULL );

INSERT INTO Class_A VALUES('布朗', 22, '东京');
INSERT INTO Class_A VALUES('拉里',   19, '埼玉');
INSERT INTO Class_A VALUES('伯杰',   21, '千叶');

INSERT INTO Class_B VALUES('齐藤',  22,   '东京');
INSERT INTO Class_B VALUES('田尻',  23,   '东京');
INSERT INTO Class_B VALUES('山田',  NULL, '东京');
INSERT INTO Class_B VALUES('和泉',  18,   '千叶');
INSERT INTO Class_B VALUES('武田',  20,   '千叶');
INSERT INTO Class_B VALUES('石川',  19,   '神奈川');

/* 查询与B班住在东京的学生年龄不同的A班学生的SQL语句？ */
--结果是空，因为山田的年龄为NULL,，没有一行在where子句里被判断为true
SELECT *
  FROM Class_A
 WHERE age NOT IN ( SELECT age
                      FROM Class_B
                     WHERE city = '东京' );

/* 正确的SQL语句：拉里和伯杰将被查询到 */
SELECT *
  FROM Class_A A
 WHERE NOT EXISTS ( SELECT *
                      FROM Class_B B
                     WHERE A.age = B.age
                       AND B.city = '东京' );
/* 4.限定谓词和NULL */
--SQL里有ALL 和ANY两个限定谓词，因为ANY与IN是等价的，所以经常不使用ANY.
DELETE FROM Class_A;
INSERT INTO Class_A VALUES('布朗',   22, '东京');
INSERT INTO Class_A VALUES('拉里',   19, '埼玉');
INSERT INTO Class_A VALUES('伯杰',   21, '千叶');

DELETE FROM Class_B;
INSERT INTO Class_B VALUES('齐藤', 22, '东京');
INSERT INTO Class_B VALUES('田尻', 23, '东京');
INSERT INTO Class_B VALUES('山田', 20, '东京');
INSERT INTO Class_B VALUES('和泉', 18, '千叶');
INSERT INTO Class_B VALUES('武田', 20, '千叶');
INSERT INTO Class_B VALUES('石川', 19, '神奈川');

/* 查询比B班住在东京的所有学生年龄都小的A班学生 */
SELECT *
  FROM Class_A
 WHERE age < ALL ( SELECT age
                     FROM Class_B
                    WHERE city = '东京' );

/* 5.限定谓词和极值函数不是等价的 */
--即使存在某个学生的年龄为NULL也可以查询，因为极值函数在统计时会把为NULL的数据排除掉.
DELETE FROM Class_B;
INSERT INTO Class_B VALUES('和泉', 18, '千叶');
INSERT INTO Class_B VALUES('武田', 20, '千叶');
INSERT INTO Class_B VALUES('石川', 19, '神奈川');
/*查询比B班住在东京的最小的学生还要小的A班学生*/
SELECT * 
    FROM Class_A 
   WHERE age <(SELECT MIN(age) 
    FROM Class_B 
   WHERE city = '东京');
/*6 聚合函数和NULL*/
/* 查询比住在东京的学生的平均年龄还要小的A班学生的SQL语句？ */
SELECT *
  FROM Class_A
 WHERE age < ( SELECT AVG(age)
                 FROM Class_B
                WHERE city = '东京' );--当没有学生住在东京时，会出现age<unknown的情况，也就是查询不到。



