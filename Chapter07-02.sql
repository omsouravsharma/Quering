--LITERALS

USE TSQLV3;
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate = '02/12/2015';


--IDENTIFY WEEKDAYS

SET DATEFIRST = 1

SELECT DATEPART(WEEKDAY, SYSDATETIME());


SELECT DATEDIFF(DAY, '19000101', SYSDATETIME())%7 +1;


SELECT DATEPART(weekday, DATEADD(day, @@DATEFIRST - 1, SYSDATETIME()));

SELECT CAST(CAST(SYSDATETIME() AS date) AS date)

SELECT DATEADD(day, DATEDIFF(day, '19000101', SYSDATETIME()), '19000101');

--FIRST LAST PREVIOUS AND NEXT DATE CALCULATION 

SELECT DATEADD(DAY, DATEDIFF(DAY, '19000101', SYSDATETIME()), '19000101')

SELECT DATEADD(MONTH, DATEDIFF(MONTH, '19000101', SYSDATETIME()), '19000101')


SELECT DATEADD(
day,
DATEDIFF(
day,
'19000101', -- Base Monday date
SYSDATETIME()) /7*7,
'19000101'); -- Base Monday date

SELECT DATEADD(day, DATEDIFF(day, '19000101', DATEADD(day, -1, SYSDATETIME()))
/7*7 + 7,
'19000101');


SELECT DATEADD(day, DATEDIFF(day, '19000102',
-- last day of year
DATEADD(year, DATEDIFF(year, '18991231', SYSDATETIME()), '18991231')
) /7*7, '19000102');


USE PerformanceV3;
SELECT orderid, orderdate, filler
FROM dbo.Orders
WHERE YEAR(orderdate) = 2014;
SELECT orderid, orderdate, filler
FROM dbo.Orders
WHERE orderdate >= '20140101'
AND orderdate < '20150101';


--PG 565


SET NOCOUNT ON;
USE tempdb;
IF OBJECT_ID('dbo.Sessions') IS NOT NULL DROP TABLE dbo.Sessions;
IF OBJECT_ID('dbo.Accounts') IS NOT NULL DROP TABLE dbo.Accounts;
CREATE TABLE dbo.Accounts
(
actid INT NOT NULL,
CONSTRAINT PK_Accounts PRIMARY KEY(actid)
);
GO
INSERT INTO dbo.Accounts(actid) VALUES(1), (2), (3);
CREATE TABLE dbo.Sessions
(
sessionid INT NOT NULL IDENTITY(1, 1),
actid INT NOT NULL,
starttime DATETIME2(0) NOT NULL,
endtime DATETIME2(0) NOT NULL,
CONSTRAINT PK_Sessions PRIMARY KEY(sessionid),
CONSTRAINT CHK_endtime_gteq_starttime
CHECK (endtime >= starttime)
);
GO
INSERT INTO dbo.Sessions(actid, starttime, endtime) VALUES
(1, '20151231 08:00:00', '20151231 08:30:00'),
(1, '20151231 08:30:00', '20151231 09:00:00'),
(1, '20151231 09:00:00', '20151231 09:30:00'),
(1, '20151231 10:00:00', '20151231 11:00:00'),
(1, '20151231 10:30:00', '20151231 12:00:00'),
(1, '20151231 11:30:00', '20151231 12:30:00'),
(2, '20151231 08:00:00', '20151231 10:30:00'),
(2, '20151231 08:30:00', '20151231 10:00:00'),
(2, '20151231 09:00:00', '20151231 09:30:00'),
(2, '20151231 11:00:00', '20151231 11:30:00'),
(2, '20151231 11:32:00', '20151231 12:00:00'),
(2, '20151231 12:04:00', '20151231 12:30:00'),
(3, '20151231 08:00:00', '20151231 09:00:00'),
(3, '20151231 08:00:00', '20151231 08:30:00'),
(3, '20151231 08:30:00', '20151231 09:00:00'),
(3, '20151231 09:30:00', '20151231 09:30:00');


-- 10,000,000 intervals
DECLARE
@num_accounts AS INT = 50,
@sessions_per_account AS INT = 200000,
@start_period AS DATETIME2(3) = '20120101',
@end_period AS DATETIME2(3) = '20160101',
@max_duration_in_seconds AS INT = 3600; -- 1 hour
TRUNCATE TABLE dbo.Sessions;
TRUNCATE TABLE dbo.Accounts;
INSERT INTO dbo.Accounts(actid)
SELECT A.n AS actid
FROM TSQLV3.dbo.GetNums(1, @num_accounts) AS A;


WITH C AS
(
SELECT A.n AS actid,
DATEADD(second,
ABS(CHECKSUM(NEWID())) %
(DATEDIFF(s, @start_period, @end_period) - @max_duration_in_seconds),
@start_period) AS starttime
FROM TSQLV3.dbo.GetNums(1, @num_accounts) AS A
CROSS JOIN TSQLV3.dbo.GetNums(1, @sessions_per_account) AS I
)
INSERT INTO dbo.Sessions WITH (TABLOCK) (actid, starttime, endtime)
SELECT actid, starttime,
DATEADD(second,
ABS(CHECKSUM(NEWID())) % (@max_duration_in_seconds + 1),
starttime) AS endtime
FROM C;


--INTERSECTION 


DECLARE
@actid AS INT = 1,
@s AS DATETIME2(0) = '20151231 11:00:00',
@e AS DATETIME2(0) = '20151231 12:00:00';
SELECT sessionid, actid, starttime, endtime
FROM dbo.Sessions
WHERE actid = @actid
AND starttime <= @e
AND endtime >= @s
OPTION(RECOMPILE);

--pg 574 Max concurrent intervals

CREATE UNIQUE INDEX idx_start_end ON dbo.Sessions(actid, starttime, endtime,
sessionid);


WITH P AS -- time points
(
SELECT actid, starttime AS ts FROM dbo.Sessions
)
SELECT actid, ts FROM P;


WITH P AS -- time points
(
SELECT actid, starttime AS ts FROM dbo.Sessions
),
C AS -- counts
(
SELECT actid, ts,
(SELECT COUNT(*)
FROM dbo.Sessions AS S
WHERE P.actid = S.actid
AND P.ts >= S.starttime
AND P.ts < S.endtime) AS cnt
FROM P
)
SELECT actid, ts, cnt FROM C;
