Select *
FROM PortfolioProject..CovidDeaths
order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Evaluate Total Cases vs Total Deaths
--Demonstrates the possibility of death if Covid is contaracted
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%States%'
order by 1,2


--Evaluate Total cases vs Population
--Reveals % of population contacted COVID

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%States%'
order by 1,2


---Countries with highest infection rate per population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%States%'
Group by Location, Population
Order by PercentPopulationInfected desc

--Identify countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

EXPLORE DATA BY CONTINENT

--Identify continents with the highest death counts

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Global Numbers!
--Demonstrates the possibility of death if Covid is contaracted
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/ Sum(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
--Group By date
order by 1,2

--Exlore total population vs vacccination rate
--USE CTE
With PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.DATE) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.DATE) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store dat for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.DATE) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3