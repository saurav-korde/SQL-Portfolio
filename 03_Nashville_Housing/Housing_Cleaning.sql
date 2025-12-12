/*
--------------------------------------------------------------------------------------------------------------------------
PROJECT 3: NASHVILLE HOUSING DATA CLEANING
--------------------------------------------------------------------------------------------------------------------------
Author: Saurav Korde
Date: December 11, 2025
Goal: Transform raw housing data into a clean, usable format for analysis.

Key Cleaning Tasks:
1. Standardize Date Formats
2. Populate Missing Property Address Data
3. Break out Address into Individual Columns (Address, City, State)
4. Split Owner Address (Address, City, State)
5. Change "Y" and "N" to "Yes" and "No" in "Sold as Vacant" field
6. Remove Duplicates
7. Delete Unused Columns
--------------------------------------------------------------------------------------------------------------------------
*/

-- ========================================================================================================================
-- 1. Standardize Date Format
-- Goal: Convert SaleDate (String/Text) into a standard DATE format (YYYY-MM-DD).
-- ========================================================================================================================

-- Step A: Setup - I am adding a new column to hold the clean date format
ALTER TABLE nashvillehousing
ADD COLUMN "SaleDateConverted" DATE;

-- Step B: Conversion - I am parsing the text string and updating the new column
-- I used TO_DATE because the source format 'Month DD, YYYY' needs explicit instruction.
UPDATE nashvillehousing
SET "SaleDateConverted" = TO_DATE("SaleDate", 'Month DD, YYYY');

-- Step C: Verification - I am comparing the old text vs. the new date to ensure accuracy
SELECT "SaleDate", "SaleDateConverted"
FROM nashvillehousing
LIMIT 10;

-- ========================================================================================================================
-- 2. Populate Property Address Data
-- Goal: Fill in NULL addresses by checking if the same ParcelID exists with an address in another row.
-- ========================================================================================================================

-- Step A: Standardization - I am converting "Ghost Strings" ('') into true NULL values
UPDATE nashvillehousing
SET "PropertyAddress" = NULL
WHERE "PropertyAddress" = '';

-- Step B: The Fix - Now I populate the NULLs using a Self-Join
-- I am joining the table to itself (t1 to t2) where the ParcelID is the same but the UniqueID is different.
UPDATE nashvillehousing t1
SET "PropertyAddress" = COALESCE(t1."PropertyAddress", t2."PropertyAddress")
FROM nashvillehousing t2
WHERE t1."ParcelID" = t2."ParcelID"
  AND t1."UniqueID " <> t2."UniqueID "
  AND t1."PropertyAddress" IS NULL;

-- Step C: Verification - I am checking if any empty strings OR nulls remain (Should be 0)
SELECT "ParcelID", "PropertyAddress"
FROM nashvillehousing
WHERE "PropertyAddress" IS NULL OR "PropertyAddress" = '';

-- ========================================================================================================================
-- 3. Breaking out Address into Individual Columns (Address, City, State)
-- Goal: "123 Main St, Nashville, TN" -> "123 Main St", "Nashville", "TN"
-- ========================================================================================================================

-- Step A: Audit - I am testing the split logic before updating the table
-- I use SUBSTRING to grab text from the 1st letter up to (but not including) the comma position.
-- Then I grab text from the comma position + 1 to the end for the City.
SELECT
    "PropertyAddress",
    SUBSTRING("PropertyAddress", 1, STRPOS("PropertyAddress", ',') - 1) AS Address,
    SUBSTRING("PropertyAddress", STRPOS("PropertyAddress", ',') + 1) AS City
FROM nashvillehousing
LIMIT 20;

-- Step B: Setup - I am adding two new columns to store the split data
ALTER TABLE nashvillehousing
ADD COLUMN "PropertySplitAddress" VARCHAR(255);

ALTER TABLE nashvillehousing
ADD COLUMN "PropertySplitCity" VARCHAR(255);

-- Step C: Execution - I am updating the new columns with the parsed data
UPDATE nashvillehousing
SET "PropertySplitAddress" = SUBSTRING("PropertyAddress", 1, STRPOS("PropertyAddress", ',') - 1);

UPDATE nashvillehousing
SET "PropertySplitCity" = SUBSTRING("PropertyAddress", STRPOS("PropertyAddress", ',') + 1);

-- Step D: Verification - I am checking the final result
SELECT "PropertyAddress", "PropertySplitAddress", "PropertySplitCity"
FROM nashvillehousing
LIMIT 10;

