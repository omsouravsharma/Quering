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

-- Pg 34

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

select *,
count(*) OVER ()

from Orders
