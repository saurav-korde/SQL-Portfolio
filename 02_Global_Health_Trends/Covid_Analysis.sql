/*
Project: Global COVID-19 Analysis
Author: Saurav Korde
Date: 2025-12-07
Goal: Analyze infection rates, death tolls, and vaccination progress using Window Functions and Joins.
*/

-- ---------------------------------------------------------
-- Q1: The Grim Reality (Likelihood of Dying)
-- Goal: Calculate the Death Percentage in your country (India).
-- Formula: (total_deaths / total_cases) * 100
-- ---------------------------------------------------------
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths::FLOAT / total_cases::FLOAT) * 100 AS death_percentage
FROM "CovidDeaths"
WHERE location = 'India'
ORDER BY date;

-- ---------------------------------------------------------
-- Q2: Infection Penetration (Total Cases vs Population)
-- Goal: What percentage of the population has contracted COVID?
-- Formula: (total_cases / population) * 100
-- Filter: Focus on 'India' first.
-- ---------------------------------------------------------
SELECT 
    location, 
    date, 
    population, 
    total_cases, 
    -- ROUND to 6 decimal places to avoid scientific notation
    ROUND((total_cases::NUMERIC / population::NUMERIC) * 100, 6) AS infection_percentage
FROM "CovidDeaths"
WHERE location = 'India'
ORDER BY date;

-- ---------------------------------------------------------
-- Q3: Infection Hotspots (Highest Infection Rate)
-- Goal: Which countries have the highest infection rates relative to their population?
-- Show: Location, Population, MAX(total_cases), and Max Infection %.
-- Order: By Percent Population Infected (Desc).
-- ---------------------------------------------------------
SELECT 
    location, 
    population, 
    MAX(total_cases) AS max_total_cases,
    (MAX(total_cases)::FLOAT / population::FLOAT) * 100 AS max_infection_percentage
FROM "CovidDeaths"
GROUP BY location, population
ORDER BY max_infection_percentage DESC NULLS LAST
LIMIT 10;

-- ---------------------------------------------------------
-- Q4: The Human Cost (Highest Death Count)
-- Goal: Which countries have the highest Total Death Count?
-- Note: You might need to filter out 'Continents' from the location column (where continent is null).
-- ---------------------------------------------------------
SELECT 
    location, 
    MAX(total_deaths) AS max_total_deaths
FROM "CovidDeaths"
WHERE continent IS NOT NULL 
  AND continent != ''   -- This catches the empty text strings
GROUP BY location
ORDER BY max_total_deaths DESC NULLS LAST
LIMIT 10;

-- ---------------------------------------------------------
-- Q5: Continent Breakdown
-- Goal: Let's zoom out. Show the continents with the highest death counts.
-- Filter: Where continent is NOT null.
-- ---------------------------------------------------------
SELECT 
    location AS continent, 
    MAX(total_deaths) AS total_death_count
FROM "CovidDeaths"
WHERE (continent IS NULL OR continent = '') 
  AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC NULLS LAST;

-- ---------------------------------------------------------
-- Q6: Global Daily Numbers
-- Goal: What were the total cases and deaths recorded globally each day?
-- Show: Date, Sum of New Cases, Sum of New Deaths.
-- ---------------------------------------------------------
SELECT 
    date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    -- NULLIF(x, 0) means: "If x is 0, treat it as NULL instead" (which stops the error)
    ROUND((SUM(new_deaths)::NUMERIC / NULLIF(SUM(new_cases), 0)::NUMERIC) * 100, 2) AS death_percentage
FROM "CovidDeaths"
WHERE location = 'World'
GROUP BY date
ORDER BY date;

-- ---------------------------------------------------------
-- Q7: Total Population vs Vaccinations (The JOIN)
-- Goal: Join the Deaths and Vaccinations tables.
-- Show: Continent, Location, Date, Population, New Vaccinations.
-- ---------------------------------------------------------
SELECT 
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations
FROM "CovidDeaths" d
JOIN "CovidVaccinations" v
  ON d.location = v.location 
 AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.date;

-- ---------------------------------------------------------
-- Q8: The Rolling Tally (Window Functions)
-- Goal: We want a running total of vaccinations for each country.
-- Logic: SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date).
-- ---------------------------------------------------------
SELECT 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_total_vaccinations
FROM "CovidDeaths" d
JOIN "CovidVaccinations" v
  ON d.location = v.location 
 AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

-- ---------------------------------------------------------
-- Q9: Vaccination vs Population (CTE)
-- Goal: Use the Rolling Tally from Q8 to calculate the % of population vaccinated.
-- Tech: You cannot use a column you just created in the same SELECT. You need a CTE or Temp Table.
-- ---------------------------------------------------------
WITH PopvsVac AS (
    SELECT 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations,
        SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_people_vaccinated
    FROM "CovidDeaths" d
    JOIN "CovidVaccinations" v
      ON d.location = v.location 
     AND d.date = v.date
    WHERE d.continent IS NOT NULL
)
SELECT 
    *,
    (rolling_people_vaccinated::NUMERIC / population::NUMERIC) * 100 AS vaccination_percentage
FROM PopvsVac;

-- ---------------------------------------------------------
-- Q10: Creating Views for Visualization
-- Goal: Create a View to store data for later visualizations (e.g., Tableau/PowerBI).
-- ---------------------------------------------------------
DROP VIEW IF EXISTS "PercentPopulationVaccinated";

CREATE VIEW "PercentPopulationVaccinated" AS
SELECT 
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    d.new_cases,
    d.total_cases,
    d.total_deaths,
    v.new_vaccinations,
    -- Calculate Rolling Vaccination Count
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_people_vaccinated,
    -- Calculate Percentage (Note: We must repeat the logic here or use a subquery structure)
    (SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.date)::NUMERIC / NULLIF(d.population, 0)::NUMERIC) * 100 AS vaccination_percentage
FROM "CovidDeaths" d
JOIN "CovidVaccinations" v
  ON d.location = v.location 
 AND d.date = v.date
WHERE d.continent IS NOT NULL;
