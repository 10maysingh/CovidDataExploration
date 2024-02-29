--select * from CovidDeaths where continent is not null order by 3,4;

--select * from CovidVaccinations order by 3,4;

--select data that we are gonna use

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths where continent is not null order by 1,2;


--looking at day-wise total cases vs total deaths (Death percentage) in United States
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as PercentPopulationInfected
from CovidDeaths where location like '%states'
and continent is not null
order by 1,2;

--Looking at the total cases vs population
--what percentage of population got covid
Select Location, date,population, total_cases, (total_cases/population)*100 as DeathPercentage
from CovidDeaths where location like '%states'
order by 1,2;


--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths 
where continent is not null
group by location, population
order by PercentPopulationInfected desc;


--show countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths where continent is not null
group by location
order by TotalDeathCount desc;


--breaking things down by continent
--showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths where continent is not null
group by continent 
order by TotalDeathCount desc;


-- Global Numbers
Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, 
Nullif(sum(new_deaths), 0)/nullif(sum(new_cases), 0)*100 as deathpercentage
from CovidDeaths where continent is not null
group by date
order by 1,2;


--looking at total population vs vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(convert(bigint,v.new_vaccinations)) OVER (PARTITION by d.location order by d.location,d.date ) as RollingPeopleVaccinated
from CovidDeaths as d JOIN CovidVaccinations as v 
on d.location=v.location and d.date=v.date where d.continent is not null
order by 2,3;

--using CTE

With PopvsVac (Continent, Location, Date, population, New_Vaccinations, RollingPeopleVaccinated)
as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(convert(bigint,v.new_vaccinations)) OVER (PARTITION by d.location order by d.location,d.date ) as RollingPeopleVaccinated
from CovidDeaths as d JOIN CovidVaccinations as v 
on d.location=v.location and d.date=v.date where d.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 from PopvsVac;

--creating a view
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(convert(bigint,v.new_vaccinations)) OVER (PARTITION by d.location order by d.location,d.date ) as RollingPeopleVaccinated
from CovidDeaths as d JOIN CovidVaccinations as v 
on d.location=v.location and d.date=v.date where d.continent is not null
--order by 2,3