-- ========================================================================================================================
-- 4. Split Owner Address
-- Goal: Use a different method (PARSENAME) to split the Owner Address.
-- ========================================================================================================================

-- Step A: Audit - I am testing the logic to ensure the split works correctly
SELECT
    "OwnerAddress",
    SPLIT_PART("OwnerAddress", ',', 1) AS Address,
    SPLIT_PART("OwnerAddress", ',', 2) AS City,
    SPLIT_PART("OwnerAddress", ',', 3) AS State
FROM nashvillehousing
LIMIT 20;

-- Step B: Setup - I am creating three new columns to hold the parsed data
ALTER TABLE nashvillehousing
ADD COLUMN "OwnerSplitAddress" VARCHAR(255);

ALTER TABLE nashvillehousing
ADD COLUMN "OwnerSplitCity" VARCHAR(255);

ALTER TABLE nashvillehousing
ADD COLUMN "OwnerSplitState" VARCHAR(255);

-- Step C: Execution - I am updating the columns with the split values
UPDATE nashvillehousing
SET "OwnerSplitAddress" = SPLIT_PART("OwnerAddress", ',', 1);

UPDATE nashvillehousing
SET "OwnerSplitCity" = SPLIT_PART("OwnerAddress", ',', 2);

UPDATE nashvillehousing
SET "OwnerSplitState" = SPLIT_PART("OwnerAddress", ',', 3);

-- Step D: Verification - I am checking the final result to confirm all three columns are populated
SELECT "OwnerAddress", "OwnerSplitAddress", "OwnerSplitCity", "OwnerSplitState"
FROM nashvillehousing
LIMIT 10;

-- ========================================================================================================================
-- 5. Change Y and N to Yes and No in "Sold as Vacant" field
-- Goal: Standardize the boolean field for consistency.
-- ========================================================================================================================

-- Step A: Audit - I am counting the distinct values to see the mess
SELECT DISTINCT("SoldAsVacant"), COUNT("SoldAsVacant")
FROM nashvillehousing
GROUP BY "SoldAsVacant"
ORDER BY 2;

-- Step B: The Fix - I am using a CASE Statement to convert 'Y' -> 'Yes' and 'N' -> 'No'
UPDATE nashvillehousing
SET "SoldAsVacant" = CASE 
    WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
    WHEN "SoldAsVacant" = 'N' THEN 'No'
    ELSE "SoldAsVacant"
END;

-- Step C: Verification - I am running the audit again to confirm only 'Yes' and 'No' remain
SELECT DISTINCT("SoldAsVacant"), COUNT("SoldAsVacant")
FROM nashvillehousing
GROUP BY "SoldAsVacant"
ORDER BY 2;

-- ========================================================================================================================
-- 6. Remove Duplicates
-- Goal: Identify duplicate rows based on unique identifiers and remove them.
-- ========================================================================================================================

-- Step A: Audit - Identify the duplicates
WITH RowNumCTE AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY "ParcelID",
                     "PropertyAddress",
                     "SalePrice",
                     "SaleDate",
                     "LegalReference"
        ORDER BY "UniqueID "
    ) as row_num
    FROM nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY "PropertyAddress";

-- Step B: The Fix - Delete the duplicates
DELETE FROM nashvillehousing
WHERE "UniqueID " IN (
    SELECT "UniqueID "
    FROM (
        SELECT "UniqueID ",
        ROW_NUMBER() OVER (
            PARTITION BY "ParcelID",
                         "PropertyAddress",
                         "SalePrice",
                         "SaleDate",
                         "LegalReference"
            ORDER BY "UniqueID "
        ) as row_num
        FROM nashvillehousing
    ) t
    WHERE t.row_num > 1
);

-- Step C: Verification - Run the audit (Step A) again. It should return 0 rows.

-- ========================================================================================================================
-- 7. Delete Unused Columns
-- Goal: Remove the raw columns that are no longer needed after splitting/cleaning.
-- ========================================================================================================================

-- Step A: The Fix - Drop the columns
ALTER TABLE nashvillehousing
DROP COLUMN "OwnerAddress",
DROP COLUMN "TaxDistrict",
DROP COLUMN "PropertyAddress",
DROP COLUMN "SaleDate";

-- Step B: Verification - Check the final clean table
SELECT *
FROM nashvillehousing
LIMIT 20;
