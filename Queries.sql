SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4;


-- Select data that we will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases VS Total Deaths
-- Shows the liklihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1, 2;

-- Looking at the total cases VS population
-- Shows what percentage of population got COVID

SELECT location, date, total_cases, population, (total_deaths/population)*100 AS percentCovidByPopulation
FROM PortfolioProject..CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1, 2;

-- Looking at the highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
HAVING location='India'
ORDER BY InfectionRate DESC;


-- Showing countries with Highest Death Count per Population
-- We'd have to cast total_deaths to integer in order to have accurate values while grouping
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breaking it down by continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Grouping by location where continent is NULL
-- We notice random values for location
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS totalNewCases, SUM(CAST(new_deaths AS int)) AS totalNewDeaths, 
MAX(total_deaths/total_cases) AS totalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) IS NOT NULL
ORDER BY 1,2;

-- Joining Deaths and Vaccination tables on location and Date

SELECT *
FROM PortfolioProject..CovidDeaths;

SELECT *
FROM PortfolioProject..CovidVaccinations;

SELECT 
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS D
INNER JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL;

SELECT 
	D.location,
	SUM(CAST(D.new_cases AS bigint)) AS NewCases, 
	SUM(CAST(D.total_cases AS bigint)) AS TotalCases, 
	SUM(CAST(V.new_vaccinations AS bigint)) AS NewVaccinations, 
	SUM(CAST(V.total_vaccinations AS bigint)) AS TotalVaccinations,
	SUM(CAST(V.new_tests AS bigint)) AS NewTests,
	SUM(CAST(V.total_tests AS bigint)) AS TotalTests
FROM PortfolioProject..CovidDeaths AS D
INNER JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location
AND D.date = V.date
GROUP BY D.location
ORDER BY D.location;

-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated (
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	NewVaccination NUMERIC,
	RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
	SELECT 
		D.continent,
		D.location,
		D.date,
		D.population,
		V.new_vaccinations,
		SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER (Partition BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths AS D
	INNER JOIN PortfolioProject..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date
	WHERE D.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated WHERE Location = 'Afghanistan' AND NewVaccination IS NOT NULL;

-- Creating view to store data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinatedView;

GO
CREATE VIEW PercentPopulationVaccinatedView AS
	SELECT 
		D.continent,
		D.location,
		D.date,
		D.population,
		V.new_vaccinations,
		SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER (Partition BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths AS D
	INNER JOIN PortfolioProject..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date
	WHERE D.continent IS NOT NULL;