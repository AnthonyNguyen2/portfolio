-- After uploading the data into SQL,  
-- Checking out the tables to make sure the data is correct
-- Then filtering the Continent column by no Null values because the Location column has aggregated entries that are not valid country names
-- Then selecting all of the colmns in the table and ordering by the 3rd column first, then the 4th column
SELECT *
FROM PortfolioTest..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM PortfolioTest..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;

--Leaving NULL values in the datasets to avoid skewing calculations later on


-- Selecting the data that I will use
SELECT location,
		date,
		new_cases,
		total_cases,
		new_deaths,
		total_deaths,
		population
FROM PortfolioTest..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Finding the COVID-19 Death Rate (Looking at Total Cases vs Total Deaths)
SELECT location,
		date,
		total_cases,	-- Use Total_Cases here to compare total on the day
		total_deaths,	-- Use Total_Deaths here to compare total on the day
		ROUND((total_deaths/total_cases)*100,6) AS Death_Percentage
FROM PortfolioTest..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Finding the COVID-19 Infection Rate (Looking at Total Cases vs Population)
SELECT location, 
		date,
		total_cases,
		population,
		ROUND((total_cases/population)*100,6) AS Infected_Percentage
FROM PortfolioTest..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Looking at Top 10 Countries with Highest Infection Rate compared to the country's population
SELECT TOP 10
		location,
		population, 
		MAX(total_cases) AS HighestInfectionCount, 
		MAX(ROUND((total_cases/population)*100,6)) AS Infected_Percentage
FROM PortfolioTest..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;


-- Showing Countries with Highest Death Count per Population
--- Casting Total_Deaths as an Integer (initially was nvarchar) in order to use the Max aggregate function
SELECT location,
		MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioTest..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;



-- Showing Continents with Highest Death Count per Population
-- with drill down option into Location
--- Casting Total_Deaths as an Integer (initially was nvarchar) in order to use the Max aggregate function
--- Filtered by Continent column not Null b/c these entries have an aggregation listed in the Location column
--- Also filtered Location column so it doesn't display results that have entries with "income" in the name
SELECT continent, location, MAX(cast(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioTest..CovidDeaths
WHERE continent IS NOT NULL AND location not like '%income%'
GROUP BY continent, location
ORDER BY 3 DESC;


-- Global numbers by Date
--- Using New_Cases and New_Deaths columns in order to avoid using the aggregated numbers found in the dataset's Total_Cases & Total_Deaths columns
SELECT date, 
	SUM(new_cases) AS TotalCases, 
	SUM(CAST(new_deaths AS BIGINT)) AS TotalDeaths,
	ROUND(SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100,6) AS Death_Percentage
FROM PortfolioTest..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


-- Joining COVID-19 Death and Vaccination tables together
-- Finding the percentage of Partially vs. Fully vaccinated people in the population
WITH PopulationVaccinated (Continent, Location, Date, Population, Partially_Vaccinated, 
Fully_Vaccinated)
AS
(
SELECT death.continent, 
	death.location, 
	death.date, 
	death.population, 
	CONVERT(BIGINT,vaccination.people_vaccinated),
	CONVERT(BIGINT,vaccination.people_fully_vaccinated)
FROM PortfolioTest..CovidDeaths death -- Adding an alias to make calling this table easier
JOIN PortfolioTest..CovidVaccinations vaccination -- Adding an alias to make calling this table easier
ON death.location = vaccination.location
	AND death.date = vaccination.date
WHERE death.continent IS NOT NULL
)
SELECT *, 
		ROUND((Partially_Vaccinated/Population)*100,6) AS Partially_Vaccinated_Percentage,
		ROUND((Fully_Vaccinated/Population)*100,6) AS Fully_Vaccinated_Percentage
FROM PopulationVaccinated
ORDER BY 1,2;




-- Main table to import into Tableau Public for data visualizations
-- Export this table as CSV or Excel file within MS SSRS
-- Adding calculations in the export to show those values in Tableau easier
CREATE VIEW COVID_19_data AS
WITH PopulationVaccinated (Continent, Location, Date, Population, 
Total_Cases, New_Cases, ICU_Patients, Hospital_Patients, Total_Deaths, 
New_Deaths, Total_Tests, New_Tests, Total_Vaccinations, 
Partially_Vaccinated, Fully_Vaccinated, Total_Boosters, New_Vaccinations)
AS
(
SELECT death.continent, 
	death.location, 
	death.date, 
	death.population, 
	death.total_cases,
	death.new_cases, 
	death.icu_patients,
	death.hosp_patients,
	death.total_deaths,
	death.new_deaths,
	vaccination.total_tests,
	vaccination.new_tests,
	CONVERT(BIGINT,vaccination.total_vaccinations),
	CONVERT(BIGINT,vaccination.people_vaccinated),
	CONVERT(BIGINT,vaccination.people_fully_vaccinated),
	vaccination.total_boosters,
	vaccination.new_vaccinations
FROM PortfolioTest..CovidDeaths death -- Adding an alias to make calling this table easier
JOIN PortfolioTest..CovidVaccinations vaccination -- Adding an alias to make calling this table easier
ON death.location = vaccination.location
	AND death.date = vaccination.date
WHERE death.continent IS NOT NULL
)
SELECT *,
		ROUND((Partially_Vaccinated/Population)*100,6) AS Partially_Vaccinated_Percentage,
		ROUND((Fully_Vaccinated/Population)*100,6) AS Fully_Vaccinated_Percentage,
		ROUND((Total_Deaths/Population)*100,6) AS Death_Percentage,
		ROUND((Total_Cases/Population)*100,6) AS Infection_Percentage
FROM PopulationVaccinated;






--copy copy; use for reference only!!!
SELECT death.continent, 
	death.location, 
	death.date, 
	death.population, 
	vaccination.people_vaccinated AS Partially_Vaccinated,
	vaccination.people_fully_vaccinated AS Fully_Vaccinated,
	ROUND((CONVERT(BIGINT, vaccination.people_vaccinated)/death.population)*100,6) AS Partially_Vaccinated_Percentage,
	ROUND((CONVERT(BIGINT, vaccination.people_fully_vaccinated)/death.population)*100,6) AS Fully_Vaccinated_Percentage,
	ROUND(CONVERT(INT, vaccination.people_fully_vaccinated)/CONVERT(INT,vaccination.people_vaccinated)*100,6) AS Percentage_of_Fully_Vac_in_Vacc_People
FROM PortfolioTest..CovidDeaths death -- Adding an alias to make calling this table easier
JOIN PortfolioTest..CovidVaccinations vaccination -- Adding an alias to make calling this table easier
ON death.location = vaccination.location
	AND death.date = vaccination.date
WHERE death.continent IS NOT NULL;