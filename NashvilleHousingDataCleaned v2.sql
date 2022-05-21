

-- Step 1: examining the data after loading it into SQL

Select *
From Portfolio1..NashvilleHousing;



-- Step 2: creating a copy of the database into another table
--- Assumption is that the original Excel file is the raw data
Drop Table If Exists Portfolio1..NashvilleHousingCleaned;
Go

Create Table Portfolio1..NashvilleHousingCleaned (
	UniqueID float,
	ParcelID nvarchar(255),
	LandUse nvarchar(255),
	PropertyAddress nvarchar(255),
	SaleDate datetime,
	SalePrice float,
	LegalReference nvarchar(255),
	SoldAsVacant nvarchar(255),
	OwnerName nvarchar(255),
	OwnerAddress nvarchar(255),
	Acreage float,
	TaxDistrict nvarchar(255),
	LandValue float,
	BuildingValue float,
	TotalValue float,
	YearBuilt float,
	Bedrooms float,
	FullBath float,
	HalfBath float
);

Insert into Portfolio1..NashvilleHousingCleaned 
Select 	UniqueID,
	ParcelID,
	LandUse,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference,
	SoldAsVacant,
	OwnerName,
	OwnerAddress,
	Acreage,
	TaxDistrict,
	LandValue,
	BuildingValue,
	TotalValue,
	YearBuilt,
	Bedrooms,
	FullBath,
	HalfBath
From Portfolio1..NashvilleHousing;



-- Step 3: adding extra columns needed before doing transformations

Alter Table Portfolio1..NashvilleHousingCleaned
Add SaleDate2 Date,
	PropertySplitAddress Nvarchar(255),
	PropertySplitCity Nvarchar(255),
	OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255)
;


-- Step 4: Updating the new columns created from the previous step and any old columns

Update Portfolio1..NashvilleHousingCleaned
Set SaleDate2 = Convert(Date,SaleDate),
	PropertySplitAddress = PARSENAME(Replace(PropertyAddress, ',', '.'), 2),
	PropertySplitCity = PARSENAME(Replace(PropertyAddress, ',', '.'), 1),
	OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1),
	SoldAsVacant = 
		 Case 
			When SoldAsVacant = 'Y' Then 'Yes'
			When SoldAsVacant = 'N' Then 'No'
			Else SoldAsVacant
		End
;



-- Step 5: Populating empty Property Address entries
--- Using a join on the table itself to identify where the Parcel ID is the same, 
--- the property address should be the same as well

Update A
Set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From Portfolio1..NashvilleHousingCleaned A --using an alias for easier referencing
Join Portfolio1..NashvilleHousingCleaned B --using an alias for easier referencing
	On A.ParcelID = B.ParcelID
	And A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null;



-- Step 6: Removing Duplicates

With RowNumCTE As (
Select *,
		ROW_NUMBER() OVER (
		Partition By ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order By UniqueID ) row_num
From Portfolio1..NashvilleHousingCleaned
)
Delete
From RowNumCTE
Where row_num > 1;



-- Step 7: Dropping unused columns in the new table

Alter Table Portfolio1..NashvilleHousingCleaned
Drop Column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate;
