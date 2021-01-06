/** ���ɷ������ڹ�ϵ�ı��Ĵ洢���� */
if exists (select * from sysobjects where type = 'P' and name = 'saveConnectInfo')
    drop procedure dbo.saveConnectInfo;
go
CREATE PROCEDURE saveConnectInfo
AS
DECLARE @a int;
DECLARE @b int;
BEGIN
	SET @a = 100;
	SET @b = 1;
	WHILE( @a BETWEEN 100 AND 300)
	BEGIN
		WHILE( @b BETWEEN 1 AND 10)
		BEGIN
			IF(@b = 1)
			BEGIN
				INSERT INTO ROOM_CONNECT VALUES(@a+@b,@a+@b+1),(@a+@b,@a+@b+5),(@a+@b,@a+@b+6);
			END
			IF(@b = 5)
			BEGIN
				INSERT INTO ROOM_CONNECT VALUES(@a+@b,@a+@b-1),(@a+@b,@a+@b+4),(@a+@b,@a+@b+5);
			END
			IF(@b = 6)
			BEGIN
				INSERT INTO ROOM_CONNECT VALUES(@a+@b,@a+@b-5),(@a+@b,@a+@b-4),(@a+@b,@a+@b+1);
			END
			IF(@b = 10)
			BEGIN
				INSERT INTO ROOM_CONNECT VALUES(@a+@b,@a+@b-6),(@a+@b,@a+@b-5),(@a+@b,@a+@b-1);
			END
			IF(@b = 2 or @b = 3 or @b = 4 or @b = 4)
			BEGIN
				INSERT INTO ROOM_CONNECT VALUES(@a+@b,@a+@b-1),(@a+@b,@a+@b+1),(@a+@b,@a+@b+4),(@a+@b,@a+@b+5),(@a+@b,@a+@b+6);
			END
			IF(@b = 6 or @b = 7 or @b = 8 or @b = 9)
			BEGIN
				INSERT INTO ROOM_CONNECT VALUES(@a+@b,@a+@b-6),(@a+@b,@a+@b-5),(@a+@b,@a+@b-4),(@a+@b,@a+@b-1),(@a+@b,@a+@b+1);
			END
			SET @b = @b + 1;
		END
		SET @b = 1;
		SET @a = @a + 100;
	END
END
