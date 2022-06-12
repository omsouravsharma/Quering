--LINEAR REGRESSION

WITH CoVarCTE AS
(
SELECT salesamount as val1,
AVG(salesamount) OVER () AS mean1,
discountamount AS val2,
AVG(discountamount) OVER() AS mean2
FROM dbo.SalesAnalysis
)
SELECT Slope1=
SUM((val1 - mean1) * (val2 - mean2))
/SUM(SQUARE((val1 - mean1))),
Intercept1=
MIN(mean2) - MIN(mean1) *
(SUM((val1 - mean1)*(val2 - mean2))
/SUM(SQUARE((val1 - mean1)))),
Slope2=
SUM((val1 - mean1) * (val2 - mean2))
/SUM(SQUARE((val2 - mean2))),
Intercept2=
MIN(mean1) - MIN(mean2) *
(SUM((val1 - mean1)*(val2 - mean2))
/SUM(SQUARE((val2 - mean2))))
FROM CoVarCTE;

SELECT categoryname, [USA],[UK]
FROM (SELECT categoryname, employeecountry, orderid FROM dbo.SalesAnalysis) AS
S
PIVOT(COUNT(orderid) FOR employeecountry
IN([USA],[UK])) AS P
ORDER BY categoryname;



WITH
ObservedCombination_CTE AS
(
SELECT categoryname, employeecountry, COUNT(*) AS observed
FROM dbo.SalesAnalysis
GROUP BY categoryname, employeecountry
),
ObservedFirst_CTE AS
(
SELECT categoryname, NULL AS employeecountry, COUNT(*) AS observed
FROM dbo.SalesAnalysis
GROUP BY categoryname
),
ObservedSecond_CTE AS
(
SELECT NULL AS categoryname, employeecountry, COUNT(*) AS observed
FROM dbo.SalesAnalysis
GROUP BY employeecountry
),
ObservedTotal_CTE AS
(
SELECT NULL AS categoryname, NULL AS employeecountry, COUNT(*) AS observed
FROM dbo.SalesAnalysis
),
ExpectedCombination_CTE AS
(
SELECT F.categoryname, S.employeecountry,
CAST(ROUND(F.observed *S.observed / T.observed, 0) AS INT) AS expected
FROM ObservedFirst_CTE AS F
CROSS JOIN ObservedSecond_CTE AS S
CROSS JOIN ObservedTotal_CTE AS T
),
ObservedExpected_CTE AS
(
SELECT O.categoryname, O.employeecountry, O.observed, E.expected
FROM ObservedCombination_CTE AS O
INNER JOIN ExpectedCombination_CTE AS E
ON O.categoryname = E.categoryname
AND O.employeecountry = E.employeecountry
)
SELECT * FROM ObservedExpected_CTE;


WITH ObservedCombination_CTE AS
(
SELECT categoryname AS onrows,
employeecountry AS oncols,
COUNT(*) AS observedcombination
FROM dbo.SalesAnalysis
GROUP BY categoryname, employeecountry
),
ExpectedCombination_CTE AS
(
SELECT onrows, oncols, observedcombination,
SUM(observedcombination) OVER (PARTITION BY onrows) AS observedonrows,
SUM(observedcombination) OVER (PARTITION BY oncols) AS observedoncols,
SUM(observedcombination) OVER () AS observedtotal,
CAST(ROUND(SUM(1.0 * observedcombination) OVER (PARTITION BY onrows)
* SUM(1.0 * observedcombination) OVER (PARTITION BY oncols)
/ SUM(1.0 * observedcombination) OVER (), 0) AS INT) AS expectedcombination
FROM ObservedCombination_CTE
)
SELECT SUM(SQUARE(observedcombination - expectedcombination)
/ expectedcombination) AS chisquared,
(COUNT(DISTINCT onrows) - 1) * (COUNT(DISTINCT oncols) - 1) AS
degreesoffreedom
FROM ExpectedCombination_CTE;

--ANOVA ANALYSIS OF VARIENCE

WITH ObservedCombination_CTE AS
(
SELECT categoryname AS onrows,
employeecountry AS oncols,
COUNT(*) AS observedcombination
FROM dbo.SalesAnalysis
GROUP BY categoryname, employeecountry
),
ExpectedCombination_CTE AS
(
SELECT onrows, oncols, observedcombination,
SUM(observedcombination) OVER (PARTITION BY onrows) AS observedonrows,
SUM(observedcombination) OVER (PARTITION BY oncols) AS observedoncols,
SUM(observedcombination) OVER () AS observedtotal,
CAST(ROUND(SUM(1.0 * observedcombination) OVER (PARTITION BY onrows)
* SUM(1.0 * observedcombination) OVER (PARTITION BY oncols)
/ SUM(1.0 * observedcombination) OVER (), 0) AS INT) AS expectedcombination
FROM ObservedCombination_CTE
)
SELECT SUM(SQUARE(observedcombination - expectedcombination)
/ expectedcombination) AS chisquared,
(COUNT(DISTINCT onrows) - 1) * (COUNT(DISTINCT oncols) - 1) AS
degreesoffreedom
FROM ExpectedCombination_CTE;

--633 

