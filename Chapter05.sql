-- CHAPTER 5 TOP AND OFFSET-FETCH
-- TOP AND OFFSET-FETCH FILTERS

-- TOP FILTERS

USE TSQLV3;
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

USE TSQLV3;
SELECT TOP (1) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

--WITH TIES

SELECT TOP (3) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT TOP (1) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY ROW_NUMBER() OVER(PARTITION BY custid ORDER BY orderdate DESC, orderid
DESC);

SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC;

SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY (SELECT NULL)

-- OFFSET-FETCH FILTER

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;

--HETCH IS OPTIONAL

-- OPTIMIZATION OF FILTERS DEMOSTRATED THROUGH PAGIN
--PG442

--OPTIMIZATION OF TOP


USE PerformanceV3
IF OBJECT_ID('DBO.GETPAGE', 'P') IS NOT NULL DROP PROC DBO.GETPAGE;

GO 
CREATE PROC DBO.GETPAGE
@ORDERID AS INT = 0, --ANCHOR SORT KEY
@PAGESIZE AS BIGINT = 25
AS 

SELECT TOP (@PAGESIZE) ORDERID, ORDERDATE, CUSTID, EMPID
FROM DBO.Orders
WHERE ORDERID > @ORDERID
ORDER BY orderid
GO


EXEC DBO.GETPAGE @PAGESIZE = 25;

EXEC DBO.GETPAGE @ORDERID = 25, @PAGESIZE = 25;

IF OBJECT_ID(N'dbo.GetPage', N'P') IS NOT NULL DROP PROC dbo.GetPage;
GO
CREATE PROC dbo.GetPage
@orderdate AS DATE = '00010101', -- anchor sort key 1 (orderdate)
@orderid AS INT = 0, -- anchor sort key 2 (orderid)
@pagesize AS BIGINT = 25
AS
SELECT TOP (@pagesize) orderid, orderdate, custid, empid
FROM dbo.Orders
WHERE orderdate >= @orderdate
AND (orderdate > @orderdate OR orderid > @orderid)
ORDER BY orderdate, orderid;
GO

EXEC dbo.GetPage @pagesize = 25;

EXEC dbo.GetPage @orderdate = '20101207', @orderid = 410, @pagesize = 25;

--OPTIMITION OF OFFSET-FETCH PG 451

IF OBJECT_ID('DBO.GETPAGE', 'P') IS NOT NULL DROP PROC DBO.GetPage;
GO
CREATE PROC DBO.GETPAGE
@PAGENUM AS BIGINT= 1,
@PAGESIZE AS BIGINT = 25
AS 

SELECT ORDERID, ORDERDATE, CUSTID, EMPID
FROM DBO.Orders
ORDER BY ORDERID
OFFSET(@PAGENUM -1) * @PAGESIZE ROWS FETCH NEXT @PAGESIZE ROWS ONLY
GO


EXEC dbo.GetPage @pagenum = 1, @pagesize = 25;
EXEC dbo.GetPage @pagenum = 2, @pagesize = 25;
EXEC dbo.GetPage @pagenum = 3, @pagesize = 25;


ALTER PROC dbo.GetPage
@pagenum AS BIGINT = 1,
@pagesize AS BIGINT = 25
AS
WITH K AS
(
SELECT orderid
FROM dbo.Orders
ORDER BY orderid
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY
)
SELECT O.orderid, O.orderdate, O.custid, O.empid
FROM dbo.Orders AS O
INNER JOIN K
ON O.orderid = K.orderid
ORDER BY O.orderid;
GO

EXEC dbo.GetPage @pagenum = 1000, @pagesize = 25;


--OFFSET TO | AFTER 

SELECT orderid, orderdate, custid, empid
FROM dbo.Orders
ORDER BY orderdate, orderid
OFFSET AFTER (@anchor_orderdate, @anchor_orderid) -- input anchor sort keys
FETCH NEXT @pagesize ROWS ONLY
LAST ROW INTO (@last_orderdate, @last_orderid); -- outputs for next page
request




--OPTIMIZATION OF ROW_NUMBER

IF OBJECT_ID(N'dbo.GetPage', N'P') IS NOT NULL DROP PROC dbo.GetPage;
GO
CREATE PROC dbo.GetPage
@pagenum AS BIGINT = 1,
@pagesize AS BIGINT = 25
AS
WITH C AS
(
SELECT orderid, orderdate, custid, empid,
ROW_NUMBER() OVER(ORDER BY orderid) AS rn
FROM dbo.Orders
)
SELECT orderid, orderdate, custid, empid
FROM C
WHERE rn BETWEEN (@pagenum - 1) @pagesize + 1 AND @pagenum @pagesize
ORDER BY rn; -- if order by orderid get sort in plan
GO

EXEC dbo.GetPage @pagenum = 1, @pagesize = 25;
EXEC dbo.GetPage @pagenum = 2, @pagesize = 25;
EXEC dbo.GetPage @pagenum = 3, @pagesize = 25;


