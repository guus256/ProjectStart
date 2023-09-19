--shows likelihood of death
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Uganda' 
ORDER BY 1, 2

--looking at total cases vs population 
SELECT location, date, total_cases, population, (total_cases/ population)*100 infectionpercentage
FROM PortfolioProject..CovidDeaths 
where total_cases is not null 
GROUP BY location, population 
ORDER BY 1, 2

--looking at countries with the highest infection rate compared to their population 

SELECT location, MAX(total_cases) HighestInfectionCount, population, MAX((total_cases/ population))*100 InfectionPercentage
FROM PortfolioProject..CovidDeaths 
where total_cases is not null 
GROUP BY location, population 
ORDER BY InfectionPercentage desc

--showing countries with the highest death rate 
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths  
where continent is not null 
GROUP BY location 
ORDER BY TotalDeathCount desc

--showing continents with the highest death rate
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths  
where continent is not null 
GROUP BY continent 
ORDER BY TotalDeathCount desc

--Global Figures
SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as TotalDeathCount
FROM PortfolioProject..CovidDeaths  
where continent is not null 
--GROUP BY date 
ORDER BY 1, 2


--Vaccination table now
--Looking for the total cases vs total vaccinations WITH CTE

WITH PopvsVac (Continent, Location, Date, Population, CummulativePeopleVccinated, new_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) CummulativePeopleVccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT*, (CummulativePeopleVccinated/ Population)*100 VaccinatedPercentage
FROM PopvsVac

--WITH TEMP TABLE

DROP TABLE IF EXISTS #CummulativePopulationVccinated
CREATE TABLE #CummulativePopulationVccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulativePeopleVccinated numeric
)
INSERT INTO #CummulativePopulationVccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) CummulativePeopleVccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CummulativePeopleVccinated/Population)*100
FROM #CummulativePopulationVccinated

--Creating views to store data for later visulaization 

CREATE view CummulativePopulationVccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) CummulativePeopleVccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2, 3

SELECT *
 FROM CummulativePopulationVccinated