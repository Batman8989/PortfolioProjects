SELECT *
FROM PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
Order By 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Order By 1,2


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
Order By 1,2

-- Looking at DeathPercentage
-- Likelihood of dying if contracting if you contract covid in your country
--Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths$
--Where Location LIKE '%states%'
--Order By 1,2

-- Looking at Total Cases vs Population (United States Only)
Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where Location LIKE '%states%'
Order By 1,2

-- Shows what percentage of population got covid (United States Only)
Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where Location LIKE '%states%'
Order By Location, population



-- Looking at countries with highest infection rate compared to population

SELECT Location, population, 
    MAX(total_cases) AS HighestInfectionCount, 
    MAX(total_cases) / NULLIF(population, 0) * 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentagePopulationInfected desc;

-- Looking at countries with the highest death count per population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc;


-- By Continent 

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths$
Where continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc;



-- Showing the continents with the highest deaht count

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- GLOBAL NUMBERS

-- Total cases, total deaths, and death percentage by date

Select date, SUM(new_cases) AS totsl_cases, SUM(cast(new_deaths AS int)) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100) 
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
GROUP BY date
Order By 1,2


-- Global cases, deaths, and death percentage
Select SUM(new_cases) AS totsl_cases, SUM(cast(new_deaths AS int)) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100) 
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
Order By 1,2;

-- Use CTE
-- Looking at Total Population VS Vaccinations
WITH Popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN 
	PortfolioProject.. CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population) * 100
From Popvsvac;


-- Temp Table
-- Drop Table if exists #PercentPopulationVaccinated
--- Run seperately to drop temp table.
--- Cascading Effects: Be cautious when dropping tables, especially 
--- in production environments, as this action cannot be undone and 
--- may have cascading effects if the table is referenced by other
--- database objects.

Create Table #PercentPopulationVaccinated
(continent nvarchar(255), Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths$ dea
JOIN 
	PortfolioProject.. CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated;

SELECT *
FROM PercentPopulationVaccinated

-- Creating view to store data for later visualizations
-- Looking at countries with the highest death count per population
ALTER VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN 
	PortfolioProject.. CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


