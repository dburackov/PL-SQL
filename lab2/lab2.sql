-- Task 1 ____________________________________________

CREATE TABLE STUDENTS
(
    ID       NUMBER PRIMARY KEY,
    NAME     VARCHAR2(50) NOT NULL,
    GROUP_ID NUMBER       NOT NULL
);

CREATE TABLE GROUPS
(
    ID    NUMBER PRIMARY KEY,
    NAME  VARCHAR2(50) NOT NULL,
    C_VAL NUMBER       NOT NULL
);

-- Task 2 ____________________________________________

CREATE OR REPLACE TRIGGER tr_unique_student_id
    FOR INSERT OR UPDATE OF ID
    ON STUDENTS
    COMPOUND TRIGGER
    id_list SYS_REFCURSOR;
    id_curr STUDENTS.ID%TYPE;
    unique_id BOOLEAN;

BEFORE STATEMENT IS
BEGIN

    OPEN id_list FOR
        SELECT ID FROM STUDENTS;

END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN

        unique_id := true;

        LOOP
            FETCH id_list INTO id_curr;
            EXIT WHEN id_list%NOTFOUND;

            IF id_curr = :NEW.ID THEN
                unique_id := false;
            END IF;
        END LOOP;

        CLOSE id_list;

        IF NOT unique_id THEN
            RAISE_APPLICATION_ERROR(-20999, 'NOT UNIQUE STUDENT ID');
        end if;

    END BEFORE EACH ROW;
    END tr_unique_student_id;


CREATE OR REPLACE TRIGGER tr_unique_group_id
    FOR INSERT OR UPDATE OF ID
    ON GROUPS
    COMPOUND TRIGGER
    id_list SYS_REFCURSOR;
    id_curr GROUPS.ID%TYPE;
    unique_id BOOLEAN;

BEFORE STATEMENT IS
BEGIN

    OPEN id_list FOR
        SELECT ID FROM GROUPS;

END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN

        unique_id := true;

        LOOP
            FETCH id_list INTO id_curr;
            EXIT WHEN id_list%NOTFOUND;

            IF id_curr = :NEW.ID THEN
                unique_id := false;
            END IF;
        END LOOP;

        CLOSE id_list;

        IF NOT unique_id THEN
            RAISE_APPLICATION_ERROR(-20999, 'NOT UNIQUE GROUP ID');
        end if;

    END BEFORE EACH ROW;
    END tr_unique_group_id;


CREATE OR REPLACE TRIGGER tr_unique_group_name
    FOR INSERT OR UPDATE OF NAME
    ON GROUPS
    COMPOUND TRIGGER
    name_list SYS_REFCURSOR;
    name_curr GROUPS.NAME%TYPE;
    unique_name BOOLEAN;

BEFORE STATEMENT IS
BEGIN

    OPEN name_list FOR
        SELECT NAME FROM GROUPS;

END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN

        unique_name := true;

        LOOP
            FETCH name_list INTO name_curr;
            EXIT WHEN name_list%NOTFOUND;

            IF name_curr = :NEW.NAME THEN
                unique_name := false;
            END IF;
        END LOOP;

        CLOSE name_list;

        IF NOT unique_name THEN
            RAISE_APPLICATION_ERROR(-20999, 'NOT UNIQUE GROUP NAME');
        end if;

    END BEFORE EACH ROW;
    END tr_unique_group_name;


CREATE SEQUENCE student_id_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    CACHE 20;

CREATE OR REPLACE TRIGGER tr_generate_student_id
    BEFORE INSERT
    ON STUDENTS
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := student_id_seq.nextval;
    END IF;
END;

CREATE SEQUENCE group_id_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    CACHE 20;

CREATE OR REPLACE TRIGGER tr_generate_group_id
    BEFORE INSERT
    ON GROUPS
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := group_id_seq.nextval;
    END IF;
END;


-- Task 3 ____________________________________________

CREATE OR REPLACE TRIGGER tr_group_delete_cascade
    AFTER DELETE
    ON GROUPS
    FOR EACH ROW
BEGIN
    EXECUTE IMMEDIATE 'ALTER TRIGGER TR_C_VAL_UPDATE DISABLE';

    DELETE
    FROM STUDENTS
    WHERE STUDENTS.GROUP_ID = :OLD.ID;

    EXECUTE IMMEDIATE 'ALTER TRIGGER TR_C_VAL_UPDATE ENABLE';
END;


-- Task 4 ____________________________________________

DROP TABLE STUDENTS_LOGS;

