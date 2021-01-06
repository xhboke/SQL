﻿/** 1、房间类型表 */
DROP TABLE IF EXISTS dbo.ROOM_TYPE;
CREATE TABLE ROOM_TYPE 
(
	ROOM_TYPE_ID INT PRIMARY KEY,
	ROOM_TYPE_NAME VARCHAR(20),
	ROOM_FEATURES VARCHAR(MAX),
	/** 最大入住人数大于等于1小于等于10*/
	ROOM_MAX INT CHECK(ROOM_MAX BETWEEN 1 AND 6),
	/** 最低单价大于等于100 */
	ROOM_PRICE INT CHECK(ROOM_PRICE >= 100),
);
INSERT INTO ROOM_TYPE VALUES 
(1,'经济间','面积20m²,卫生间其他附属设备，单人床，可吸烟，无窗',1,199),
(2,'单人间','面积20m²,卫生间其他附属设备，单人床，可吸烟，有窗',1,219),
(3,'标准间','面积25m²,卫生间其他附属设备，双人床，可吸烟，有窗',2,269),
(4,'商务间','面积25m²,卫生间其他附属设备，双人床，可吸烟，有窗，可上网',2,289),
(5,'风景间','面积40m²,卫生间其他附属设备，双人床，可吸烟，有窗，可上网，海景',4,369),
(6,'套间','面积40m²,卫生间其他附属设备，双人床，可吸烟，有窗，可上网，有酒吧，厨房',6,399);

/** 2、房间状态表 */
DROP TABLE IF EXISTS dbo.ROOM_STATUS;
CREATE TABLE ROOM_STATUS 
(
	ROOM_STATUS_ID INT PRIMARY KEY,
	ROOM_STATUS_NAME VARCHAR(4)
);
INSERT INTO ROOM_STATUS VALUES
(1,'空闲'),
(2,'维护'),
(3,'预留'),
(4,'占用');

/** 3、房间邻接表 */
DROP TABLE IF EXISTS dbo.ROOM_CONNECT;
CREATE TABLE ROOM_CONNECT 
(
	ROOM_CONNECT_ID_LEFT INT,
	ROOM_CONNECT_ID_RIGHT INT,
	PRIMARY KEY(ROOM_CONNECT_ID_LEFT,ROOM_CONNECT_ID_RIGHT)
);
/** 插值用存储过程 */

/** 4、房间信息表 */
CREATE TABLE ROOM_INFO
(
	ROOM_ID INT PRIMARY KEY,
	ROOM_TYPE_ID INT FOREIGN KEY REFERENCES ROOM_TYPE,
	ROOM_LOCATION INT UNIQUE NOT NULL,
	ROOM_STATUS_ID INT FOREIGN KEY REFERENCES ROOM_STATUS,
	ROOM_MESSAGE VARCHAR(MAX),
)
/** 使用Python随机生成的 */
INSERT INTO ROOM_INFO VALUES
(101,2,101,1,''),
(102,2,102,1,''),
(103,4,103,1,''),
(104,5,104,1,''),
(105,4,105,1,''),
(106,4,106,1,''),
(107,6,107,1,''),
(108,3,108,1,''),
(109,1,109,1,''),
(110,3,110,1,''),
(201,6,201,1,''),
(202,6,202,1,''),
(203,4,203,1,''),
(204,5,204,1,''),
(205,1,205,1,''),
(206,1,206,1,''),
(207,1,207,1,''),
(208,5,208,1,''),
(209,1,209,1,''),
(210,3,210,1,''),
(301,3,301,1,''),
(302,3,302,1,''),
(303,3,303,1,''),
(304,3,304,1,''),
(305,3,305,1,''),
(306,3,306,1,''),
(307,3,307,1,''),
(308,3,308,1,''),
(309,6,309,1,''),
(310,2,310,1,'');


/** 5、预定*/
DROP TABLE IF EXISTS dbo.RESERVE;
CREATE TABLE RESERVE 
(
	RESERVE_ID INT PRIMARY KEY,
	ROOM_ID INT FOREIGN KEY REFERENCES ROOM_INFO,
	RESERVE_START_TIME DATE NOT NULL,
	RESERVE_LAST_TIME INT NOT NULL CHECK( RESERVE_LAST_TIME > 0),
	RESERVE_CONTACT_MESSAGE VARCHAR(MAX) NOT NULL,
);

