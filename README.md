Layoffs Data Analysis Project Using SQL
Objective: Cleaned and analyzed a layoffs dataset to identify trends and insights regarding workforce reductions across various companies.

Key Steps:

Data Cleaning:

Created a staging table: Used CREATE TABLE layoffs_staging LIKE layoffs; to preserve the original dataset.

Removed duplicates: Employed ROW_NUMBER() in a Common Table Expression (CTE) to identify duplicates.

Standardized data: Updated industry and country names with UPDATE statements and fixed date formats using STR_TO_DATE().

Handled missing values: Set blank industry fields to NULL and populated them from related entries using JOIN.

Deleted non-informative rows: Executed DELETE FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; to enhance data quality.

Exploratory Data Analysis (EDA):

Initial exploration: Used SELECT * FROM layoffs_staging2; to understand dataset structure.

Identified significant layoffs: Queried companies with 100% layoffs using WHERE percentage_laid_off = 1;.

Conducted geographical analysis: Aggregated layoffs by location with GROUP BY location.

Temporal analysis: Analyzed layoffs over time using GROUP BY YEAR(date) and running totals with window functions.

Examined by industry: Utilized GROUP BY industry to identify trends across different sectors.

Ranked companies: Employed CTEs and DENSE_RANK() to rank companies by total layoffs per year.

Outcome: Successfully improved data quality and identified significant trends and patterns in layoffs, providing valuable insights for future workforce planning and strategic decision-making.

