select * from PortFolioProject..CovidDeaths
WHERE continent is not NULL
order by 3,4

--select * from PortFolioProject..CovidVaccination
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortFolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage
from PortFolioProject..CovidDeaths
WHERE location like '%states%'
AND continent is not NULL
order by 1,2

-- Total Cases vs Population
-- Show what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Percentage
from PortFolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
order by 1,2

-- Country with Highest Infection Rate compared to Population
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentOfPopulationInfected
from PortFolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
Group By Location,Population
order by PercentOfPopulationInfected DESC

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as 'Total Death Count'
from PortFolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
Group By Location,Population
order by 'Total Death Count' DESC



-- BREAKING THINGS DOWN BY CONTINENT



Select location Location, MAX(cast(total_deaths as int)) as 'Total Death Count'
from PortFolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NULL
Group By location
order by 'Total Death Count' DESC

-- Continents With The Highest Death Count
Select continent Continent, MAX(cast(total_deaths as int)) as 'Total Death Count'
from PortFolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
Group By continent
order by 'Total Death Count' DESC


-- GLOBAL NUMBERS
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as Percentage
from PortFolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY date
order by 1,2

-- Total Population vs Vaccinations

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated