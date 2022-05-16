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

--TRUNCATE TABLE 


IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
GO
CREATE TABLE dbo.T1
(
keycol INT NOT NULL IDENTITY,
datacol VARCHAR(10) NOT NULL
);
INSERT INTO dbo.T1(datacol) VALUES('A'),('B'),('C');
SELECT keycol, datacol FROM dbo.T1;



IF EXISTS(SELECT * FROM dbo.T1)
BEGIN
BEGIN TRAN
DECLARE @tmp AS INT = (SELECT TOP (1) keycol FROM dbo.T1 WITH (TABLOCKX));
-- lock
DECLARE @reseedval AS INT = IDENT_CURRENT(N'dbo.T1') +
1; -- save
TRUNCATE TABLE
dbo.T1; -- truncate
DBCC CHECKIDENT(N'dbo.T1', RESEED,
@reseedval); -- reseed
PRINT 'Identity reseeded to ' + CAST(@reseedval AS VARCHAR(10)) + '.';
COMMIT TRAN
END
ELSE
PRINT 'Table is empty, no need to truncate.' ;


INSERT INTO dbo.T1(datacol) VALUES('X'),('Y'),('Z');
SELECT keycol, datacol FROM dbo.T1;



SET NOCOUNT ON;
USE tempdb;
IF OBJECT_ID(N'dbo.V1', N'V') IS NOT NULL DROP VIEW dbo.V1;
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
GO
CREATE TABLE dbo.T1
(
col1 INT NOT NULL PRIMARY KEY,
col2 INT NOT NULL,
col3 NUMERIC(12, 2) NOT NULL
);
INSERT INTO dbo.T1(col1, col2, col3) VALUES
( 2, 10, 200.00),
( 3, 10, 800.00),
( 5, 10, 100.00),
( 7, 20, 300.00),
(11, 20, 500.00),
(13, 20, 1300.00);
GO
CREATE VIEW dbo.V1 WITH SCHEMABINDING
AS
SELECT col2, SUM(col3) AS total , COUNT_BIG(*) AS cnt
FROM dbo.T1
GROUP BY col2;
GO
CREATE UNIQUE CLUSTERED INDEX idx_col2 ON dbo.V1(col2);
GO
SELECT col2, total, cnt FROM dbo.V1;


TRUNCATE TABLE dbo.T1;


CREATE TABLE dbo.T1_STAGE
(
col1 INT NOT NULL PRIMARY KEY,
col2 INT NOT NULL,
col3 NUMERIC(12, 2) NOT NULL
);
ALTER TABLE dbo.T1 SWITCH TO dbo.T1_STAGE;
DROP TABLE dbo.T1_STAGE;


--DELETING DUPLICATES

