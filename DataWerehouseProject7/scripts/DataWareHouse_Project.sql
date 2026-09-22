/*
=============================================================
Create Database and Schemas
=============================================================
Description:
    This script creates the 'DataWarehouse' database and prepares
    the required schemas for the data warehouse architecture.
    If a database with the same name already exists, it is first
    deleted and then recreated. The script also creates the
    'bronze', 'silver', and 'gold' schemas.

Note:
    Running this script will erase the current 'DataWarehouse'
    database and all stored data. Verify that any important data
    has been backed up before execution.
=============================================================
*/

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO


/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


	if OBJECT_ID ('bronze.crm_customer_inf','U') is not null
		drop table bronze.crm_customer_inf;
	create table bronze.crm_customer_inf
	(
		cst_id int ,
		cst_key nvarchar(50),
		cst_firstname nvarchar(50),
		cst_lastname nvarchar(50),
		cst_marital_status nvarchar(50),
		cst_gndr nvarchar(50),
		cst_create_date date
	)

	if OBJECT_ID ('bronze.crm_prd_info','U') is not null
		drop table bronze.crm_prd_info;
	create table bronze.crm_prd_info
	(
		prd_id int ,
		prd_key nvarchar(50),
		prd_nm nvarchar(50),
		prd_cost int ,
		prd_line nvarchar(50),
		prd_start_dt datetime ,
		prd_end_dt datetime
	)



	if OBJECT_ID ('bronze.crm_sales_details','U') is not null
		drop table bronze.crm_sales_details;

	create table bronze.crm_sales_details
	(
		sls_ord_num nvarchar(50) ,
		sls_prd_key nvarchar(50),
		sls_cust_id int,
		sls_order_dt int,
		sls_ship_dt int,
		sls_due_dt int,
		sls_sales int,
		sls_quantity int,
		sls_price int
	)


	if OBJECT_ID ('bronze.erp_loc_a101','U') is not null
		drop table bronze.erp_loc_a101;
	create table bronze.erp_loc_a101
	(
		CID nvarchar(50),
		CNTRY nvarchar(50)
	)

	if OBJECT_ID ('bronze.erp_cust_az12','U') is not null
		drop table bronze.erp_cust_az12;
	create table bronze.erp_cust_az12
	(
		CID nvarchar(50),
		BDATE date,
		GEN nvarchar(50)
	)

	if OBJECT_ID ('bronze.erp_px_cat_g1v2','U') is not null
		drop table bronze.erp_px_cat_g1v2;
	create table bronze.erp_px_cat_g1v2
	(
		ID  nvarchar(50),
		CAT  nvarchar(50),
		SUBCAT  nvarchar(50),
		MAINTENANCE  nvarchar(50)
	);
GO

