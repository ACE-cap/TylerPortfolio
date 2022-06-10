--Getting familiar with the rows and columns
SELECT TOP 5 *
FROM [PortfolioProject2]..FinancialData

SELECT DISTINCT type
FROM PortfolioProject2..FinancialData

--Renaming step column and one other column due to typo
EXEC sp_rename 'dbo.FinancialData.step', 'HourofMonth', 'COLUMN'
EXEC sp_rename 'dbo.FinancialData.oldbalanceOrg', 'OldBalanceOrig', 'COLUMN'

--Converting step column datatype
ALTER TABLE [PortfolioProject2]..FinancialData ALTER COLUMN HourofMonth int

--Converting the other columns datatypes as well for easier querying
ALTER TABLE [PortfolioProject2]..FinancialData ALTER COLUMN amount DECIMAL (20,2)
ALTER TABLE [PortfolioProject2]..FinancialData ALTER COLUMN oldbalanceorig DECIMAL (20,2)
ALTER TABLE [PortfolioProject2]..FinancialData ALTER COLUMN newbalanceorig DECIMAL (20,2)
ALTER TABLE [PortfolioProject2]..FinancialData ALTER COLUMN oldbalancedest DECIMAL (20,2)
ALTER TABLE [PortfolioProject2]..FinancialData ALTER COLUMN newbalancedest DECIMAL (20,2)
--had some issues with converting these datatypes and not enough time to troubleshoot it
--so I will move forward for now without worrying about it

--converting the fraud columns to int
ALTER TABLE [PortfolioProject2]..FinancialData ALTER COLUMN isFraud int
ALTER TABLE [PortfolioProject2]..FinancialData ALTER COLUMN isFlaggedFraud int

--Viewing all transactions that were flagged fraud but was not actually fraud to check for false positives

SELECT COUNT(*) AS False_Positive
FROM PortfolioProject2..financialdata
WHERE isfraud = 0 and isflaggedfraud = 1
--this returned zero results so we can see that the flags are working well

----Viewing all transactions that were fraud but were not flagged. Also checking transactions that were fraud and flagged
SELECT * FROM PortfolioProject2..financialdata
WHERE isfraud = 1 and isflaggedfraud = 0

SELECT * FROM PortfolioProject2..financialdata
WHERE isfraud = 1 and isflaggedfraud = 1

--Drilling down to see which percentage of transactions that were fraud, did not get flagged for fraud
--Viewing how many total transactions that are transfers or cash_outs that are NOT fraud
SELECT * FROM PortfolioProject2..financialdata
WHERE isfraud = 0 and type = 'transfer' or type = 'cash_out'

--Counting number of rows that's fraud but wasn't flagged and vice versa
SELECT COUNT(*) AS FraudNotFlagged
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 and isflaggedfraud = 0

SELECT COUNT(*) AS FraudAndFlagged
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 and isflaggedfraud = 1

--Getting the percentage of transactions that are fraud but did not get flagged
SELECT
(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 and isflaggedfraud = 0)
/
(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 ) * 100 AS 'Percent_Unflagged'

--Getting count of total fraud transactions
SELECT COUNT(*) AS FraudTransactions
FROM PortfolioProject2..financialdata
WHERE isfraud = 1

--Getting count of flagged fraud
SELECT COUNT(*) AS Flagged_Fraud
FROM PortfolioProject2..financialdata
WHERE isflaggedfraud = 1

--


--Total Sum of fraudulent transactions
SELECT SUM(CAST(amount as float)) as TotalFraudAmount
FROM PortfolioProject2..FinancialData
WHERE isfraud = 1 

--Sum of fraudulent transactions grouped by receiving account
SELECT nameDest, 
SUM(CAST(amount as float)) as TotalFraudAmount
FROM PortfolioProject2..FinancialData
WHERE isfraud = 1 
GROUP BY nameDest
--ORDER BY TotalFraudAmount desc

