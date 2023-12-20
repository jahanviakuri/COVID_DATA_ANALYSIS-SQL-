--exploring data

select * from Protfolioproject..CovidDeaths order by location

select * from Protfolioproject..CovidVaccinations order by location


---location wise cases

Select location,total_cases, new_cases,population
From Protfolioproject..CovidDeaths
Where continent is not null 
order by location


Select location,max(total_cases) as Infectedcount, ROUND(max(total_cases/population)*100,2) as Infectedpercent
From Protfolioproject..CovidDeaths
Where continent is not null 
group by location
order by infectedpercent DESC

--location wise deaths 

Select location,total_deaths, new_deaths,population
From Protfolioproject..CovidDeaths
Where continent is not null 
order by location


Select location,max(total_deaths) as Deathcount, ROUND(max(convert(int,total_deaths)/population)*100,2) as  deathpercent
From Protfolioproject..CovidDeaths
Where continent is not null and location = 'Canada'
group by location
order by deathpercent DESC

---continent wise cases

Select continent,total_cases, new_cases,population
From Protfolioproject..CovidDeaths
Where continent is not null 
order by continent


Select continent,max(total_cases) as Infectedcount, ROUND(max(total_cases/population)*100,2) as Infectedpercent
From Protfolioproject..CovidDeaths
Where continent is not null 
group by continent
order by Infectedpercent DESC

--continent wise deaths 

Select continent,total_deaths, new_deaths,population
From Protfolioproject..CovidDeaths
Where continent is not null 
order by continent


Select continent,max(total_deaths) as Deathcount, ROUND(max(convert(int,total_deaths)/population)*100,2) as  deathpercent
From Protfolioproject..CovidDeaths
Where continent is not null 
group by continent
order by deathpercent DESC

--worldwide cases and deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Protfolioproject..CovidDeaths
where continent is not null 


---Population vs Vaccinations

---for every location we need to starover count,  so partition by loc

Select d.location,d.population,v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location order by d.location, d.date) as vaccinatedcount
From Protfolioproject..CovidDeaths d
join Protfolioproject..CovidVaccinations v
on d.location = v.location
and d.date=v.date
Where d.continent is not null
order by d.location

--create CTE or temp table to use the vaccinated count column 

With CTE_COVID(location ,population,new_vaccination,Vaccinatedcount)
as
(
Select d.location,d.population,v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location order by d.location, d.date) as vaccinatedcount
From Protfolioproject..CovidDeaths d
join Protfolioproject..CovidVaccinations v
on d.location = v.location
and d.date=v.date
Where d.continent is not null

)
select *,(Vaccinatedcount/population)*100 as PercentPopulationVaccinated from CTE_COVID


--temp table 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
location nvarchar(255),
Population numeric,
New_vaccinations numeric,
Vaccinatedcount numeric
)

Insert into #PercentPopulationVaccinated
Select d.location,d.population,v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location order by d.location, d.date) as vaccinatedcount
From Protfolioproject..CovidDeaths d
join Protfolioproject..CovidVaccinations v
on d.location = v.location
and d.date=v.date
Where d.continent is not null

select *,(Vaccinatedcount/population)*100 as PercentPopulationVaccinated from #PercentPopulationVaccinated


--creating view

Create View PercentPopulationVaccinated as

Select d.location,d.population,v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location order by d.location, d.date) as vaccinatedcount
From Protfolioproject..CovidDeaths d
join Protfolioproject..CovidVaccinations v
on d.location = v.location
and d.date=v.date
Where d.continent is not null


select * from PercentPopulationVaccinated
