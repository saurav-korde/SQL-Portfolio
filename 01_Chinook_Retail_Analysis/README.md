# 🎵 SQL Project: Chinook Digital Media Store

## 📄 Project Overview
**Role:** Backend Data Analyst (Simulation)  
**Domain:** E-Commerce / Digital Retail  
**Database:** PostgreSQL  
**Tools:** VS Code, Git

This project simulates a real-world business scenario where I acted as the lead analyst for "Chinook," a digital media retailer. The goal was to transform raw relational data into actionable business strategies, focusing on customer segmentation, sales trends, and inventory management.

## 🔧 The Schema
![Chinook ER Diagram](./chinook_schema.png)

The analysis utilizes the Chinook database, a highly normalized relational schema consisting of **11 tables** (depicted above).

## 🚀 Key Business Problems Solved
I wrote optimized SQL queries to answer critical business questions. You can find the complete SQL script in [`Chinook_Analysis.sql`](./Chinook_Analysis.sql).

### 1. Customer Segmentation (High-Value Targets)
* **The Challenge:** Marketing needed to identify VIP customers for a loyalty campaign.
* **The Solution:** Implemented a **CTE (Common Table Expression)** to calculate average customer spending and filter for those exceeding the baseline.
* **Tech Stack:** `WITH ... AS`, Subqueries, Aggregations.

### 2. Global Market Penetration
* **The Challenge:** The executive team needed a clear view of our strongest geographic markets.
* **The Solution:** Aggregated sales data by country, applying a `HAVING` clause to filter out low-performing regions ($100+ threshold).
* **Tech Stack:** `GROUP BY`, `HAVING`, `SUM()`.

### 3. Inventory Categorization
* **The Challenge:** The Product team required a better way to categorize songs by duration for playlist generation.
* **The Solution:** Developed logic to classify tracks as 'Short', 'Medium', or 'Long' based on millisecond duration.
* **Tech Stack:** `CASE` Statements (Conditional Logic).

### 4. Sales Attribution (The "Chain Link" Join)
* **The Challenge:** Tracing individual line-item sales back to the original Artist to find our "Best Selling Artist."
* **The Solution:** Executed a complex **4-table JOIN** (`InvoiceLine` -> `Track` -> `Album` -> `Artist`) to maintain data integrity across the normalized schema.
* **Tech Stack:** `INNER JOIN`, Relational Data Modeling.

## 🛠️ Setup Instructions
If you want to replicate this analysis locally:
1.  Clone this repository.
2.  Open the `Chinook_PostgreSql.sql` file in VS Code.
3.  Run the script to build the schema in your local PostgreSQL instance.
4.  Execute `Chinook_Analysis.sql` to view the queries and results.

---
*Analysis by Saurav Korde | 2025*
