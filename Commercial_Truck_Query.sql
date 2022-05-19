-- This is my log of analyzing 2 commercial truck datasets



-- First, looking at the datasets to see if they were uploaded correctly
Select *
From Portfolio1..FleetSize
Order By 1,2;

Select *
From Portfolio1..PolkData
Order By 1,2,4;



-- Second, looking at data splits

-- Which Brand sold the most model units from in 2019?
Select Brand, SUM(Unit_Count) as Total_Units
From Portfolio1..PolkData
Where Year_of_Registered_Date = 2019
Order By 2 Desc;

-- What model segment had the most sales in 2019?
Select Model_Segment, SUM(Unit_Count) as Total_Units
From Portfolio1..PolkData
Where Year_of_Registered_Date = 2019
Group By Model_Segment
Order By 2 Desc;

-- Which Fuel Type did customers prefer in 2019?
Select Fuel_Name, SUM(Unit_Count) as Total_Units
From Portfolio1..PolkData
Where Year_of_Registered_Date = 2019
Group By Fuel_Name
Order By 2 Desc;

-- Which State had the most orders in 2019?
Select Preferred_State, SUM(Unit_Count) as Total_Units
From Portfolio1..PolkData
Where Year_of_Registered_Date = 2019
Group By Preferred_State
Order By 2 Desc;

-- Which Month had the most orders in 2019?
Select Month_Of_Registered_Date, SUM(Unit_Count) as Total_Units
From Portfolio1..PolkData
Where Year_of_Registered_Date = 2019
Group By Month_Of_Registered_Date
Order By 2 Desc;

-- Finding the Brand that sells the most model units by Registration year
Select Brand, Year_of_Registered_Date, SUM(Unit_Count) as Total_Units
From Portfolio1..PolkData
Group By Brand, Year_of_Registered_Date
Order By 3 Desc;

-- For the Brand that sold the most units in 2019, what were their best selling models?
Select Brand, Model, Model_Segment, SUM(Unit_Count) as Total_Units
From Portfolio1..PolkData
Where Year_of_Registered_Date = 2019 And Brand = 'Mack'
Group by Brand, Model, Model_Segment
Order By 4 Desc;

-- Finding units by Fleet Group, Model Segment, Regisration Month, & Registration year
-- use this one for view
Select Brand, Fleet_Group, Model_Segment, Month_of_Registered_Date, Year_of_Registered_Date, Unit_Count as Total_Units
From Portfolio1..PolkData
Order By 1,2,3;

-- Finding the Engine Manufacturer, Model, and Size that sells the most model units from 2015-2020
Select Eng_Mfr, SUM(Unit_Count) as TotalUnits
From Portfolio1..PolkData
Group By Eng_Mfr
Order By 1;


-- Finding the Engine Manufacturer, Model, and Size that sells the most model units by Fleet Group, Model Segment, & Registration year
-- use this one for view
Select Eng_Mfr, Eng_Model, Eng_Size, Fleet_Group, Model_Segment, Year_of_Registered_Date, SUM(Unit_Count) as TotalUnits
From Portfolio1..PolkData
Group By Eng_Mfr, Eng_Model, Eng_Size, Fleet_Group, Model_Segment, Year_of_Registered_Date
Order By 1,2,3,4;



-- Joining the Fleet Size and Polk Data tables together
Select *
From Portfolio1..FleetSize Fleet
Join Portfolio1..PolkData Polk
	On Fleet.Target_Name = Polk.Target_Name;


-- What type of customers buy commercial trucks in 2019?
Select	Fleet.Fleet_Size,
		Sum(Polk.Unit_Count) as Total_Units
From Portfolio1..FleetSize Fleet
Join Portfolio1..PolkData Polk
	On Fleet.Target_Name = Polk.Target_Name
Where Year_Of_Registered_Date = 2019
Group By Fleet.Fleet_Size
Order By 2 Desc;






--- main table for dataset to import into Tableau Public
----Adding calculations
CREATE VIEW CommercialTruckDataExport AS
Select 	Fleet.Fleet_Size,
		Polk.Brand,
		Polk.Fleet_Group,
		Polk.Eng_Mfr,
		Polk.Eng_Model,
		Polk.Eng_Size,
		Polk.Fuel_Name,
		Polk.Model_Segment,
		Polk.Month_Of_Registered_Date,
		Polk.Year_Of_Registered_Date,
		Polk.Preferred_State,
		Polk.Unit_Count as Total_Units
From Portfolio1..FleetSize Fleet
Join Portfolio1..PolkData Polk
	On Fleet.Target_Name = Polk.Target_Name;

--can't use Order By when creating views







-----------------------------------------------------------------
-- copy copy; this section is for unused queries/redundant queries
-- What type of Fuel types do customers prefer from 2019?
Select	Polk.Fuel_Name,
		Sum(Polk.Unit_Count) as Total_Units
From Portfolio1..FleetSize Fleet
Join Portfolio1..PolkData Polk
	On Fleet.Target_Name = Polk.Target_Name
Where Year_Of_Registered_Date = 2019
Group By Polk.Fuel_Name
Order By 2 Desc;


-- Where are customers located from 2019?
Select	Polk.Preferred_State,
		Sum(Polk.Unit_Count) as Total_Units
From Portfolio1..FleetSize Fleet
Join Portfolio1..PolkData Polk
	On Fleet.Target_Name = Polk.Target_Name
Group By Polk.Preferred_State
Order By 2 Desc;
