/* P27 */
ALTER TABLE Student
ADD Major varchar(20) NOT NULL

ALTER TABLE Student
ADD CONSTRAINT SName_Unique Unique(SName)

ALTER TABLE Student
ADD CONSTRAINT SGender_Check CHECK(SGender in ('F', 'M'))

/* P28 */

CREATE TABLE Salary
(
    EID char(10) Foreign key References Employee(EID),
    SMonth char(6) Not null,
    BSalary smallmoney,
    PSalary smallmoney,
    ESalary smallmoney,
    ASalary as BSalary + PSalary + ESalary,
    Primary key(EID, SMonth)
)

/* P43 */
CREATE VIEW M_Track2018_SV AS
    SELECT SID,
        SName,
        SGender,
        datepart(yyyy, GetDate() - datepart(yyyy, BirthDate)),
        Telephone
    FROM S
    WHERE Major = '轨道' AND EntryYear = 2018

/* P56 创建索引 */
CREATE CLUSTERED INDEX W_id_index
    ON writers(w_Id DESC)

CREATE INDEX Multildx
    ON writers(w_name, w_address)