#layoff's Data Cleaning

USE world_layoffs;

select * from layoffs;
select column_name from information_schema.columns where table_name='layoffs'; # to know the columns

# first we are creating a copy of data. this doesnot effect the raw data in case if something goes wrong.
CREATE TABLE layoffs_staging 
LIKE layoffs;

INSERT into layoffs_staging select * from layoffs; 
select * from layoffs_staging;
# Now, when we are cleaning data, we follow few steps 
-- 1. check duplicates and remove 
-- 2. Standardize data 
-- 3. check for null values/blanks
-- 4. remove columns/rows if not necessary

# we dont have any unique column
-- So we find duplicates based on all columns:
WITH duplicate_cte as
(
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
select * from duplicate_cte where row_num>1;

-- delete from duplicate_cte where row_num>1;  ## Error : the target table duplicate_cte of the DELETE is not updatable.
-- so we create a new table and add a new column row_num , then we delete duplicate rows.

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2 
(
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
);

select * from layoffs_staging2;  ## created new column row_num 
    
## now we delete duplicate rows     
DELETE from layoffs_staging2 where row_num>1;


-- 2. Standardise data : here we fix some data issues

SELECT distinct(company) from layoffs_staging2;
UPDATE layoffs_staging2 SET company=trim(company);
select * from layoffs_staging2;
-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry like 'crypto%';

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

select distinct country from layoffs_staging2;

-- found some issue with country name , which makes it difficult while grouping,accuracy
select distinct country from layoffs_staging2 
where country like 'united states%';

 -- to fix this
UPDATE layoffs_staging2 
SET country='United States'  ## set country=trim(trailing '.' from country)
where country like 'united states%';    

-- Let's also fix the date columns:
SELECT *
FROM layoffs_staging2;

-- we can use str to date to update this field
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. to deal with null/blank values
-- if we look at industry it looks like we have some null and empty rows, let's take a look at these
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry is NULL 
OR industry = ''
ORDER BY industry;


select t1.industry,t2.industry
from layoffs_staging2 t1 
join layoffs_staging2 t2
on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and t2.industry is not null;
-- let's take a look at these
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';
-- nothing wrong here
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- now we need to populate those nulls if possible


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;



-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values




-- 4. remove any columns and rows we need to

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

