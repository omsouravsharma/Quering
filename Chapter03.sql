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