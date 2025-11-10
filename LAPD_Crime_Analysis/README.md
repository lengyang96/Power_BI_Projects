# LAPD Crime Analysis

## Introduction

This Power BI dashboard provides an insightful analysis of historical crime data from the LAPD, offering a comprehensive view of crime patterns. It includes visualizations that display the frequency of crimes throughout the week and by hour of the day, helping to identify peak times for criminal activity. Additionally, the dashboard highlights which premises are most frequently affected by crime and showcases the most commonly reported types of crimes, providing a valuable tool for understanding trends and informing public safety efforts.

## Methodology
- **Data Cleaning and Transformation with MySQL:** Cleaned and transformed raw data, addressing missing values to ensure better alignment with data descriptions. A .sql file is provided showcasing this step.
- **Data Transformation (ETL) with Power Query:** Loaded the cleaned data from a local mySQL server and performed additional transformations for integration into the dashboard.
- **Core Charts:** Utilized bar charts to showcase crime trends and summarize the crime data.
- **KPI Indicators:** Utilized cards to display key metrics, such as the number of reports and the average age of victims.

## Dashboard Overview

### Dashboard Landing Page

![Dashboard](/LAPD_Crime_Analysis/images/Dashboard.png)

The dashboard features two cards: one that summarizes the total number of reports and another that displays the average age of victims. These values update dynamically as users apply filters through the provided slicers.

At the top of the dashboard, two slicers allow users to filter the data by crime type and/or division area. Multiple selections can be made at once, offering greater control over how the data is displayed in the visualizations. Additionally, there is a button to clear all selectons made in the slicers, effectively resetting the visualizations to their default state.

The top two bar charts summarize crime frequencies, showing trends both throughout the week and by the hour of the day. This enables users to identify peak times for criminal activity. Additionally, the bottom two bar charts highlight where crimes are most concentrated and which types of crime are most prevalent.

## Data Source
The original data was produced and provided by the Los Angeles Police Department. The raw data can be found [here](https://data.lacity.org/Public-Safety/Crime-Data-from-2020-to-Present/2nrs-mtv8/about_data).