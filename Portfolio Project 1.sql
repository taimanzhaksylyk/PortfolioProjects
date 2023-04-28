select *
from PortfolioP1..CovidDeaths$
where continent is not null
order by 3, 4

 select * 
from PortfolioP1..CovidVaccinations$
where continent is not null
order by 3, 4

--Select data to be used
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioP1..CovidDeaths$
where continent is not null
order by 1, 2

--Total cases vs total deaths
SELECT Location, date, CAST(total_cases as int) as total_cases, CAST(total_deaths as int) as total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 as news
FROM PortfolioP1..CovidDeaths$
where Location = 'Canada' and continent is not null
ORDER BY 1, 2

--Total cases vs population 
SELECT Location, date, population, CAST(total_cases as int) as total_cases, (CAST(total_cases as float)/CAST(population as float))*100 as infection_rate
fROM PortfolioP1..CovidDeaths$
where Location = 'Canada'
ORDER BY 1, 2

--Countries by infection rate  
SELECT Location, population, MAX(CAST(total_cases as int)) as max_total_cases, (max(CAST(total_cases as float))/CAST(population as float))*100 as total_infection_rate
FROM PortfolioP1..CovidDeaths$
group by Location, population
ORDER BY total_infection_rate desc

--Countries by death rate  
SELECT Location, population, MAX(CAST(total_deaths as int)) as max_total_deaths, (max(CAST(total_deaths as float))/CAST(population as float))*100 as total_death_rate
FROM PortfolioP1..CovidDeaths$
where continent is not null
group by Location, population
ORDER BY total_death_rate desc

--STATS BY CONTINENT
select location, max(cast(total_deaths as float)) as total_deaths,
	(max(cast(total_deaths as float))/cast(population as float))*100 as death_rate
from PortfolioP1..CovidDeaths$
where continent is null 
	and location not like '%income' 
	and location <> 'world'
group by location, population
order by death_rate desc

--Global stats
select date, sum(cast(new_cases as float)) as total_cases,
	sum(cast(new_deaths as float)) as total_deaths,
	(case when sum(new_cases) = 0 then 0 else sum(cast(new_deaths as float))/sum(new_cases)*100 end) as death_rate
from PortfolioP1..CovidDeaths$
where continent is not null and total_deaths > 0
group by date
order by 1, 2

--Overall total cases and deaths
select  sum(cast(new_cases as float)) as total_cases,
	sum(cast(new_deaths as float)) as total_deaths,
	sum(cast(new_deaths as float))/sum(new_cases)*100 as death_rate
from PortfolioP1..CovidDeaths$
where continent is not null and total_deaths > 0
order by 1, 2


select * 
from PortfolioP1..CovidDeaths$ as dea
join PortfolioP1..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date

--Total vaccination by location and date
select dea.date, dea.location, dea.population, vac.new_vaccinations,
	sum(cast(new_vaccinations as float)) 
	over (partition by dea.location order by dea.location, dea.date) 
	as total_vacc_to_date
from PortfolioP1..CovidDeaths$ as dea
join PortfolioP1..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where vac.continent is not null
order by dea.location, dea.date

--Share of the vaccinated population from the total population
with PopVsVac (Continent, Location, Date, Population, new_vac, total_rolling_vac)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(new_vaccinations as float)) 
	over (partition by dea.location order by dea.location, dea.date) 
	as total_vacc_to_date
from PortfolioP1..CovidDeaths$ as dea
join PortfolioP1..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where vac.continent is not null
)

select *, (total_rolling_vac/Population)*100 as vac_rate
from PopVsVac
order by Location, Date

--The latest vaccination rate by country
with PopVsVac (Continent, Location, Date, Population, new_vac, total_vac_count)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(new_vaccinations as float)) 
	over (partition by dea.location order by dea.location, dea.date) 
	as total_vacc_to_date
from PortfolioP1..CovidDeaths$ as dea
join PortfolioP1..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where vac.continent is not null
)

select Location, max(Date), Population, max(total_vac_count), (max(total_vac_count))/Population*100 as vac_rate
from PopVsVac
group by Location, Population
order by vac_rate desc


--Create view to store date for data visualization

Create View VacRateByCountry
as 
with PopVsVac (Continent, Location, Date, Population, new_vac, total_vac_count)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(new_vaccinations as float)) 
	over (partition by dea.location order by dea.location, dea.date) 
	as total_vacc_to_date
from PortfolioP1..CovidDeaths$ as dea
join PortfolioP1..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where vac.continent is not null
)

select Location, max(Date) as latest_date, Population, max(total_vac_count) as total_vac_count, (max(total_vac_count))/Population*100 as vac_rate
from PopVsVac
group by Location, Population

select * from VacRateByCountry
