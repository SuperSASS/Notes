/* P85 - DML */
INSERT INTO S VALUES('20150101', 'WH', '男', 21)

UPDATE C SET CRedit = 2
    WHERE CName = 'SJK'

UPDATE SC SET Score = 1.1*Score
    FROM S, SC
    WHERE S.SID = SC.SID AND SName = 'ZL'

DELETE SC
    FROM C, SC
    WHERE C.CID = SC.CID AND CName = 'GDDS'

/* P83 - DML */
UPDATE sc SET score = score*1.1
    FROM teacher, course, sc
    WHERE tearcher.tno = course.tno AND course.cno = sc.cno AND tname = 'LY'

DELETE SC
    WHERE sno = 20108001122

DELETE SC
    FROM sc,course,teacher
    WHERE sc.cno=course.cno AND course.tno=teacher.tno AND Tname='吕燕'​

/* P107 - GROUP BY */
SELECT S.Sid, Sname, avg(Score), count(Cid) FROM S NATURAL JOIN SC GROUP BY Students.Sid, Sname​

/* P112 - Practice */
SELECT student.sno, sname, count(cno), sum(score)
    FROM student LEFT JOIN sc /* 注意没选课的同学也要统计，因此左连接 */
    WHERE student.sno = sc.sno
    GROUP BY student.sno, sname

SELECT count(*)
    FROM teacher
    WHERE tname LIKE '刘%'

SELECT sno, sname
    FROM s LEFT JOIN sc
    GROUP BY sno, sname
    HAVING count(cno) < (SELECT count(cno) FROM c)
    
SELECT cno, max(socre), min(socre)
    FROM sc
    GROUP BY cno

SELECT c.cno, count(s.sno), sum(CASE WHEN score>60 THEN 1.0 else 0.0 END)/count(s.sno)
    FROM c LEFT JOIN sc /* 可能存在没有学生选的课 */
    WHERE c.cno = sc.cno
    GROUP BY c.cno

/* 有误
SELECT s.sno, avg(score)
    FROM s NATURAL JOIN sc
    WHERE count(CASE WHEN score<60 THEN 1 ELSE 0 END) > 2
    GROUP BY s.sno
*/
