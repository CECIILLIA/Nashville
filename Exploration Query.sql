USE [master]
GO

/****** Object:  Table [dbo].[Housing]    Script Date: 5/11/2023 1:21:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Housing](
	[UniqueID ] [float] NULL,
	[ParcelID] [nvarchar](255) NULL,
	[LandUse] [nvarchar](255) NULL,
	[SalePrice] [float] NULL,
	[LegalReference] [nvarchar](255) NULL,
	[SoldAsVacant] [nvarchar](255) NULL,
	[OwnerName] [nvarchar](255) NULL,
	[Acreage] [float] NULL,
	[TaxDistrict] [nvarchar](255) NULL,
	[LandValue] [float] NULL,
	[BuildingValue] [float] NULL,
	[TotalValue] [float] NULL,
	[YearBuilt] [float] NULL,
	[Bedrooms] [float] NULL,
	[FullBath] [float] NULL,
	[HalfBath] [float] NULL,
	[SaleDate] [date] NULL,
	[HouseAddress] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[OwnerHouse] [nvarchar](255) NULL,
	[OwnerCity] [nvarchar](255) NULL,
	[OwnerState] [nvarchar](255) NULL
) ON [PRIMARY]
GO

---------------------------------------------------------------------------------------
---Viewing the Table
--------------------
SELECT *
FROM Housingg

-- Grouping the Land Use
------------------------
SELECT DISTINCT LandUse, COUNT(LandUse) AS Total
FROM Housingg
GROUP BY LandUse 
Order by Total DESC


-- The Average SalesPrice of the Land by Use
--------------------------------------------
SELECT DISTINCT LandUse, AVG(SalePrice) OVER(PARTITION BY LandUse) AS AveragePrices
FROM Housingg
ORDER BY AveragePrices DESC

-- The Number of lands that have been sold and are vacant
---------------------------------------------------------
SELECT SoldAsVacant, COUNT(SoldAsVacant) AS Total
FROM Housingg
GROUP BY SoldAsVacant

-- Selecting Owners with the highest Number of Parcels of Land and land Acres
-----------------------------------------------------------------------------
SELECT DISTINCT OwnerName, 
	   SUM(Acreage) OVER(PARTITION BY  OwnerName) AS TotalAcreage,
	   COUNT(ParcelID) OVER(PARTITION BY  OwnerName) AS TotalParcelID	   
FROM Housingg
ORDER BY TotalAcreage DESC

-- Viewing Tax Districts 
-------------------------
SELECT DISTINCT TaxDistrict, SUM(UniqueID) OVER(PARTITION BY  TaxDistrict) AS TotalTaxDistrict
FROM Housingg
ORDER BY TotalTaxDistrict DESC

--How many property was sold in each year
----------------------------------------
/*Extracting the date*/
SELECT PARSENAME(REPLACE(SaleDate, '-','.'), 3) AS SaleYear
FROM Housingg
/*Update the table*/
ALTER TABLE Housingg
ADD SaleYearr nvarchar(255)
/*Update the table*/
UPDATE Housingg
SET SaleYearr = PARSENAME(REPLACE(SaleDate, '-','.'), 3)


SELECT DISTINCT SaleYearr, COUNT(SaleYearr) AS Total
FROM Housingg
GROUP BY SaleYearr
ORDER BY Total DESC



