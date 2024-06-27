create database Nashville

use Nashville

select * from nashvillehousing

--------------------------------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT

alter table NashvilleHousing
add SaleDatee date

update NashvilleHousing
set SaleDatee = CONVERT(date, SaleDate)

alter table NashvilleHousing
drop column SaleDate

EXEC sp_rename 'NashvilleHousing.SaleDatee',  'SaleDate', 'COLUMN';


--------------------------------------------------------------------------------------------------
-- POPULATE PROPERTY ADDRESS DATA

select * from NashvilleHousing
where PropertyAddress is NULL

select 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NashvilleHousing a
join NashvilleHousing b 
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NashvilleHousing a
join NashvilleHousing b 
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


--------------------------------------------------------------------------------------------------
-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

select 
    PropertyAddress,
    PropAddress,
    PropCity
    -- SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
    -- SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 2, LEN(PropertyAddress)) as City
from NashvilleHousing


select OwnerAddress
from NashvilleHousing
where OwnerAddress LIKE '%TN'


alter table NashvilleHousing
add PropAddress NVARCHAR(255)


alter table NashvilleHousing
add PropCity NVARCHAR(255)


update NashvilleHousing
set PropAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


update NashvilleHousing
set PropCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 2, LEN(PropertyAddress))


select 
    OwnerFullAddress,
    OwnerAddress,
    OwnerCity,
    OwnerState
FROM NashvilleHousing


select
    TRIM(PARSENAME(REPLACE(OwnerFullAddress,',','.'), 3)) as OwnerAddress,
    TRIM(PARSENAME(REPLACE(OwnerFullAddress,',','.'), 2)) as OwnerCity,
    TRIM(PARSENAME(REPLACE(OwnerFullAddress,',','.'), 1)) as OwnerState
from NashvilleHousing


EXEC sp_rename 'NashvilleHousing.OwnerAddress',  'OwnerFullAddress', 'COLUMN';


alter table NashvilleHousing
add 
    OwnerAddress NVARCHAR(255),
    OwnerCity NVARCHAR(255),
    OwnerState NVARCHAR(255)


UPDATE NashvilleHousing
set 
    OwnerAddress = TRIM(PARSENAME(REPLACE(OwnerFullAddress,',','.'), 3)),
    OwnerCity = TRIM(PARSENAME(REPLACE(OwnerFullAddress,',','.'), 2)),
    OwnerState = TRIM(PARSENAME(REPLACE(OwnerFullAddress,',','.'), 1))





--------------------------------------------------------------------------------------------------
-- CHANGE Y AND N TO YES AND NO IN "SOLID AS VACANT" FIELD

select distinct -- To check if I replace Y and N to Yes and No correctly
    SoldAsVacant
    -- IIF(SoldAsVacant = 'N', 'No', SoldAsVacant) as SoldAsVacant_No
    -- IIF(SoldAsVacant = 'Y', 'Yes', SoldAsVacant) as SoldAsVacant_Yes
from NashvilleHousing


update NashvilleHousing -- Replace N to No
set SoldAsVacant = IIF(SoldAsVacant = 'N', 'No', SoldAsVacant)


update NashvilleHousing -- Replace Y to Yes
set SoldAsVacant = IIF(SoldAsVacant = 'Y', 'Yes', SoldAsVacant)



--------------------------------------------------------------------------------------------------
-- REMOVE DUPLICATES


select -- check duplicates if exists
    *
from (
    select 
        *,
        ROW_NUMBER() OVER (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as uniqueCheck
    from NashvilleHousing
    -- order by ParcelID
) as uniqueCheck_tbl
where uniqueCheck > 1


with uniquecheck_tbl as ( -- remove duplicate values
    select 
        *,
        ROW_NUMBER() OVER (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as uniqueCheck
    from NashvilleHousing
)
DELETE from uniquecheck_tbl where uniqueCheck > 1



--------------------------------------------------------------------------------------------------
-- DELETE UNUSED COLUMNS

select top 5 * from NashvilleHousing


alter table NashvilleHousing
drop COLUMN PropertyAddress, OwnerFullAddress, TaxDistrict