/* GRANT */
GRANT ALL PRIVILIGES
    ON TABLE 学生, 班级
    TO U1
    WITH GRANT OPTION

GRANT SELECT, UPDATE(家庭住址)
    ON TABLE 学生
    TO U2

GRANT SELECT
    ON TABLE 班级
    TO PUBLIC

GRANT SELECT, UPDATE
    ON TABLE 学生
    TO R1

GRANT R1
    TO U1
    WITH GRANT OPTION

/* GRANT#6 */
CREATE VIEW V_Wedges
(
    最高工资,
    最低工资,
    平均工资
)
AS
    SELECT 部门名, max(工资), min(工资), avg(工资)
    FROM 职工
    GROUP BY 部门名

GRANT SELECT
    ON V_Wedges
    TO 杨兰