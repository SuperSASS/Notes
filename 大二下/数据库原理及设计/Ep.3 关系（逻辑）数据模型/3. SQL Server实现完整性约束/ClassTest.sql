/* Test 1 */
CREATE TABLE Class
(
    ClassID smallint Primary Key,
    ClassName nvarchar(10) Not Null
)

CREATE TABLE Student
(
    StuID smallint Primary Key,
    StuName nvarchar(10) Not Null,
    StuGender bit Not Null,
    StuAge tinyint Not Null
    StuClassID smallint Foreign Key references Class(ClassID),
    StuPhone smallint
)

INSERT Class values(20200101, '计算机2020-01班')
INSERT Class values(20200102, '计算机2020-02班')
INSERT Class values(20200201, '信息2020-01班')

INSERT Student values(2020)

/* Test 2 */
CREATE TABLE Worker
(
    WID char(10) Primary Key,
    WName nvarchar(5) Not Null,
    WCID char(18) Unique,
    WAge as datepart(yyyy, GetDate()) - datepart(yyyy, convert(Date, SubString(WCID, 7, 8)))
)

INSERT Worker values('2020010001', '张三', '513723200112300051')

/* Test 3 */
CREATE TABLE Student
(
    SID char(10) Primary Key,
    SName nvarchar(10) Not Null,
    SGender char(1) Not Null,
    BirthDate date Not Null,
    Age as DatePart(YYYY, (GetDate() - BirthDate))
)

/* Test 4 */
CREATE TABLE Course
(
    CID char(10) Primary Key,
    CName nvarchar(20) Not Null,
    Credit tinyint Not Null
)

/* Test 5 */
CREATE TABLE Ctake
(
    SID char(10) Foreign Key references Stu(SID)
    CID char(10) Foreign Key references Class(CID),
    Grede tinyint CONSTRAINT Gread_constraint CHECK(Gread between 0 and 100)

    Primary Key(SID, CID)
)

/*未检查*/
CREATE Employee
(
    ENo char(10) Primary Key,
    EName varchar(10) Not Null,
    EntryDate date Not Null,
    EGender char(1) CONSTRAINT EGender_constraint CHECK(in('男', '女'))
    DNo char(10) Foreign Key references 
)

CREATE CLass