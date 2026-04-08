/*Preparing the Gold LAYER:
	standardlizing columns names
	putting the final touch of normalizing data
	removing any un wanted columns
	rearranging coulmns order for better ui experience
	then implementing gold layers' tables
*/

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

-- creating the 1st dimention table (gold.dim_customers), and set as VIEW
CREATE VIEW gold.dim_customers AS
	SELECT
		ROW_NUMBER() OVER(ORDER BY cst_id)	AS customer_key, -- surogate key
		ci.cst_id							AS cutomer_id,
		ci.cst_key							AS customer_number,
		ci.cst_firstname					AS first_name,
		ci.cst_lastname						AS last_name,
		la.cntry							AS country,
		ci.cst_marital_status				AS marital_status,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
		-- we use the CRM to be the master of the gender info
		ELSE COALESCE(ca.gen,'n/a') 
		-- then if it's 'n/a' in CRM gender column, we use the data in erp gender column
		-- and we use COALESCE to replace any null in erp gnd column with 'n/a' and then add it to the new_gen column
	END AS gender,
		ca.bdate							AS birthdate,
		ci.cst_create_date					AS create_date
		
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON			ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON			ci.cst_key = la.CID

--##########################################################
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
--Creating the 2nd gold dimention table (gold.dim_products), and set as VIEW.
CREATE VIEW gold.dim_products AS 
	SELECT
		ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key, -- surogate key
		pn.prd_id		AS product_id,
		pn.prd_key		AS product_number,
		pn.prd_nm		AS product_name,
		pn.cat_id		AS category_id,
		pc.cat			AS category,
		pc.subcat		AS sub_category,
		pc.maintenance,
		pn.prd_cost		AS cost,
		pn.prd_line		AS product_line,
		pn.prd_start_dt AS start_da

	FROM silver.crm_prd_info pn
	LEFT JOIN silver.erp_PX_CAT_G1V2 pc
	ON pn.cat_id = pc.ID
	WHERE prd_end_dt IS NULL -- we filter all historical data and keeping only the current dates

--##########################################################
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
--Creating the 1st fact gold table (gold.fact_sales), and set as VIEW.
CREATE VIEW gold.fact_sales	AS
SELECT
sd.sls_ord_num		AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt		AS order_date,
sd.sls_ship_dt		AS shipping_date,
sd.sls_due_dt		AS due_date,
sd.sls_sales		AS sales_amount,
sd.sls_quantity		AS quantity,
sd.sls_price		AS price

FROM silver.crm_sales_details	AS sd
LEFT JOIN gold.dim_products		AS pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers	AS cu
ON sd.sls_cust_id = cu.cutomer_id
