----CHAPTER-04
----WINDOWS FUNCTION
----AGGREGATED WINDOWS FUNCTION

--SET NOCOUNT ON;
--USE tempdb;

----ORDERVALUE TABLE
--IF OBJECT_ID(N'DBO.ORDERVALUES', N'U') IS NOT NULL DROP TABLE DBO.ORDERVALUES;

--SELECT * INTO DBO.ORDERVALUES FROM TSQLV3.Sales.OrderValues

--ALTER TABLE DBO.ORDERVALUES ADD CONSTRAINT PK_ORDERVALUES PRIMARY KEY (ORDERID);

--GO

----EMPORDERS TABLE

--IF OBJECT_ID(N'DBO.EMPORDERS', N'U') IS NOT NULL DROP TABLE DBO.EMPORDERS;

--SELECT empid, ISNULL(ordermonth, CAST('19000101' AS DATE)) AS ordermonth, qty,
--val, numorders
--INTO DBO.EMPORDERS
--FROM TSQLV3.Sales.EmpOrders;

--ALTER TABLE DBO.EMPORDERS ADD CONSTRAINT PK_EMPORDERS PRIMARY KEY(EMPID, ORDERMONTH);
--GO

----TRANSATIONS TABLE 

---- Transactions table
--IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions;
--IF OBJECT_ID('dbo.Accounts', 'U') IS NOT NULL DROP TABLE dbo.Accounts;

--CREATE TABLE dbo.Accounts
--(
--actid INT NOT NULL CONSTRAINT PK_Accounts PRIMARY KEY
--);

--CREATE TABLE dbo.Transactions
--(
--actid INT NOT NULL,
--tranid INT NOT NULL,
--val MONEY NOT NULL,
--CONSTRAINT PK_Transactions PRIMARY KEY(actid, tranid)
--);

--DECLARE 
--@NUM_PARTITIONS AS INT = 100, 
--@ROWS_PER_PARTITION AS INT = 2000;


--INSERT INTO DBO.ACCOUNTS WITH (TABLOCK) (ACTID) 
--SELECT NP.N
--FROM TSQLV3.DBO.GETNUMS(1, @NUM_PARTITIONS) AS NP;

--INSERT INTO DBO.TRANSACTIONS WITH (TABLOCK)  (ACTID, TRANID, VAL)
--SELECT NP.N, RPP.N, 
--(ABS(CHECKSUM(NEWID())%2)*2-1) * (1+ abs(CHECKSUM(NEWID())%5))
--FROM TSQLV3.DBO.GetNums(1, @NUM_PARTITIONS) AS np
--CROSS JOIN TSQLV3.DBO.GetNums(1, @ROWS_PER_PARTITION) AS RPP;


-- LIMITATION PG344 working on queries at work
-- WINDOWS ELEMENT 