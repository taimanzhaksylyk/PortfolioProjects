-- Looking at data
select top 100 * 
from PortfolioP3..NashvilleHousing 


-- Standardize Date Format
select SaleDate, convert(Date, SaleDate)
from PortfolioP3..NashvilleHousing;

alter table Portfoliop3..NashvilleHousing
add SaleDateConverted Date;

update PortfolioP3..NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate);

select SaleDateConverted
from PortfolioP3..NashvilleHousing


--Populate property address data
select *
from PortfolioP3..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioP3..NashvilleHousing as a
join PortfolioP3..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioP3..NashvilleHousing as a
join PortfolioP3..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into individual columns (Address, City, State)
select PropertyAddress
from PortfolioP3..NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress) ) as City
from PortfolioP3..NashvilleHousing;

alter table PortfolioP3..NashvilleHousing
add StreetAddress Nvarchar(255);

update PortfolioP3..NashvilleHousing
set StreetAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1);

alter table PortfolioP3..NashvilleHousing
add CityAddress Nvarchar(255);

update PortfolioP3..NashvilleHousing
set CityAddress = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress) );

select * 
from PortfolioP3..NashvilleHousing

-- Breaking out OwnerAddress using parsename
select parsename(replace(OwnerAddress, ',', '.'), 3),
	parsename(replace(OwnerAddress, ',', '.'), 2), 
	parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioP3..NashvilleHousing

alter table PortfolioP3..NashvilleHousing
add OwnerStreetAddress Nvarchar(255);

update PortfolioP3..NashvilleHousing
set OwnerStreetAddress = parsename(replace(OwnerAddress, ',', '.'), 3);

alter table PortfolioP3..NashvilleHousing
add OwnerCityAddress Nvarchar(255);

update PortfolioP3..NashvilleHousing
set OwnerCityAddress = parsename(replace(OwnerAddress, ',', '.'), 2);

alter table PortfolioP3..NashvilleHousing
add OwnerStateAddress Nvarchar(255);

update PortfolioP3..NashvilleHousing
set OwnerStateAddress = parsename(replace(OwnerAddress, ',', '.'), 1);


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioP3..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from PortfolioP3..NashvilleHousing

update PortfolioP3..NashvilleHousing
set SoldAsVacant = 
	case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from PortfolioP3..NashvilleHousing


--Remove Duplicates

with Temp as (
	select *, row_number() 
		over (partition by 
			ParcelID, 
			PropertyAddress, 
			SalePrice, 
			SaleDate, 
			LegalReference
			order by UniqueID)
		as row_num
	from PortfolioP3..NashvilleHousing
)

delete
from Temp 
where row_num > 1


-- Delete unused columns
alter table PortfolioP3..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
