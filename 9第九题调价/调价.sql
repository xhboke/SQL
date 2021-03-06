IF EXISTS (select * from sysobjects where type = 'P' and name = 'TiaoJia')
    DROP PROCEDURE TiaoJia;
GO
CREATE PROCEDURE TiaoJia
	@start_time date
AS
BEGIN
	DECLARE @end_time date;
	SET @end_time = DATEADD(DAY,60,@start_time);

	if OBJECT_ID('tempdb..#temp') is not null drop table #temp
	CREATE TABLE #Temp
	(
		ROOM_TYPE_ID INT,
		_RATE FLOAT
	);

INSERT INTO #Temp 

	SELECT S.ROOM_TYPE_ID,ROUND( CAST(SUM(��ס����) AS FLOAT)/60,3) 'RATE'  FROM
	(
		/** ��������ס */
		SELECT ROOM_TYPE.ROOM_TYPE_ID,SUM(DATEDIFF(DD,CHECKIN_START_TIME,CHANGE_TIME)) '��ס����' FROM CHECKIN 
			LEFT JOIN ROOM_INFO ON CHECKIN.ROOM_ID = ROOM_INFO.ROOM_ID
			LEFT JOIN ROOM_TYPE ON ROOM_INFO.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
			LEFT JOIN CHANGE_ROOM ON CHANGE_ROOM.CHECKIN_ID = CHECKIN.CHECKIN_ID
			WHERE 
		DATEADD(DAY,PLAN_TIME,CHECKIN_START_TIME) BETWEEN @start_time AND @end_time
		AND CHANGE_ID IS NOT NULL
		GROUP BY ROOM_TYPE.ROOM_TYPE_ID
	union all
		/** û�л�������ס */
		SELECT ROOM_TYPE.ROOM_TYPE_ID,SUM(PLAN_TIME) '��ס����' FROM CHECKIN 
			LEFT JOIN ROOM_INFO ON CHECKIN.ROOM_ID = ROOM_INFO.ROOM_ID
			LEFT JOIN ROOM_TYPE ON ROOM_INFO.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
			LEFT JOIN CHANGE_ROOM ON CHANGE_ROOM.CHECKIN_ID = CHECKIN.CHECKIN_ID
			WHERE 
		DATEADD(DAY,PLAN_TIME,CHECKIN_START_TIME) BETWEEN @start_time AND @end_time
		AND CHANGE_ID IS NULL
		GROUP BY ROOM_TYPE.ROOM_TYPE_ID
	)S GROUP BY S.ROOM_TYPE_ID;


	DECLARE @START INT;
	DECLARE @END INT;

		SELECT * FROM(
			SELECT row_number() OVER(ORDER BY #Temp.ROOM_TYPE_ID) as Xuhao,#TEMP.ROOM_TYPE_ID,_RATE from #Temp LEFT JOIN ROOM_TYPE ON #Temp.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
		)A 

	SET @START = (
		SELECT MIN(Xuhao) FROM(
		SELECT row_number() OVER(ORDER BY #Temp.ROOM_TYPE_ID) as Xuhao,#TEMP.ROOM_TYPE_ID,_RATE from #Temp LEFT JOIN ROOM_TYPE ON #Temp.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
		)A 
	)
	SET @END = (
		SELECT MAX(Xuhao) FROM(
		SELECT row_number() OVER(ORDER BY #Temp.ROOM_TYPE_ID) as Xuhao,#TEMP.ROOM_TYPE_ID,_RATE from #Temp LEFT JOIN ROOM_TYPE ON #Temp.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
		)A 
	)


	DECLARE @ROOM_TYPE_ID INT;
	DECLARE @ROOM_RATE FLOAT;
	DECLARE @ROOM_PRICE MONEY;

	WHILE @START <= @END 
	BEGIN
		SET @ROOM_TYPE_ID = (SELECT ROOM_TYPE_ID FROM(
			SELECT row_number() OVER(ORDER BY #Temp.ROOM_TYPE_ID) as Xuhao,#TEMP.ROOM_TYPE_ID,_RATE from #Temp LEFT JOIN ROOM_TYPE ON #Temp.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
		)A WHERE Xuhao = @START);
		SET @ROOM_RATE = (SELECT _RATE FROM(
			SELECT row_number() OVER(ORDER BY #Temp.ROOM_TYPE_ID) as Xuhao,#TEMP.ROOM_TYPE_ID,_RATE from #Temp LEFT JOIN ROOM_TYPE ON #Temp.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
		)A WHERE Xuhao = @START);
		SET @ROOM_PRICE = (SELECT ROOM_PRICE FROM(
			SELECT row_number() OVER(ORDER BY #Temp.ROOM_TYPE_ID) as Xuhao,#TEMP.ROOM_TYPE_ID,_RATE,ROOM_PRICE from #Temp LEFT JOIN ROOM_TYPE ON #Temp.ROOM_TYPE_ID = ROOM_TYPE.ROOM_TYPE_ID
		)A WHERE Xuhao = @START);
		IF( @ROOM_RATE > 0.9)
		BEGIN
			UPDATE ROOM_TYPE
			SET ROOM_PRICE = ROOM_PRICE * 1.2
			WHERE ROOM_TYPE_ID = @ROOM_TYPE_ID;
		END
		ELSE IF ( @ROOM_RATE <= 0.6)
		BEGIN
			IF @ROOM_PRICE * 0.8 < 100
			BEGIN
			SET @ROOM_PRICE = 125
			END
			UPDATE ROOM_TYPE
			SET ROOM_PRICE = ROOM_PRICE * 0.8
			WHERE ROOM_TYPE_ID = @ROOM_TYPE_ID;
		END

		SET @START = @START + 1;
	END
END