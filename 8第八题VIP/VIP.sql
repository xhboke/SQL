IF (OBJECT_ID('T_VIP', 'tr') IS NOT  NULL)
    DROP TRIGGER T_VIP
GO
/** VIP��¼ */
CREATE TRIGGER T_VIP ON CHECKOUT
	FOR INSERT
AS
	DECLARE @CHECKIN_ID INT;
	DECLARE @TABLE table(_name varchar(100),_number INT,_price MONEY);
	DECLARE @XIAOFEI MONEY;
	DECLARE @DAY INT;

	DECLARE @NAME VARCHAR(20);
	DECLARE @ID INT;
	DECLARE @IDCARD VARCHAR(18);

	SET @CHECKIN_ID = (SELECT CHECKIN_ID FROM INSERTED);
	INSERT INTO @TABLE EXEC P_CHECKOUT @CHECKIN_ID;
	SET @XIAOFEI = (SELECT MAX(_price) FROM @TABLE);
	SET @DAY = (SELECT _number FROM @TABLE WHERE _name = '[��ס����]');
	SET @NAME = (SELECT NAME_CONSUMER FROM CHECKIN WHERE CHECKIN_ID = @CHECKIN_ID);
	SET @IDCARD = (SELECT CONTACT_CONSUMER FROM CHECKIN WHERE CHECKIN_ID = @CHECKIN_ID);
	SET @ID = (SELECT MAX(_ID) FROM VIP);

	IF @ID IS NOT NULL
	BEGIN
		SET @ID = @ID + 1;
	END
	ELSE
	BEGIN
		SET @ID = 1;
	END

	IF(@DAY > 3 OR @XIAOFEI > 1000 )
	BEGIN
		INSERT INTO VIP VALUES(@ID,@NAME,GETDATE(),@IDCARD,@XIAOFEI);
		SELECT * FROM VIP;
	END