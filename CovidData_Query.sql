
select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2



select 
location, 
population, 
max(total_cases) as 'Highest Infection Count', 
max(convert(float, total_cases)/population)*100 as 'Percentage Infected of Population'
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by 'Percentage Infected of Population' desc

--countries with higheset death count per population

select 
location as 'Country', 
max(cast(total_deaths as int)) as 'xx Total Deaths xx' 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by 'xx Total Deaths xx' desc


-- countries with highest death count per population

select 
location as 'Country', 
max(cast(total_deaths as int)) as 'Total Deaths' 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
group by location
order by 'Total Deaths' desc


-- total deaths by continent 

select 
location, 
max(cast(total_deaths as int)) as 'Total Deaths' 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null 
group by location
order by 'Total Deaths' desc


-----------------------

select 
continent, 
max(cast(total_deaths as int)) as 'Total Deaths' 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
group by continent
order by 'Total Deaths' desc


-- continents with highest death count per population 

select 
continent, 
max(cast(total_deaths as int)) as 'Total Deaths' 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
group by continent
order by 'Total Deaths' desc



-- Global numbers 

select 
date,
total_cases,
total_deaths,
cast(total_deaths as float)/(total_cases)*100 as 'DeathPercentage'
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

-------------------------

select 
date 'Date', sum(new_cases) 'Total Cases', sum(cast(new_deaths as int)) 'Total Deaths',  
sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death %'
from PortfolioProject..CovidDeaths
where (new_cases != 0 and new_deaths != 0)
group by date
order by 1,2

-------------------------

select 
--date 'Date' 
sum(new_cases) 'Total Cases', sum(cast(new_deaths as int)) 'Total Deaths',  
sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death %'
from PortfolioProject..CovidDeaths
where (new_cases != 0 and new_deaths != 0)
--group by date
order by 1,2



---- Total population vs vaccinations 


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


---- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (Rolling_People_Vaccinated/Population)*100 as 'vaccination%'
from PopvsVac



-- Temp Table 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continen nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
Rolling_People_Vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
-- order by 2,3

select *, (Rolling_People_Vaccinated/Population)*100 as 'vaccination%'
from #PercentPopulationVaccinated



----- Creating view to store data for later visualization 

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
