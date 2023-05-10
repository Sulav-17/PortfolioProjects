
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-------- Select Data that I am going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


--- Total cases vs Total Deaths

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where total_cases is NOT Null AND Location In ('Canada', 'United States') 
order by 1,2

--- Total Cases vs Population

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
Where total_cases is NOT Null AND Location In ('Canada', 'United States') 
order by 1,2

--- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as 
HighInfectedPercentage
From PortfolioProject..CovidDeaths
--Where total_cases is NOT Null AND Location In ('Canada', 'United States') 
Group by Location, Population
order by HighInfectedPercentage desc



---- Showing Countries with highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where total_cases is NOT Null AND Location In ('Canada', 'United States') 
Where continent is not null
Group by Location
order by TotalDeathCount desc

----------------------------------------------------------------------

--- Showing the continet with the highest death count

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where total_cases is NOT Null AND Location In ('Canada', 'United States') 
Where continent is not null
Group by continent
order by TotalDeathCount desc


----- Global Numbers

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
SUM(new_deaths )/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2




-- Total population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(vac.new_vaccinations)  OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
order by 2,3


---- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent,Location, Date, Population,new_vaccinations, RoolingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(vac.new_vaccinations)  OVER (Partition by death.Location Order by death.location, death.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
--order by 2,3
)
Select *, (RoolingPeopleVaccinated/Population) * 100
From PopvsVac




--- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View For Visualization 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3