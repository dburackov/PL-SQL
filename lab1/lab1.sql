--Task 1
CREATE TABLE MyTable
(
    id  NUMBER,
    val NUMBER
);


--Task 2
DECLARE
    N CONSTANT NUMBER := 10;
BEGIN
    FOR i IN 1..N
        LOOP
            INSERT INTO MyTable
                (id, val)
            VALUES (i, DBMS_RANDOM.RANDOM());
        END LOOP;
END;


--Task 3
CREATE OR REPLACE FUNCTION F2
    RETURN VARCHAR2
    IS
    even_cnt NUMBER := 0;
    odd_cnt  NUMBER := 0;
    result   VARCHAR2(5);
BEGIN
    SELECT COUNT(*)
    INTO even_cnt
    FROM MyTable
    WHERE MOD(ABS(val), 2) = 0;

    SELECT COUNT(*)
    INTO odd_cnt
    FROM MyTable
    WHERE MOD(ABS(val), 2) = 1;

    IF even_cnt > odd_cnt THEN
        result := 'TRUE';
    ELSIF even_cnt < odd_cnt THEN
        result := 'FALSE';
    ELSE
        result := 'EQUAL';
    END IF;

    RETURN result;
END;

--Task 4
CREATE OR REPLACE FUNCTION get_insert_query(id NUMBER, val NUMBER := DBMS_RANDOM.RANDOM())
    RETURN VARCHAR2
    IS
    table_name CONSTANT CHAR(7) := 'MyTable';
BEGIN
    RETURN UTL_LMS.FORMAT_MESSAGE('INSERT INTO %s (id, val) VALUES (%d, %d);', table_name, TO_CHAR(id), TO_CHAR(val));
END;

--Task 5
CREATE OR REPLACE PROCEDURE insert_query(id NUMBER := DBMS_RANDOM.RANDOM(), val NUMBER := DBMS_RANDOM.RANDOM())
IS
BEGIN
    INSERT INTO MyTable
    VALUES
    (id, val);
END;


begin
    DBMS_OUTPUT.ENABLE(buffer_size => NULL);
end;

SELECT F2()
FROM DUAL;

SELECT get_insert_query(1123, 123)
FROM DUAL;
SELECT get_insert_query(112134)
FROM DUAL;

SELECT COUNT(*)
FROM MyTable;
SELECT *
FROM MyTable;

EXEC insert_query(11, 11);

DELETE
FROM MyTable
WHERE id = id;