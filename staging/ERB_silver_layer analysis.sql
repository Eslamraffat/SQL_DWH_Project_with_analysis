/* 
Bornz Layer Quality Check:ERB TABLE1 (silver.erp_CUST_AZ12)
Here I'm doing all the analytic stuff (cleaning, transofrming, replacing)
for each table from the CRM folder I'm making sure of the below:
	A-primary key is not null/duplicate.
	B- checking for unwanted spaces.
	C- Checking the consistency of data.
*/
-- A- Primary key is not null/duplicate. PASSED
-- B- Checking for unwanted spaces. PASSED
-- C- Checking the consistency of values.
PRINT '>> Truncateting table: silver.erp_CUST_AZ12';
TRUNCATE TABLE silver.erp_CUST_AZ12;
INSERT INTO silver.erp_CUST_AZ12(
	cid,
	bdate,
	gen
	)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
-- we removed 'NAS' to match cid unique key with ((cst_key)) from the table ((silver.crm_cust_info))
	ELSE cid
END cid,
CASE WHEN BDATE > GETDATE() THEN NULL
	ELSE BDATE
END BDATE,
CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
	ELSE 'n/a'
END gen
FROM bronze.erp_CUST_AZ12

SELECT bdate
FROM bronze.erp_CUST_AZ12
WHERE bdate <'1924-01-01' OR BDATE > GETDATE()
-- Checking if and date is very old, or in the future

--#######################################
/* Bornz Layer Quality Check: ERB TABLE2 (silver.erp_LOC_A101)
	A- Primary key is not null/duplicate. PASSED
	B- Checking for unwanted spaces. PASSED	 
 */
-- C- Checking the consistency of data.
PRINT '>> Truncateting table: silver.erp_LOC_A101';
TRUNCATE TABLE silver.erp_LOC_A101;
INSERT INTO silver.erp_LOC_A101(
cid,cntry
)
SELECT
	REPLACE(cid, '-','') AS cid,
CASE
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
	WHEN TRIM(cntry) ='' OR cntry IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_LOC_A101;
--#######################################
/* Bornz Layer Quality Check: ERB TABLE3 (silver.erp_PX_CAT_G1V2)
	A- Primary key is not null/duplicate. PASSED
	B- Checking for unwanted spaces. PASSED
	C- Checking the consistency of data. PASSED
 */
PRINT '>> Truncateting table: silver.erp_PX_CAT_G1V2';
TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
INSERT INTO silver.erp_PX_CAT_G1V2 (
	id,
	cat,
	subcat,
	maintenance
	)
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_PX_CAT_G1V2;
