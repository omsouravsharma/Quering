-- CHAPTER 8
SET COUNT ON; 

USE TSQLV3;

IF OBJECT_ID('DBO.SALESANALYSIS','V') IS NOT NULL DROP VIEW DBO.SALESANALYSIS;

GO

CREATE VIEW DBO.SALESANALYSIS
AS 


SELECT 
O.orderid,P.productid, C.country AS CUSTOMERCOUNTYRY, 

CASE

WHEN C.country IN ('Argentina', 'Brazil', 'Canada', 'Maxico', 'USA', 'Venezuela') then 'AMERICAS' 
ELSE 'EUROPE'
END AS CUSTOMERCONTINENT, 
E.country AS EMPLOYEECOUNTRY, 
PC.categoryname, YEAR(O.ORDERDATE) AS ORDERYEAR, 
DATEDIFF(DAY, O.requireddate, O.shippeddate) AS REQUIREDVSSHIPPED, 
OD.unitprice, OD.QTY, OD.discount, 
CAST(OD.unitprice*OD.qty AS numeric(10,2)) AS SALESAMOUNT, 
CAST(OD.unitprice * OD.qty*OD.discount AS numeric(10, 2)) AS DISCOUNTAMOUNT
FROM SALES.ORDERDETAILS AS OD
INNER JOIN SALES.ORDERS AS O ON OD.ORDERID =O.ORDERID
INNER JOIN SALES.CUSTOMERS AS C ON C.CUSTID =O.CUSTID
INNER JOIN PRODUCTION.PRODUCTS AS P ON OD.PRODUCTID =P.PRODUCTID
INNER JOIN PRODUCTION.CATEGORIES AS PC ON P.CATEGORYID = PC.CATEGORYID
INNER JOIN HR.EMPLOYEES AS E ON O.EMPID =E.empid


--FREQUENCIES


WITH FreqCTE AS
(
SELECT categoryname,
COUNT(categoryname) AS absfreq,
ROUND(100. * (COUNT(categoryname)) /
(SELECT COUNT(*) FROM dbo.SalesAnalysis), 4) AS absperc
FROM dbo.SalesAnalysis
GROUP BY categoryname
)
SELECT C1.categoryname,
C1.absfreq,
(SELECT SUM(C2.absfreq)
FROM FreqCTE AS C2
WHERE C2.categoryname <= C1.categoryname) AS cumfreq,
CAST(ROUND(C1.absperc, 0) AS INT) AS absperc,
CAST(ROUND((SELECT SUM(C2.absperc)
FROM FreqCTE AS C2
WHERE C2.categoryname <= C1.categoryname), 0) AS INT) AS cumperc,
CAST(REPLICATE('*',C1.absPerc) AS VARCHAR(100)) AS histogram
FROM FreqCTE AS C1
ORDER BY C1.categoryname;

--

WITH FreqCTE AS
(
SELECT categoryname,
COUNT(categoryname) AS absfreq,
ROUND(100. * (COUNT(categoryname)) /
(SELECT COUNT(*) FROM dbo.SalesAnalysis), 4) AS absperc
FROM dbo.SalesAnalysis
GROUP BY categoryname
)
SELECT categoryname,
absfreq,
SUM(absfreq)
OVER(ORDER BY categoryname
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW) AS cumfreq,
CAST(ROUND(absperc, 0) AS INT) AS absperc,
CAST(ROUND(SUM(absperc)
OVER(ORDER BY categoryname
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW), 0) AS INT) AS CumPerc,
CAST(REPLICATE('*',absperc) AS VARCHAR(50)) AS histogram
FROM FreqCTE
ORDER BY categoryname;


SELECT categoryname,
ROW_NUMBER() OVER(PARTITION BY categoryname
ORDER BY categoryname, orderid, productid) AS rn_absfreq,
ROW_NUMBER() OVER(
ORDER BY categoryname, orderid, productid) AS rn_cumfreq,
PERCENT_RANK()
OVER(ORDER BY categoryname) AS pr_absperc,
CUME_DIST()
OVER(ORDER BY categoryname, orderid, productid) AS cd_cumperc
FROM dbo.SalesAnalysis;


WITH FreqCTE AS
(
SELECT categoryname,
ROW_NUMBER() OVER(PARTITION BY categoryname
ORDER BY categoryname, orderid, productid) AS rn_absfreq,
ROW_NUMBER() OVER(
ORDER BY categoryname, orderid, productid) AS rn_cumfreq,
ROUND(100 * PERCENT_RANK()
OVER(ORDER BY categoryname), 4) AS pr_absperc,
ROUND(100 * CUME_DIST()
OVER(ORDER BY categoryname, orderid, productid), 4) AS cd_cumperc
FROM dbo.SalesAnalysis
)
SELECT categoryname,
MAX(rn_absfreq) AS absfreq,
MAX(rn_cumfreq) AS cumfreq,
ROUND(MAX(cd_cumperc) - MAX(pr_absperc), 0) AS absperc,
ROUND(MAX(cd_cumperc), 0) AS cumperc,
CAST(REPLICATE('*',ROUND(MAX(cd_cumperc) - MAX(pr_absperc),0)) AS
VARCHAR(100)) AS histogram
FROM FreqCTE
GROUP BY categoryname
ORDER BY categoryname;
GO

--DESCRIPTIVE STATISTICS FOR CONTINUOUS VARIABLES. 599


