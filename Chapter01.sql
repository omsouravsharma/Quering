

-- ORDER OF QUERY PROCESSING

--(5) SELECT (5-2) DISTINCT (7) TOP(<top_specification>) (5-1) <select_list>
--(1) FROM (1-J) <left_table> <join_type> JOIN <right_table> ON <on_predicate>
--(2) WHERE <where_predicate>
--(3) GROUP BY <group_by_specification>
--(4) HAVING <having_predicate>
--(6) ORDER BY <order_by_list>
--(7) OFFSET <offset_specification> ROWS FETCH NEXT <fetch_specification> ROWS ONLY;

SET NOCOUNT ON;
USE tempdb;

IF OBJECT_ID(N'dbo.orders',N'U') IS NOT NULL DROP TABLE dbo.orders;
IF OBJECT_ID(N'dbo.customers',N'U') IS NOT NULL DROP TABLE dbo.customers;

-- CREATING CUSTOMER TABLE

CREATE TABLE dbo.customers(
custid CHAR(5) NOT NULL,
city VARCHAR(10) NOT NULL, 
CONSTRAINT PK_Cutomers PRIMARY KEY(custid)
);

--CREATING ORDERS TABLE

CREATE TABLE dbo.Orders
(
orderid INT NOT NULL,
custid CHAR(5) NULL,
CONSTRAINT PK_Orders PRIMARY KEY(orderid),
CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
REFERENCES dbo.Customers(custid)
);

-- INSERTING DATA INTO CUSTOMER TABLE

INSERT INTO dbo.Customers(custid, city) VALUES
('FISSA', 'Madrid'),
('FRNDO', 'Madrid'),
('KRLOS', 'Madrid'),
('MRPHS', 'Zion' );

-- INSERTING DATA INTO ORDERS TABLE

INSERT INTO dbo.Orders(orderid, custid) VALUES
(1, 'FRNDO'),
(2, 'FRNDO'),
(3, 'KRLOS'),
(4, 'KRLOS'),
(5, 'KRLOS'),
(6, 'MRPHS'),
(7, NULL );

SELECT * FROM dbo.Customers;
SELECT * FROM dbo.Orders;

-- Q: MADRID CUSTOMERS WITH FEWER THAN THREE ORDERS 

SELECT C.custid, count(o.orderid) as numorder
FROM dbo.customers as C
RIGHT outer JOIN dbo.Orders O ON C.custid = O.custid
WHERE C.city = 'Madrid'
group by c.custid
having COUNT(o.orderid) < 3
order by numorder


SELECT C.custid, count(o.orderid) as numorder
FROM dbo.customers as C
LEFT  JOIN dbo.Orders O ON C.custid = O.custid
WHERE C.city = 'Madrid'
group by c.custid
having COUNT(o.orderid) < 3
order by numorder



-- Logical Values
SELECT c.*, o.*, 
CASE 
WHEN C.custid = O.custid THEN 'True'
WHEN c.custid IS NULL then 'Unknown'
WHEN O.custid IS NULL then 'Unknown'
ELSE 'False' 
END as 'Logical Value'
FROM dbo.customers as C
CROSS JOIN dbo.Orders O 



-- On predicate Logical Values
SELECT c.*, o.*, 
CASE 
WHEN C.custid = O.custid THEN 'True'
WHEN c.custid IS NULL then 'Unknown'
WHEN O.custid IS NULL then 'Unknown'
ELSE 'False' 
END as 'Logical Value'
FROM dbo.customers as C
CROSS JOIN dbo.Orders O 

WHERE (CASE 
WHEN C.custid = O.custid THEN 'True'
WHEN c.custid IS NULL then 'Unknown'
WHEN O.custid IS NULL then 'Unknown'
ELSE 'False' 
END) = 'True'

-- outer join

SELECT C.*, O.*
FROM dbo.customers as C
LEFT outer JOIN dbo.Orders O ON C.custid = O.custid
where c.city = 'Madrid'

-- group by 

