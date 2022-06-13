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
