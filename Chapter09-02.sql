--TRIGGER 
-- After DML Tigger INSERT, UPDATE, DELETE

SET NOCOUNT ON;
USE tempdb;
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
CREATE TABLE dbo.T1
(
keycol INT NOT NULL IDENTITY
CONSTRAINT PK_T1 PRIMARY KEY,
datacol VARCHAR(10) NOT NULL,
lastmodified DATETIME2 NOT NULL
CONSTRAINT DFT_T1_lastmodified DEFAULT(SYSDATETIME())
);

CREATE TRIGGER TRG_T1_U ON T1 AFTER UPDATE
AS 
UPDATE T1 
SET lastmodified = SYSDATETIME()
FROM DBO.T1
INNER JOIN inserted AS I 
ON I.keycol = T1.keycol
GO


EXEC sp_configure 'nested triggers', 0;
RECONFIGURE;


--INSTEAD OF DML TRIGGER

-- AFTER DDL TRIGGERS

USE master;
IF DB_ID(N'testdb') IS NOT NULL DROP DATABASE testdb;
CREATE DATABASE testdb;
GO
USE testdb;


IF OBJECT_ID(N'dbo.AuditDDLEvents', N'U') IS NOT NULL
DROP TABLE dbo.AuditDDLEvents;
CREATE TABLE dbo.AuditDDLEvents
(
auditlsn INT NOT NULL IDENTITY,
posttime DATETIME NOT NULL,
eventtype sysname NOT NULL,
loginname sysname NOT NULL,
schemaname sysname NOT NULL,
objectname sysname NOT NULL,
targetobjectname sysname NULL,
eventdata XML NOT NULL,
CONSTRAINT PK_AuditDDLEvents PRIMARY KEY(auditlsn)
);



CREATE TRIGGER trg_audit_ddl_events ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
AS
SET NOCOUNT ON;
DECLARE @eventdata AS XML = eventdata();
INSERT INTO dbo.AuditDDLEvents(
posttime, eventtype, loginname, schemaname, objectname, targetobjectname,
eventdata)
VALUES( @eventdata.value('(/EVENT_INSTANCE/PostTime)
[1]', 'VARCHAR(23)'),
@eventdata.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname'),
@eventdata.value('(/EVENT_INSTANCE/LoginName)[1]', 'sysname'),
@eventdata.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname'),
@eventdata.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname'),
@eventdata.value('(/EVENT_INSTANCE/TargetObjectName)[1]', 'sysname'),
@eventdata );
GO


CREATE TABLE dbo.T1(col1 INT NOT NULL PRIMARY KEY);
ALTER TABLE dbo.T1 ADD col2 INT NULL;
ALTER TABLE dbo.T1 ALTER COLUMN col2 INT NOT NULL;
CREATE NONCLUSTERED INDEX idx1 ON dbo.T1(col2);


SELECT * FROM dbo.AuditDDLEvents;