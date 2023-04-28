/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format(My dates were already standardized, but still went through the process 
--of converting/updating


Select SaleDateConverted, Convert(Date, SaleDate)
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
SET SaleDate = Convert(Date, SaleDate)

ALTER TABLE [Nashville Housing Data for Data Cleaning (reuploaded)]
ADD SaleDateConverted Date;

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
SET SaleDateConverted = Convert(Date, SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]
--WHERE PropertyAddress is null
ORDER BY ParcelID

Select nasha.ParcelID, nasha.PropertyAddress, nashb.ParcelID, nashb.PropertyAddress, 
ISNULL(nasha.PropertyAddress, nashb.PropertyAddress)
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)] nasha
JOIN PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)] nashb
    ON nasha.ParcelID = nashb.ParcelID
	AND nasha.UniqueID <> nashb.UniqueID
WHERE nasha.PropertyAddress is null

Update nasha
SET PropertyAddress = ISNULL(nasha.PropertyAddress, nashb.PropertyAddress)
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)] nasha
JOIN PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)] nashb
    ON nasha.ParcelID = nashb.ParcelID
	AND nasha.UniqueID <> nashb.UniqueID
WHERE nasha.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]



ALTER TABLE [Nashville Housing Data for Data Cleaning (reuploaded)]
ADD PropertySplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE [Nashville Housing Data for Data Cleaning (reuploaded)]
ADD PropertySplitCity Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

SELECT *
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]


ALTER TABLE [Nashville Housing Data for Data Cleaning (reuploaded)]
ADD OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

ALTER TABLE [Nashville Housing Data for Data Cleaning (reuploaded)]
ADD OwnerSplitCity Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing Data for Data Cleaning (reuploaded)]
ADD OwnerSplitState Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field(My SoldAsVacant columns were '0' and '1'
--for some reason but changed them to 'No' and 'Yes')

SELECT *
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]

SELECT DISTINCT(SoldAsVacantYN), COUNT(SoldAsVacantYN)
FROM PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]
GROUP BY SoldAsVacantYN

SELECT REPLACE(REPLACE(SoldAsVacant, '0', 'No'), '1', 'Yes')
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]

ALTER TABLE PortfolioProject.[dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
ADD SoldAsVacantYN Nvarchar(255);

Update PortfolioProject.[dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
SET SoldAsVacantYN = REPLACE(REPLACE(SoldAsVacant, '0', 'No'), '1', 'Yes')
;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
				 ) row_num
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]
--ORDER BY ParcelID
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT *
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
From PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]


ALTER TABLE PortfolioProject..[Nashville Housing Data for Data Cleaning (reuploaded)]
DROP COLUMN SaleDate