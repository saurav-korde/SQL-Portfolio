# 🌍 Global COVID-19 Analysis (SQL)

## 📌 Project Overview
This project analyzes real-world pandemic data (Jan 2020 - Dec 2023) to identify global health trends, infection rates, and vaccination progress. Moving beyond basic aggregations, this analysis focuses on **Time-Series Analysis** and **Advanced SQL functions**.

**Key Technical Skills:**
* **Window Functions:** `OVER (PARTITION BY ... ORDER BY ...)` for rolling totals.
* **CTEs:** Complex calculations on aggregated data.
* **Data Wrangling:** Handling `NULL` vs Empty Strings in legacy datasets.
* **Views:** Creating persistent virtual tables for visualization tools.

## 🗄️ The Data
* **Source:** Our World in Data (Standardized COVID-19 Dataset).
* **Volume:** ~85,000+ records across 2 tables (`CovidDeaths`, `CovidVaccinations`).
* **Format:** Relational Structure (Joined on `location` and `date`).

## 🔎 Key Insights Generated
1.  **Likelihood of Dying:** Calculated daily death percentages for specific regions (e.g., India, USA).
2.  **Infection Rates:** Identified countries with the highest infection count relative to population.
3.  **Vaccination Speed:** Implemented rolling counts to track how quickly populations reached vaccination milestones.

## 🛠️ Code Structure
* `Covid_Analysis.sql`: The main analytical script containing all 10 strategic queries.
* `load_data.sql`: The schema setup for PostgreSQL (Tables & Data Types).