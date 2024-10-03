### Global Covid Analysis

**Table of Contents**
- [Introduction](#introduction)
- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Exploratory Data Analysis and Methodology](#exploratory-data-analysis-and-methodology)

  ## Introduction
  This project involved analyzing the global impact of COVID-19 by utilizing two key datasets: COVID-19 deaths and vaccinations. As an introductory project in my data analysis journey, I conducted exploratory data analysis (EDA) to derive meaningful insights about the pandemic's effects across different regions.

  ## Project Overview
  The main objectives of this project included evaluating the likelihood of death in Uganda, comparing total COVID-19 cases to global population, identifying countries with the highest infection rates relative to their population, and highlighting countries and continents with the highest death rates. Furthermore, I analyzed the global death count and percentage of deaths relative to cases, examined the relationship between total cases and vaccinations worldwide, and created SQL views for efficient data storage, aiding future visualizations. This analysis provided a foundational understanding of the pandemic's spread and impact, allowing for deeper insights into global health trends during this challenging time.

  ## Data Sources
  The datasets for this analysis were sourced from GitHub, providing up-to-date information on COVID-19 deaths and vaccinations. You can access the datasets through the following links:
  - [Covid deaths](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/CovidDeaths.xlsx)
  - [Covid Vaccinations](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/CovidVaccinations.xlsx)

  ## Exploratory Data Analysis and Methodology
Below is a bit of exploration i did to uncover a few insights into my data;

- The likelihood of deaths globally and particularly in my home country (Uganda)
```sql
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Uganda' 
ORDER BY 1, 2
```

- I had a glance at the total cases vis-a-vis the the population based on the different locations provided as well
 ```sql
 SELECT location, date, total_cases, population, (total_cases/ population)*100 infectionpercentage
 FROM PortfolioProject..CovidDeaths 
 where total_cases is not null 
 GROUP BY location, population 
 ORDER BY 1, 2
 ```

- Countries with the highest infection rate compared to their population
```sql
SELECT location, MAX(total_cases) HighestInfectionCount, population, MAX((total_cases/ population))*100 InfectionPercentage
FROM PortfolioProject..CovidDeaths 
where total_cases is not null 
GROUP BY location, population 
ORDER BY InfectionPercentage desc
```

- Countries with the highest death rate
```sql
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths  
where continent is not null 
GROUP BY location 
ORDER BY TotalDeathCount desc
```

- Continents with the highest death rate
```sql
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths  
where continent is not null 
GROUP BY continent 
ORDER BY TotalDeathCount desc
```

- Global death count and percentage (in regards to number of cases and deaths)
```sql
SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as TotalDeathCount
FROM PortfolioProject..CovidDeaths  
where continent is not null 
--GROUP BY date 
ORDER BY 1, 2
```

- Discovering the total cases vs total vaccinations globally
```sql
WITH PopvsVac (Continent, Location, `Date`, Population, CummulativePeopleVccinated, new_vaccinations)
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
```

- With this done, i created a view where i could then store my data for vizualisation later on.
```sql
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
```
