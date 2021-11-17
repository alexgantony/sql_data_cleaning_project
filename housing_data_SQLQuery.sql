/*
	Cleaning data in SQL
*/

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT
  SaleDate,
  CAST(SaleDate AS date)
FROM HousingData..NashvilleHousing

ALTER TABLE HousingData..NashvilleHousing
ADD SaleDateConverted date;

UPDATE HousingData..NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS date)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT
  *
FROM HousingData..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT
  a.ParcelID,
  a.PropertyAddress,
  b.ParcelID,
  b.PropertyAddress,
  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData..NashvilleHousing a
JOIN HousingData..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData..NashvilleHousing a
JOIN HousingData..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


---------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
  PropertyAddress,
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS city
FROM HousingData..NashvilleHousing;

ALTER TABLE HousingData..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE HousingData..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE HousingData..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE HousingData..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


-- Breaking out Owner Address 

SELECT
  OwnerAddress,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM HousingData..NashvilleHousing;

ALTER TABLE HousingData..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE HousingData..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE HousingData..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE HousingData..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE HousingData..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE HousingData..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT
  *
FROM HousingData..NashvilleHousing;


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT
  (SoldAsVacant),
  COUNT(SoldAsVacant)
FROM HousingData..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT
  SoldAsVacant,
  CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END
FROM HousingData..NashvilleHousing;

UPDATE HousingData..NashvilleHousing
SET SoldAsVacant =
                  CASE
                    WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                  END


----------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
  SELECT 
    *, 
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID, 
      PropertyAddress, 
      SalePrice, 
      SaleDate, 
      LegalReference 
      ORDER BY 
        UniqueID
    ) AS RowNum 
  FROM 
    HousingData..NashvilleHousing
) 
DELETE FROM 
  RowNumCTE 
WHERE 
  RowNum > 1;


----------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT
  *
FROM HousingData..NashvilleHousing

ALTER TABLE HousingData..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict;
