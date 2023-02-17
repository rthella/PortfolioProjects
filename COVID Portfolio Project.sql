
--**************COVID DEATHS**************
SELECT *
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select data that to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of a person dying if they contracted COVID in Australia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percent
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location = 'Australia' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows the percentage of population who had COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infected_population_percent
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location = 'Australia' AND continent IS NOT NULL
ORDER BY 1,2

--Showing countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population)*100) AS infected_population_percent
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infected_population_percent DESC


--Showing countries with the highest death count 
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

--Showing continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

--Global Numbers
SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS INT)) AS total_deaths, 
       SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percent
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--**************COVID VACCINATIONS**************
SELECT *
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Looking at Total Population vs Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
       SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths cd
JOIN [Portfolio Project]..CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
       SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths cd
JOIN [Portfolio Project]..CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac

--Using TEMP TABLE 
--Highest percent of people vaccinated

DROP TABLE if exists #HighestPercentVaccinated
CREATE TABLE #HighestPercentVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric
)
INSERT INTO #HighestPercentVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
       SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths cd
JOIN [Portfolio Project]..CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100
FROM #HighestPercentVaccinated

--Creating View to store data for later visualizations
Create VIEW HighestPercentVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
       SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths cd
JOIN [Portfolio Project]..CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

--Showing HighestPercentVaccinated view
SELECT *
FROM HighestPercentVaccinated
