--CHAPTER 6 DATA MODIFICATION 

--SELECT INTO

SET NOCOUNT ON;
USE PerformanceV3;
IF OBJECT_ID(N'dbo.MyOrders', N'U') IS NOT NULL DROP TABLE dbo.MyOrders;


SELECT ORDERID, CUSTID, EMPID, SHIPPERID, ORDERDATE, FILLER
INTO DBO.MYORDERS
FROM DBO.ORDERS

select COUNT(*) 
FROM DBO.MYORDERS


select COUNT(*) 
FROM DBO.ORDERS

--pg 476

USE PerformanceV3;
IF OBJECT_ID(N'dbo.MyOrders', N'U') IS NOT NULL DROP TABLE dbo.MyOrders;


USE PerformanceV3;
BEGIN TRAN
SELECT orderid, custid, empid, shipperid, orderdate, filler
INTO dbo.MyOrders
FROM dbo.Orders;

USE PerformanceV3;
SELECT SCHEMA_NAME(schema_id) AS schemaname, name AS tablename FROM sys.tables;

--pg 476