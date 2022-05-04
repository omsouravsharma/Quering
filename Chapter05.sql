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
