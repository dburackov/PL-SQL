CREATE TABLE T1
(
    ID  NUMBER,
    num NUMBER,
    val VARCHAR(100),
    CONSTRAINT T1_PK PRIMARY KEY (ID)
);

CREATE TABLE T2
(
    ID  NUMBER,
    ID2 NUMBER,
    num NUMBER,
    val VARCHAR(100),
    CONSTRAINT T2_PK PRIMARY KEY (ID),
    CONSTRAINT T2_FK FOREIGN KEY (ID2) REFERENCES T1 (ID)
);

CREATE TABLE T3
(
    ID NUMBER,
    ID2 NUMBER,
    num NUMBER,
    val VARCHAR(100),
    CONSTRAINT T3_PK PRIMARY KEY (ID),
    CONSTRAINT T3_FK FOREIGN KEY (ID2) REFERENCES T2(ID)
);

SELECT *
FROM t2;

DECLARE
    INPUT_DATA VARCHAR2(3000) := '<Operation>
    <Type>SELECT</Type>
    <Tables>
        <Table>T1</Table>
        <Table>T2</Table>
        <Table>T3</Table>
    </Tables>
    <Joins>
        <Join>
            <Type>RIGHT JOIN</Type>
                <Condition>T2.ID2 = T1.ID</Condition>
        </Join>
        <Join>
            <Type>LEFT JOIN</Type>
                <Condition>T3.ID2 = T2.ID</Condition>
        </Join>
    </Joins>
    <Columns>
        <Column>*</Column>
    </Columns>
    <Where>
        <Conditions>
            <Condition>
                <Body>T1.ID IN</Body>
                <Operation>
                    <Type>SELECT</Type>
                    <Tables>
                        <Table>T2</Table>
                    </Tables>
                    <Columns>
                        <Column>ID</Column>
                    </Columns>
                    <Where>
                        <Conditions>
                            <Condition>
                                <Body>t2.val LIKE ''%a%''</Body>
                                <Operator>AND</Operator>
                            </Condition>
                            <Condition>
                                <Body>T2.num BETWEEN 2 AND 4</Body>
                            </Condition>
                        </Conditions>
                    </Where>
                </Operation>
            </Condition>
        </Conditions>
    </Where>
</Operation>';
BEGIN
    PARSE(INPUT_DATA);
END;