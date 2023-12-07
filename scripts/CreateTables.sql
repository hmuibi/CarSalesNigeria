/*
Car Sales in Nigeria 
Author: Hauwa M
Data Source: https://www.kaggle.com/datasets/oyekanmiolamilekan/nigeria-car-sales-dataset
File name: Createtables.sql
Project Description: This file documents create statements needed to analyze the car sales 
data in Nigeria, the cleaning process, and findings based on the data collected. 
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
SELECT * FROM dbo.carsalesnigeria --there are 2894 records in the table

--Cleaning the data
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
-- condition IN ('Nigerian Used', 'Foreign Used') ORDER BY mileage

--Second step in cleaning is to correctly deduce the region's state using the region field so as to identify the volume by states in Nigeria.
--There are only 36 states in Nigeria so it was not terrible to write a case statement, an alternative to this would be to store the 36 states in a list
--and then deduce the state by checking the region against the stored list. I chose to go the case statement route. 
--After the deduction, the new records are dumped into a temp table
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

--Validation after data clean up and validation against the states in Nigeria
--The original field reg_city has erroneous/incomplete data which necessitated going back to the original field "region" to determine state and city
--The check below validates that the new field deduced in the temp table above is relying on the original field "region"
SELECT * FROM #FinalTable 
WHERE region  NOT LIKE '%' + reg_state + '%' 
ORDER BY reg_city

/*This second kicks off the exploration portion of this project*/

/*Used Cars Section*/
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

--** 5. What states have the most activity in car sales?
--The result : No surprises that Lagos has the highest unmber of cars bought with Abuja falling in second place.
--The surprising part for me is that Oyo came in third place
SELECT reg_state, COUNT ( reg_state) FROM #FinalTable GROUP BY reg_state ORDER BY COUNT ( reg_state)

--** 4b. What states have the most activity in car sales?
--Looking at Oyo's data, as suspected and from driving around Nigeria, Toyota represents 47% of cars bought and registered in Oyo state with 128 out of 270
--with a close second being Honda with only 24 cars sold and registered. 
--Oyo has 27 different types of cars
SELECT make, COUNT(make) 
FROM #FinalTable WHERE reg_state = 'Oyo' GROUP BY make ORDER BY COUNT(make)
--
SELECT condition, COUNT(condition) 
FROM #FinalTable WHERE reg_state = 'Oyo' GROUP BY condition ORDER BY COUNT(condition)

SELECT * FROM #FinalTable WHERE  reg_state = 'Oyo'
SELECT DISTINCT condition FROM #FinalTable WHERE  reg_state = 'Oyo'

--Looking at Abuja's data, Toyota still represents the lion share with 37% of cars and not so close second being Mercedes Benz represnting 13%
--Abuja has 32 different types of cars
SELECT make, COUNT(make) 
FROM #FinalTable WHERE reg_state = 'Abuja' GROUP BY make ORDER BY COUNT(make)

SELECT condition, COUNT(condition) 
FROM #FinalTable WHERE reg_state = 'Abuja' GROUP BY condition ORDER BY COUNT(condition)


SELECT DISTINCT condition FROM #FinalTable WHERE  reg_state = 'Abuja'

--Looking at Lagos, again Toyota remains undefeated with 39% of car sales while Honda the next in line represented 9%
--Lagos has the most diversity in cars bought with 36 types of cars 
SELECT make, COUNT(make) 
FROM #FinalTable WHERE reg_state = 'Lagos' GROUP BY make ORDER BY COUNT(make)

SELECT condition, COUNT(condition) 
FROM #FinalTable WHERE reg_state = 'Lagos' GROUP BY condition ORDER BY COUNT(condition)

SELECT DISTINCT condition FROM #FinalTable WHERE  reg_state = 'Lagos'


/*
Facts
There are 2,894 rows in the data set collected in August 2023
Goal: Exploratory data analysis to understand car buying trends in Nigeria
Observations
--Limitations include the fact that the mileage for the brand new cars is high considering the fact that they are brand new. 
--Also according to the data, Nigerians 
99% of car sales are not brand new, we are a used car nation - only 1 percent are brand new cars

Out of the used cars, 83% of the cars are Nigerian used while 17% are foreign used
*/
SELECT car_sale_id, description, amount, region, make, model, 
year_of_man, mileage, fuel_type, transmission FROM dbo.carsalesnigeria WHERE condition = 'Brand New' ORDER BY year_of_man

SELECT car_sale_id, description, amount, region, make, model, 
year_of_man, mileage, fuel_type, transmission FROM dbo.carsalesnigeria WHERE condition = 'Brand New'

SELECT DISTINCT condition FROM dbo.carsalesnigeria