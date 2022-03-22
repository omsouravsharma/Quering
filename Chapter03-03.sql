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
