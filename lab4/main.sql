CREATE TYPE XML_RECORD AS TABLE OF VARCHAR2(1000);

CREATE OR REPLACE FUNCTION CONCAT_STRING(CONCAT_DATA IN XML_RECORD, SEPARATOR IN VARCHAR2) RETURN VARCHAR2
    IS
    STRING_RESULT VARCHAR2(10000) := '';
    I             INTEGER;
BEGIN
    I := CONCAT_DATA.FIRST;
    IF I IS NULL
    THEN
        RETURN STRING_RESULT;
    END IF;

    STRING_RESULT := CONCAT_DATA(I);
    I := CONCAT_DATA.NEXT(I);
    WHILE I IS NOT NULL
        LOOP
            STRING_RESULT := STRING_RESULT || SEPARATOR || CONCAT_DATA(I);
            I := CONCAT_DATA.NEXT(I);
        END LOOP;

    RETURN STRING_RESULT;
END;