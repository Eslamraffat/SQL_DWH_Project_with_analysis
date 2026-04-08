📦 SQL Data Warehouse Project
End‑to‑End Data Warehouse Design | ETL | Star Schema
🧠 Overview
This project implements a complete SQL-based data warehouse following industry best practices.
It covers the full lifecycle: data ingestion → staging → transformation → dimensional modeling → analytics.
The goal is to simulate a real business scenario where raw operational data is transformed into a clean, analytics‑ready warehouse that supports reporting and decision‑making.
This project was inspired by a learning series created by DataWithBaraa, In addition to implementing the warehouse, I added my own analytical SQL layer to answer real business questions and demonstrate practical decision‑making insights.

🚀 Project Objectives
- Build a data warehouse using SQL Server
- Design a Star Schema with fact and dimension tables
- Implement ETL pipelines using SQL transformations
- Apply data cleaning, standardization, and validation
- Demonstrate warehouse modeling concepts (surrogate keys, SCD logic, grain definition, etc.)

🏗️ Architecture
Layers Included
- Raw Layer – Direct ingestion of source files
- Staging Layer – Data cleaning, type casting, deduplication
- Warehouse Layer – Fact & dimension tables
Schema Design
- FactSales (transaction-level facts)
- DimCustomer
- DimProduct

🛠️ Technologies Used
- SQL Server
- Dimensional Modeling (Kimball)
- ETL SQL Scripts
- Data Cleaning & Standardization

📁 Repository Structure
├── data_relations/
├── raw_data/
├── staging_scripts/
├── warehouse_scripts/
├── diagrams/
├── README.md
├── Data_catalog.md
├── License

🙌 Credits
This project was inspired by and built alongside the learning series created by Baraa (DataWithBaraa).
He generously provides the project idea and dataset for free educational use.
Original concept and dataset: DataWithBaraa
Implementation, enhancements, documentation: Eslam
