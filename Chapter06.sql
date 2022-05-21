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

USE tempdb;
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
GO
SELECT
orderid, custid, empid, orderdate, requireddate, shippeddate,
shipperid, freight, shipname, shipaddress, shipcity, shipregion,
shippostalcode, shipcountry
INTO dbo.Orders
FROM TSQLV3.Sales.Orders
CROSS JOIN TSQLV3.dbo.Nums
WHERE n <= 3;


WITH C AS (
SELECT *, ROW_NUMBER() over(PARTITION BY ORDERID ORDER BY (SELECT NULL)) AS N
FROM DBO.Orders
)

DELETE FROM C 
WHERE N >1 

--UPDATING DATA

USE tempdb;
IF OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL DROP TABLE dbo.Customers;
CREATE TABLE dbo.Customers
(
custid INT NOT NULL,
companyname VARCHAR(25) NOT NULL,
phone VARCHAR(20) NULL,
address VARCHAR(50) NOT NULL,
CONSTRAINT PK_Customers PRIMARY KEY(custid)
);
GO
INSERT INTO dbo.Customers(custid, companyname, phone, address)
VALUES(1, 'cust 1', '(111) 111-1111', 'address 1'),
(2, 'cust 2', '(222) 222-2222', 'address 2'),
(3, 'cust 3', '(333) 333-3333', 'address 3'),
(4, 'cust 4', '(444) 444-4444', 'address 4'),
(5, 'cust 5', '(555) 555-5555', 'address 5');
GO
IF OBJECT_ID(N'dbo.CustomersStage', N'U') IS NOT NULL DROP TABLE
dbo.CustomersStage;
CREATE TABLE dbo.CustomersStage
(
custid INT NOT NULL,
companyname VARCHAR(25) NOT NULL,
phone VARCHAR(20) NULL,
address VARCHAR(50) NOT NULL,
CONSTRAINT PK_CustomersStage PRIMARY KEY(custid)
);
GO
INSERT INTO dbo.CustomersStage(custid, companyname, phone, address)
VALUES(2, 'AAAAA', '(222) 222-2222', 'address 2'),
(3, 'cust 3', '(333) 333-3333', 'address 3'),
(5, 'BBBBB', 'CCCCC', 'DDDDD'),
(6, 'cust 6 (new)', '(666) 666-6666', 'address 6'),
(7, 'cust 7 (new)', '(777) 777-7777', 'address 7');


WITH C AS
(
SELECT
TGT.custid,
SRC.companyname AS src_companyname,
TGT.companyname AS tgt_companyname,
SRC.phone AS src_phone,
TGT.phone AS tgt_phone,
SRC.address AS src_address,
TGT.address AS tgt_address
FROM dbo.Customers AS TGT
INNER JOIN dbo.CustomersStage AS SRC
ON TGT.custid = SRC.custid
)
UPDATE C
SET tgt_companyname = src_companyname,
tgt_phone = src_phone,
tgt_address = src_address


--UPDATE WITH VARIABLE 


USE tempdb;
IF OBJECT_ID(N'dbo.MySequence', N'U') IS NOT NULL DROP TABLE dbo.MySequence;
CREATE TABLE dbo.MySequence(val INT NOT NULL);
INSERT INTO dbo.MySequence(val) VALUES(0);


DECLARE @newval AS INT;
UPDATE dbo.MySequence SET @newval = val += 1;
SELECT @newval;


--MERGING DATA


MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
ON TGT.custid = SRC.custid
WHEN MATCHED THEN
UPDATE SET
TGT.companyname = SRC.companyname,
TGT.phone = SRC.phone,
TGT.address = SRC.address
WHEN NOT MATCHED THEN
INSERT (custid, companyname, phone, address)
VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
WHEN NOT MATCHED BY SOURCE THEN
DELETE;

--MERGE STILL PENDING 


IF OBJECT_ID(N'dbo.AddCustomer', N'P') IS NOT NULL DROP PROC dbo.AddCustomer;
GO
CREATE PROC dbo.AddCustomer
@custid INT, @companyname VARCHAR(25), @phone VARCHAR(20), @address
VARCHAR(50)
AS
MERGE INTO dbo.Customers  WITH (SERIALIZABLE)  AS TGT
USING (VALUES(@custid, @companyname, @phone, @address))
AS SRC(custid, companyname, phone, address)
ON TGT.custid = SRC.custid
WHEN MATCHED THEN
UPDATE SET
TGT.companyname = SRC.companyname,
TGT.phone = SRC.phone,
TGT.address = SRC.address
WHEN NOT MATCHED THEN
INSERT (custid, companyname, phone, address)
VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address);
GO

--USING IS SIMILAR TO FROM

-- THE OUTPUT CLAUSE


USE tempdb;
IF OBJECT_ID(N'dbo.T1', N'U') IS NOT NULL DROP TABLE dbo.T1;
GO
CREATE TABLE dbo.T1
(
keycol INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_T1 PRIMARY KEY,
datacol NVARCHAR(40) NOT NULL
);


INSERT INTO dbo.T1(datacol)
OUTPUT inserted.$identity, inserted.datacol
SELECT lastname
FROM TSQLV3.HR.Employees
WHERE country = N'USA';

TRUNCATE TABLE dbo.T1;


DECLARE @NewRows TABLE(keycol INT, datacol NVARCHAR(40));
INSERT INTO dbo.T1(datacol)
OUTPUT inserted.$identity, inserted.datacol
INTO @NewRows(keycol, datacol)
SELECT lastname
FROM TSQLV3.HR.Employees
WHERE country = N'USA';

SELECT keycol, datacol FROM @NewRows;

--EXAMPLE OF ARCHIVING DELETED DATA 521