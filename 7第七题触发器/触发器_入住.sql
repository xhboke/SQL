IF (OBJECT_ID('T_CHECKIN', 'tr') IS NOT  NULL)
    DROP TRIGGER T_CHECKIN
GO
/** 入住表的触发器 */
CREATE TRIGGER T_CHECKIN ON CHECKIN
	FOR INSERT,UPDATE,DELETE
AS
	DECLARE @_A INT;
	DECLARE @_B INT;
	SET @_A = (SELECT COUNT(ROOM_STATUS_ID) FROM ROOM_INFO WHERE ROOM_ID IN (SELECT INSERTED.ROOM_ID FROM INSERTED));
	SET @_B = (SELECT COUNT(ROOM_STATUS_ID) FROM ROOM_INFO WHERE ROOM_ID IN (SELECT INSERTED.ROOM_ID FROM INSERTED) AND ROOM_STATUS_ID = 1);
	/** 判断入住的房间均为空闲 */
	IF @_A = @_B 
	BEGIN
		/** 对于更新新的设置为4(占用)，旧的设置为1(空闲) */
		/** 对于插入设置为4(占用) */
		UPDATE ROOM_INFO SET ROOM_STATUS_ID = 4 WHERE ROOM_ID IN (SELECT INSERTED.ROOM_ID  FROM INSERTED);
		/** 对于更新和删除设置为2(预留) */
		UPDATE ROOM_INFO SET ROOM_STATUS_ID = 2 WHERE ROOM_ID IN (SELECT DELETED.ROOM_ID  FROM DELETED);
	END
	ELSE
	BEGIN
		SELECT '插入失败！';
		ROLLBACK;
	END
