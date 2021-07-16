SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccination
WHERE continent is not null
ORDER BY 3,4

-- Select the data we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country
SELECT 
    location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid  
SELECT 
    location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS total_cases_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2

-- Looking at countries with highest Infection rate compared to Population

SELECT 
    location,
	population,
	MAX(total_cases) AS highestinfectioncount,
	MAX((total_cases/population)*100) AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- Showing Countries with highest death count per population

SELECT 
    location,
	MAX(cast(total_deaths AS int)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY totaldeathcount DESC

-- Let's Break things down by continent

SELECT 
    continent,
	MAX(cast(total_deaths AS int)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathcount DESC

-- Showing the Continents with the highest death counts

SELECT 
    continent,
	MAX(cast(total_deaths AS int)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathcount DESC

-- Global Numbers

SELECT 
   SUM(new_cases) AS total_cases,
   SUM(CAST(new_deaths AS int)) AS total_deaths,
   (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT 
      dea.continent,
	  dea.location,
	  dea.date,
	  dea.population,
	  vac.new_vaccinations,
	  SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dea.location) 
	  AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccination vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE

WITH PopvsVac (continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(SELECT 
      dea.continent,
	  dea.location,
	  dea.date,
	  dea.population,
	  vac.new_vaccinations,
	  SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dea.location) 
	  AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccination vac
JOIN PortfolioProject..CovidDeaths dea
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * , 
(RollingPeopleVaccinated/population)*100 AS VaccinationPercentage
FROM PopvsVac

-- Using TEMP Table

DROP TABLE IF exists #PercentPopulationVaccinated
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
SELECT 
      dea.continent,
	  dea.location,
	  dea.date,
	  dea.population,
	  vac.new_vaccinations,
	  SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dea.location) 
	  AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccination vac
JOIN PortfolioProject..CovidDeaths dea
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *,
(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2,3

-- Creating View to store data for later visualizations

Create View PercentagePopulationVaccinated AS
(SELECT 
      dea.continent,
	  dea.location,
	  dea.date,
	  dea.population,
	  vac.new_vaccinations,
	  SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dea.location) 
	  AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccination vac
JOIN PortfolioProject..CovidDeaths dea
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *
FROM PercentagePopulationVaccinated