ALTER PROC dbo.GetPage
@PAGENUM AS BIGINT= 1,
@PAGESIZE AS BIGINT = 25
AS
WITH C AS
(
SELECT orderid, ROW_NUMBER() OVER(ORDER BY orderid) AS rn
FROM dbo.Orders
),
K AS
(
SELECT orderid, rn
FROM C
WHERE rn BETWEEN (@pagenum - 1) @PAGESIZE + 1 AND @pagenum @pagesize
)
SELECT O.orderid, O.orderdate, O.custid, O.empid
FROM dbo.Orders AS O
INNER JOIN K
ON O.orderid = K.orderid
ORDER BY K.rn;
GO

USE PerformanceV3;
IF OBJECT_ID(N'dbo.MyOrders', N'U') IS NOT NULL DROP TABLE dbo.MyOrders;
GO
SELECT * INTO dbo.MyOrders FROM dbo.Orders;
CREATE UNIQUE CLUSTERED INDEX idx_od_oid ON dbo.MyOrders(orderdate, orderid);

DELETE TOP (50) FROM dbo.MyOrders;


WITH C AS
(
SELECT TOP (50) *
FROM dbo.MyOrders
ORDER BY orderdate, orderid
)
DELETE FROM C;


--MODIFYING IN CHUNKS PG 460

SET NOCOUNT ON;
WHILE 1 = 1
BEGIN
DELETE TOP (3000) FROM dbo.MyOrders WHERE orderdate < '20130101';
IF @@ROWCOUNT < 3000 BREAK;
END

--TOP N PER GROUP 461

USE TSQLV3;
CREATE UNIQUE INDEX idx_poc ON Sales.Orders(custid, orderdate DESC, orderid
DESC)
INCLUDE(empid);

WITH C AS
(
SELECT
ROW_NUMBER() OVER(
PARTITION BY custid
ORDER BY orderdate DESC, orderid DESC) AS rownum,
orderid, orderdate, custid, empid
FROM Sales.Orders
)
SELECT custid, orderdate, orderid, empid
FROM C
WHERE rownum <= 3;



-- TOP AND APPLY 

SELECT TOP (3) orderid, orderdate, empid
FROM Sales.Orders
WHERE custid = 1
ORDER BY orderdate DESC, orderid DESC;


SELECT C.custid, A.ORDERID, A.ORDERDATE, A.EMPID
FROM Sales.CUSTOMERS AS C
CROSS APPLY
(SELECT TOP (3) orderid, orderdate, empid
FROM Sales.Orders AS O
WHERE O.custid = C.custid
ORDER BY orderdate DESC, orderid DESC) AS A;

-- TOP OVER


--SELECT TOP (3) OVER ( PARTITION BY custid ORDER BY orderdate, orderid )
--orderid, orderdate, custid, empid
--FROM dbo.Orders
--ORDER BY custid, orderdate, orderid;


-- SOLUTION USFING CONCATENATION ( A CARRY - ALONG SORT) 

DROP INDEX idx_poc ON Sales.Orders;


WITH C AS
(
SELECT
custid,
MAX( (CONVERT(CHAR(8), orderdate, 112)
+ RIGHT('000000000' + CAST(orderid AS VARCHAR(10)), 10)
+ CAST(empid AS CHAR(10)) ) COLLATE Latin1_General_BIN2 ) AS s
FROM Sales.Orders
GROUP BY custid
)
SELECT custid,
CAST( SUBSTRING(s, 1, 8) AS DATE ) AS orderdate,
CAST( SUBSTRING(s, 9, 10) AS INT ) AS orderid,
CAST( SUBSTRING(s, 19, 10) AS CHAR(10) ) AS empid
FROM C;


USE PerformanceV3;
WITH C AS
(
SELECT
custid,
MAX( (CONVERT(CHAR(8), orderdate, 112)
+ RIGHT('000000000' + CAST(orderid AS VARCHAR(10)), 10)
+ CAST(empid AS CHAR(10)) ) COLLATE Latin1_General_BIN2 ) AS s
FROM dbo.Orders
GROUP BY custid
)
SELECT custid,
CAST( SUBSTRING(s, 1, 8) AS DATE ) AS orderdate,
CAST( SUBSTRING(s, 9, 10) AS INT ) AS orderid,
CAST( SUBSTRING(s, 19, 10) AS CHAR(10) ) AS empid
FROM C;
--MEDIAN 

USE tempdb;
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
GO
CREATE TABLE dbo.T1
(
id INT NOT NULL IDENTITY
CONSTRAINT PK_T1 PRIMARY KEY,
grp INT NOT NULL,
val INT NOT NULL
);
CREATE INDEX idx_grp_val ON dbo.T1(grp, val);
INSERT INTO dbo.T1(grp, val)
VALUES(1, 30),(1, 10),(1, 100),
(2, 65),(2, 60),(2, 65),(2, 10);

DECLARE 

@NUMGROUPS AS INT = 10, 
@ROWSPERGROUP AS INT = 1000000;

TRUNCATE TABLE DBO.T1; 

INSERT INTO DBO.T1 WITH(TABLOCK) (GRP, VAL) 
SELECT G.N, ABS(CHECKSUM(NEWID())) % 1000000
FROM TSQLV3.DBO.GetNums(1, @NUMGROUPS) AS G
CROSS JOIN TSQLV3.DBO.GetNums(1, @ROWSPERGROUP) AS RL


CREATE INDEX idx_grp_val ON dbo.T1(grp, val);

-- PG469