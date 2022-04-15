CREATE TABLE MovieCompany
(
    MCName nvarchar(10) Primary Key,
    MCCountry nvarchar(10) Not Null
)

CREATE TABLE Actor
(
    AID char(10) Primary Key,
    AName nvarchar(10) Not Null,
    ABirth date Not Null,
    AGender char(1) Not Null CONSTRAINT AGender_constraint CHECK(in('F','M'))
)