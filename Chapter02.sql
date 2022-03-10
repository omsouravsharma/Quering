SET NOCOUNT ON;
USE PerformanceV3;

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 10000;

SET STATISTICS IO, TIME ON;

--CREATE EVENT SESSION query_performance ON SERVER
--ADD EVENT sqlserver.sql_statement_completed(
--WHERE (sqlserver.session_id=(60))); -- replace with your session ID;

--ALTER EVENT SESSION query_performance ON SERVER STATE = START;