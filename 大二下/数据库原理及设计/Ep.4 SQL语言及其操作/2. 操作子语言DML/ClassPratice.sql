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
