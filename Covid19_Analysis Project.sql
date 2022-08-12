-- select * from coviddeaths order by 3,4;

-- select * from covidvaccinations order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from coviddeaths order by 1,2;

-- Looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from coviddeaths where location like "%states%"
order by 1,2 ASC;

-- Looking at Total cases vs population
select location, date, population, total_cases, (total_cases/population) * 100 as percentofpopulation
from coviddeaths where location like "%states%"
order by 1,2 ASC;

-- Country has highest infection rate
select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population)) * 100 as percentofpopulation
from coviddeaths 
-- where location like "%states%"
group by population, location
order by 1,2 ASC;

-- Showing total deaths per countries
select location, population, MAX(cast(total_deaths as signed)) as totaldeathscount
from coviddeaths 
-- where location like "%states%"
where continent is not null
group by location, population
order by 1,2 ASC;

-- Break things down by continent
select continent, MAX(cast(total_deaths as signed)) as totaldeathscount
from coviddeaths 
-- where location like "%states%"
where continent != ''
group by continent
order by totaldeathscount DESC;

-- showing contnent with highest death rate
select continent, MAX(cast(total_deaths as signed)) as totaldeathscount
from coviddeaths 
-- where location like "%states%"
where continent != ''
group by continent
order by totaldeathscount DESC;

-- global numbers 
select date,Sum(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/ SUM(NEw_cases) *100 as deathpercentage 
from coviddeaths 
-- where location like "%states%"
where continent is not null
group by date, date
order by 1,2 ;

--  JOIN
select *
FROM coviddeaths dea 
join covidvaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date;
    
-- Looking for total population 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddeaths dea Join covidvaccinations vac
	on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;  

-- Looking for total population vs population 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations, signed)) 
over (partition by dea.location order by dea.location, dea.date)
-- (rollingpeoplevaccinated / population )*100
from coviddeaths dea Join covidvaccinations vac
	on dea.location = vac.location 
    and dea.date = vac.date
Where dea.continent is not null
order by 2,3;

-- USE CTE

With popvsvac (contitnet, Location, date, population, New_vaccinations, Rollingpeoplevaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations, signed)) 
over (partition by dea.location order by dea.location, dea.date)
-- (rollingpeoplevaccinated / population )*100
from coviddeaths dea Join covidvaccinations vac
	on dea.location = vac.location 
    and dea.date = vac.date
Where dea.continent != ''
-- order by 2,3
)
Select *, (Rollingpeoplevaccinated/Population) *100
From popvsvac;

-- Temp table
Drop table if exists portfolio_project.temp1;

Create temporary table portfolio_project.temp1

(
continent nvarchar(255),
Location nvarchar (2255),
population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric
);

Insert into portfolio_project.temp1
Select dea.continent, dea.location, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations, signed)) 
over (partition by dea.location order by dea.location, dea.date)
-- (rollingpeoplevaccinated / population )*100
from coviddeaths dea Join covidvaccinations vac
	on dea.location = vac.location 
    and dea.date = vac.date
    where vac.new_vaccinations != '';
-- Where dea.continent != ''
-- order by 2,3

Select *, (Rollingpeoplevaccinated/Population) *100
From portfolio_project.temp1;

-- creating view
create view Portfolio_Project.percentpopulation as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations, signed)) 
over (partition by dea.location order by dea.location, dea.date)
-- (rollingpeoplevaccinated / population )*100
from coviddeaths dea Join covidvaccinations vac
	on dea.location = vac.location 
    and dea.date = vac.date
Where dea.continent != '';percentpopulation




