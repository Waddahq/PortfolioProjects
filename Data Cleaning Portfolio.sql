---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

---- cleaning data in SQL Queries 

select *
from PortfolioProject..NashvilleHousing 



---------------------------------------------------------------------------------------------------------
--- Standardize Date Format

select SaleDate, SaleDateConverted, convert(date,saledate)
from PortfolioProject..NashvilleHousing


update NashvilleHousing
set saledate = convert(date,saledate)


alter table nashvillehousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date,saledate)



---------------------------------------------------------------------------------------------------------
---- Populate Property Address data 


select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null 
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



---------------------------------------------------------------------------------------------------------
 -- Breaking out Address into individual columns (Address, City, State)



select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null 
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as City


from PortfolioProject..NashvilleHousing


alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))


select *
from PortfolioProject..NashvilleHousing




select OwnerAddress
from PortfolioProject..NashvilleHousing


select
parsename(replace(OwnerAddress, ',', '.'), 3) as street,
parsename(replace(OwnerAddress, ',', '.'), 2) as city,
parsename(replace(OwnerAddress, ',', '.'), 1) as state

from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3) 


alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity  = parsename(replace(OwnerAddress, ',', '.'), 2) 


alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1) 



select *
from PortfolioProject..NashvilleHousing



---------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant' field 


select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2




select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing


update NashvilleHousing
set SoldAsVacant = 	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing



---------------------------------------------------------------------------------------------------------
-- Remove Duplicates 


with RowNumCTE as (
select *, 
	ROW_NUMBER() over (
	partition by parcelID,
				 propertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					uniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
--where row_num > 1
)
select * 
from RowNumCTE 
where row_num > 1
order by propertyaddress


select * 
from PortfolioProject..NashvilleHousing



---------------------------------------------------------------------------------------------------------
-- Delete unused columns 


select * 
from PortfolioProject..NashvilleHousing


alter table PortfolioProject..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress, saledate


alter table PortfolioProject..NashvilleHousing
drop column saledate



---------------------------------------------------------------------------------------------------------