/*

Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- looking for total cases vs total deaths 
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select a.continent, a.location, a.date, a.population, b.new_vaccinations
,SUM(CONVERT(float,b.new_vaccinations)) OVER (Partition by b.Location Order by b.location, b.Date) as RollingPeopleVaccinated
from CovidDeaths as a
join CovidVaccinations as b
on a.location = b.location and a.date = b.date
where a.continent is not null
order by 2,3

-- Using CTE or sub query to perform Calculation on Partition By in previous query

select * , (RollingPeopleVaccinated/Population)*100 as pop_recieved_onedose from
(Select a.continent, a.location, a.date, a.population, b.new_vaccinations
,SUM(CONVERT(float,b.new_vaccinations)) OVER (Partition by b.Location Order by b.location, b.Date) as RollingPeopleVaccinated
from CovidDeaths as a
join CovidVaccinations as b
on a.location = b.location and a.date = b.date
where a.continent is not null) as d

-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select * , (RollingPeopleVaccinated/Population)*100 as pop_recieved_onedose from
(Select a.continent, a.location, a.date, a.population, b.new_vaccinations
,SUM(CONVERT(float,b.new_vaccinations)) OVER (Partition by b.Location Order by b.location, b.Date) as RollingPeopleVaccinated
from CovidDeaths as a
join CovidVaccinations as b
on a.location = b.location and a.date = b.date
where a.continent is not null) as d


