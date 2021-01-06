
/** 2、视图：位于3楼且空闲相邻且空闲的标准间所容纳人数总和大于11的标准间 */
IF EXISTS (select table_name from information_schema.views where table_name = 'V1' )
		DROP VIEW V1;
GO
CREATE VIEW V1
AS
SELECT M.ROOM_ID,SUM(A.ROOM_MAX) * 2 - COUNT(A.ROOM_MAX) * SUM(A.ROOM_MAX) / COUNT(A.ROOM_MAX) '最大人数' FROM ROOM_INFO M
	LEFT JOIN ROOM_TYPE A ON A.ROOM_TYPE_ID = M.ROOM_TYPE_ID
	LEFT JOIN ROOM_CONNECT ON ROOM_CONNECT.ROOM_CONNECT_ID_LEFT = M.ROOM_ID
	LEFT JOIN ROOM_INFO N ON N.ROOM_ID = ROOM_CONNECT.ROOM_CONNECT_ID_RIGHT
	LEFT JOIN ROOM_TYPE B ON B.ROOM_TYPE_ID = N.ROOM_TYPE_ID
	/* 3楼、空闲、标准间、相邻*/
WHERE
	M.ROOM_STATUS_ID = 1 AND N.ROOM_STATUS_ID = 1 AND /** 相邻的房间均为空闲 */
	LEFT(M.ROOM_LOCATION,1) = 3 AND  /** 默认同一楼层相邻的房间还是在同一楼层 */
	A.ROOM_TYPE_ID = 3 AND B.ROOM_TYPE_ID = 3 /** 相邻的两个房间均为标准间（3） */
GROUP BY M.ROOM_ID HAVING SUM(A.ROOM_MAX) * 2 - COUNT(A.ROOM_MAX) * SUM(A.ROOM_MAX) / COUNT(A.ROOM_MAX) >= 11; 
/** 计算该房间与所有相邻的房间人数所容纳最大人数的总和 公式：每一对房间的总和 减去 单个房间 乘以 对数 减一 */; 