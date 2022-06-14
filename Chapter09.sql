--DYNAMIC PROGRAMMING OBJECT

USE TSQLV3;

DECLARE  @S AS NVARCHAR(200);

SET @S = 'Davis';

DECLARE @sql AS NVARCHAR(1000);
SET @sql = N'SELECT empid, firstname, lastname, hiredate
FROM HR.Employees WHERE lastname = N''' + @s + N''';';

PRINT @SQL; 

EXEC (@SQL);
DECLARE  @S AS NVARCHAR(200);

SET @S = N'abc'' UNION ALL SELECT object_id, SCHEMA_NAME(schema_id), name, NULL
FROM sys.objects WHERE type IN (''U'', ''V''); --';


SELECT empid, firstname, lastname, hiredate
FROM HR.Employees WHERE lastname = N'abc' UNION ALL
SELECT object_id, SCHEMA_NAME(schema_id), name, NULL
FROM sys.objects WHERE type IN ('U', 'V'); --';


--SP_EXECUTESQL

DECLARE @s AS NVARCHAR(200);
SET @s = N'Davis';
DECLARE @sql AS NVARCHAR(1000);
SET @sql = 'SELECT empid, firstname, lastname, hiredate
FROM HR.Employees WHERE lastname = @lastname;';
PRINT @sql; -- For debug purposes
EXEC sp_executesql
@stmt = @sql,
@params = N'@lastname AS NVARCHAR(200)',
@lastname = @s;



--DYNAMIC PIVOTING 658


USE TSQLV3;
DECLARE
@cols AS NVARCHAR(1000),
@sql AS NVARCHAR(4000);
SET @cols =
STUFF(
(SELECT N',' + QUOTENAME(orderyear) AS [text()]
FROM (SELECT DISTINCT YEAR(orderdate) AS orderyear
FROM Sales.Orders) AS Years
ORDER BY orderyear
FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')
SET @sql = N'SELECT custid, ' + @cols + N'
FROM (SELECT custid, YEAR(orderdate) AS orderyear, val
FROM Sales.OrderValues) AS D
PIVOT(SUM(val) FOR orderyear IN(' + @cols + N')) AS P;';
EXEC sys.sp_executesql @stmt = @sql;


USE master;
GO
IF OBJECT_ID(N'dbo.sp_pivot', N'P') IS NOT NULL DROP PROC dbo.sp_pivot;
GO
CREATE PROC dbo.sp_pivot
@query AS NVARCHAR(MAX),
@on_rows AS NVARCHAR(MAX),
@on_cols AS NVARCHAR(MAX),
@agg_func AS NVARCHAR(257) = N'MAX',
@agg_col AS NVARCHAR(MAX)
AS
BEGIN TRY
-- Input validation
IF @query IS NULL OR @on_rows IS NULL OR @on_cols IS NULL
OR @agg_func IS NULL OR @agg_col IS NULL
THROW 50001, 'Invalid input parameters.', 1;
-- Additional input validation goes here (SQL injection attempts, etc.)
DECLARE
@sql AS NVARCHAR(MAX),
@cols AS NVARCHAR(MAX),
@newline AS NVARCHAR(2) = NCHAR(13) + NCHAR(10);
-- If input is a valid table or view
-- construct a SELECT statement against it
IF COALESCE(OBJECT_ID(@query, N'U'), OBJECT_ID(@query, N'V')) IS NOT NULL
SET @query = N'SELECT * FROM ' + @query;
-- Make the query a derived table
SET @query = N'(' + @query + N') AS Query';
-- Handle * input in @agg_col
IF @agg_col = N'*' SET @agg_col = N'1';
-- Construct column list
SET @sql =
N'SET @result = ' + @newline +
N' STUFF(' + @newline +
N' (SELECT N'',['' + '
+ 'CAST(pivot_col AS sysname) + '
+ 'N'']'' AS [text()]' + @newline +
N' FROM (SELECT DISTINCT('
+ @on_cols + N') AS pivot_col' + @newline +
N' FROM' + @query + N') AS DistinctCols' + @newline +
N' ORDER BY pivot_col'+ @newline +
N' FOR XML PATH('''')),'+ @newline +
N' 1, 1, N'''');'
EXEC sp_executesql
@stmt = @sql,
@params = N'@result AS NVARCHAR(MAX) OUTPUT',
@result = @cols OUTPUT;
-- Create the PIVOT query
SET @sql =
N'SELECT *' + @newline +
N'FROM (SELECT '
+ @on_rows
+ N', ' + @on_cols + N' AS pivot_col'
+ N', ' + @agg_col + N' AS agg_col' + @newline +
N' FROM ' + @query + N')' +
+ N' AS PivotInput' + @newline +
N' PIVOT(' + @agg_func + N'(agg_col)' + @newline +
N' FOR pivot_col IN(' + @cols + N')) AS PivotOutput;'
EXEC sp_executesql @sql;
END TRY
BEGIN CATCH
;THROW;
END CATCH;
GO


EXEC TSQLV3.dbo.sp_pivot
@query = N'Sales.Orders',
@on_rows = N'empid, YEAR(orderdate) AS orderyear',
@on_cols = N'MONTH(orderdate)',
@agg_func = N'COUNT',
@agg_col = N'*';


EXEC TSQLV3.dbo.sp_pivot
@query = N'SELECT O.orderid, empid, orderdate, qty, unitprice
FROM Sales.Orders AS O
INNER JOIN Sales.OrderDetails AS OD
ON OD.orderid = O.orderid',
@on_rows = N'empid',
@on_cols = N'YEAR(orderdate)',
@agg_func = N'SUM',
@agg_col = N'qty * unitprice';