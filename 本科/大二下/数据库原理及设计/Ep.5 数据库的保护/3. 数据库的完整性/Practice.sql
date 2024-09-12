CREATE TRIGGER base_trigger
    ON salary
    FOR INSERT, UPDATE
    AS

    @my_fact = SELECT fact FROM inserted;
    @boss_fact = SELECT fact FROM salary, PERSON WHERE 

    