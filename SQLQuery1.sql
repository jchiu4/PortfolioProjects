SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4
--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Total cases vs Total Deaths 
--Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY location, date; 

--Total Cases vs Population 
--Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY location, date; 

--Country with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

--Countries with the Highest Death Count per Population 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

--Continents with Highest Death Count Per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc;

--Global Numbers 
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY date



--Total Population vs Vaccinations

 --USE CTE 
 With PopvsVac(continent, Location, Date, Population, new_vaccinations_smoothed, RollingPeopleVaccinated) 
 As
 (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
SUM(CONVERT(BIGINT, vac.new_vaccinations_smoothed)) OVER 
(Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac
ORDER BY location, date

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
SUM(CONVERT(BIGINT, vac.new_vaccinations_smoothed)) OVER 
(Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated
ORDER BY Location, Date

--Creating view to store data for visualization 
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
SUM(CONVERT(BIGINT, vac.new_vaccinations_smoothed)) OVER 
(Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
