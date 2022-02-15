-- Explore the two imported tables

SELECT *
FROM CovidExploration..CovidDeaths
ORDER BY 3,4

SELECT *
FROM CovidExploration..CovidVaccinations
ORDER BY 3,4

-- Select columns that are intersting

SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	population
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Comparing number of deaths to number of cases
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	total_deaths/total_cases * 100 AS DeathsPercentage
FROM CovidExploration..CovidDeaths
WHERE location LIKE '%Egypt%'
ORDER BY 1,2 


-- Exploring cases relative to population

SELECT 
	location,
	date,
	population,
	total_cases,
	total_cases/population * 100 AS InfectionPercentage
FROM CovidExploration..CovidDeaths
WHERE location LIKE '%Egypt%'
ORDER BY 1,2 

-- Discovering maximum number of cases and highest percentage of infection per country

SELECT 
	location,
	population,
	MAX(total_cases) AS MaxNumCases,
	MAX(total_cases/population * 100) AS MaxInfectionPercentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MaxInfectionPercentage DESC


-- What are countries with highest deaths count per capita??

SELECT 
	location,
	MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Which continent has the highest deth cout per capita?


SELECT 
	continent,
	MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Discovering how the whole world is going in terms of Covid numbers


SELECT 
	date,
	SUM(new_cases) AS TotalCases,
	SUM(cast(new_deaths as int)) AS TotalDeaths,
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- What are the total number of deaths and cases globaly?
SELECT 
	SUM(new_cases) AS TotalCases,
	SUM(cast(new_deaths as int)) AS TotalDeaths,
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Let's discover some facts about vaccinations

SELECT 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (partition by d.location ORDER BY d.location,
	d.date) AS CommulativeVaccinations


FROM CovidExploration..CovidDeaths d 
JOIN CovidExploration..CovidVaccinations v
	ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL
ORDER BY 2,3

-- What is the rolling percentage of people that are vaccinated?
-- Using CTE
WITH PercentVac (continent, location, date, population, new_vaccinations, CommulativeVaccinations)
AS

(
SELECT 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (partition by d.location ORDER BY d.location,
	d.date) AS CommulativeVaccinations


FROM CovidExploration..CovidDeaths d 
JOIN CovidExploration..CovidVaccinations v
	ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL
)
SELECT *, CommulativeVaccinations / population * 100
FROM PercentVac

-- USING TEMP TABLE

DROP TABLE if exists #PercentVacc
CREATE TABLE #PercentVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacc numeric,
CommulativeVax numeric
)

INSERT INTO #PercentVacc

SELECT 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (partition by d.location ORDER BY d.location,
	d.date) AS CommulativeVaccinations


FROM CovidExploration..CovidDeaths d 
JOIN CovidExploration..CovidVaccinations v
	ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL AND d.location LIKE '%states%'

SELECT *, CommulativeVax/Population * 100 AS PercentofVax
FROM #PercentVacc


-- Creating Views

CREATE VIEW PercentPopVax as
SELECT 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (partition by d.location ORDER BY d.location,
	d.date) AS CommulativeVaccinations


FROM CovidExploration..CovidDeaths d 
JOIN CovidExploration..CovidVaccinations v
	ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL
