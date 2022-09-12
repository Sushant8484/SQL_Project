/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- select data that we are going to be starting with

select location , date , total_cases , new_cases, total_deaths ,population
from covid_deaths 
where continent is not null
order by 1 ;

-- Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

select location ,total_cases,total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths 
where location like  "%states%"
where continent is not null
order by 1; 

-- Total Cases vs Population 
-- show what percentage of population infectetd with covid

select location ,date,population  ,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from covid_deaths 
-- where location like  "%states%"
order by 1; 

-- Countries with Highest Infection Rate compared to Population

select location , population  ,max(total_cases) as HighestInfectionCount ,max((total_cases/population))*100 as PercentPopulationInfected
from covid_deaths 
-- where location like  "%states%"
group by location
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

select location , max(cast(total_deaths AS float)) as TotalDeathCount
from covid_deaths 
where continent is not null
group by location
order by TotalDeathCount desc;

-- Breaking Things Down by Continent

-- Showing Continents with the highest death count per population

select continent , max(cast(total_deaths AS float)) as TotalDeathCount
from covid_deaths 
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Global Numbers

select sum(new_cases) as total_cases , sum(new_deaths) as total_deaths ,
sum(new_deaths)/sum(new_cases) *100 as DeathPercentage  from covid_deaths
where continent is not null 
-- group by date
order by 1 ;

-- Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent , dea.location , dea.date , dea.population ,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location ,
dea.date) as RollingPeopleVaccination
from covid_deaths as dea inner join covidvacc as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2 ,3 
; 

-- Using CTE to perform Calculation on Partition By in previous query

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

-- Using Temp Table to perform Calculation on Partition By in previous query

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

-- Creating View to store data for later visualization

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

