/*
		Project Name: Car Sales in Nigeria 
		Author: Hauwa M
		Data Source: https://www.kaggle.com/datasets/oyekanmiolamilekan/nigeria-car-sales-dataset
		File name: Createtables.sql
		Project Description: This file documents create statements needed to analyze the car sales 
		data in Nigeria, the cleaning process, and findings based on the data collected. 
*/

/*		Facts: There are 2,894 rows in the data set downloaded in August 2023 via the source listed above.
		The year of manufacture spans from 1988 to 2023.
		Goal: The goal of this project is for exploratory purposes to better understand car buying trends in Nigeria
		over the period when this data was collected. 
		Limitations: There are some nulls in vital fields like mileage, fuel_type, etc. 
		There are also some questionable/erroneous values in the mileage field, an example was 7,402,6754
*/
--Create the schema for the table for importing data
CREATE SCHEMA dbo GO;

--Creat the main table
DROP TABLE IF EXISTS [dbo].[CarSalesNigeria]; 
CREATE TABLE [dbo].[CarSalesNigeria](
	[car_sale_id] [SMALLINT] NOT NULL,
	[car_id] [NVARCHAR](50) NOT NULL,
	[description] [NVARCHAR](100) NOT NULL,
	[amount] [INT] NOT NULL,
	[region] [NVARCHAR](50) NOT NULL,
	[make] [NVARCHAR](50) NOT NULL,
	[model] [NVARCHAR](50) NOT NULL,
	[year_of_man] [SMALLINT] NOT NULL,
	[color] [NVARCHAR](50) NULL,
	[condition] [NVARCHAR](50) NULL,
	[mileage] [INT] NULL,
	[engine_size] [INT] NULL,
	[selling_condition] [NVARCHAR](50) NULL,
	[bought_condition] [NVARCHAR](50) NULL,
	[trim] [NVARCHAR](50) NULL,
	[drive_train] [NVARCHAR](50) NULL,
	[reg_city] [NVARCHAR](50) NULL,
	[seat] [TINYINT] NULL,
	[num_cylinder] [TINYINT] NULL,
	[horse_power] [SMALLINT] NULL,
	[body_build] [NVARCHAR](50) NULL,
	[fuel_type] [NVARCHAR](50) NULL,
	[transmission] [NVARCHAR](50) NULL,
PRIMARY KEY CLUSTERED 
([car_sale_id] ASC)
) ON [PRIMARY]
GO

--Import data from CSV files found here - > https://github.com/hmuibi/CarSalesNigeria/tree/main/scripts
--I was using sql server so I imported data using the the SQL wizard
--More info. can be found here ->https://learn.microsoft.com/en-us/sql/relational-databases/import-export/import-flat-file-wizard?view=sql-server-ver16

--Once the data has been imported, verify that you have the anticipated data
SELECT * FROM dbo.carsalesnigeria ORDER BY mileage--there are 2894 records in the table

			/*****************************************Data Cleaning*****************************************/
DROP TABLE IF EXISTS #CleaningRegCity
--The first step is to make the reg_city readable, I chose to make it camel case 
SELECT 
[car_sale_id], [car_id], [description], [amount], [region], [make], [model], [year_of_man], [color], 
[condition], [mileage], [engine_size], [selling_condition], [bought_condition], [trim], [drive_train], 
[reg_city], [seat], [num_cylinder], [horse_power], [body_build], [fuel_type], [transmission],
REPLACE(COALESCE ( NULLIF ( [ssis].[fn_CamelCase] ( reg_city ), '' ), NULL ), 'State', '') AS reg_city_replacement 
INTO #CleaningRegCity
FROM dbo.carsalesnigeria

--SELECT * FROM #CleaningRegCity

