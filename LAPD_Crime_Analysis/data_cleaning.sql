-- Create Table
DROP TABLE IF EXISTS crime_data_from_2020_to_present;

CREATE TABLE `crime_data_from_2020_to_present` (
  `dr_no` text,
  `date_rptd` text,
  `date_occ` text,
  `time_occ` text,
  `area` text,
  `area_name` text,
  `rpt_dist_no` text,
  `part_1_2` int DEFAULT NULL,
  `crm_cd` text,
  `crm_cd_desc` text,
  `mocodes` text,
  `vict_age` text,
  `vict_sex` text,
  `vict_descent` text,
  `premis_cd` int DEFAULT NULL,
  `premis_desc` text,
  `weapon_used_cd` text,
  `weapon_desc` text,
  `status` text,
  `status_desc` text,
  `crm_cd_1` text,
  `crm_cd_2` text,
  `crm_cd_3` text,
  `crm_cd_4` text,
  `location` text,
  `cross_street` text,
  `lat` double DEFAULT NULL,
  `lon` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/**
Load in local data file into the respective table within the database.
 - Fields are terminated by a comma as the data is contained within a csv file.
 - Fields are optionally enclosed by a double quotation mark to account for within-field commas separating comments/remarks (e.g. crime code descriptions).
 - Ignore the first row which contains the header row.
**/
SET GLOBAL local_infile = 1;

LOAD DATA
 LOCAL
 INFILE 'C:/Users/Leng/Documents/LAPD_Crime_Analysis/Crime_Data_from_2020_to_Present.csv'
 INTO TABLE crime_data_from_2020_to_present
 FIELDS
  TERMINATED BY ','
  OPTIONALLY ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS;

-- Duplicate table for staging data cleaning.
CREATE TABLE crime_data_from_2020_to_present_staging AS SELECT * FROM crime_data_from_2020_to_present;

-- dr_no: Check for duplicate records using unique ID.
SELECT
 COUNT(DISTINCT DR_NO) AS distinct_records,
 COUNT(*) AS all_records
FROM crime_data_from_2020_to_present_staging;

/** 
date_rptd: Convert datetime string into a standardized datetime format.
- Check that the format is correctly converted.
- Update the column with the new format.
- Convert the column to the correct data type.
**/
SELECT
 date_rptd,
 STR_TO_DATE(date_rptd, '%m/%d/%Y %h:%i:%s %p') as date_rptd_std
FROM crime_data_from_2020_to_present_staging
LIMIT 10;

UPDATE crime_data_from_2020_to_present_staging
SET date_rptd = STR_TO_DATE(date_rptd, '%m/%d/%Y %h:%i:%s %p');

ALTER TABLE crime_data_from_2020_to_present_staging
MODIFY COLUMN date_rptd DATETIME;

/** 
date_occ: Combine DATE OCC & TIME OCC columns into a string, then into a standardized datetime format and standardized column name.
- Check that the format is correctly converted.
- Update the column with the new format.
- Convert the column into the correct date type and standardize the name.
- Drop the redundant time column.
**/
SELECT
 date_occ,
 time_occ,
 STR_TO_DATE(CONCAT(SUBSTRING(date_occ, 1, 10), ' ', time_occ), '%m/%d/%Y %H%i') AS datetime_occ
FROM crime_data_from_2020_to_present_staging
LIMIT 10;

UPDATE crime_data_from_2020_to_present_staging
SET date_occ = STR_TO_DATE(CONCAT(SUBSTRING(date_occ, 1, 10), ' ', time_occ), '%m/%d/%Y %H%i');

ALTER TABLE crime_data_from_2020_to_present_staging
CHANGE COLUMN date_occ datetime_occ DATETIME;

ALTER TABLE crime_data_from_2020_to_present_staging
DROP COLUMN time_occ;

-- area: Check geographic area codes, of which there are 21. This matches the data dictionary.
SELECT DISTINCT area
FROM crime_data_from_2020_to_present_staging
ORDER BY area;

-- area_name: Check geographic area names. There are 21 area names, matching the number of area codes.
SELECT DISTINCT area_name
FROM crime_data_from_2020_to_present_staging
ORDER BY area_name;


-- rpt_dist_no: The four-digit codes refer to sub-areas within larger geographic areas. Therefore, values should range from 01xx to 21xx.
SELECT DISTINCT rpt_dist_no
FROM crime_data_from_2020_to_present_staging
ORDER BY rpt_dist_no
LIMIT 10;

SELECT DISTINCT rpt_dist_no
FROM crime_data_from_2020_to_present_staging
ORDER BY rpt_dist_no DESC
LIMIT 10;

-- part_1_2: There should only be two values as they refer to the two categories of crimes in the FBI's Uniform Crime Reporting (UCR) program.
SELECT DISTINCT part_1_2
FROM crime_data_from_2020_to_present_staging;

-- crm_cd: Check for integrity of data, ensuring all codes are numeric. 140 unique codes are listed.
SELECT DISTINCT crm_cd
FROM crime_data_from_2020_to_present_staging
ORDER BY crm_cd;

-- crm_cd_desc: Check for integrity of data, ensuring no textual errors. 140 unique descriptions are listed, matching the number of respective codes.
SELECT DISTINCT crm_cd_desc
FROM crime_data_from_2020_to_present_staging
ORDER BY crm_cd_desc;

-- mocodes: Check for integrity of data, ensuring all numeric codes.
SELECT DISTINCT mocodes
FROM crime_data_from_2020_to_present_staging
ORDER BY mocodes
LIMIT 10;

SELECT DISTINCT mocodes
FROM crime_data_from_2020_to_present_staging
ORDER BY mocodes DESC
LIMIT 10;

/**
vict_age: Verify age is within a reasonable range.
- Convert data type to numeric.
- Replace negative values with 0, indicating unknown age at time of report.
**/
ALTER TABLE crime_data_from_2020_to_present_staging
MODIFY COLUMN vict_age INT;

UPDATE crime_data_from_2020_to_present_staging
SET vict_age = 0
WHERE vict_age < 0;

/**
vict_sex: Verify data corresponds to data dictionary.
- Querying the data shows there exists invalid values (e.g. blanks, H, -)
- Replace invalid values with X, representing an "unknown" sex.
**/
SELECT DISTINCT vict_sex
FROM crime_data_from_2020_to_present_staging;

UPDATE crime_data_from_2020_to_present_staging
SET vict_sex = 'X'
WHERE vict_sex IN ('', 'H', '-');

/**
vict_descent: Verify data corresponds to data dictionary.
- Querying the data shows there exists invalid values (e.g. blanks, and -)
- Replace invalid values with X, representing an "unknown" descent.
**/
SELECT DISTINCT vict_descent
FROM crime_data_from_2020_to_present_staging
ORDER BY vict_descent;

UPDATE crime_data_from_2020_to_present_staging
SET vict_descent = 'X'
WHERE vict_descent IN ('', '-');

-- premis_cd & premis_desc: Inspect premise codes and their corresponding descripstions. No changes needed.
SELECT DISTINCT premis_cd, premis_desc
FROM crime_data_from_2020_to_present_staging
ORDER BY premis_cd;

-- weapon_used_cd & weapon_desc: Inspect weapon codes and their corresponding descriptions. No changes needed.
SELECT DISTINCT weapon_used_cd, weapon_desc
FROM crime_data_from_2020_to_present_staging
ORDER BY weapon_used_cd;

/**
status & status_desc: Inspect status codes and their corresponding descriptions.
- Querying results found an empty status with a description of 'UNK'.
- Modified invalid results to match the default value stated in the data dictionary (IC/ Invest Cont).
**/
SELECT DISTINCT status, status_desc
FROM crime_data_from_2020_to_present_staging
ORDER BY status;

UPDATE crime_data_from_2020_to_present_staging
SET
 status = 'IC',
 status_desc = 'Invest Cont'
WHERE status = '';

-- crm_cd_1-4: Inspect codes to ensure integrity.
SELECT DISTINCT crm_cd_1
FROM crime_data_from_2020_to_present_staging
ORDER BY 1;

/**
location: Inspect location names for textuals errors.
- Stripped excess whitespace.
**/
SELECT DISTINCT TRIM(REGEXP_REPLACE(location, '[[:space:]]+', ' ')) as loc_trim
FROM crime_data_from_2020_to_present_staging
ORDER BY 1;

UPDATE crime_data_from_2020_to_present_staging
SET location = TRIM(REGEXP_REPLACE(location, '[[:space:]]+', ' '));

/**
cross_street: Inspect cross street names for textuals errors.
- Stripped excess whitespace.
**/
SELECT DISTINCT TRIM(REGEXP_REPLACE(cross_street, '[[:space:]]+', ' ')) as cross_street_trim
FROM crime_data_from_2020_to_present_staging
ORDER BY 1;

UPDATE crime_data_from_2020_to_present_staging
SET cross_street = TRIM(REGEXP_REPLACE(cross_street, '[[:space:]]+', ' '));

-- lat & long: Inspect values to ensure they are within bounds.
SELECT DISTINCT lat
FROM crime_data_from_2020_to_present_staging
ORDER BY lat;

SELECT DISTINCT lat
FROM crime_data_from_2020_to_present_staging
ORDER BY lat DESC;

SELECT DISTINCT lon
FROM crime_data_from_2020_to_present_staging
ORDER BY lon;

SELECT DISTINCT lon
FROM crime_data_from_2020_to_present_staging
ORDER BY lon DESC;