/*====================================================================================
	1.Creating Stored Procedure  : bronze.load_silver
	2.Loadind Data Using Bulk Insert : from CRM and ERP Sources (.csv)
	3.Handling Bulk Insert Errors During Loadind Data From from 'CRM and ERP' to 'bronze.load_silver'
======================================================================================*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
	DECLARE @START_TIME DATETIME, @END_TIME DATETIME, @BATCH_START_TIME DATETIME, @BATCH_END_TIME DATETIME

	BEGIN TRY
		SET @BATCH_START_TIME=GETDATE();
		print'===============================================================';
		print'Loading Bronze Layer';
		print'===============================================================';

		print'---------------------------------------------------------------';
		print'Loading From CRM';
		print'---------------------------------------------------------------';

		SET @START_TIME=GETDATE()
		print '>>>> Truncate table: bronze.crm_customer_inf';
		truncate table bronze.crm_customer_inf;

		print '>>>> Insert Data Into: bronze.crm_customer_inf';
		bulk insert bronze.crm_customer_inf
		from 'C:\Users\user\Desktop\DataWerehouseProject7\datasets\source_crm\cust_info.csv'
		with (firstrow = 2, fieldterminator = ',', tablock);
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'


		SET @START_TIME=GETDATE()
		print '>>>> Truncate table: bronze.crm_prd_info';
		truncate table bronze.crm_prd_info;

		print '>>>> Insert Data Into: bronze.crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'C:\Users\user\Desktop\DataWerehouseProject7\datasets\source_crm\prd_info.csv'
		with (firstrow = 2, fieldterminator = ',', tablock);
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'	


		SET @START_TIME=GETDATE()
		print '>>>> Truncate table: bronze.crm_sales_details';
		truncate table bronze.crm_sales_details;

		print '>>>> Insert Data Into: bronze.crm_sales_details';
		bulk insert bronze.crm_sales_details
		from 'C:\Users\user\Desktop\DataWerehouseProject7\datasets\source_crm\sales_details.csv'
		with (firstrow = 2, fieldterminator = ',', tablock);
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'		


		print'---------------------------------------------------------------';
		print'Loading From ERP';
		print'---------------------------------------------------------------';


		SET @START_TIME=GETDATE()
		print '>>>> Truncate table: bronze.erp_loc_a101';
		truncate table bronze.erp_loc_a101;

		print '>>>> Insert Data Into: bronze.erp_loc_a101';
		bulk insert bronze.erp_loc_a101
		from 'C:\Users\user\Desktop\DataWerehouseProject7\datasets\source_erp\LOC_A101.csv'
		with (firstrow = 2, fieldterminator = ',', tablock);
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'		

		SET @START_TIME=GETDATE()
		print '>>>> Truncate table: bronze.erp_cust_az12';
		truncate table bronze.erp_cust_az12;

		print '>>>> Insert Data Into: bronze.erp_cust_az12';
		bulk insert bronze.erp_cust_az12
		from 'C:\Users\user\Desktop\DataWerehouseProject7\datasets\source_erp\CUST_AZ12.csv'
		with (firstrow = 2, fieldterminator = ',', tablock);
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'		

		SET @START_TIME=GETDATE()
		print '>>>> Truncate table: bronze.erp_px_cat_g1v2';
		truncate table bronze.erp_px_cat_g1v2;

		print '>>>> Insert Data Into: bronze.erp_px_cat_g1v2';
		bulk insert bronze.erp_px_cat_g1v2
		from 'C:\Users\user\Desktop\DataWerehouseProject7\datasets\source_erp\PX_CAT_G1V2.csv'
		with (firstrow = 2, fieldterminator = ',', tablock);
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'	
		

		SET @BATCH_END_TIME=GETDATE()
		PRINT '========================================================='
		PRINT 'LOADING BRONZE LAYER IS COMPLITED ';
		PRINT ' -TOTAL LOAD DERATION: ' +CAST(DATEDIFF(SECOND,@BATCH_START_TIME,@BATCH_END_TIME) AS NVARCHAR) + 'SECONDS';
		PRINT '========================================================='

	END TRY
	BEGIN CATCH
		PRINT '========================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'ERROR MESSAGE:'+ERROR_MESSAGE();
		PRINT 'ERROR NUMBER:'+CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE:'+CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================='
	END CATCH
END;
GO
exec bronze.load_bronze

/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Overview:
    This script defines the table structure for the 'silver' schema.
    Existing tables with the same names are dropped before new ones
    are created to ensure the schema is up to date.

Usage:
    Execute this script to initialize or recreate the Silver layer
    database objects.
===============================================================================
*/

	if OBJECT_ID ('silver.crm_customer_inf','U') is not null
		drop table silver.crm_customer_inf;
	create table silver.crm_customer_inf
	(
		cst_id int ,
		cst_key nvarchar(50),
		cst_firstname nvarchar(50),
		cst_lastname nvarchar(50),
		cst_marital_status nvarchar(50),
		cst_gndr nvarchar(50),
		cst_create_date date,
		dwh_create_date datetime2 default getdate()
	)


	if OBJECT_ID ('silver.crm_prd_info','U') is not null
		drop table silver.crm_prd_info;
	create table silver.crm_prd_info
	(
		prd_id int ,
		cat_id nvarchar(50),
		prd_key nvarchar(50),
		prd_nm nvarchar(50),
		prd_cost int ,
		prd_line nvarchar(50),
		prd_start_dt datetime ,
		prd_end_dt datetime,
		dwh_create_date datetime2 default getdate()
	)


	if OBJECT_ID ('silver.crm_sales_details','U') is not null
		drop table silver.crm_sales_details;

	create table silver.crm_sales_details
	(
		sls_ord_num nvarchar(50) ,
		sls_prd_key nvarchar(50),
		sls_cust_id int,
		sls_order_dt date,
		sls_ship_dt date,
		sls_due_dt date,
		sls_sales int,
		sls_quantity int,
		sls_price int,
		dwh_create_date datetime2 default getdate()
	)


	if OBJECT_ID ('silver.erp_loc_a101','U') is not null
		drop table silver.erp_loc_a101;
	create table silver.erp_loc_a101
	(
		CID nvarchar(50),
		CNTRY nvarchar(50),
		dwh_create_date datetime2 default getdate()
	)


	if OBJECT_ID ('silver.erp_cust_az12','U') is not null
		drop table silver.erp_cust_az12;
	create table silver.erp_cust_az12
	(
		CID nvarchar(50),
		BDATE date,
		GEN nvarchar(50),
		dwh_create_date datetime2 default getdate()
	)


	if OBJECT_ID ('silver.erp_px_cat_g1v2','U') is not null
		drop table silver.erp_px_cat_g1v2;
	create table silver.erp_px_cat_g1v2
	(
		ID  nvarchar(50),
		CAT  nvarchar(50),
		SUBCAT  nvarchar(50),
		MAINTENANCE  nvarchar(50),
		dwh_create_date datetime2 default getdate()
	);