SELECT C.custid, count(o.orderid), c.city
FROM dbo.customers as C
LEFT outer JOIN dbo.Orders O ON C.custid = O.custid
where c.city = 'Madrid'
group by c.custid, c.city
having COUNT(o.orderid) <3



--Distict 
select * from Orders

select Distinct  custid, ROW_NUMBER() OVER (ORDER BY custid) as num
from orders
where custid is not null

-- Phase evaluate 5-1 before all duplicates are removed 


--If you want to get assign row number after duplicate removal you can use CTE (Common Table Expression)


WITH C AS 
(
SELECT DISTINCT CUSTID 
FROM Orders
WHERE custid IS NOT NULL)

SELECT CUSTID, ROW_NUMBER() OVER(ORDER BY CUSTID) AS NUM
FROM C


-- ORDER BY 

SELECT custid, orderid
FROM Orders
ORDER BY  custid, orderid

-- NULL ARE CONSIDERS LOWERS

-- CURSOR 

SELECT CUSTID, ORDERID
FROM
(SELECT custid, orderid
FROM Orders
ORDER BY  custid, orderid)D

--The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.

-- SIMILARLY VIEW CANNOT BE CREATED WITH ORDER BY 

CREATE VIEW DBO.MYORDERS AS

SELECT custid, orderid
FROM Orders
ORDER BY  custid, orderid

-- USIGN ALIAS FROM SELECT 

SELECT C.custid, count(o.orderid) as numorder
FROM dbo.customers as C
LEFT  JOIN dbo.Orders O ON C.custid = O.custid
WHERE C.city = 'Madrid'
group by c.custid
having COUNT(o.orderid) < 3
order by numorder DESC

-- TOP OR OFFET FECTH FILTER

--TOP 
SELECT TOP 3 custid, orderid
FROM Orders
ORDER BY orderid DESC

-- OFFSET-FETCH NEXT

SELECT custid, orderid
FROM Orders
ORDER BY orderid DESC
OFFSET 4 ROWS FETCH NEXT 2 ROWS ONLY


--ORDERING IS NOT GAURENTEE IF OUTER MOST QUERY DOES NOT HAVE ORDER BY CLAUSE

SELECT CUSTID, ORDERID
FROM
(SELECT TOP 3 custid, orderid
FROM Orders
ORDER BY orderid desc
)D


-- AN ANTTEMPT TO CREATE A SORETED VIEW 
IF OBJECT_ID(N'DBO.MYORDERS', N'V') IS NOT NULL DROP VIEW DBO.MYORDERS;
GO

CREATE VIEW DBO.MYORDERS
AS
SELECT TOP (100) PERCENT orderid, custid
FROM dbo.Orders
ORDER BY orderid DESC;
GO


SELECT CUSTID, ORDERID FROM DBO.MYORDERS	

-- EXPECTED RESULT IS TO GET ORDERID IN DESC ORDER


--SIMILARLY WITH OFFSET AND FETCH

IF OBJECT_ID(N'DBO.MYORDERS', N'V') IS NOT NULL DROP VIEW DBO.MYORDERS;
GO

CREATE VIEW DBO.MYORDERS
AS 
SELECT orderid, custid
FROM Orders
ORDER BY orderid DESC
OFFSET 0 ROWS

SELECT orderid, custid FROM MYORDERS


--TABLE OPERATORS 

--(JOIN) <left_input_table>
--	{CROSS | INNER | OUTER} JOIN <right_input_table>
--	ON <on_predicate>
--(APPLY) <left_input_table>
--	{CROSS | OUTER} APPLY <right_input_table>
--(PIVOT) <left_input_table>
--	PIVOT (<aggregate_func(<aggregation_element>)> FOR
--	<spreading_element> IN(<target_col_list>))
--	AS <result_table_alias>
--(UNPIVOT) <left_input_table>
--	UNPIVOT (<target_values_col> FOR
--	<target_names_col> IN(<source_col_list>))
--	AS <result_table_alias>

-- UNION, EXCEPT, INTERSECT OPERATORS 

--(1) query1
--(2) <operator>
--(1) query2
--(3) [ORDER BY <order_by_list>]