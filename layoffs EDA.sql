-- EDA : Exploratory Data Analysis
Use world_layoffs;


-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers
-- normally when you start the EDA process you have some idea of what you're looking for
select * from layoffs_staging2;

-- with this info we are just going to look around and see what we find!
select max(total_laid_off) from layoffs_staging2;

select max(percentage_laid_off) from layoffs_staging2;  
-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
order by total_laid_off desc;
-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funds_raised_millions we can see how big some of these companies were
SELECT *
FROM layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, Quibi! I recognize that company raised like 2 billion dollars and went under.

-- company with biggest single layoff
select company,total_laid_off 
from layoffs_staging2
order by 2 desc 
limit 5;

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;


-- by location
SELECT location, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

select min(`date`),max(`date`) from layoffs_staging2;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 desc;


SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- running total of layoffs per month
select substring(`date`,1,7) as `MONTH` ,sum(total_laid_off) as total_layoffs
from layoffs_staging2
where substring(`date`,1,7) is not null
group by 1
order by 1;

-- now use it in a CTE so we can query off of it
with month_cte as
(
select substring(`date`,1,7) as `MONTH` ,sum(total_laid_off) as total_layoffs
from layoffs_staging2
where substring(`date`,1,7) is not null
group by 1
order by 1
)
select `month`,total_layoffs, sum(total_layoffs) over(order by `month`) as running_total
from month_cte;

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year
select company,year(`date`),sum(total_laid_off) as total_layoffs
from layoffs_staging2
group by 1,2
order by 3 desc;

-- to rank them based on year
with company_year  as 
(
select company,year(`date`) as `year`,sum(total_laid_off) as total_layoffs
from layoffs_staging2
group by 1,2
order by 3 desc
) , 
company_year_rank as
(
select *, dense_rank() over(partition by `year` order by total_layoffs desc) as ranking
from company_year
where `year` is not null
)
select * from company_year_rank
where ranking <=5;
