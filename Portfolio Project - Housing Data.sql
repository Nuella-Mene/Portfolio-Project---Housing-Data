-- Data Cleaning in SQL

SELECT*
FROM [Nashville Housing]

--Standardising Sale Date format

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SaleDate = CONVERT(DATE, SaleDate)

--Populate Property Address Data

SELECT*
FROM [Nashville Housing]
--WHERE PropertyAddress IS NULL 
ORDER BY ParcelID

SELECT T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress, ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM [Nashville Housing] AS T1
JOIN [Nashville Housing] AS T2
ON T1.ParcelID = T2.ParcelID
AND T1.UniqueID <> T2.UniqueID
WHERE T1.PropertyAddress IS NULL

UPDATE T1
SET PropertyAddress = ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM [Nashville Housing] AS T1
JOIN [Nashville Housing] AS T2
ON T1.ParcelID = T2.ParcelID
AND T1.UniqueID <> T2.UniqueID
WHERE T1.PropertyAddress IS NULL

--Breaking Out Address Column into Multiple Colums (Address, City, State)

SELECT PropertyAddress
FROM [Nashville Housing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address 
FROM [Nashville Housing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address  
FROM [Nashville Housing]
  
--Adding the column to the table

ALTER TABLE [Nashville Housing]
ADD PropertyAddressSplit NVARCHAR(255)

UPDATE [Nashville Housing]
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville Housing]
ADD City NVARCHAR(255)

UPDATE [Nashville Housing]
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

--Splitting OwnerAddress (Using PARSENAME)

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD OwnerAddressSplit NVARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Nashville Housing]
ADD OwnerCitySplit NVARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Nashville Housing]
ADD OwnerStateSplit NVARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--Changing/Updating Values (Changing Y and N to Yes and No)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoLdAsVacant
	  END
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoLdAsVacant
	  END


--Remove Duplicates

WITH RowNumCTE AS(
SELECT*,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
				    UniqueID
				    ) row_num
FROM [Nashville Housing]
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Deleting Unused Columns

SELECT*
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate