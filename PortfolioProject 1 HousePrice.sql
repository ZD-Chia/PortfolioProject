SELECT * 
FROM PortfolioProject..houseprice
ORDER BY 1,2

SELECT * 
FROM PortfolioProject..housetype
ORDER BY 1,2


-- select the data that going to be use to check the relationship to house price

SELECT t.Id, t.MSZoning, t.LotArea, t.Neighborhood, t.BldgType, t.HouseStyle, t.OverallCond, t.YearBuilt, ROUND(p.SalePrice,2) AS SalePrice
FROM PortfolioProject..housetype t
JOIN PortfolioProject..housePrice p
	ON p.Id = t.Id
ORDER BY t.Neighborhood


-- Total house in each neighborhood

SELECT COUNT(Id) AS NumberOfHouse, Neighborhood
FROM PortfolioProject..housetype
GROUP BY Neighborhood
ORDER BY Neighborhood

-- Looking for the oldest and newest house in each neighborhood
SELECT COUNT(Id) AS NumberOfHouse, MIN(YearBuilt) AS OldestUnit, MAX(YearBuilt) AS NewestUnit, Neighborhood
FROM PortfolioProject..housetype
GROUP BY Neighborhood
ORDER BY Neighborhood

-- looking for the number of house for each of the bldgtype in each neighborhood
SELECT COUNT(Id) AS NumberOfHouse, BldgType, Neighborhood
FROM PortfolioProject..housetype
GROUP BY BldgType, Neighborhood
ORDER BY Neighborhood

-- looking for the lotarea range in each neighborhood
SELECT COUNT(Id) AS NumberOfHouse, MIN(LotArea) AS SmallestUnitSize, MAX(LotArea) AS LargestUnitSize, Neighborhood
FROM PortfolioProject..housetype
GROUP BY Neighborhood
ORDER BY Neighborhood

-- looking for the number of house for each of the lotarea range
SELECT l.range as [LotAreaRange] , COUNT(*) AS NumberOfHouse
FROM (
	SELECT CASE
		WHEN LotArea between 1000 and 1999 then '1000+'
		WHEN LotArea between 2000 and 2999 then '2000+'
		WHEN LotArea between 3000 and 3999 then '3000+'
		WHEN LotArea between 4000 and 4999 then '4000+'
		WHEN LotArea between 5000 and 5999 then '5000+'
		WHEN LotArea between 6000 and 6999 then '6000+'
		WHEN LotArea between 7000 and 7999 then '7000+'
		WHEN LotArea between 8000 and 8999 then '8000+'
		WHEN LotArea between 9000 and 9999 then '9000+'
		ELSE '10000+' END AS range
	FROM PortfolioProject..housetype) l
	   GROUP BY l.range 
	   ORDER BY l.range 


-- Check total number of building type and style in each neighborhood
SELECT  COUNT( DISTINCT BldgType) AS TotalTypeOfHouse, COUNT( DISTINCT HouseStyle) AS TotalStyleOfHouse,  Neighborhood
FROM PortfolioProject..housetype
GROUP BY Neighborhood



-- Looking for lowest and highest house price in each neighborhood
SELECT MIN(ROUND(p.SalePrice, 2)) AS LowestHousePrice, MAX(ROUND(p.Saleprice, 2)) AS HighestHousePrice, Neighborhood
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id
GROUP BY Neighborhood
ORDER BY Neighborhood

-- Checking zoning vs price
SELECT t.MSZoning, MIN(ROUND(p.SalePrice, 2)) AS LowestHousePrice, MAX(ROUND(p.Saleprice, 2)) AS HighestHousePrice
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id
GROUP BY MSZoning
ORDER BY MSZoning

--Calculate average per square foot price(psf) in each neighborhood

WITH PSF AS
(
SELECT  t.Neighborhood AS Neighborhood, SUM(p.SalePrice) AS TotalPrice, SUM(t.LotArea) AS TotalArea
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id
GROUP BY Neighborhood

)
SELECT Neighborhood, ROUND(TotalPrice/TotalArea, 2) AS AveragePSF
FROM PSF
ORDER BY Neighborhood

--check the average psf in each zoning
WITH PSF AS
(
SELECT  t.MSZoning AS MSZoning, SUM(p.SalePrice) AS TotalPrice, SUM(t.LotArea) AS TotalArea
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id
GROUP BY MSZoning	
)
SELECT MSZoning, ROUND(TotalPrice/TotalArea, 2) AS AveragePSF
FROM PSF
ORDER BY MSZoning

-- Checking psf for different house style, building type in each neighborhood

SELECT  t.HouseStyle AS HouseStyle, t.BldgType AS BldgType, ROUND(p.SalePrice/t.LotArea, 2) AS PSF, t.Neighborhood AS Neighborhood
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id
ORDER BY t.Neighborhood

--Lowest and Highest PSF for each house style
WITH PSF AS
(
SELECT  t.HouseStyle AS HouseStyle, ROUND(p.SalePrice/t.LotArea, 2) AS PSF
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id

)
SELECT HouseStyle, MIN(PSF) AS LowestPSF, MAX(PSF) AS HighestPSF
FROM PSF
GROUP BY HouseStyle

-- Average PSF of each hosue style
WITH PSF AS
(
SELECT  t.HouseStyle AS HouseStyle, SUM(p.SalePrice) AS TotalPrice, SUM(t.LotArea) AS TotalArea
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id
GROUP BY HouseStyle	
)
SELECT HouseStyle, ROUND(TotalPrice/TotalArea, 2) AS AveragePSF
FROM PSF
ORDER BY HouseStyle

--Check overall condition of house vs psf
SELECT  t.OverallCond AS OverallCond, ROUND(p.SalePrice/t.LotArea, 2) AS PSF, t.Neighborhood AS Neighborhood
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id
ORDER BY t.Neighborhood


--TEMP TABLE

DROP TABLE IF exists #PSF_of_each_house
CREATE TABLE #PSF_of_each_house
(
MSZoning varchar(255),
LotArea numeric,
Neightborhood varchar(255),
BldgType varchar(255),
HouseStyle varchar(255),
OverallCond numeric,
PSF decimal
)

INSERT INTO #PSF_of_each_house (MSZoning, LotArea, Neightborhood, BldgType, HouseStyle, OverallCond,  PSF)
SELECT t.MSZoning, t.LotArea, t.Neighborhood, t.BldgType, t.HouseStyle, t.OverallCond, ROUND(p.SalePrice/t.LotArea, 2) AS PSF
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id

SELECT * 
FROM #PSF_of_each_house
ORDER BY Neightborhood



-- Creating View to store dat for visualisation

USE PortfolioProject
GO
CREATE View PSF_of_each_house AS
SELECT t.MSZoning, t.LotArea, t.Neighborhood, t.BldgType, t.HouseStyle, t.OverallCond, ROUND(p.SalePrice/t.LotArea, 2) AS PSF
FROM PortfolioProject..HousePrice p
JOIN PortfolioProject..housetype t
	ON p.Id = t.Id
