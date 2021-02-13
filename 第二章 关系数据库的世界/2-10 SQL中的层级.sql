/* 以组为单位进行聚合查询 */
SELECT team, AVG(age)
  FROM Teams
 GROUP BY team;
/* 以组为单位进行聚合查询？ */
SELECT team, AVG(age), age
  FROM Teams
 GROUP BY team;
/* 错误 */
SELECT team, AVG(age), member
  FROM Teams
 GROUP BY team;
/* 正确 */
SELECT team, MAX(age),
       (SELECT MAX(member)
          FROM Teams T2
         WHERE T2.team = T1.team
           AND T2.age = MAX(T1.age)) AS oldest
  FROM Teams T1
 GROUP BY team;