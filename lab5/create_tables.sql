CREATE TABLE TABLE1
(
    ID         NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    TESTCOLUMN VARCHAR(20)
);

CREATE TABLE TABLE2
(
    ID         NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    TESTCOLUMN DATE
);

CREATE TABLE TABLE3
(
    ID         NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    TESTCOLUMN NUMBER,
    TABLE2_ID  NUMBER,
    CONSTRAINT TABLE3_TABLE2_FK FOREIGN KEY (TABLE2_ID) REFERENCES TABLE2 (ID) ON DELETE CASCADE
);

CREATE TABLE TABLE1_LOGGING_ACTIONS
(
    ID             NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    OPERATION      VARCHAR2(10) NOT NULL,
    DATE_EXEC      TIMESTAMP    NOT NULL,
    IS_REVERTED    NUMBER       NOT NULL,
    NEW_ID         NUMBER,
    NEW_TESTCOLUMN VARCHAR(20),
    OLD_ID         NUMBER,
    OLD_TESTCOLUMN VARCHAR(20)
);


CREATE TABLE TABLE2_LOGGING_ACTIONS
(
    ID             NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    OPERATION      VARCHAR2(10) NOT NULL,
    DATE_EXEC      TIMESTAMP    NOT NULL,
    IS_REVERTED    NUMBER       NOT NULL,
    NEW_ID         NUMBER,
    NEW_TESTCOLUMN DATE,
    OLD_ID         NUMBER,
    OLD_TESTCOLUMN DATE
);

CREATE TABLE TABLE3_LOGGING_ACTIONS
(
    ID             NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    OPERATION      VARCHAR2(10) NOT NULL,
    DATE_EXEC      TIMESTAMP    NOT NULL,
    IS_REVERTED    NUMBER       NOT NULL,
    NEW_ID         NUMBER,
    NEW_TESTCOLUMN NUMBER,
    NEW_FK_ID      NUMBER,
    OLD_ID         NUMBER,
    OLD_TESTCOLUMN NUMBER,
    OLD_FK_ID      NUMBER
);
