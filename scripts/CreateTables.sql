/*
This file will document all create statements for tables needed to analyze the car sales data
*/

SELECT * FROM dbo.carsalesnigeria --2894

--What percentage is brand new vs used
SELECT COUNT(*) FROM dbo.carsalesnigeria WHERE condition IN ('Nigerian Used', 'Foreign Used') --2871
SELECT COUNT(*) FROM dbo.carsalesnigeria WHERE condition IN ('Brand New') --23


-- Delving into used cars 
SELECT COUNT(*) FROM dbo.carsalesnigeria WHERE condition IN ('Nigerian Used') --2374
SELECT COUNT(*) FROM dbo.carsalesnigeria WHERE condition IN ('Foreign Used') --497

--Cleaning the data
DROP TABLE IF EXISTS #temp
--The first step is to make the reg_city readable, I chose to make it camel case 
SELECT 
[car_sale_id], [car_id], [description], [amount], [region], [make], [model], [year_of_man], [color], 
[condition], [mileage], [engine_size], [selling_condition], [bought_condition], [trim], [drive_train], 
[reg_city], [seat], [num_cylinder], [horse_power], [body_build], [fuel_type], [transmission],
REPLACE(COALESCE ( NULLIF ( [ssis].[fn_CamelCase] ( reg_city ), '' ), NULL ), 'State', '') AS reg_city_replacement 
INTO #temp
FROM dbo.carsalesnigeria

--SELECT * FROM #temp
-- condition IN ('Nigerian Used', 'Foreign Used') ORDER BY mileage

--Second step in cleaning is to correctly deduce the region's state using the region field so as to identify the volume by states in Nigeria.
--There are only 36 states in Nigeria so it was not terrible to write a case statement, an alternative to this would be to store the 36 states in a list
--and then deduce the state by checking the region against the stored list. I chose to go the case statement route. 
--After the deduction, the new records are dumped into a temp table
DROP TABLE IF EXISTS #temp2
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
END AS reg_state INTO #temp2
FROM #temp --WHERE condition = 'Nigerian Used'

--Validation after data clean up and validation against the states in Nigeria
--The original field reg_city has erroneous/incomplete data which necessitated going back to the original field "region" to determine state and city
--The check below validates that the new field deduced in the temp table above is relying on the original field "region"
SELECT * FROM #temp2 
WHERE region  NOT LIKE '%' + reg_state + '%' 
ORDER BY reg_city

--Exploration

SELECT * FROM #temp2
--Let us determine what states have the most activity in car sales
--No surprises that Lagos has the highest unmber of cars bought with Abuja falling in second place.
--What is suprising is that Oyo falls in third place
SELECT reg_state, COUNT ( reg_state) FROM #temp2 GROUP BY reg_state ORDER BY COUNT ( reg_state)

--Looking at Oyo's data, as suspected and from driving around Nigeria, Toyota represents 47% of cars bought and registered in Oyo state with 128 out of 270
--with a close second being Honda with only 24 cars sold and registered. 
--Oyo has 27 different types of cars
SELECT make, COUNT(make) 
FROM #temp2 WHERE reg_state = 'Oyo' GROUP BY make ORDER BY COUNT(make)
--
SELECT condition, COUNT(condition) 
FROM #temp2 WHERE reg_state = 'Oyo' GROUP BY condition ORDER BY COUNT(condition)

SELECT * FROM #temp2 WHERE  reg_state = 'Oyo'
SELECT DISTINCT condition FROM #temp2 WHERE  reg_state = 'Oyo'

--Looking at Abuja's data, Toyota still represents the lion share with 37% of cars and not so close second being Mercedes Benz represnting 13%
--Abuja has 32 different types of cars
SELECT make, COUNT(make) 
FROM #temp2 WHERE reg_state = 'Abuja' GROUP BY make ORDER BY COUNT(make)

SELECT condition, COUNT(condition) 
FROM #temp2 WHERE reg_state = 'Abuja' GROUP BY condition ORDER BY COUNT(condition)


SELECT DISTINCT condition FROM #temp2 WHERE  reg_state = 'Abuja'

--Looking at Lagos, again Toyota remains undefeated with 39% of car sales while Honda the next in line represented 9%
--Lagos has the most diversity in cars bought with 36 types of cars 
SELECT make, COUNT(make) 
FROM #temp2 WHERE reg_state = 'Lagos' GROUP BY make ORDER BY COUNT(make)

SELECT condition, COUNT(condition) 
FROM #temp2 WHERE reg_state = 'Lagos' GROUP BY condition ORDER BY COUNT(condition)

SELECT DISTINCT condition FROM #temp2 WHERE  reg_state = 'Lagos'


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