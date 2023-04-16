CREATE OR REPLACE PROCEDURE PROD_FUNCTION_CREATE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    AUTHID CURRENT_USER
    IS
    counter NUMBER(10);
BEGIN
    FOR res IN (SELECT DISTINCT object_name
                FROM all_objects
                WHERE object_type = 'FUNCTION'
                  AND Owner = dev_schema_name
                  AND object_name NOT IN
                      (SELECT object_name FROM all_objects WHERE Owner = prod_schema_name AND object_type = 'FUNCTION'))
        LOOP
            counter := 0;
            DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE ');
            FOR res2 IN (SELECT text
                         FROM all_source
                         WHERE type = 'FUNCTION'
                           AND name = res.object_name
                           AND Owner = dev_schema_name)
                LOOP
                    IF counter != 0 THEN
                        DBMS_OUTPUT.PUT_LINE(RTRIM(res2.text, CHR(10) || CHR(13)));
                    ELSE
                        DBMS_OUTPUT.PUT_LINE(RTRIM('FUNCTION ' || prod_schema_name || '.' || SUBSTR(res2.text, 14),
                                CHR(10) || CHR(13)));
                        counter := 1;
                    END IF;
                END LOOP;
        END LOOP;
END;