CREATE TABLE STUDENTS_LOGS
(
    ID NUMBER PRIMARY KEY,
    TIME TIMESTAMP NOT NULL,
    OPERATION_TYPE VARCHAR2(10) NOT NULL,
    OLD_ID NUMBER DEFAULT NULL,
    OLD_NAME VARCHAR2(50) DEFAULT NULL,
    OLD_GROUP_ID NUMBER DEFAULT NULL,
    NEW_ID NUMBER DEFAULT NULL,
    NEW_NAME VARCHAR2(50) DEFAULT NULL,
    NEW_GROUP_ID NUMBER DEFAULT NULL
);

CREATE SEQUENCE students_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    CACHE 20;

CREATE OR REPLACE TRIGGER tr_generate_students_logs_id
    BEFORE INSERT
    ON STUDENTS_LOGS
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := students_logs_id_seq.nextval;
    END IF;
END;

CREATE OR REPLACE TRIGGER tr_student_log
    AFTER INSERT OR UPDATE OR DELETE
    ON STUDENTS
    FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE(CURRENT_TIMESTAMP);
    CASE
        WHEN INSERTING THEN BEGIN
            INSERT INTO STUDENTS_LOGS
            (TIME, OPERATION_TYPE, NEW_ID, NEW_NAME, NEW_GROUP_ID)
            VALUES (CURRENT_TIMESTAMP, 'UPDATE', :NEW.ID, :NEW.NAME, :NEW.GROUP_ID);
        END;

        WHEN UPDATING THEN BEGIN
            INSERT INTO STUDENTS_LOGS
            (TIME, OPERATION_TYPE, OLD_ID, OLD_NAME, OLD_GROUP_ID, NEW_ID, NEW_NAME, NEW_GROUP_ID)
            VALUES (CURRENT_TIMESTAMP, 'UPDATE', :OLD.ID, :OLD.NAME, :OLD.GROUP_ID, :NEW.ID, :NEW.NAME, :NEW.GROUP_ID);
        END;

        WHEN DELETING THEN BEGIN
            INSERT INTO STUDENTS_LOGS
            (TIME, OPERATION_TYPE, OLD_ID, OLD_NAME, OLD_GROUP_ID)
            VALUES (CURRENT_TIMESTAMP, 'DELETE', :OLD.ID, :OLD.NAME, :OLD.GROUP_ID);
        END;
    END CASE;
END;


-- Task 5 ________________________________________________________________

CREATE OR REPLACE PROCEDURE roll_back(time TIMESTAMP)
    IS
    CURSOR c_logs IS
        SELECT * FROM STUDENTS_LOGS ORDER BY TIME DESC;
BEGIN
    FOR curr IN c_logs
        LOOP
            IF curr.TIME > time THEN
                IF curr.OPERATION_TYPE = 'INSERT' THEN
                    DELETE
                    FROM STUDENTS
                    WHERE ID = curr.NEW_ID;
                ELSIF curr.OPERATION_TYPE = 'UPDATE' THEN
                    UPDATE STUDENTS
                    SET ID = curr.OLD_ID,
                        NAME = curr.OLD_NAME,
                        GROUP_ID = curr.OLD_GROUP_ID
                    WHERE ID = curr.NEW_ID;
                ELSIF curr.OPERATION_TYPE = 'DELETE' THEN
                    INSERT INTO STUDENTS
                    VALUES (curr.OLD_ID, curr.OLD_NAME, curr.OLD_GROUP_ID);
                ELSE
                    RAISE_APPLICATION_ERROR(-20999, 'WRONG OPERATION');
                END IF;
            ELSE
                EXIT;
            END IF;
        END LOOP;
END;


-- Task 6 _______________________________________________________________

CREATE OR REPLACE TRIGGER tr_c_val_update
    AFTER INSERT OR UPDATE OF GROUP_ID OR DELETE
    ON STUDENTS
    FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    CASE
        WHEN INSERTING THEN BEGIN
            UPDATE GROUPS
            SET C_VAL = C_VAL + 1
            WHERE ID = :NEW.GROUP_ID;
        END;

        WHEN UPDATING ('GROUP_ID') THEN BEGIN
            UPDATE GROUPS
            SET C_VAL = C_VAL - 1
            WHERE ID = :OLD.GROUP_ID;

            UPDATE GROUPS
            SET C_VAL = C_VAL + 1
            WHERE ID = :NEW.GROUP_ID;
        END;

        WHEN DELETING THEN BEGIN
            UPDATE GROUPS
            SET C_VAL = C_VAL - 1
            WHERE ID = :OLD.GROUP_ID;
        END;
    END CASE;

    IF UPDATING ('GROUP_ID') OR DELETING THEN
        SELECT C_VAL
        INTO cnt
        FROM GROUPS
        WHERE ID = :OLD.GROUP_ID;

        IF cnt = 0 THEN
            DELETE
            FROM GROUPS
            WHERE ID = :OLD.GROUP_ID;
        END IF;
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('GROUP DOES NOT EXISTS');
END;