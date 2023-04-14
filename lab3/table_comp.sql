CREATE OR REPLACE PROCEDURE PROD_CREATE_LIST(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    IS
    counter NUMBER(10);
BEGIN
    FOR diff IN (Select DISTINCT table_name
                 from all_tab_columns
                 where owner = dev_schema_name
                   and (table_name, column_name) not in
                       (select table_name, column_name from all_tab_columns where owner = prod_schema_name))
        LOOP
            counter := 0;

            SELECT COUNT(*)
            INTO counter
            FROM all_tables
            where owner = prod_schema_name
              and table_name = diff.table_name;

            IF counter > 0 THEN
                FOR res2 IN (Select DISTINCT column_name, data_type
                             from all_tab_columns
                             where owner = dev_schema_name
                               and table_name = diff.table_name
                               and (table_name, column_name) not in
                                   (select table_name, column_name from all_tab_columns where owner = prod_schema_name))
                    LOOP
                        DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' || prod_schema_name || '.' || diff.table_name || ' ADD ' ||
                                             res2.column_name || ' ' || res2.data_type || ';');
                    END LOOP;
            ELSE
                DBMS_OUTPUT.PUT_LINE('CREATE TABLE ' || prod_schema_name || '.' || diff.table_name ||
                                     ' AS (SELECT * FROM ' || dev_schema_name || '.' || diff.table_name || ');');
            END IF;
        END LOOP;
END;


CREATE OR REPLACE PROCEDURE PROD_DELETE_LIST(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    IS
BEGIN
    FOR diff IN (Select DISTINCT table_name
                 from all_tab_columns
                 where owner = prod_schema_name
                   and (table_name, column_name) not in
                       (select table_name, column_name from all_tab_columns where owner = dev_schema_name))
        LOOP
            DBMS_OUTPUT.PUT_LINE(diff.TABLE_NAME);
        END LOOP;
END;


CALL PROD_CREATE_LIST('DEV', 'PROD');
CALL PROD_DELETE_LIST('DEV', 'PROD');
