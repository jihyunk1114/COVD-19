SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1 , 2;

SELECT *
FROM covidvaccinations
WHERE continent IS NOT NULL
ORDER BY 1 , 2;

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%ｓｔａｔｅｓ%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_deaths/population)*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE location LIKE '%ｓｔａｔｅｓ%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS TotalInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population
ALTER TABLE coviddeaths
MODIFY COLUMN total_deaths INTEGER;

/*
MAX(CAST total_deaths AS INT)   # in microsoft SQL
*/

SELECT Location, population, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY TotalDeathCount DESC;

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let's break things down by continent
-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- global numbers
ALTER TABLE coviddeaths
MODIFY COLUMN new_cases INTEGER;

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases)) AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases)) AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;

-- creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM percentpopulationvaccinated;