--Second step in cleaning is to correctly deduce the region's state using the region field so as to identify the volume by states in Nigeria.
--There are only 36 states in Nigeria so it was not terrible to write a case statement, an alternative to this would be to store the 36 states in a list
--and then deduce the state by checking the region against the stored list. I chose to go the case statement route. 
--After cleaning, the new records are dumped into a temp table
DROP TABLE IF EXISTS #FinalTable
SELECT [car_sale_id], [car_id], [description], [amount], [region], [make], [model], [year_of_man], [color], 
[condition], [mileage], [engine_size], [selling_condition], [bought_condition], [trim], [drive_train], 
[reg_city_replacement] AS [reg_city], [seat], [num_cylinder], [horse_power], [body_build], [fuel_type], [transmission],
CASE WHEN region like '%Abuja%' THEN 'Abuja'
WHEN region LIKE '%Abia%'THEN 'Abia'
WHEN region LIKE '%Adamawa%'THEN 'Adamawa'
WHEN region LIKE '%Akwa Ibom%' THEN 'Akwa Ibom'
WHEN region LIKE '%Anambra%' THEN 'Anambra'
WHEN region LIKE '%Bauchi%' THEN 'Bauchi'
WHEN region LIKE '%Bayelsa%' THEN 'Bayelsa'
WHEN region LIKE '%Benue%' THEN 'Benue'
WHEN region LIKE '%Borno%' THEN 'Borno'
WHEN region LIKE '%Cross River%' THEN 'Cross River'
WHEN region LIKE '%Delta%' THEN 'Delta'
WHEN region LIKE '%Ebonyi%' THEN 'Ebonyi'
WHEN region LIKE '%Edo%' THEN 'Edo'
WHEN region LIKE '%Ekiti%' THEN 'Ekiti'
WHEN region LIKE '%Enugu%' THEN 'Enugu'
WHEN region LIKE '%Gombe%' THEN 'Gombe'
WHEN region LIKE '%Imo%' THEN 'Imo'
WHEN region LIKE '%Jigawa%' THEN 'Jigawa'
WHEN region LIKE '%Kaduna%' THEN 'Kaduna'
WHEN region LIKE '%Kano%' THEN 'Kano'
WHEN region LIKE '%Katsina%' THEN 'Katsina'
WHEN region LIKE '%Kebbi%' THEN 'Kebbi'
WHEN region LIKE '%Kogi%' THEN 'Kogi'
WHEN region LIKE '%Kwara%' THEN 'Kwara'
WHEN region LIKE '%Lagos%' THEN 'Lagos'
WHEN region LIKE '%Nassarawa%'THEN 'Nassarawa'
WHEN region LIKE '%Niger%'THEN 'Niger'
WHEN region LIKE '%Ogun%' THEN 'Ogun'
WHEN region LIKE '%Ondo%' THEN 'Ondo'
WHEN region LIKE '%Osun%'THEN 'Osun'
WHEN region LIKE '%Oyo%' THEN 'Oyo'
WHEN region LIKE '%Plateau%'THEN 'Plateau'
WHEN region LIKE '%Rivers%'THEN 'Rivers'
WHEN region LIKE '%Sokoto%'THEN 'Sokoto'
WHEN region LIKE '%Taraba%' THEN 'Taraba'
WHEN region LIKE '%Yobe%' THEN 'Yobe'
WHEN region LIKE '%Zamfara%' THEN 'Zamfara'
END AS reg_state INTO #FinalTable
FROM #CleaningRegCity

--Validating after data clean up and checking against the region field to validate states
--The original field reg_city has erroneous/incomplete data which necessitated going back to the original field "region" to determine state and city
--The check below validates that the new field deduced in the temp table above is relying on the original field "region"
SELECT * FROM #FinalTable 
WHERE region  NOT LIKE '%' + reg_state + '%' 
ORDER BY reg_city

			/*****************************************Data Exploration*****************************************/

			/*******Used Cars Section*********/
-- ** 1. What percentage is brand new vs used? 
SELECT COUNT(*) FROM #FinalTable WHERE condition IN ('Nigerian Used', 'Foreign Used') --2871
SELECT COUNT(*) FROM #FinalTable WHERE condition IN ('Brand New') --23

-- ** 2. Delving into used cars, what portion is Nigerian used vs Foreign used? Foreign used means imported for selling purposes
--This shows that most of the used cars bought in nigeria (when this data was collected) were not imported
SELECT COUNT(*) FROM #FinalTable WHERE condition IN ('Nigerian Used') --2374
SELECT COUNT(*) FROM #FinalTable WHERE condition IN ('Foreign Used') --497

-- ** 3. What segments make up the Nigerian used cars section? i.e. was the seller the first owner of the car or also bought it from a previous owner
SELECT * FROM #FinalTable WHERE condition IN ('Nigerian Used')
--The result shows that 65% of the cars were bought from a previous owner, 42% were imported and only 3% was classified as brand new
SELECT bought_condition, COUNT(*) FROM [dbo].[carsalesnigeria] WHERE condition IN ('Nigerian Used') GROUP BY bought_condition

--** 4a. What are vehicle classification by propulsion systems for the Nigerian used cars and Foreign used cars?
SELECT * FROM #FinalTable WHERE condition IN ('Nigerian Used')
--The result shows that Petrol fueled cars dominate the number of Nigerian used cars bought with 99% and the closest in line are Hybrid cars with less than 1%
SELECT fuel_type, Records, CAST (CAST(records AS DECIMAL(17,2))/CAST(A.totalcount AS DECIMAL(17,2)) AS DECIMAL(17,7))* 100 FROM (
SELECT fuel_type, COUNT(*) AS Records, SUM(COUNT(*)) OVER() AS totalcount FROM #FinalTable WHERE condition IN ('Nigerian Used') GROUP BY fuel_type
)A 

