IF EXISTS (select * from sysobjects where type = 'P' and name = 'P_CHECKOUT')
    DROP PROCEDURE P_CHECKOUT;
GO
CREATE PROCEDURE P_CHECKOUT @CHECKIN_ID INT
AS
BEGIN
	DECLARE @True_Day INT;	
	DECLARE @Start DATE;
	DECLARE @Last DATE;
SET @Start = (SELECT CHECKIN_START_TIME FROM CHECKIN WHERE CHECKIN_ID = @CHECKIN_ID);
SET @Last = GETDATE();
SET @True_Day = DATEDIFF(day,@Start,@Last);
CREATE TABLE #Temp
(
	PRICE_NAME VARCHAR(50),
	NUMBER INT,
	PRICE MONEY 
)
IF @CHECKIN_ID IN (SELECT CHECKIN_ID FROM CHANGE_ROOM)
BEGIN

	/** �����һ�λ���ǰ�ļ۸� */
	DECLARE @FIRST_BEFORE_ROOM_ID INT;
	DECLARE @FIRST_AFTER_ROOM_ID INT;
	DECLARE @FIRST_START_TIME DATE;
	DECLARE @FIRST_AFTER_TIME DATE;
	DECLARE @FIRST_PRICE MONEY;
	DECLARE @FIRST_DAY INT;
	SET @FIRST_BEFORE_ROOM_ID = (SELECT BEFORE_ROOM_ID FROM CHANGE_ROOM WHERE CHANGE_ID = (SELECT MIN(CHANGE_ID) FROM CHANGE_ROOM));
	SET @FIRST_AFTER_ROOM_ID = (SELECT AFTER_ROOM_ID FROM CHANGE_ROOM WHERE CHANGE_ID = (SELECT MIN(CHANGE_ID) FROM CHANGE_ROOM));
	SET @FIRST_START_TIME = (SELECT CHECKIN_START_TIME FROM CHECKIN WHERE CHECKIN_ID = @CHECKIN_ID);
	SET @FIRST_AFTER_TIME = (SELECT CHANGE_TIME FROM CHANGE_ROOM WHERE CHANGE_ID = (SELECT MIN(CHANGE_ID) FROM CHANGE_ROOM));

	SET @FIRST_PRICE = (SELECT ROOM_PRICE FROM ROOM_INFO 
		LEFT JOIN ROOM_TYPE ON ROOM_INFO.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
	WHERE ROOM_ID = @FIRST_BEFORE_ROOM_ID);

	SET @FIRST_DAY = DATEDIFF(DD,@FIRST_START_TIME,@FIRST_AFTER_TIME);

	INSERT INTO #Temp VALUES (CONCAT('[',@FIRST_BEFORE_ROOM_ID,']',@FIRST_START_TIME,'->',@FIRST_AFTER_TIME,'[',@FIRST_AFTER_ROOM_ID,']'),@FIRST_DAY,@FIRST_PRICE);

	/** ���㻻���ڼ����� */
	SELECT * INTO #TT
	FROM
	(
		SELECT A.CHANGE_ID,A.AFTER_ROOM_ID,B.ROOM_ID,A.CHANGE_TIME,A.ROOM_PRICE,B.CHANGE_TIME AS 'AFTER_TIME' FROM
		(
		SELECT CHANGE_ID,AFTER_ROOM_ID,CHANGE_TIME,ROOM_PRICE FROM CHANGE_ROOM
			LEFT JOIN ROOM_INFO ON CHANGE_ROOM.AFTER_ROOM_ID = ROOM_INFO.ROOM_ID
			LEFT JOIN ROOM_TYPE ON ROOM_INFO.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
		)A
		LEFT JOIN 
		(
		SELECT CHANGE_ID,ROOM_ID,CHANGE_TIME FROM CHANGE_ROOM
			LEFT JOIN ROOM_INFO ON CHANGE_ROOM.AFTER_ROOM_ID = ROOM_INFO.ROOM_ID
			LEFT JOIN ROOM_TYPE ON ROOM_INFO.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
		)B
		ON A.CHANGE_ID = B.CHANGE_ID - 1
		WHERE B.CHANGE_ID IS NOT NULL
	) AS aaa;


	SELECT * INTO #TTT
	FROM	
	(
		SELECT ROW_NUMBER() OVER (ORDER BY #TT.CHANGE_ID ASC) AS XUHAO,#TT.* FROM #TT
	) AS BBB;
	

	/** ��������ÿһ�� */
	DECLARE @i INT;
	DECLARE @max INT;
	SET @i = 1;
	SET @max = (SELECT COUNT(*) FROM #TTT);


	WHILE @i <= @max
	BEGIN
	
		DECLARE @BEFORE_ROOM_ID INT;
		DECLARE @AFTER_ROOM_ID INT;
		DECLARE @BEFORE_TIME DATE;
		DECLARE @AFTER_TIME DATE;
		DECLARE @PRICE MONEY;
		DECLARE @DAY INT;



		SET @BEFORE_ROOM_ID = (SELECT AFTER_ROOM_ID FROM #TTT WHERE CHANGE_ID = @i);
		SET @AFTER_ROOM_ID = (SELECT ROOM_ID FROM #TTT WHERE CHANGE_ID = @i);
		SET @BEFORE_TIME = (SELECT CHANGE_TIME FROM #TTT WHERE CHANGE_ID = @i);
		SET @AFTER_TIME = (SELECT AFTER_TIME FROM #TTT WHERE CHANGE_ID = @i);
		SET @PRICE = (SELECT ROOM_PRICE FROM #TTT WHERE CHANGE_ID = @i);
		SET @DAY = DATEDIFF(DD,@BEFORE_TIME,@AFTER_TIME);

		INSERT INTO #Temp VALUES (CONCAT('[',@BEFORE_ROOM_ID,']',@BEFORE_TIME,'->',@AFTER_TIME,'[',@AFTER_ROOM_ID,']'),@DAY,@PRICE);

		SET @i = @i + 1;
	END


	/** ���һ�λ��귿���᷿ */
	DECLARE @LAST_ROOM_ID INT;
	DECLARE @LAST_START_TIME DATE;
	DECLARE @LAST_ROOM_PRICE MONEY;
	DECLARE @LAST_END_TIME DATE;
	DECLARE @LAST_DAY INT;

	SET @LAST_ROOM_ID = (SELECT ROOM_ID FROM #TT WHERE CHANGE_ID = (SELECT MAX(CHANGE_ID) FROM #TT));
	SET @LAST_START_TIME = (SELECT AFTER_TIME FROM #TT WHERE CHANGE_ID = (SELECT MAX(CHANGE_ID) FROM #TT));
	SET @LAST_ROOM_PRICE = (
		SELECT ROOM_PRICE FROM ROOM_INFO
			LEFT JOIN ROOM_TYPE ON ROOM_INFO.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
		WHERE ROOM_ID = @LAST_ROOM_ID
	);
	SET @LAST_END_TIME = GETDATE();
	SET @LAST_DAY = DATEDIFF(DD,@LAST_START_TIME,@LAST_END_TIME);

	INSERT INTO #Temp VALUES (CONCAT('[',@LAST_ROOM_ID,']',@LAST_START_TIME,'->',@LAST_END_TIME),@LAST_DAY,@LAST_ROOM_PRICE);

END
ELSE
BEGIN
/** û�л��� */

DECLARE @B_ROOM_ID INT;

DECLARE @B_TIME DATE;
DECLARE @N_TIME DATE;

DECLARE @N_PRICE MONEY;
DECLARE @N_DAY INT;

SET @B_ROOM_ID = (SELECT ROOM_ID FROM CHECKIN WHERE CHECKIN_ID = @CHECKIN_ID);

SET @B_TIME = (SELECT CHECKIN_START_TIME FROM CHECKIN WHERE CHECKIN_ID = @CHECKIN_ID);
SET @N_TIME = GETDATE();

SET @N_PRICE = (
SELECT ROOM_PRICE FROM CHECKIN 
	LEFT JOIN ROOM_INFO ON CHECKIN.ROOM_ID = ROOM_INFO.ROOM_ID
	LEFT JOIN ROOM_TYPE ON ROOM_INFO.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
WHERE CHECKIN_ID = @CHECKIN_ID
)

SET @DAY = DATEDIFF(DD,@B_TIME,@N_TIME);

INSERT INTO #Temp VALUES (CONCAT('[',@B_ROOM_ID,']',@B_TIME,'->',@N_TIME),@DAY,@N_PRICE);
END

/** ���Ӳ�Ʒ */
DECLARE @M INT;
DECLARE @P_MAX INT;
SET @M = 1;
SET @P_MAX = (SELECT COUNT(*) FROM BOOKKEEPING WHERE CHECKIN_ID = @CHECKIN_ID);

SELECT * INTO #TA
FROM	
(
	SELECT ROW_NUMBER() OVER (ORDER BY BOOKKEEPING.BOOKKEEPING_ID ASC) AS XUHAO,BOOKKEEPING.* FROM BOOKKEEPING
) AS BBB;

WHILE @M <= @P_MAX
BEGIN
	DECLARE @PRODUCE_ID INT;
	DECLARE @PRODUCE_NAME VARCHAR(20);
	DECLARE @PRODUCE_NUMBER INT;
	DECLARE @PRODUCE_PRICE MONEY;

	SET @PRODUCE_ID = (	SELECT #TA.PRODUCT_ID FROM #TA LEFT JOIN PRODUCT ON #TA.PRODUCT_ID = PRODUCT.PRODUCT_ID WHERE XUHAO = @M);
	SET @PRODUCE_NAME = (	SELECT PRODUCT_NAME FROM #TA LEFT JOIN PRODUCT ON #TA.PRODUCT_ID = PRODUCT.PRODUCT_ID WHERE XUHAO = @M);
	SET @PRODUCE_NUMBER = (	SELECT NUMBER FROM #TA LEFT JOIN PRODUCT ON #TA.PRODUCT_ID = PRODUCT.PRODUCT_ID WHERE XUHAO = @M);
	SET @PRODUCE_PRICE = (	SELECT PRODUCT.PRODUCT_PRICE FROM #TA LEFT JOIN PRODUCT ON #TA.PRODUCT_ID = PRODUCT.PRODUCT_ID WHERE XUHAO = @M);

	INSERT INTO #Temp VALUES (CONCAT('[',@PRODUCE_ID,']',@PRODUCE_NAME),@PRODUCE_NUMBER,@PRODUCE_PRICE);
	SET @M = @M + 1;
END


/** ���������� */
DECLARE @_ALL MONEY;

SET @_ALL = (SELECT SUM(#Temp.NUMBER * #Temp.PRICE) FROM #Temp);
INSERT INTO #Temp VALUES ('[��ס����]',@True_Day,NULL);
INSERT INTO #Temp VALUES ('[������]',1,@_ALL);
SELECT * FROM #Temp;

/** ��¼���˷��� */
DECLARE @CHECKOUT_MAX_ID INT;
SET @CHECKOUT_MAX_ID = (SELECT MAX(CHECKOUT_ID) FROM CHECKOUT);
IF @CHECKOUT_MAX_ID IS NULL
BEGIN
	INSERT INTO CHECKOUT VALUES (1,@CHECKIN_ID,GETDATE());
END
ELSE
BEGIN
	INSERT INTO CHECKOUT VALUES (@CHECKOUT_MAX_ID + 1,@CHECKIN_ID,GETDATE());
END

/** ���µ�������Ϣ��״̬*/
UPDATE ROOM_INFO SET ROOM_STATUS_ID = 2 WHERE ROOM_ID = (SELECT ROOM_ID FROM CHECKIN WHERE CHECKIN_ID = @CHECKIN_ID);

END