CREATE TABLE Teams
(member VARCHAR(32) PRIMARY KEY,
 team   CHAR(1)     NOT NULL,
 age    INTEGER     NOT NULL);

INSERT INTO Teams VALUES('大木',	'A',	28);
INSERT INTO Teams VALUES('逸见',	'A',	19);
INSERT INTO Teams VALUES('新藤',	'A',	23);
INSERT INTO Teams VALUES('山田',	'B',	40);
INSERT INTO Teams VALUES('久本',	'B',	29);
INSERT INTO Teams VALUES('桥田',	'C',	30);
INSERT INTO Teams VALUES('野野宫',      'D',	28);
INSERT INTO Teams VALUES('鬼塚',	'D',	28);
INSERT INTO Teams VALUES('加藤',	'D',	24);
INSERT INTO Teams VALUES('新城',	'D',	22);
/* 理解PARTITION BY */
SELECT member, team, age ,
       RANK() OVER(PARTITION BY team ORDER BY age DESC) rn,
       DENSE_RANK() OVER(PARTITION BY team ORDER BY age DESC) dense_rn,
       ROW_NUMBER() OVER(PARTITION BY team ORDER BY age DESC) row_num
  FROM Teams
 ORDER BY team, rn;
CREATE TABLE Natural
(num INTEGER  NOT NULL PRIMARY KEY);

INSERT INTO Natural VALUES(0);
INSERT INTO Natural VALUES(1);
INSERT INTO Natural VALUES(2);
INSERT INTO Natural VALUES(3);
INSERT INTO Natural VALUES(4);
INSERT INTO Natural VALUES(5);
INSERT INTO Natural VALUES(6);
INSERT INTO Natural VALUES(7);
INSERT INTO Natural VALUES(8);
INSERT INTO Natural VALUES(9);
INSERT INTO Natural VALUES(10);
/* 对从1到10的整数以3为模求剩余类 */
SELECT MOD(num, 3) AS modulo,
       num
  FROM Natural
 ORDER BY modulo, num;