use TSQLV3

select	top (1)	 WITH TIES SALESAMOUNT, COUNT(*) AS NUMBER 
FROM DBO.SALESANALYSIS
GROUP BY SALESAMOUNT
ORDER BY COUNT(*) desc;

--MEDIAN

IF OBJECT_ID(N'dbo.TestMedian',N'U') IS NOT NULL
DROP TABLE dbo.TestMedian;
GO
CREATE TABLE dbo.TestMedian
(
val INT NOT NULL
);
GO
INSERT INTO dbo.TestMedian (val)
VALUES (1), (2), (3), (4);


SELECT DISTINCT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY VAL) OVER() AS MEDIANDISC, 
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY VAL) OVER() AS MEDIANCOUNT
FROM DBO.TestMedian


SELECT DISTINCT
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salesamount) OVER () AS median
FROM dbo.SalesAnalysis;


--MEAN


SELECT AVG(salesamount) AS mean
FROM dbo.SalesAnalysis;

--SPREAD OF DISTRIBUTION

--RANGE
SELECT max(SALESAMOUNT) - MIN(SALESAMOUNT)
FROM SALESANALYSIS

--INTER-QUARTUILE RANGE

--IOR - Q3-Q1


SELECT distiNCT
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SALESAMOUNT) over() - 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY SALESAMOUNT) over()  
FROM SALESANALYSIS


--MEAN ABSOLUTE DEVIATION 


DECLARE @MEAN AS NUMERIC(10,2)
SET @MEAN = (SELECT AVG(SALESAMOUNT) FROM SALESANALYSIS)

SELECT SUM(ABS(SALESAMOUNT - @MEAN))/COUNT(*) AS mad
FROM SALESANALYSIS


--MEAN SQUARED DEVIATION 
DECLARE @MEAN AS NUMERIC(10,2)
SET @MEAN = (SELECT AVG(SALESAMOUNT) FROM SALESANALYSIS)

SELECT SUM(sQUARE(SALESAMOUNT - @MEAN))/COUNT(*) AS mad
FROM SALESANALYSIS

--DEGREE OF FREEDOM AND VARIANCE

SELECT VAR(SALESAMOUNT) AS populationvariance,
VARP(SALESAMOUNT) AS samplevariance,
VARP(SALESAMOUNT) / VAR(SALESAMOUNT) AS samplevspopulation1,
(1.0 * COUNT(*) - 1) / COUNT(*) AS samplevspopulation2
FROM dbo.SalesAnalysis;

--STANDARD DEVIATION 
SELECT STDEV(salesamount) AS populationstdev,
STDEVP(salesamount) AS samplestdev,
STDEV(salesamount) / AVG(salesamount) AS CVsalesamount,
STDEV(discountamount) / AVG(discountamount) AS CVdiscountamount
FROM dbo.SalesAnalysis;


--HIGHER POPULATION MOMENTS

--SKEWNESS

WITH SkewCTE AS
(
SELECT SUM(salesamount) AS rx,
SUM(POWER(salesamount,2)) AS rx2,
SUM(POWER(salesamount,3)) AS rx3,
COUNT(salesamount) AS rn,
STDEV(salesamount) AS stdv,
AVG(salesamount) AS av
FROM dbo.SalesAnalysis
)
SELECT
(rx3 - 3*rx2*av + 3*rx*av*av - rn*av*av*av)
/ (stdv*stdv*stdv) * rn (rn-1) (rn-2) AS skewness
FROM SkewCTE;


--KURTOSIS

WITH KurtCTE AS
(
SELECT SUM(salesamount) AS rx,
SUM(POWER(salesamount,2)) AS rx2,
SUM(POWER(salesamount,3)) AS rx3,
SUM(POWER(salesamount,4)) AS rx4,
COUNT(salesamount) AS rn,
STDEV(salesamount) AS stdv,
AVG(salesamount) AS av
FROM dbo.SalesAnalysis
)
SELECT
(rx4 - 4*rx3*av + 6*rx2*av*av - 4*rx*av*av*av + rn*av*av*av*av)
/ (stdv*stdv*stdv*stdv) rn (rn+1) (rn-1) (rn-2) / (rn-3)
- 3.0 (rn-1) (rn-1) (rn-2) (rn-3) AS kurtosis
FROM KurtCTE;


-- LINEAR DEPENDENCIES

--Covarience: 

WITH CoVarCTE AS
(
SELECT salesamount as val1,
AVG(salesamount) OVER () AS mean1,
discountamount AS val2,
AVG(discountamount) OVER() AS mean2
FROM dbo.SalesAnalysis
)
SELECT
SUM((val1-mean1)*(val2-mean2)) / COUNT(*) AS covar
FROM CoVarCTE;


WITH CoVarCTE AS
(
SELECT salesamount as val1,
AVG(salesamount) OVER () AS mean1,
discountamount AS val2,
AVG(discountamount) OVER() AS mean2
FROM dbo.SalesAnalysis
)
SELECT
SUM((val1-mean1)*(val2-mean2)) / COUNT(*) AS covar,
(SUM((val1-mean1)*(val2-mean2)) / COUNT(*)) /
(STDEVP(val1) * STDEVP(val2)) AS correl,
SQUARE((SUM((val1-mean1)*(val2-mean2)) / COUNT(*)) /
(STDEVP(val1) * STDEVP(val2))) AS CD
FROM CoVarCTE;

623