--Percentage of all transactions this month that were fraudulent
SELECT
(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1)
/
(SELECT (COUNT(*))
FROM PortfolioProject2..financialdata) * 100 AS 'Percent_Fraud'

--Converting the HourofMonth to days of week 
ALTER TABLE PortfolioProject2..FinancialData
ADD DayofWeek varchar(20);

	UPDATE PortfolioProject2..FinancialData
	SET DayofWeek = 'Monday'
WHERE HourOfMonth Between 1 AND 24
	OR HourofMonth Between 169 AND 192
	OR HourofMonth Between 337 AND 360
	OR HourofMonth Between 505 AND 528
	OR HourofMonth Between 673 AND 696;
	
UPDATE PortfolioProject2..FinancialData
SET DayofWeek = 'Tuesday'
 WHERE HourOfMonth Between 25 AND 48
	OR HourofMonth Between 193 AND 216
	OR HourofMonth Between 361 AND 384
	OR HourofMonth Between 529 AND 552
	OR HourofMonth Between 697 AND 720;
	
	UPDATE PortfolioProject2..FinancialData
SET DayofWeek = 'Wednesday'
 WHERE HourOfMonth Between 49 AND 72
	OR HourofMonth Between 217 AND 240
	OR HourofMonth Between 385 AND 408
	OR HourofMonth Between 553 AND 576
	OR HourofMonth Between 721 AND 743;
	
	UPDATE PortfolioProject2..FinancialData
SET DayofWeek = 'Thursday'
 WHERE HourOfMonth Between 73 AND 96
	OR HourofMonth Between 241 AND 264
	OR HourofMonth Between 409 AND 432
	OR HourofMonth Between 577 AND 600;
	
	UPDATE PortfolioProject2..FinancialData
SET DayofWeek = 'Friday'
 WHERE HourOfMonth Between 97 AND 120
	OR HourofMonth Between 265 AND 288
	OR HourofMonth Between 433 AND 456
	OR HourofMonth Between 601 AND 624;
	
	UPDATE PortfolioProject2..FinancialData
SET DayofWeek = 'Saturday'
 WHERE HourOfMonth Between 121 AND 144
	OR HourofMonth Between 289 AND 312
	OR HourofMonth Between 457 AND 480
	OR HourofMonth Between 625 AND 648;
	
	UPDATE PortfolioProject2..FinancialData
SET DayofWeek = 'Sunday'
 WHERE HourOfMonth Between 145 AND 168
	OR HourofMonth Between 313 AND 336
	OR HourofMonth Between 481 AND 504
	OR HourofMonth Between 649 AND 672;
--Verifying all rows in the new column have a value
SELECT * FROM FinancialData
WHERE DayofWeek = NULL

--Trying to see if a certain day of the week had a higher percentage of fraud transactions
SELECT
	(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 AND DayofWeek = 'Monday')
/
(SELECT (COUNT(*))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1) * 100 AS 'Monday_Percentage',

	(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 AND DayofWeek = 'Tuesday')
/
(SELECT (COUNT(*))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1) * 100 AS 'Tuesday_Percentage',

(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 AND DayofWeek = 'Wednesday')
/
(SELECT (COUNT(*))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1) * 100 AS 'Wednesday_Percentage',

(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 AND DayofWeek = 'Thursday')
/
(SELECT (COUNT(*))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1) * 100 AS 'Thursday_Percentage',

(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 AND DayofWeek = 'Friday')
/
(SELECT (COUNT(*))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1) * 100 AS 'Friday_Percentage',

(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 AND DayofWeek = 'Saturday')
/
(SELECT (COUNT(*))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1) * 100 AS 'Saturday_Percentage',

(SELECT CAST(COUNT(*) AS DECIMAL(8,4))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1 AND DayofWeek = 'Sunday')
/
(SELECT (COUNT(*))
FROM PortfolioProject2..financialdata
WHERE isfraud = 1) * 100 AS 'Sunday_Percentage';


--
