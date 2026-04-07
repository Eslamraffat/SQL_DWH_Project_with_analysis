/*Bornz Layer Quality Check:CRM TABLES
Here I'm doing all the analytic stuff (cleaning, transofrming, replacing)
for each table from the CRM folder I'm making sure of the below:
	A-primary key is not null/duplicate.
	B- checking for unwanted spaces.
	C- Checking the consistency of data.
*/
-- Bornz Layer Quality Check: ERB TABLE1 (bronze.crm_cust_info)
-- A- primary key is not null/duplicate:
SELECT cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
-- here we found 6 cst_ids with duplicates and one null values

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466;
-- we took a sample of the duplicated values to understand why, and which one to keep
-- in this case we're keeping only the latest values.
SELECT 
	*
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	)t
WHERE flag_last =1;
-- here we'll have only the no null and most recent values on which we've decided to keep them

-- B- checking for unwanted spaces:
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
-- checking the unwanted spaces in customer's first name
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
-- checking the unwanted spaces in customer's last name
SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_firstname) AS cst_firstname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	)t
WHERE flag_last =1;
-- here we got better/cleaned version

--##########################################################
-- C- Check the consistency of values:
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info
-- we'll have to replace the current values (F-M-NULL) with better ones
SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_firstname) AS cst_firstname,
CASE 
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	ELSE 'n/a'
END cst_marital_status,
CASE 
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	ELSE 'n/a'
END cst_gndr,
	cst_create_date
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	)t
WHERE flag_last =1;
-- we changed the abbreviations to full name values (male-female-married-single- n/a)
PRINT '>> Truncateting table: silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	)
SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_firstname) AS cst_firstname,
CASE 
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	ELSE 'n/a'
END cst_marital_status,
CASE 
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	ELSE 'n/a'
END cst_gndr,
	cst_create_date
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	)t
WHERE flag_last =1;
-- lastly we inserted the new cleaned data to the silver layer table ((bronze.crm_cust_info)).

--#######################################
-- Bornz Layer Quality Check: CRM TABLE2 (bronze.crm_prd_info)
-- A- primary key is not null/duplicate
SELECT 
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5), '-','_') AS cat_id,
-- we took the first 5 characters as it represents the unique key that conncets 
-- ((crm_prd_info)) table with the ((erp_PX_CAT_G1V2)) table
-- then we replaced the '-' with '_' to match the key in ((erp_PX_CAT_G1V2)) table.
	SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
-- when we use LEN(column name) with substring, we make the end of column values dynamic
-- and we got the prd_key because it represents the unique key that conncets 
-- ((crm_prd_info)) table with the ((crm_sales_details)) table
	prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
CASE 
	WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	ELSE 'n/a'
END prd_line,
	prd_start_dt,
LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt
FROM bronze.crm_prd_info
-- WHERE REPLACE(SUBSTRING(prd_key,1,5), '-','_') NOT IN
--(SELECT DISTINCT id from bronze.erp_PX_CAT_G1V2)
-- checking any unmatching values

-- B- checking for unwanted spaces
-- we found nothing
-- C- Check the consistency of values
-- ISNULL(prd_cost,0) AS prd_cost, we replaced the null values to 0 (based on the business roles)
-- we changed the abbreviations (M-R-S-T) to (Mountain-Road-Other Sales-Touring)
-- lastly we ignored the old ((prd_end_dt)) values as they're not making sencse, 
-- and used LEAD() to use the start date of the next date as the end date and so on.
PRINT '>> Truncateting table: silver.crm_prd_info';
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)
SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5), '-','_') AS cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
	prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
CASE 
	WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	ELSE 'n/a'
END prd_line,
	prd_start_dt,
LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt
FROM bronze.crm_prd_info;
 -- lastly we insert the new cleaned data to the table ((silver.crm_prd_info)) from the table ((bronze.crm_prd_info))

 --#######################################
-- Bornz Layer Quality Check:CRM TABLE3 (bronze.crm_sales_details)
-- A- primary key is not null/duplicate
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt =0 OR LEN(sls_order_dt)!= 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		--1st case is ti change the format to varchar so we can change it to date
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt =0 OR LEN(sls_ship_dt)!= 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		--1st case is ti change the format to varchar so we can change it to date
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt =0 OR LEN(sls_due_dt)!= 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		--1st case is ti change the format to varchar so we can change it to date
	END AS sls_due_dt,

	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price) -- to turn every negative to positive
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
	THEN sls_sales/NULLIF(sls_quantity,0) -- here we change and 0 to null to avoid dividing upon 0 and break the code, instead we devide on Null if found and will get a null value, and code won't break
	ELSE sls_price
	END AS sls_price

FROM bronze.crm_sales_details
-- WHERE sls_ord_num != TRIM(sls_ord_num) no unwanted spaces/null values
-- WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info) finding unmatched values

/*SELECT 
NULLIF(sls_order_dt,0) AS sls_order_dt -- change values to nulls if values are <=0
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0
OR LEN(sls_order_dt)!= 8 -- as the default lenth of the date must be 8
OR sls_order_dt >20500101 -- random future date
OR sls_order_dt < 19000101 -- random old historic date
 we checking fo any oulines in date formats/values
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt
	order date shouldn't be after the shipping date, and shipping date can't be after due date
*/
-- C- Check the consistency of values
-- sales must be = (quntity*price), and no negative,0,nulls are allowed
SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity AS old_sls_quantity,
	sls_price AS old_sls_price,

CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price) -- to turn every negative to positive
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0
	THEN sls_sales/NULLIF(sls_quantity,0) 
-- here we change and 0 to null to avoid dividing upon 0 and break the code, instead we devide on Null if found and will get a null value, and code won't break
	ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR  sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,sls_quantity,sls_price

-- 1st rule with sales: if sales is negative, 0, or null get it using quantity and price
-- if price is 0 or null, claculate it using sales and quantity.
-- if price is negative, convert it to positive.
PRINT '>> Truncateting table: silver.crm_sales_details';
TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details(
	sls_ord_num ,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt =0 OR LEN(sls_order_dt)!= 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		--1st case is ti change the format to varchar so we can change it to date
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt =0 OR LEN(sls_ship_dt)!= 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		--1st case is ti change the format to varchar so we can change it to date
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt =0 OR LEN(sls_due_dt)!= 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		--1st case is ti change the format to varchar so we can change it to date
	END AS sls_due_dt,

	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price) -- to turn every negative to positive
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
	THEN sls_sales/NULLIF(sls_quantity,0)
	ELSE sls_price
	END AS sls_price

FROM bronze.crm_sales_details