CREATE TABLE #StdNormDist
(z0 DECIMAL(3,2) NOT NULL,
yz DECIMAL(10,9) NOT NULL);
GO
-- Insert the data
DECLARE @z0 DECIMAL(3,2), @yz DECIMAL(10,9);
SET @z0=-4.00;
WHILE @z0 <= 4.00
BEGIN
SET @yz=1.00/SQRT(2.00*PI())*EXP((-1.00/2.00)*SQUARE(@z0));
INSERT INTO #StdNormDist(z0,yz) VALUES(@z0, @yz);
SET @z0=@z0+0.01;
END
GO

WITH ZvaluesCTE AS
(
SELECT z0, yz,
FIRST_VALUE(yz) OVER(ORDER BY z0 ROWS UNBOUNDED PRECEDING) AS fyz,
LAST_VALUE(yz)
OVER(ORDER BY z0
ROWS BETWEEN CURRENT ROW
AND UNBOUNDED FOLLOWING) AS lyz
FROM #StdNormDist
WHERE z0 >= 0 AND z0 <= 1
)
SELECT 
100.0 *((0.01 / 2.0) *(SUM(2 * yz) - MIN(fyz) - MAX(lyz))) AS pctdistribution
FROM ZvaluesCTE;


WITH ZvaluesCTE AS
(
SELECT z0, yz,
FIRST_VALUE(yz) OVER(ORDER BY z0 ROWS UNBOUNDED PRECEDING) AS fyz,
LAST_VALUE(yz)
OVER(ORDER BY z0
ROWS BETWEEN CURRENT ROW
AND UNBOUNDED FOLLOWING) AS lyz
FROM #StdNormDist
WHERE z0 >= 0 AND z0 <= 1.96
)
SELECT 50 - 100.0* ((0.01 / 2.0) *(SUM(2 * yz) - MIN(fyz) - MAX(lyz))) AS
pctdistribution
FROM ZvaluesCTE;

--Moving Average and Entropy
CREATE TABLE dbo.MAvg
(id INT NOT NULL IDENTITY(1,1),
val FLOAT NULL);
GO
INSERT INTO dbo.MAvg(val) VALUES
(1), (2), (3), (4), (1), (2), (3), (4), (1), (2);
GO


SELECT ID, VAL, 
ROUND(aVG(VAL) OVER(ORDER BY ID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS SMA
FROM DBO.MAvg
ORDER BY ID;

DECLARE @A AS FLOAT;
SET @A = 0.7;
SELECT id, val, 

LAG(VAL, 1, val) OVER (ORDER BY id) AS prevval,
@A  VAL + (1 - @A)
(LAG(val, 1, val) OVER (ORDER BY id)) AS WMA
FROM dbo.MAvg
ORDER BY id;


DECLARE @CurrentEMA AS FLOAT, @PreviousEMA AS FLOAT,
@Id AS INT, @Val AS FLOAT,
@A AS FLOAT;
DECLARE @Results AS TABLE(id INT, val FLOAT, EMA FLOAT);
SET @A = 0.7;
DECLARE EMACursor CURSOR FOR
SELECT id, val
FROM dbo.MAvg
ORDER BY id;
OPEN EMACursor;
FETCH NEXT FROM EMACursor
INTO @Id, @Val;
SET @CurrentEMA = @Val;
SET @PreviousEMA = @CurrentEMA;
WHILE @@FETCH_STATUS = 0
BEGIN
SET @CurrentEMA = ROUND(@A @Val + (1-@A) @PreviousEMA, 2);
INSERT INTO @Results (id, val, EMA)
VALUES(@Id, @Val, @CurrentEMA);
SET @PreviousEMA = @CurrentEMA;
FETCH NEXT FROM EMACursor
INTO @Id, @Val;
END;
CLOSE EMACursor;
DEALLOCATE EMACursor;
SELECT id, val, EMA
FROM @Results;
GO

--ENTROPY

SELECT (-1) *(0.1*LOG(0.1,2) + 0.9*LOG(0.9,2)) AS unequaldistribution,
(-1) *(0.5*LOG(0.5,2) + 0.5*LOG(0.5,2)) AS equaldistribution


SELECT (-1)*(2)*(1.0/2)*LOG(1.0/2,2) AS TwoStatesMax,
(-1)*(3)*(1.0/3)*LOG(1.0/3,2) AS ThreeStatesMax,
(-1)*(4)*(1.0/4)*LOG(1.0/4,2) AS FourStatesMax;

SELECT LOG(2,2) AS TwoStatesMax,
LOG(3,2) AS ThreeStatesMax,
LOG(4,2) AS FourStatesMax;


WITH ProbabilityCTE AS
(
SELECT customercountry,
COUNT(customercountry) AS StateFreq
FROM dbo.SalesAnalysis
WHERE customercountry IS NOT NULL
GROUP BY customercountry
),
StateEntropyCTE AS
(
SELECT customercountry,
1.0*StateFreq / SUM(StateFreq) OVER () AS StateProbability
FROM ProbabilityCTE
)

SELECT (-1)*SUM(StateProbability * LOG(StateProbability,2)) AS TotalEntropy,
LOG(COUNT(*),2) AS MaxPossibleEntropy,
100 ((-1)SUM(StateProbability * LOG(StateProbability,2))) /
(LOG(COUNT(*),2)) AS PctOfMaxPossibleEntropy
FROM StateEntropyCTE;

--652