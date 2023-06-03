--------------------------------------- DATA CLEANING FOR HOUSING DATA ------------------------------------------------

SELECT *
FROM Housing

-- Higlighting and Updating the Sale Date
------------------------------------------
/*Viewing the Date in the table corrected date */
SELECT SaleDate, CONVERT(DATE, SaleDate) AS Date
FROM Housing
/*Adding a column to the Hosing table */
ALTER TABLE Housing
ADD SaleDateConvert date
/*Updating the table to include a new column of corrected data*/
UPDATE Housing
SET SaleDateConvert = CONVERT(DATE, SaleDate)


-- Property Address Data
------------------------
/* Viewing the entries with null addresses*/
SELECT UniqueID, ParcelID, PropertyAddress
FROM Housing
WHERE PropertyAddress IS NULL
/* Checking the relationship between PropertyAddress and ParcelID*/
/* -- It has been observed that the PropertyAddress is the same for entries with the same ParcelID --*/
SELECT UniqueID, ParcelID, PropertyAddress
FROM Housing
ORDER BY ParcelID
/*Making a self-join, and Viewing the null propertyAddress values, where uniqueID is not the same*/
SELECT a.PropertyAddress, a.ParcelID, b.ParcelID, b.PropertyAddress
FROM Housing a JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL
/*Populating the propertyAddress in the self-join using the ISNULL function*/
SELECT a.PropertyAddress, a.ParcelID, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
FROM Housing a JOIN Housing b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL  
/*Updating the empty propertyAddresses with the results gotten from the ISNULL function*/
UPDATE a
SET propertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
FROM Housing a JOIN Housing b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL  
/* Confirming the entries have no null propertyAddresses*/
SELECT UniqueID, ParcelID, PropertyAddress
FROM Housing
WHERE PropertyAddress IS NULL


-- Breaking out propertyAddress into Address,City Using Substring Functions
--------------------------------------------------------------------------
/*Selecting Address*/
SELECT PropertyAddress
FROM Housing
/*Using Substring to extract house Address*/
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS HouseAddress
FROM Housing
/*Creating a new column to hold House Address*/
ALTER TABLE Housing
ADD HouseAddress nvarchar(255)
/*Update the House Address*/
UPDATE Housing
SET HouseAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
/*Using Substring to extract City*/
SELECT SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM Housing
/*Creating a new column to hold City*/
ALTER TABLE Housing
ADD City nvarchar(255)
/*Update the House Address*/
UPDATE Housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))
/* Confirming the entries have been successfully split*/
SELECT PropertyAddress, HouseAddress, City
FROM Housing


-- Breaking out OwnerAddress into Address,City,State Using Substring Functions
------------------------------------------------------------------------------
/*Parsename works only with '.', so we replace out the ',' before passing it into the parsename function*/
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerHouse
/*Creating a new column to hold OwnerHouse*/
ALTER TABLE Housing
ADD OwnerHouse nvarchar(255)
/*Update the OwnerHouse*/
UPDATE Housing
SET OwnerHouse = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
/*Parsename works only with '.', so we replace out the ',' before passing it into the parsename function*/
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity
/*Creating a new column to hold OwnerCity */
ALTER TABLE Housing
ADD OwnerCity nvarchar(255)
/*Update the OwnerCity*/
UPDATE Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
/*Parsename works only with '.', so we replace out the ',' before passing it into the parsename function*/
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM Housing
/*Creating a new column to hold OwnerState */
ALTER TABLE Housing
ADD OwnerState nvarchar(255)
/*Update the OwnerCity*/
UPDATE Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
/* Confirming the entries have been successfully split*/
SELECT OwnerAddress, OwnerHouse, OwnerCity, OwnerState
FROM Housing



-- Bringing Uniformity to the SoldAsVacant Column
-------------------------------------------------
/*Viewing the distinct values of the column*/
SELECT DISTINCT SoldAsVacant
FROM Housing
/*Using a case statement to alter the column's values*/
SELECT CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END AS SoldAsVacantT
FROM Housing
/*Modifying the Case statement and putting it in an update statement*/
UPDATE Housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
/*Confirming the distinct values have been updated*/
SELECT DISTINCT SoldAsVacant
FROM Housing


-- Removing Duplcates
---------------------
/*Creating a query to partiiton the row to show duplicates*/
SELECT *, ROW_NUMBER() OVER (PARTITION BY LegalReference, ParcelID
ORDER BY UniqueID) RowNum
FROM Housing
/*Inserting the query above into a CTE */
WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY LegalReference, ParcelID
ORDER BY UniqueID) RowNum
FROM Housing)
/*Querying the CTE that was created to enlist duplicates*/
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY  ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
ORDER BY UniqueID) RowNum
FROM Housing
)
SELECT *
FROM RowNumCTE
WHERE RowNum > 1
/*Deleting Duplicates*/
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY  ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
ORDER BY UniqueID) RowNum
FROM Housing
)
DELETE 
FROM RowNumCTE
WHERE RowNum > 1
/*Confirming DUplicates have been duplicated*/
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY  ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
ORDER BY UniqueID) RowNum
FROM Housing
)
SELECT *
FROM RowNumCTE
WHERE RowNum > 1


-- Deleting Unused Columns
/*Viewing all the colums*/
SELECT *
FROM Housing
/*Deleting Columns*/
ALTER TABLE Housing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate



