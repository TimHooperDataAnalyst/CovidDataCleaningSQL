/*

Cleansing Data in SQL Queries

*/

SELECT *
FROM Portfolio..NashvilleHousing

-- Standardize Sale Date

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Portfolio..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM Portfolio..NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER by ParcelID

-- Solving NULL Property Address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into indiviual columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Portfolio..NashvilleHousing

SELECT OwnerAddress
FROM Portfolio..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM Portfolio..NashvilleHousing

---------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
GROUP by SoldAsVacant
ORDER by 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Portfolio..NashvilleHousing
	
UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates (Only Deleting From The Copy of Original Data)

WITH RowNumCTE AS(
SELECT *,
	Row_Number() OVER(
	PARTITION  by ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER by UniqueID
							) row_num
FROM Portfolio..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER by PropertyAddress

SELECT *
FROM Portfolio..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns (Only Deleting From The Copy of Original Data)

SELECT *
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