--** 4b. Same question but for Foreign used cars
SELECT * FROM #FinalTable WHERE condition IN ('Foreign Used')
--The result shows that Petrol fueled cars dominate the number of Foreign used cars bought with 98.5% and the closest in line are Hybrid cars with less than 1%
SELECT fuel_type, Records, CAST (CAST(records AS DECIMAL(17,2))/CAST(A.totalcount AS DECIMAL(17,2)) AS DECIMAL(17,7))* 100 FROM (
SELECT fuel_type, COUNT(*) AS Records, SUM(COUNT(*)) OVER() AS totalcount FROM #FinalTable WHERE condition IN ('Foreign Used') GROUP BY fuel_type
)A 

--** 5. What states have the most activity in used car sales?
--The result : No surprises that Lagos has the highest unmber of cars bought with Abuja falling in second place.
--The surprising part for me is that Oyo came in third place
SELECT reg_state, COUNT ( reg_state) AS Numberof FROM #FinalTable WHERE condition IN ('Nigerian Used') GROUP BY reg_state ORDER BY COUNT ( reg_state)
SELECT reg_state, COUNT ( reg_state) FROM #FinalTable WHERE condition IN ('Foreign Used') GROUP BY reg_state ORDER BY COUNT ( reg_state)

--** 6a. What types of cars were bought in the used car categories?
SELECT make, COUNT(make) AS NoOfCarsSold FROM #FinalTable WHERE condition IN ('Nigerian Used') GROUP BY make ORDER BY COUNT(make) DESC

--** 6b. What types of cars were bought in the used car categories?
SELECT make, COUNT(make) AS NoOfCarsSold FROM #FinalTable WHERE condition IN ('Foreign Used') GROUP BY make ORDER BY COUNT(make) DESC

--** 6c. What types of used cars were bought by state?
SELECT reg_state, COUNT(make) AS NoOfCarsSoldByState FROM #FinalTable WHERE condition IN ('Nigerian Used', 'Foreign Used') GROUP BY reg_state 
ORDER BY COUNT(make) DESC

--** 6d. What types of brand new cars were bought by state?
SELECT reg_state, COUNT(make) AS NoOfCarsSoldByState FROM #FinalTable WHERE condition IN ('Brand New') GROUP BY reg_state 
ORDER BY COUNT(make) DESC

--**7. What types of transmission make up the bought Used cars?
SELECT transmission, COUNT(transmission) AS CountsByTransmission FROM #FinalTable WHERE condition IN ('Nigerian Used', 'Foreign Used') AND transmission IS NOT NULL 
GROUP BY transmission

			/*******New Cars Section*********/
--**1. How many new cars were sold? 
SELECT COUNT(*) FROM #FinalTable WHERE condition IN ('Brand New') --23

--**2. What are vehicle classification by propulsion systems for Brand New cars?
SELECT * FROM #FinalTable WHERE condition IN ('Brand New')
--The result shows that Petrol fueled cars dominate the number of Nigerian used cars bought with 99% and the closest in line are Hybrid cars with less than 1%
SELECT fuel_type, Records, CAST (CAST(records AS DECIMAL(17,2))/CAST(A.totalcount AS DECIMAL(17,2)) AS DECIMAL(17,7))* 100 FROM (
SELECT fuel_type, COUNT(*) AS Records, SUM(COUNT(*)) OVER() AS totalcount FROM #FinalTable WHERE condition IN ('Brand New')
AND fuel_type IS NOT NULL GROUP BY fuel_type
)A 

--**3. What states have the most activity in Brand New cars?
--The result : No surprises that Lagos has the highest unmber of cars bought with Abuja falling in second place.
--The surprising part for me is that Imp came in third place.
SELECT reg_state, COUNT ( reg_state) AS NumberofCars FROM #FinalTable WHERE condition IN ('Brand New') GROUP BY reg_state ORDER BY COUNT ( reg_state)

--**4. What types of New cars were bought?
SELECT make, COUNT(make) AS NoOfCarsSold FROM #FinalTable WHERE condition IN ('Brand New') GROUP BY make ORDER BY COUNT(make) DESC

--**5. What types of New cars were bought by make and state?
SELECT reg_state, make,  COUNT(condition) AS NoOfCarsSoldByState FROM #FinalTable WHERE condition IN ('Brand New') 
GROUP BY reg_state, make ORDER BY reg_state

--**6. What types of transmission made up the New cars that were?
SELECT transmission, COUNT(transmission) FROM #FinalTable WHERE condition IN ('Brand New') GROUP BY transmission