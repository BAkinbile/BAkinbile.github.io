Select *
From "Portfolio Project"..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From "Portfolio Project"..CovidVaccinations
--order by 3,4

-- Select the Data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From "Portfolio Project"..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths showing the likelihood of dying 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From "Portfolio Project"..CovidDeaths
Where location like '%Nigeria%'
Where continent is not null
order by 1,2

-- Total Cases vs Population showing the percentage of people with Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Population_Percentage
From "Portfolio Project"..CovidDeaths
Where location like '%Nigeria%'
order by 1,2

-- Countries with the highest infection rate in comparison to their Population

Select Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Population_Percentage
From "Portfolio Project"..CovidDeaths
--Where location like '%Nigeria%'
Group by Location, Population
order by Population_Percentage desc

-- Countries with the Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
From "Portfolio Project"..CovidDeaths 
--Where location like '%Nigeria%'
Where continent is not null
Group by Location
order by Total_Death_Count desc



--BREAKING THINGS DOWN BY CONTINENT

--Continents with the Highest Death Count per population

Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
From "Portfolio Project"..CovidDeaths 
--Where location like '%Nigeria%'
Where continent is not null
Group by continent 
order by Total_Death_Count desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From "Portfolio Project"..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--Group By date
order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From "Portfolio Project"..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group By date
order by 1,2


-- Showing Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location, 
  dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From "Portfolio Project"..CovidDeaths dea
Join "Portfolio Project"..CovidVaccinations vac 
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
  dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From "Portfolio Project"..CovidDeaths dea
Join "Portfolio Project"..CovidVaccinations vac 
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
)
Select *, (Rolling_People_Vaccinated/population)*100
From PopvsVac
order by 2,3

-- TEMP TABLE

DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
  dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From "Portfolio Project"..CovidDeaths dea
Join "Portfolio Project"..CovidVaccinations vac 
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (Rolling_People_Vaccinated/population)*100
From #Percent_Population_Vaccinated




--Creating View to store data for later visualizations
USE "Portfolio Project"
GO

DROP VIEW if exists Percent_Population_Vaccinated


Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
  dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From "Portfolio Project"..CovidDeaths dea
Join "Portfolio Project"..CovidVaccinations vac 
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From Percent_Population_Vaccinated