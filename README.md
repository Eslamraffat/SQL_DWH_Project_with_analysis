📦 SQL Data Warehouse Project
End‑to‑End Data Warehouse Design | ETL | Star Schema | Business Analytics
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
- Create business‑ready analytical queries
- Demonstrate warehouse modeling concepts (surrogate keys, SCD logic, grain definition, etc.)

🏗️ Architecture
Layers Included
- Raw Layer – Direct ingestion of source files
- Staging Layer – Data cleaning, type casting, deduplication
- Warehouse Layer – Fact & dimension tables
- Analytics Layer – Business metrics and insights
Schema Design
- FactSales (transaction-level facts)
- DimCustomer
- DimProduct

📊 Business Questions Answered
Examples of insights generated:
- Which products generate the highest revenue
- Customer purchasing behavior and segmentation
- Store performance across regions
- Monthly and yearly sales trends
- Profitability analysis by product and store

🛠️ Technologies Used
- SQL Server
- Dimensional Modeling (Kimball)
- ETL SQL Scripts
- Data Cleaning & Standardization
- Power BI

📁 Repository Structure
├── raw_data/
├── staging_scripts/
├── warehouse_scripts/
├── analytics_queries/
├── diagrams/
└── README.md



🧩 My Contributions
To ensure this project reflects my own skills and not just a tutorial replication, I added:
- Additional SQL optimizations
- Enhanced documentation and comments
- A fully rewritten README with business context
- Additional analytical queries
- Custom ERD and architecture diagrams
- Improved naming conventions and folder structure

🙌 Credits
This project was inspired by and built alongside the learning series created by Baraa (DataWithBaraa).
He generously provides the project idea and dataset for free educational use.
Original concept and dataset: DataWithBaraa
Implementation, enhancements, documentation: Eslam