GO

/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Description:
    This procedure transfers data from the Bronze layer to the Silver
    layer by performing extraction, transformation, and loading (ETL)
    operations.

Operations:
    - Removes existing records from the Silver tables.
    - Reads data from the Bronze tables.
    - Cleans and transforms the data.
    - Populates the Silver tables with the processed results.

Parameters:
    None.

Example:
    EXEC silver.load_silver;
===============================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN 
	DECLARE @START_TIME DATETIME, @END_TIME DATETIME, @BATCH_START_TIME DATETIME, @BATCH_END_TIME DATETIME

	BEGIN TRY
		SET @BATCH_START_TIME=GETDATE();
		print'===============================================================';
		print'Loading Silver Layer';
		print'===============================================================';

		print'---------------------------------------------------------------';
		print'Loading From CRM';
		print'---------------------------------------------------------------';


		/*================================================================
		Data Celeaning & Inserting:  silver.crm_customer_inf
		==================================================================*/

		SET @START_TIME=GETDATE()
		print'>>>>>Truncate Table: silver.crm_customer_inf'
		Truncate table silver.crm_customer_inf

		print'>>>>>Inserting Data Into: silver.crm_customer_inf'
		INSERT INTO silver.crm_customer_inf
		(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		select
			cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,
			trim(cst_lastname) as cst_lastname,
			case 
				when upper(trim(cst_marital_status))='M' then 'Married'
				when upper(trim(cst_marital_status))='S' then 'Single'
				else 'n/a'
			end cst_marital_status,
			case 
				when upper(trim(cst_gndr))='F' then 'Female'
				when upper(trim(cst_gndr))='M' then 'Men'
				else 'n/a'
			end cst_gndr,
			cst_create_date	
		from
		(
		select
		*,
		row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_customer_inf
		where cst_id is not null
		) t where flag_last=1
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'


		/*================================================================
					Data Celeaning & Inserting:  silver.crm_prd_info
		==================================================================*/
		SET @START_TIME=GETDATE()
		print'>>>>>Truncate Table: silver.crm_prd_info'
		Truncate table silver.crm_prd_info

		print'>>>>>Inserting Data Into: silver.crm_prd_info'
		insert into silver.crm_prd_info
		(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt

		)
		select
			prd_id,
			replace(substring(prd_key,1,5),'-','_') as cat_id,
			substring(prd_key,7,len(prd_key)) as prd_key,
			prd_nm,
			isnull(prd_cost,0) as prd_cost,
			case upper(trim(prd_line))
				when 'M' then 'Mountin'
				when 'R' then 'Road'
				when 'S' then 'Other Sales'
				when 'T' then 'Touring'
				else 'n/a'
			end prd_line,
			cast(prd_start_dt as date) as prd_start_dt,
			cast(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as Date) as prd_end_dt
		from bronze.crm_prd_info
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'

		/*================================================================
				Data Celeaning & Inserting:  silver.crm_sales_details
		==================================================================*/

		SET @START_TIME=GETDATE()
		print'>>>>>Truncate Table: silver.crm_sales_details'
		Truncate table silver.crm_sales_details
		print'>>>>>Inserting Data Into: silver.crm_sales_details'
		insert into silver.crm_sales_details
		(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		select
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case 
				when sls_order_dt=0 or len(sls_order_dt)!=8 then null
				else cast(cast(sls_order_dt as varchar)as Date) 
			end sls_order_dt,
			case 
				when sls_ship_dt=0 or len(sls_ship_dt)!=8 then null
				else cast(cast(sls_ship_dt as varchar)as Date) 
			end sls_ship_dt,
			case 
				when sls_due_dt=0 or len(sls_due_dt)!=8 then null
				else cast(cast(sls_due_dt as varchar)as Date) 
			end sls_due_dt,
			case 
				when sls_sales IS NULL OR sls_sales <= 0 or sls_sales != sls_quantity * sls_price
				then sls_quantity*abs(sls_price)
				else sls_sales
			end sls_sales,
			sls_quantity,
			case 
				when sls_price is null or sls_price<=0 
				then sls_sales/nullif(sls_quantity,0)
				else sls_price
			end sls_price
		from bronze.crm_sales_details
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'

		/*================================================================
				Data Celeaning & Inserting:  silver.erp_loc_a101
		==================================================================*/

		SET @START_TIME=GETDATE()
		print'>>>>>Truncate Table: silver.erp_loc_a101'
		Truncate table silver.erp_loc_a101
		print'>>>>>Inserting Data Into: silver.erp_loc_a101'
		insert into silver.erp_loc_a101
		(
			CID,
			CNTRY
		)
		select
			replace(CID,'-','') as CID,
			case 
				when trim(CNTRY)='DE' then 'Germany'
				when trim(CNTRY) in('US','USA') then 'United States'
				when trim(CNTRY)='' or trim(CNTRY) is null then  'n/a'
				else trim(CNTRY)
			end CNTET
		from bronze.erp_loc_a101
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'

		/*================================================================
				Data Celeaning & Inserting:  silver.erp_cust_az12
		==================================================================*/

		SET @START_TIME=GETDATE()
		print'>>>>>Truncate Table: silver.erp_cust_az12 '
		Truncate table silver.erp_cust_az12
		print'>>>>>Inserting Data Into: silver.erp_cust_az12'
		insert into silver.erp_cust_az12  
		(
			CID,
			BDATE,
			GEN
		)
		select
			case 
				when CID like 'NAS%' then substring(CID,4,len(cid)) 
				else CID
			end as CID,
			case 
				when BDATE>getdate() then null
				else BDATE
			end as BDATE,
			case 
				when upper(trim(GEN)) in ('F','Female') then 'Female'
				when upper(trim(GEN)) in ('M','Male') then 'Male'
				else 'n/a'
			end as GEN
		from bronze.erp_cust_az12
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'

		/*================================================================
				Data Celeaning & Inserting:  silver.erp_px_cat_g1v2
		==================================================================*/

		SET @START_TIME=GETDATE()
		print'>>>>>Truncate Table: silver.erp_px_cat_g1v2'
		Truncate table silver.erp_px_cat_g1v2
		print'>>>>>Inserting Data Into: silver.erp_px_cat_g1v2'
		insert into silver.erp_px_cat_g1v2
		(
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		)
		select
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		from bronze.erp_px_cat_g1v2
		SET @END_TIME=GETDATE()
		PRINT'LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS'
		PRINT'>>>.------------------------'


		SET @BATCH_END_TIME=GETDATE()
		PRINT '========================================================='
		PRINT 'LOADING SILVER LAYER IS COMPLITED ';
		PRINT ' -TOTAL LOAD DERATION: ' +CAST(DATEDIFF(SECOND,@BATCH_START_TIME,@BATCH_END_TIME) AS NVARCHAR) + 'SECONDS';
		PRINT '========================================================='

	END TRY
	BEGIN CATCH
		PRINT '========================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'ERROR MESSAGE:'+ERROR_MESSAGE();
		PRINT 'ERROR NUMBER:'+CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE:'+CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================='
	END CATCH
END;
GO

exec silver.load_silver
/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Overview:
    This script creates the Gold layer views within the data warehouse.

    The Gold layer stores the final business-facing dimension and fact
    tables based on the Star Schema model. The views retrieve and refine
    data from the Silver layer, applying the necessary transformations
    to generate reliable datasets for reporting and analytical purposes.

Usage:
    - Use these views as the primary source for dashboards, reports,
      and business analysis.
===============================================================================
*/


IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
create view gold.dim_customers as
select
	row_number() over(order by cst_id) as customer_key,
	cs.cst_id as customer_id,
	cs.cst_key as customer_number,
	cs.cst_firstname as first_name,
	cs.cst_lastname as last_name,
	la.CNTRY as country,
	cs.cst_marital_status as marital_status,
	case 
		when cs.cst_gndr!='n/a 'then cs.cst_gndr --CRM is master for gender integration
		else coalesce(ca.GEN,'n/a')
	end as gender,
	ca.BDATE as birth_date,
	cs.cst_create_date as create_date
from silver.crm_customer_inf cs
left join silver.erp_cust_az12 ca
on cs.cst_key=ca.CID
left join silver.erp_loc_a101 la
on cs.cst_key=la.CID;
GO


IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

create view gold.dim_products as
select
	row_number() over(order by pn.prd_start_dt,pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.CAT as category ,
	pc.SUBCAT as subcategory,
	pc.MAINTENANCE as maintance,
	pn.prd_cost as product_cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.ID
where pn.prd_end_dt is null;
GO

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
create view gold.fact_sales as
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price as price
FROM silver. crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;
GO

select*from gold.fact_sales
select*from gold.dim_products
select*from gold.dim_customers

--exec silver.load_silver
--exec bronze.load_bronze
