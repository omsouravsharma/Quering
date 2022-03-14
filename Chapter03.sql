--CHAPTER 3

USE TSQLV3

--SELECT Custid,COUNT(DISTINCT empid)
--FROM Sales.Orders
--group by custid
--having COUNT(DISTINCT empid) = (Select count(*) from hr.Employees)


--SELECT *
--FROM Sales.Orders
--WHERE orderdate IN 
--(
--SELECT  MAX(orderdate) AS LASTDATE
--FROM Sales.Orders
--GROUP BY YEAR(orderdate), MONTH(ORDERDATE))


--CORRELATED QUERIES

--SELECT *
--FROM Sales.ORDERS O1
--WHERE O1.orderdate =

--(SELECT MAX(ORDERDATE)
--FROM Sales.Orders O2

--WHERE O2.CUSTID = O1.CUSTID)
--ORDER BY CUSTID

--PG -261

--SELECT orderid, orderdate, custid, empid
--FROM Sales.Orders AS O1
--WHERE orderdate =
--(SELECT MAX(orderdate)
--FROM Sales.Orders AS O2
--WHERE O2.custid = O1.custid)
--AND orderid =
--(SELECT MAX(orderid)
--FROM Sales.Orders AS O2
--WHERE O2.custid = O1.custid
----AND O2.orderdate = O1.orderdate);

--SELECT orderid, orderdate, custid, empid
--FROM Sales.Orders AS O1
--WHERE orderid =
--(SELECT TOP (1) orderid
--FROM Sales.Orders AS O2
--WHERE O2.custid = O1.custid
--ORDER BY orderdate DESC, orderid DESC);


--CREATE UNIQUE INDEX IDX_POC 
--ON 
--SALES.ORDERS(CUSTID, ORDERDATE DESC, ORDERID DESC) INCLUDE(EMPID);

--SELECT
--(SELECT TOP (1) orderid
--FROM Sales.Orders AS O
--WHERE O.custid = C.custid
--ORDER BY orderdate DESC, orderid DESC) AS orderid
--FROM Sales.Customers AS C;


--SELECT orderid, orderdate, custid, empid
--FROM Sales.Orders
--WHERE orderid IN 
--(
--SELECT 
--(SELECT TOP (1) orderid
--FROM SALES.Orders AS O
--WHERE O.custid = c.CUSTID
--ORDER BY orderdate DESC, orderid DESC) AS ORDERID

--FROM Sales.Customers AS C)


--DROP INDEX idx_poc ON Sales.Orders;


-- THE EXIST PREDICATE

--SELECT  custid, companyname
--FROM SALES.CUSTOMERS AS C
--WHERE EXISTS 
--(SELECT * 
--FROM Sales.Orders AS O
--WHERE O.custid = C.custid)


--SET NOCOUNT ON;
--USE tempdb;
--IF OBJECT_ID(N'DBO.T1' , N'U') IS NOT NULL DROP TABLE DBO.T1;
--CREATE TABLE T1( COL1 INT NOT NULL CONSTRAINT PF_T1 PRIMARY KEY);
--INSERT INTO DBO.T1 VALUES(1),(2), (3),(7),(8),(9),(11),(15),(16),(17),(28);

--TRUNCATE TABLE dbo.T1;
--INSERT INTO dbo.T1 WITH (TABLOCK) (col1)
--SELECT n FROM TSQLV3.dbo.GetNums(1, 10000000) AS Nums WHERE n % 10000 <> 0
--OPTION(MAXDOP 1);

--SELECT MIN(A.COL1) + 1 AS MISSINGVAL
--FROM DBO.T1 AS A
--WHERE NOT EXISTS(
--SELECT * FROM dbo.T1 AS B
--WHERE A.COL1 = B.COL1 +1) ;


--SELECT TOP (1) A.col1 + 1 AS missingval
--FROM dbo.T1 AS A
--WHERE NOT EXISTS
--(SELECT *
--FROM dbo.T1 AS B
--WHERE B.col1 = A.col1 + 1)
--ORDER BY A.col1 + 1;

--SELECT TOP (1) A.col1 + 1 AS missingval
--FROM dbo.T1 AS A
--WHERE NOT EXISTS
--(SELECT *
--FROM dbo.T1 AS B
--WHERE A.col1 = B.col1 - 1)
--ORDER BY A.col1;



----CASE STATEMENT TO FIND MISSING

--SELECT 
--CASE
--WHEN NOT EXISTS ( SELECT * FROM DBO.T1 WHERE COL1 = 1) THEN 1
--ELSE (SELECT TOP(1) A.COL1+1 AS MISSINGVAL FROM DBO.T1 AS A  WHERE NOT EXISTS (SELECT * FROM DBO.T1 AS B
--WHERE B.COL1 = A.COL1 -1) ORDER BY MISSINGVAL)
--END AS MISSINGVAL

