show databases;
use project;
show tables;

-- select data that we are going to be using
select location , date , total_cases , new_cases, total_deaths ,population
from covid_deaths 
where continent is not null
order by 1 ;

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location ,total_cases,total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths 
-- where location like  "%states%"
where continent is not null
order by 1; 

-- looking at total cases vs population 
-- show what percentage of population got covid

select location ,date,population  ,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from covid_deaths 
-- where location like  "%states%"
where continent is not null
order by 1; 

-- Looking at countries with highest infection rate compared to population

select location , population  ,max(total_cases) as HighestInfectionCount ,max((total_cases/population))*100 as PercentPopulationInfected
from covid_deaths 
-- where location like  "%states%"
where continent is not null
group by location
order by PercentPopulationInfected desc;

-- showing countries with Highest Death Count per Population

select location , max(cast(total_deaths AS float)) as TotalDeathCount
from covid_deaths 
where continent is not null
group by location
order by TotalDeathCount desc;

-- Let's break things down by continent

-- showing continents with the highest death count per population
select continent , max(cast(total_deaths AS float)) as TotalDeathCount
from covid_deaths 
where continent is not null
group by continent
order by TotalDeathCount desc;

-- global numbers ( have to look into this more  )

select /*STR_TO_DATE(date,"%d/%m/%Y %h:%i %p") as D ,*/ sum(new_cases) as total_cases , sum(new_deaths) as total_deaths ,
sum(new_deaths)/sum(new_cases) *100 as DeathPercentage  from covid_deaths
where continent is not null 
-- group by D
order by 1 ;

-- looking at total population vs vaccination

select dea.continent , dea.location , dea.date , dea.population ,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location ,
dea.date) as RollingPeopleVaccination
from covid_deaths as dea inner join covidvacc as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2 ,3 
; 

-- USE CTE

with popVSvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccination) 
as
(
select dea.continent , dea.location , dea.date , dea.population ,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location ,
dea.date) as RollingPeopleVaccination
from covid_deaths as dea inner join covidvacc as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2 ,3 
)
select * , (rollingpeoplevaccination / population )*100 as VaccinationRate 
from popVSvac;

-- USE Temp Table

DROP table if exists PercentPopulationVaccinated

create temporary table PercentPopulationVaccinated
(
select dea.continent , dea.location , dea.date , dea.population ,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location ,
dea.date) as RollingPeopleVaccination
from covid_deaths as dea inner join covidvacc as vac
on dea.location = vac.location and dea.date = vac.date
-- where dea.continent is not null 
order by 2 ,3 
);

select * ,(rollingpeoplevaccination / population )*100 as VaccinationRate   from PercentPopulationVaccinated; 

-- create view to store data for later visualization

create view  PercentPopulationVaccinated 
as
select dea.continent , dea.location , dea.date , dea.population ,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location ,
dea.date) as RollingPeopleVaccination
from covid_deaths as dea inner join covidvacc as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2 ,3 
;

select * from PercentPopulationVaccinated;

