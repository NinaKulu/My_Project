
 SELECT location,date,total_cases,new_cases,total_cases,population
 FROM PortfolioProject..CovidDeaths$
 --Where continent is not null
 ORDER BY 3,4

 -----
SELECT * FROM PortfolioProject..CovidDeaths$
Where continent is not null
ORDER BY 3,4
 --
  SELECT * from [dbo].[CovidVaccinations$]
 order by 3, 4

 -- Looking at Total Cases VS Total Deaths
 -- Shows Likelihood of dying if you contact covid in your country

 SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths$
 where location like 'Et%'
 ORDER BY 1,2

 -- Looking at Total Cases vs population
 -- Shows what percentage of population got Covid
 SELECT location,date,population,total_cases,(total_cases/population)*100 as Population_Got_Covid
 FROM PortfolioProject..CovidDeaths$
 where location like 'Er%'
 ORDER BY 1,2


 --Looking at Countries with Highest Infection Rate Compared to Population
  SELECT location,population,MAX(total_cases)  as HighestInfection,MAX((total_cases/population))*100 as 
  PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths$
--where location like 'Er%'
Group by location,population
 ORDER BY PercentPopulationInfected desc

 -- showing countries with Highest Death Count per Population
 SELECT location,MAX(Cast(Total_deaths as int)) As TotalDeathCount
 FROM PortfolioProject..CovidDeaths$
--where location like 'Er%'
Where continent is not null
Group by location
 ORDER BY TotalDeathCount desc

 -- LET's BREAK THINGS DOWN BY CONTINENT
SELECT continent,MAX(Cast(Total_deaths as int)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--where location like 'Er%'
Where continent is NOT null
Group by continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

 SELECT date, sum(new_cases), sum(cast(new_deaths as int)), as DeathPercentage
 FROM PortfolioProject..CovidDeaths$
-- where location like 'Et%'
 Where continent is not null
 group by date
 ORDER BY 1,2

 -- Looking at Total Population Vs Vaccination
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , sum(convert (int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
 from CovidDeaths$ dea
 join CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date=vac.date 
where dea.continent is not null
--and vac.new_vaccinations is not null
Order by 2,3


-- USE CTE

With PopvsVac (continent,location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , sum(convert (int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
 from CovidDeaths$ dea
 join CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date=vac.date 
where dea.continent is not null
--and vac.new_vaccinations is not null
--Order by 2,3
)
select* ,(RollingPeopleVaccinated/Population)*100 as Total
from PopvsVac

-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , sum(convert (int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
 from CovidDeaths$ dea
 join CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date=vac.date 
--where dea.continent is not null
--and vac.new_vaccinations is not null
--Order by 2,3

select* ,(RollingPeopleVaccinated/Population)*100 as Total
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinated