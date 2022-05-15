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

COMMIT TRAN

--MEASURING THR AMOUNT OF LOGGING
--BULK ROWSET PROVIDER PG 481

USE tempdb;
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
CREATE TABLE dbo.T1
(
id INT NOT NULL PRIMARY KEY,
xmlval XML NULL,
textval VARCHAR(MAX) NULL,
ntextval NVARCHAR(MAX) NULL,
binval VARBINARY(MAX) NULL
);

INSERT INTO dbo.T1(id, xmlval)
VALUES( 1,
(SELECT xmlval FROM OPENROWSET(
BULK 'C:\temp\xmlfile.xml', SINGLE_NCLOB) AS F(xmlval)) );

-- SEQUENCES

-- CHARACTERISTICS AND INFLEXIBILITIES OF THE IDENTITY PROPERTY
-- SEQUENCE OBJECT


USE PerformanceV3;
IF OBJECT_ID(N'dbo.Seqorderids', N'SO') IS NOT NULL DROP SEQUENCE
dbo.Seqorderids;
CREATE SEQUENCE dbo.Seqorderids AS INT
MINVALUE 1
CYCLE
CACHE 1000;

SELECT NEXT VALUE FOR dbo.Seqorderids;


SELECT current_value, start_value, increment, minimum_value, maximum_value,
is_cycling,
is_cached, cache_size
FROM sys.Sequences
WHERE object_id = OBJECT_ID(N'dbo.Seqorderids', N'SO');


ALTER TABLE dbo.Orders
ADD CONSTRAINT DFT_Orders_orderid
DEFAULT(NEXT VALUE FOR dbo.Seqorderids) FOR orderid;



IF OBJECT_ID(N'dbo.MyOrders', N'U') IS NOT NULL DROP TABLE dbo.MyOrders;
SELECT orderid, custid, empid, shipperid, orderdate, filler
INTO dbo.MyOrders
FROM dbo.Orders
WHERE empid = 1;
ALTER TABLE dbo.MyOrders ADD CONSTRAINT PK_MyOrders PRIMARY KEY(orderid);


UPDATE dbo.MyOrders
SET orderid = NEXT VALUE FOR dbo.Seqorderids;


SELECT * from dbo.MyOrders


INSERT INTO dbo.MyOrders(orderid, custid, empid, shipperid, orderdate, filler)
SELECT NEXT VALUE FOR dbo.Seqorderids OVER(ORDER BY orderid) AS orderid,
custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE empid = 2;

--DELETING DATA 501