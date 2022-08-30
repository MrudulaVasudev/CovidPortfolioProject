SELECT * FROM PortfolioProject..NashvilleHousing;

----------------------------------------------------------------------------------------------------------------------

/* Standardize Date format */

SELECT 
	SaleDate, 
	CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing;

-- Just an update statement wouldn't work here because update statement changes the data without changing the datatype
-- Datatype requires to be converted from datetime to date
-- We hence create a new column for date

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

----------------------------------------------------------------------------------------------------------------------
/* Populating Property Address Data */

-- We use replacement function ISNULL
-- Create an illusion of two tables by using aliases
-- We join tables on SAME parcelid but DIFFERENT UniqueIDs making it a crosstabulation

SELECT 
	a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress, 
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON A.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyAddress IS NULL;

----------------------------------------------------------------------------------------------------------------------

/* Breaking out address into individual columns (Address, City, State) */

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing;

-- Creating two new columns

ALTER TABLE NashvilleHousing
ADD Address NVARCHAR(255), City NVARCHAR(255);

UPDATE NashvilleHousing
SET 
	Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
	City = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


----------------------------------------------------------------------------------------------------------------------

/* Breaking OwnerAddress into address, city, state */

SELECT *
FROM NashvilleHousing;

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerAddress1 VARCHAR(255), OwnerCity VARCHAR(255), OwnerState VARCHAR(255);

UPDATE NashvilleHousing
SET 
	OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

----------------------------------------------------------------------------------------------------------------------

/* Change Y and N to Yes and No in "Sold As Vacant" */

SELECT DISTINCT SoldAsVacant
FROM NashvilleHousing;

SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'N' THEN 'No'
		 WHEN SoldAsVacant ='Y' THEN 'Yes'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'N' THEN 'No'
		 WHEN SoldAsVacant ='Y' THEN 'Yes'
		 ELSE SoldAsVacant
		 END

----------------------------------------------------------------------------------------------------------------------

/* Remove Duplicates */

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
	) rownum
FROM NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE rownum > 1
--ORDER BY PropertyAddress;
----------------------------------------------------------------------------------------------------------------------

SELECT *
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
