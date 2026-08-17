# Brazilian Fuel Prices: Database Analysis

A comprehensive relational database project designed to store, clean, validate, and analyze historical fuel price data in Brazil. The dataset originates from the National Agency of Petroleum, Natural Gas and Biofuels (ANP).

* **Official Portal:** https://dados.gov.br/dados/conjuntos-dados/serie-historica-de-precos-de-combustiveis-e-de-glp
* **Specific Resource Used:** 1º Semestre de 2004 - Combustíveis Automotivos

## 🛠️ Tech Stack
* **Database Management System:** PostgreSQL
* **Language/Scripting:** SQL, PL/pgSQL
* **Tools:** pgAdmin 4
---

## 🗄️ Database Architecture & Normalization

The raw data provided by the ANP was heavily denormalized. To eliminate data redundancy and anomalies, the schema was systematically restructured up to the **Third Normal Form (3NF)**:

1. **`REGIAO` & `ESTADO`**: Geographic hierarchy of Brazil.
2. **`LOCAL`**: Maps postal codes (CEPs) to specific municipalities and states.
3. **`REVENDA`**: Normalized station records linked to local postal codes.
4. **`PRODUTO`**: Catalog of fuel types (gasoline, ethanol, diesel, GNV) with unique identifiers.
5. **`PRECO`**: A transactional table recording prices, collection dates, and measurement units using a composite primary key.

---

## ⚙️ Backend Engineering (PL/pgSQL)

T* **Procedures:** Handles bulk price updates and blocks duplicate CEP entries.
* **Triggers:** Validates that selling prices are greater than zero and never drop below purchasing costs, while automatically logging historical updates to an audit table.

---

## 🚀 How to Run and Test

Follow the execution order below in your PostgreSQL / pgAdmin environment to build the database from scratch:

1. **Schema:** Run `1_schema.sql` to create the database architecture.
   
2. **ETL:** Run `4_etl_pipeline.sql` to create the staging table `temp2`, import your raw CSV data into it, and execute the remaining scripts to clean and distribute the data into the normalized tables.
   
3. **Business Rules:** Run `2_procedures_triggers.sql` to deploy functions and triggers.
   
4. **Analytics:** Execute `3_analytics_queries.sql` to run the analytical reports.

---
