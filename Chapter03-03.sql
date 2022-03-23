-- joins
USE TSQLV3

-- CROSS JOIN 

--SELECT E1.firstname AS firstname1, E1.lastname AS lastname1,
--E2.firstname AS firstname2, E2.lastname AS lastname2
--FROM HR.EMPLOYEES AS E1
--CROSS JOIN HR.Employees AS E2


--DECLARE @S AS DATE = '20150101', @E AS DATE = '20150131'
--, @NUMCUSTS AS INT = 50, @NUMEMPS AS INT = 50

--SELECT 
--ROW_NUMBER() OVER(ORDER BY (SELECT NULL))  AS ORDERID, 
--DATEADD(DAY, D.N, @S) AS ORDERDATE, C.N AS CUSTID , E.N AS EMPID
--FROM DBO.GetNums(0, DATEDIFF(DAY, @S, @E) ) AS D
--CROSS JOIN DBO.GETNUMS(1, @NUMCUSTS) AS C
--CROSS JOIN DBO.GETNUMS(1, @NUMEMPS) AS E

--SELECT orderid, VAL, 
--VAL/(SELECT SUM(VAL) FROM Sales.OrderValues) AS PCT, 
--VAL - (SELECT AVG(VAL) FROM Sales.OrderValues) AS DIFF
--FROM Sales.OrderValues
--WHERE orderid = 10248

--SELECT orderid, VAL, 
--VAL/ SUMVAL AS PCT, 
--VAL - AVGVAL AS DIFF
--FROM Sales.OrderValues
--CROSS JOIN (SELECT SUM(VAL) AS SUMVAL, AVG(VAL) AS AVGVAL
--FROM Sales.OrderValues) AS AGGS

-- INNER JOIN

--SELECT C.custid, C.companyname, O.orderid
--FROM Sales.Customers AS C
--INNER JOIN Sales.Orders AS O
--ON C.custid = O.custid
--WHERE C.country = 'USA'

--OUTER JOIN

--SELECT C.custid, C.companyname, C.country, O.orderid, O.shipcountry

--FROM Sales.Customers AS C
--LEFT OUTER JOIN Sales.Orders AS O
--ON C.custid = O.custid


--SELECT C.custid, C.companyname, C.country, O.orderid, O.shipcountry

--FROM Sales.Customers AS C
--LEFT OUTER JOIN Sales.Orders AS O
--ON C.custid = O.custid
--WHERE O.orderid IS NULL


-- SELF JOIN

--SELECT E.firstname +' ' + E.lastname AS EMP, M.firstname + ' ' + M.lastname AS MGR
--FROM HR.Employees AS E

--LEFT OUTER JOIN HR.Employees AS M
--ON E.mgrid = M.empid

-- EQUI JOIN AND NONEQUI JOIN
--SELECT E1.empid, E1.lastname, E1.firstname, E2.empid, E2.lastname, E2.firstname
--FROM HR.Employees AS E1
--INNER JOIN HR.EMPLOYEES E2
--ON E1.EMPID < E2.EMPID

--MULTI JOIN 

--SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
--FROM Sales.Customers AS C
--INNER JOIN Sales.Orders AS O
--ON O.custid = C.custid
--INNER JOIN SALES.OrderDetails OD
--ON OD.orderid = O.orderid
--INNER JOIN Production.Products AS P
--ON P.productid = OD.productid
--INNER JOIN Production.Suppliers AS S
--ON S.supplierid = P.supplierid
--ORDER BY customer

---- TO INCLUDE THE CUSTOMER WHO DOES NOT PLACE AN ORDER

--SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
--FROM  Sales.Orders AS O

--INNER JOIN SALES.OrderDetails OD
--ON OD.orderid = O.orderid
--INNER JOIN Production.Products AS P
--ON P.productid = OD.productid
--INNER JOIN Production.Suppliers AS S
--ON S.supplierid = P.supplierid
--RIGHT OUTER JOIN Sales.Customers AS C
--ON C.custid= O.custid
--ORDER BY customer

-- SEMI AND ANTI SEMI JOINS. 

--SELECT DISTINCT C.custid, C.companyname
--FROM Sales.Customers AS C
--INNER JOIN Sales.Orders AS O
--ON C.custid = O.custid


--SELECT  C.custid, C.companyname
--FROM Sales.Customers AS C
--WHERE EXISTS (SELECT * FROM Sales.Orders AS O
--WHERE C.custid = O.custid)

---- anti join

--SELECT C.custid, C.companyname
--FROM Sales.Customers AS C
--LEFT OUTER JOIN Sales.Orders AS O
--ON O.custid = C.custid
--WHERE O.orderid IS not NULL;

--pg -320

-- ALGORITHM NESTED, MERGE, HASH

--USE PERFORMANCEV3

--SELECT C.custid, C.custname, O.orderid, O.empid, O.shipperid, O.orderdate
--FROM DBO.CUSTOMERS AS C
--INNER JOIN DBO.ORDERS AS O
--ON O.CUSTID = C.CUSTID
--WHERE C.CUSTNAME LIKE 'Cust_1000%'
--AND O.orderdate >='20140101' AND O.orderdate < '20140401'


--CREATE INDEX IDX_NC_CN_I_CID on DBO.CUSTOMERS(CUSTNAME) INCLUDE (CUSTID);
--CREATE INDEX idx_nc_cid_od_i_oid_eid_sid ON DBO.ORDERS(custid, orderdate) include(orderid, empid, shipperid);

--SET NOCOUNT ON;
USE tempdb;
--IF OBJECT_ID(N'dbo.Arrays', N'U') IS NOT NULL DROP TABLE dbo.Arrays;
--CREATE TABLE dbo.Arrays
--(
--id VARCHAR(10) NOT NULL PRIMARY KEY,
--arr VARCHAR(8000) NOT NULL
--);
--GO
--INSERT INTO dbo.Arrays VALUES('A', '20,223,2544,25567,14');
--INSERT INTO dbo.Arrays VALUES('B', '30,-23433,28');
--INSERT INTO dbo.Arrays VALUES('C', '12,10,8099,12,1200,13,12,14,10,9');
--INSERT INTO dbo.Arrays VALUES('D', '-4,-6,-45678,-2');

--SELECT * FROM DBO.ARRAYS

--SELECT id, 
--ROW_NUMBER() over (PARTITION BY ID ORDER BY N)  AS POS, 
--SUBSTRING(ARR, N, CHARINDEX(',', ARR+ ',',N)-N) AS ELEMENT, 
--arr, n
--FROM dbo.Arrays
--INNER JOIN TSQLV3.dbo.Nums
--ON n <= LEN(arr) +1
--AND SUBSTRING(',' + arr, n, 1) = ',';


--alter FUNCTION DBO.SPLITS(@ARR AS VARCHAR(8000), @SEP AS CHAR(1)) RETURNS TABLE
--AS 
--RETURN

--SELECT 
--ROW_NUMBER() over (ORDER BY N)  AS POS, 
--SUBSTRING(@ARR, N, CHARINDEX(@SEP, @ARR+ @SEP,N)-N) AS ELEMENT
--FROM TSQLV3.dbo.Nums
--WHERE n <= LEN(@ARR) +1
--AND SUBSTRING(@SEP + @ARR, n, 1) = @SEP;
--GO



--SELECT * FROM dbo.SplitS('10248,10249,10250', ',') AS S;