--SELECT col1
--FROM dbo.T1 AS A
--SELECT col1
--FROM dbo.T1 AS A
--WHERE NOT EXISTS
--(SELECT *
--FROM dbo.T1 AS B
--WHERE B.col1 = A.col1 + 1)
--AND col1 < (SELECT MAX(col1) FROM dbo.T1);


--SELECT COL1+1 AS RANGE_FROM, 
--	(SELECT MIN(B.COL1)
--	FROM DBO.T1 AS B
--	WHERE B.COL1 >A.COL1) -1 AS RANGE_TO
--FROM DBO.T1 AS A
--WHERE NOT EXISTS (
--SELECT * FROM DBO.T1 AS B
--WHERE B.COL1 = a.COL1+1) AND
--COL1< (SELECT MAX(COL1) FROM DBO.T1);



--use TSQLV3

--SELECT custid
--FROM Sales.Orders
--GROUP BY CUSTID 
--HAVING COUNT(DISTINCT EMPID) = (SELECT COUNT(*) FROM HR.Employees);




--SELECT CUSTID, COMPANYNAME
--FROM Sales.Customers AS C
--WHERE NOT EXISTS(
--SELECT * FROM HR.Employees as E
--WHERE NOT EXISTS (
--SELECT * FROM Sales.Orders AS O
--WHERE O.custid = C.custid AND 
--O.empid = E.empid));


--IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
--IF OBJECT_ID(N'dbo.T2', N'U') IS NOT NULL DROP TABLE dbo.T2;
--GO
--CREATE TABLE dbo.T1(col1 INT NOT NULL);
--CREATE TABLE dbo.T2(col2 INT NOT NULL);
--INSERT INTO dbo.T1(col1) VALUES(1);
--INSERT INTO dbo.T1(col1) VALUES(2);
--INSERT INTO dbo.T1(col1) VALUES(3);
--INSERT INTO dbo.T2(col2) VALUES(2);

-- SUBQUERY WHEN COLUMNS NAME  CAN BE SAME  - MISTAKE 

--SELECT * FROM DBO.T1
--SELECT * FROM DBO.T2

--SELECT COL1
--FROM DBO.T1 WHERE COL1 IN ( SELECT T2.COL2 FROM DBO.T2)




--IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
--IF OBJECT_ID(N'dbo.T2', N'U') IS NOT NULL DROP TABLE dbo.T2;
--GO
--CREATE TABLE dbo.T1(col1 INT NULL);
--CREATE TABLE dbo.T2(col1 INT NOT NULL);
--INSERT INTO dbo.T1(col1) VALUES(1);
--INSERT INTO dbo.T1(col1) VALUES(2);
--INSERT INTO dbo.T1(col1) VALUES(NULL);
--INSERT INTO dbo.T2(col1) VALUES(2);
--INSERT INTO dbo.T2(col1) VALUES(3);


-- VLAUE APPEAR IN T2 NOT IN T1

--SELECT T2.col1
--FROM DBO.T2 
--WHERE T2.col1 NOT IN (SELECT T1.col1 FROM DBO.T1 WHERE T1.col1 IS NOT NULL)

--SELECT T2.col1
--FROM DBO.T2 
--WHERE NOT EXISTS (SELECT T1.col1 FROM DBO.T1 WHERE T1.col1 = T2.col1)

-- DERIVED TABLE




--IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
--GO
--CREATE TABLE dbo.T1(col1 INT);
--INSERT INTO dbo.T1(col1) VALUES(1);
--INSERT INTO dbo.T1(col1) VALUES(2);


--SELECT COL1, EXPR+1 AS EXPR2
--FROM (
--SELECT T1.col1, T1.col1 + 1 AS EXPR
--FROM T1) AS D;


--SELECT ORDERYEAR, NUMCUSTS
--FROM 

--( SELECT ORDERYEAR, COUNT( DISTINCT CUSTID) AS NUMCUSTS FROM 


--(SELECT YEAR(ORDERDATE) AS ORDERYEAR, CUSTID FROM Sales.Orders)  AS d1


--GROUP BY ORDERYEAR) AS D2
--WHERE NUMCUSTS > 70


--SELECT CUR.orderyear, CUR.numorders, PRV.numorders, CUR.numorders - PRV.numorders AS diff
--FROM (SELECT YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
--FROM Sales.Orders
--GROUP BY YEAR(orderdate)) AS CUR
--LEFT OUTER JOIN
--(SELECT YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
--FROM Sales.Orders
--GROUP BY YEAR(orderdate)) AS PRV
--ON CUR.orderyear = PRV.orderyear + 1;

--PG 282 CTEs