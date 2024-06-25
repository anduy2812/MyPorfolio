create database CovidStatistical

use CovidStatisical

select *
from CovidDeaths

select *
from CovidVaccinations

-- data that I going to be using

select
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from CovidDeaths
order by 1,2

-- Total cases vs total deaths

---- worldwide
select
	location,
	date,
	total_cases,
	total_deaths,
	format (total_deaths/total_cases, 'p') as deaths_pct
from CovidDeaths
where continent is not NULL
order by 1,2


---- Vietnam

select
	location,
	date,
	total_cases,
	total_deaths,
	format (total_deaths/total_cases, 'p') as deaths_pct_by_cases
from CovidDeaths
where location = 'Vietnam'
order by 1,2


-- Total cases rate vs population

select
	location,
	date,
	total_cases,
	population,
	format(total_cases/population, 'p') as infection_rate
from CovidDeaths
where continent is not NULL
order by 1,2

-- Countries with highest infection rate over population

select
	location,
	population,
	MAX(total_cases) as highest_cases_count,
	MAX((total_cases/population)*100) as infection_rate
from CovidDeaths
where continent is not NULL
group by [location], population
order by 4 desc


-- Highest death rate over population

select
	location,
	population,
	MAX(cast(total_deaths as INT)) as highest_deaths_count,
	MAX(format(cast(total_deaths as INT)/population, 'p')) as highest_deaths_rate
from CovidDeaths
where continent is not NULL
group by location, population
order by 3 DESC

select
	[location],
	MAX(cast (total_deaths as int)) as highest_death_count
from CovidDeaths
where continent is not null
group by [location]
order by MAX(cast (total_deaths as int)) DESC


-- highest deaths count by continent


select
	continent,
	MAX(CAST(total_deaths as int)) as highest_death_count
from CovidDeaths
where continent is not NULL
group by continent
order by highest_death_count


-- Global deaths count and deaths rate

select
	date,
	SUM (new_cases) as total_cases,
	SUM (cast (new_deaths as int)) as total_deaths,
	FORMAT (SUM (cast (new_deaths as int)) / SUM (new_cases), 'p') as deaths_rate
from CovidDeaths
where continent is not NULL
group by [date]
order by deaths_rate ASC


select
	SUM (new_cases) as total_cases,
	SUM (cast (new_deaths as int)) as total_deaths,
	FORMAT (SUM (cast (new_deaths as int)) / SUM (new_cases), 'p') as deaths_rate
from CovidDeaths
where continent is not NULL
order by deaths_rate ASC

select top 5
	*
from CovidVaccinations
select top 5
	*
from CovidDeaths

-- Population vs Vaccinations

select
	dea.continent,
	dea.[location],
	dea.[date],
	dea.population,
	vac.new_vaccinations
FROM CovidDeaths dea
	JOIN CovidVaccinations vac
	on 	dea.location = vac.location
		AND dea.[date] = vac.[date]
where dea.continent is not NULL
order by 2,3

-- Total population vs Vaccinations

-- Rolling count vaccinated

---- Using subquery

select
	*,
	format(rolling_people_vaccinated/population,'p') as pct
from (
	select
		dea.continent,
		dea.[location],
		dea.[date],
		dea.population,
		vac.new_vaccinations,
		SUM(cast (vac.new_vaccinations as int)) OVER (PARTITION BY vac.location order by dea.location, dea.[date]) as rolling_people_vaccinated
	from CovidDeaths dea
		join CovidVaccinations vac
		on dea.[location] = vac.[location]
			and dea.[date] = vac.[date]
	where vac.new_vaccinations > 0 and dea.continent is not null
	-- order by 2,3
) as rolling_tbl


---- Using CTE

With
	PopvsVac
	AS
	(
		Select
			dea.continent,
			dea.location,
			dea.date,
			dea.population,
			vac.new_vaccinations,
			SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
		--, (RollingPeopleVaccinated/population)*100
		From CovidDeaths dea
			Join CovidVaccinations vac
			On dea.location = vac.location
				and dea.date = vac.date
		where dea.continent is not null
		--order by 2,3
	)
Select
	*,
	FORMAT ((RollingPeopleVaccinated /population), 'p') as RollingVaccinatedPct
From PopvsVac

;

---- Remove null values

With
	PopvsVac
	AS
	(
		Select
			dea.continent,
			dea.location,
			dea.date,
			dea.population,
			CONVERT (int, IIF (vac.new_vaccinations is null, 0, vac.new_vaccinations)) as new_vaccinations
		From CovidDeaths dea
			Join CovidVaccinations vac
			On dea.location = vac.location
				and dea.date = vac.date
		where dea.continent is not null
	)
Select
	*,
	SUM(new_vaccinations) OVER (Partition by [location] order by [location],[date]) as RollingPeopleVaccinated,
	FORMAT (SUM(new_vaccinations) OVER (Partition by [location] order by [location],[date])/population, 'p') as RollingVaccinatedPct
From PopvsVac
order by 2,3

;

-- Create view

create view RollingVaccinatedPct AS 
select
	*,
	format(rolling_people_vaccinated/population,'p') as pct
from (
	select
		dea.continent,
		dea.[location],
		dea.[date],
		dea.population,
		vac.new_vaccinations,
		SUM(cast (vac.new_vaccinations as int)) OVER (PARTITION BY vac.location order by dea.location, dea.[date]) as rolling_people_vaccinated
	from CovidDeaths dea
		join CovidVaccinations vac
		on dea.[location] = vac.[location]
			and dea.[date] = vac.[date]
	where vac.new_vaccinations > 0 and dea.continent is not null
) as rolling_tbl



