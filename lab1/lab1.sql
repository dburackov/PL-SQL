SET SERVEROUTPUT ON;
--Task 1
DROP TABLE MyTable;

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
            VALUES (i, DBMS_RANDOM.RANDOM());
        END LOOP;
END;


SELECT COUNT(*) FROM MyTable;
SELECT id, val FROM MyTable ORDER BY id FETCH FIRST 10 ROWS ONLY;


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

    DBMS_OUTPUT.PUT_LINE(even_cnt);
    DBMS_OUTPUT.PUT_LINE(odd_cnt);

    RETURN result;
END;


SELECT F2 FROM DUAL;


--Task 4
CREATE OR REPLACE FUNCTION get_insert_query(id_val NUMBER, val_val NUMBER := DBMS_RANDOM.RANDOM())
    RETURN VARCHAR2
    IS
    table_name CONSTANT CHAR(7) := 'MyTable';
    res NUMBER;
    cnt NUMBER;
    exc EXCEPTION;
BEGIN
    SELECT count(*) INTO cnt FROM MyTable WHERE id=id_val;

    IF cnt = 0 THEN
        RAISE exc;
    ELSE
        SELECT val INTO res FROM MyTable WHERE id=id_val;
        RETURN UTL_LMS.FORMAT_MESSAGE('INSERT INTO %s (id, val) VALUES (%d, %d)', table_name, TO_CHAR(id_val), TO_CHAR(res));
    END IF;

    RETURN UTL_LMS.FORMAT_MESSAGE('INSERT INTO %s (id, val) VALUES (%d, %d)', table_name, TO_CHAR(id_val), TO_CHAR(val_val));

    EXCEPTION
        WHEN exc THEN BEGIN
            DBMS_OUTPUT.PUT_LINE('AAAAAAAAAAAAAAAAAA');
            RETURN null;
        END;
END;

SELECT get_insert_query(1) FROM DUAL;
SELECT get_insert_query(11) FROM DUAL;

SELECT  * FROM MyTable;

--Task 5
CREATE OR REPLACE PROCEDURE insert_query(id NUMBER,
                                         val NUMBER := DBMS_RANDOM.RANDOM())
    IS
BEGIN
    EXECUTE IMMEDIATE get_insert_query(id, val);
END;


BEGIN
    insert_query(12, 12);
END;
SELECT * FROM MyTable WHERE id=12;


CREATE OR REPLACE PROCEDURE update_query(id NUMBER, val NUMBER := DBMS_RANDOM.RANDOM())
    IS
    table_name CONSTANT CHAR(7) := 'MyTable';
BEGIN
    EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('UPDATE %s SET val=%d WHERE id=%d', table_name, TO_CHAR(val), TO_CHAR(id));
END;


BEGIN
    update_query(12, 13);
END;
SELECT * FROM MyTable WHERE id=12;


CREATE OR REPLACE PROCEDURE delete_query(id NUMBER)
    IS
    table_name CONSTANT CHAR(7) := 'MyTable';
BEGIN
    EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('DELETE FROM %s WHERE id=%d', table_name, TO_CHAR(id));
END;


BEGIN
    delete_query(12);
END;
SELECT * FROM MyTable WHERE id=12;


--Task 6
CREATE OR REPLACE FUNCTION get_total_remuneration(salary NUMBER, annual_percentage_rate NUMBER)
RETURN NUMBER
IS
    incorrect_value EXCEPTION;
BEGIN
    IF annual_percentage_rate < 0 OR salary < 0 OR TRUNC(annual_percentage_rate) != annual_percentage_rate THEN
        RAISE incorrect_value;
    END IF;

    RETURN (1 + annual_percentage_rate / 100) * 12 * salary;

    EXCEPTION
        WHEN incorrect_value THEN
            RETURN NULL;
        WHEN INVALID_NUMBER THEN
            RETURN NULL;
        WHEN VALUE_ERROR THEN
            RETURN NULL;
END;


DECLARE
    result NUMBER;
BEGIN
    SELECT get_total_remuneration(123, 1234)
    INTO result
    FROM DUAL;

    DBMS_OUTPUT.PUT_LINE(result);

    EXCEPTION
        WHEN INVALID_NUMBER THEN
            DBMS_OUTPUT.PUT_LINE('WRONG INPUT!!!!!!!!');
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('WRONG INPUT!!!!!!!!');
END;


DELETE
FROM MyTable
WHERE id = id;