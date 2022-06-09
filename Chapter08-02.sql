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