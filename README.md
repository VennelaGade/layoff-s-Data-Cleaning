# layoff's -Data-Cleaning
SQL Data Cleaning Project on Layoffs Dataset



Layoffs Data Cleaning Using SQL:

Objective:

Cleaned and prepared a layoffs dataset by removing duplicates, standardizing data, handling missing values, and fixing data types for accurate analysis.

Key Steps:

Duplicate Removal: Identified and removed duplicate records using ROW_NUMBER().

Data Standardization: Trimmed spaces, unified industry names (e.g., standardized "Crypto"), and fixed inconsistent country names.

Handling Missing Values: Replaced nulls in industry using other rows with the same company, retained meaningful nulls in financial columns.

Data Transformation: Converted text dates to DATE format for accuracy.

Cleaning Useless Data: Deleted rows with nulls in key columns (total_laid_off, percentage_laid_off).


Outcome:

Successfully cleaned and standardized the dataset, ensuring it’s ready for analysis.

