
--SELECT * 
--FROM [Portfolio Project1]..CovidDeaths
--order by 3,4

--SELECT * 
--FROM [Portfolio Project1]..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

--SELECT Location,date,total_cases,new_cases,total_deaths,population
--FROM [Portfolio Project1]..CovidDeaths
--order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
--SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
--FROM [Portfolio Project1]..CovidDeaths
--WHERE location = 'United States'
--order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
--SELECT Location,date,population,total_cases,(total_cases/population)*100 AS PopPercent
--FROM [Portfolio Project1]..CovidDeaths
--WHERE continent is not null 
--WHERE location = 'United States'
--order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
--SELECT Location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
--FROM [Portfolio Project1]..CovidDeaths
--WHERE continent is not null 
--Group by Location,Population
--order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
--SELECT Location,MAX(cast(total_deaths as int)) AS TotalDeathCount
--FROM [Portfolio Project1]..CovidDeaths
--WHERE continent is not null 
--Group by Location
--order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

--SELECT continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
--FROM [Portfolio Project1]..CovidDeaths
--WHERE continent is not null 
--Group by continent
--order by TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project1]..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--convert vac.new_vaccinations data type to bigint due to errors
ALTER TABLE [Portfolio Project1]..CovidVaccinations
ALTER COLUMN new_vaccinations bigint

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project1]..CovidDeaths dea
JOIN [Portfolio Project1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

--USE CTE

WITH PopvsVac (Continent,Location,Date,Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project1]..CovidDeaths dea
JOIN [Portfolio Project1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentVaccinated
FROM PopvsVac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations bigint,
RollingPeopleVaccinated bigint)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project1]..CovidDeaths dea
JOIN [Portfolio Project1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project1]..CovidDeaths dea
JOIN [Portfolio Project1]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
