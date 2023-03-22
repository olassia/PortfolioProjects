SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidVaccinations

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
SUM(CAST(new_deaths + 0.0 AS int))/SUM(new_cases + 0.0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Total population  vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) 
OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, ((RollingPeopleVaccinated + 0.0)/(population + 0.0))*100
FROM PopvsVac


--Temp Table

Drop Table if EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, ((RollingPeopleVaccinated + 0.0)/(population + 0.0))*100
FROM #PercentPopulationVaccinated

--Creating view to store for later viz
Create View PercentPopulationVaccinated 
AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PortfolioProject..PercentPopulationVaccinated