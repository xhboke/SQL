/** 2����ͼ��λ��3¥�ҿ��������ҿ��еı�׼�������������ܺʹ���11�ı�׼�� */
IF EXISTS (select table_name from information_schema.views where table_name = 'V1' )
		DROP VIEW V1;
GO
CREATE VIEW V1
AS
SELECT M.ROOM_ID,SUM(A.ROOM_MAX) * 2 - COUNT(A.ROOM_MAX) * SUM(A.ROOM_MAX) / COUNT(A.ROOM_MAX) '�������' FROM ROOM_INFO M
	LEFT JOIN ROOM_TYPE A ON A.ROOM_TYPE_ID = M.ROOM_TYPE_ID
	LEFT JOIN ROOM_CONNECT ON ROOM_CONNECT.ROOM_CONNECT_ID_LEFT = M.ROOM_ID
	LEFT JOIN ROOM_INFO N ON N.ROOM_ID = ROOM_CONNECT.ROOM_CONNECT_ID_RIGHT
	LEFT JOIN ROOM_TYPE B ON B.ROOM_TYPE_ID = N.ROOM_TYPE_ID
	/* 3¥�����С���׼�䡢����*/
WHERE
	M.ROOM_STATUS_ID = 1 AND N.ROOM_STATUS_ID = 1 AND /** ���ڵķ����Ϊ���� */
	LEFT(M.ROOM_LOCATION,1) = 3 AND  /** Ĭ��ͬһ¥�����ڵķ��仹����ͬһ¥�� */
	A.ROOM_TYPE_ID = 3 AND B.ROOM_TYPE_ID = 3 /** ���ڵ����������Ϊ��׼�䣨3�� */
GROUP BY M.ROOM_ID HAVING SUM(A.ROOM_MAX) * 2 - COUNT(A.ROOM_MAX) * SUM(A.ROOM_MAX) / COUNT(A.ROOM_MAX) >= 11; 
/** ����÷������������ڵķ�����������������������ܺ� ��ʽ��ÿһ�Է�����ܺ� ��ȥ �������� ���� ���� ��һ */; 