/** 6、预定的价格 */
DROP TABLE IF EXISTS dbo.RESERVE_MONEY;
CREATE TABLE RESERVE_MONEY
(
	ROOM_ID INT FOREIGN KEY REFERENCES ROOM_INFO,
	RESERVE_MONEY MONEY CHECK (RESERVE_MONEY >= 0),
);
INSERT INTO RESERVE_MONEY VALUES
(101,45),
(102,11),
(103,40),
(104,15),
(105,46),
(106,36),
(107,20),
(108,41),
(109,33),
(110,42),
(201,14),
(202,31),
(203,48),
(204,37),
(205,18),
(206,32),
(207,35),
(208,49),
(209,39),
(210,17),
(301,11),
(302,19),
(303,43),
(304,47),
(305,13),
(306,34),
(307,15),
(308,18),
(309,43),
(310,32);

/*  7、登记入住表*/
DROP TABLE IF EXISTS dbo.CHECKIN;
CREATE TABLE CHECKIN
(
	CHECKIN_ID INT PRIMARY KEY,
	ROOM_ID INT FOREIGN KEY REFERENCES ROOM_INFO,
	NAME_CONSUMER VARCHAR(40) NOT NULL,
	IDCARD_CONSUMER VARCHAR(18) NOT NULL,
	CONTACT_CONSUMER VARCHAR(11) NOT NULL,
	ISRESERVE INT NOT NULL,
	CHECKIN_START_TIME DATE NOT NULL,
	PLAN_TIME INT NOT NULL,
	OTHER_MESSAGE VARCHAR(MAX),
);

/** 8、换房 */
DROP TABLE IF EXISTS dbo.CHANGE_ROOM;
CREATE TABLE CHANGE_ROOM
(
	CHANGE_ID INT PRIMARY KEY,
	CHECKIN_ID INT FOREIGN KEY REFERENCES CHECKIN,
	BEFORE_ROOM_ID INT FOREIGN KEY REFERENCES ROOM_INFO,
	AFTER_ROOM_ID INT FOREIGN KEY REFERENCES ROOM_INFO,
	CHANGE_TIME DATE NOT NULL,
);


/** 9、退房 */
DROP TABLE IF EXISTS dbo.CHECKOUT;
CREATE TABLE CHECKOUT
(
	CHECKOUT_ID INT PRIMARY KEY,
	CHECKIN_ID INT FOREIGN KEY REFERENCES CHECKIN,
	CHECKOUT_TIME DATETIME NOT NULL,
);


/** 10、消费产品 */
DROP TABLE IF EXISTS dbo.PRODUCT;
CREATE TABLE PRODUCT
(
	PRODUCT_ID INT PRIMARY KEY,
	PRODUCT_NAME VARCHAR(30) NOT NULL,
	PRODUCT_PRICE MONEY NOT NULL CHECK(PRODUCT_PRICE > 0),
);
INSERT INTO PRODUCT VALUES
(1,'早餐',5),
(2,'午餐',10),
(3,'晚餐',8),
(4,'雪碧',4),
(5,'可口可乐',4),
(6,'统一方便面',5);
/** 11、消费产品记账 */
DROP TABLE IF EXISTS dbo.BOOKKEEPING;
CREATE TABLE BOOKKEEPING
(
	BOOKKEEPING_ID INT PRIMARY KEY,
	CHECKIN_ID INT FOREIGN KEY REFERENCES CHECKIN,
	PRODUCT_ID INT FOREIGN KEY REFERENCES PRODUCT,
	NUMBER INT NOT NULL,
	_TIME DATE NOT NULL,
);

/** 12、VIP记录 */
CREATE TABLE VIP
(
	_ID INT PRIMARY KEY,
	_NAME VARCHAR(20),
	_DATE DATE,
	_IDCARD VARCHAR(18),
	_MONEY MONEY
)