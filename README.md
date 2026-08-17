# Brazilian Fuel Prices: Database Modeling & Analysis

A comprehensive relational database project designed to store, clean, validate, and analyze historical fuel price data in Brazil. The dataset originates from the National Agency of Petroleum, Natural Gas and Biofuels (ANP).

* **Official Portal:** [Dados.gov.br - Série Histórica de Preços de Combustíveis]https://dados.gov.br/dados/conjuntos-dados/serie-historica-de-precos-de-combustiveis-e-de-glp
* **Specific Resource Used:** 1º Semestre de 2004 - Combustíveis Automotivos

## 🛠️ Tech Stack
* **Database Management System:** PostgreSQL
* **Language/Scripting:** SQL, PL/pgSQL
* **Tools:** pgAdmin 4
---

## 🗄️ Database Architecture & Normalization

The raw data provided by the ANP was heavily denormalized. To eliminate data redundancy and anomalies, the schema was systematically restructured up to the **Third Normal Form (3NF)**:

1. **`REGIAO`**: Stores the macro geographic regions of Brazil.
2. **`ESTADO`**: Houses state acronyms linked via Foreign Key to their respective regions.
3. **`LOCAL`**: Maps postal codes (CEPs) to specific municipalities and states.
4. **`REVENDA`**: Contains normalized cadastro data for individual fuel stations, linked to postal codes.
5. **`PRODUTO`**: Catalog of fuel types (gasoline, ethanol, diesel, GNV) with unique identifiers.
6. **`PRECO`**: The core transactional table recording prices, collection dates, and measurement units using a composite primary key.

---

## ⚙️ Backend Engineering (PL/pgSQL)

The database enforces automated business rules and auditing directly at the engine level:

* **Mass Price Updates (`Stored Procedure`):** Allows bulk percentage adjustments on purchasing prices safely across the dataset.
* **CEP Duplication Guard (`Stored Procedure`):** Prevents duplicate entries for postal codes by validating existence prior to insertion.
* **Sales Price Validation (`Trigger`):** Blocks any insert or update where the selling price is zero, negative, or lower than the purchasing price.
* **Automated Auditing (`Trigger & Log Table`):** Automatically logs historical updates made to fuel prices into a `PRECO_AUDITORIA` table, recording old/new values, timestamps, and the user responsible.

---

## 🚀 How to Run and Test

Follow the execution order below in your PostgreSQL / pgAdmin environment to build the database from scratch:

1. **Create the Schema & Tables:**
   Run `1_schema.sql` to instantiate the normalized relational schema inside a dedicated schema.
2. **Load Raw Data (ETL Staging):**
   Run `4_etl_pipeline.sql` (creating the staging table `temp2`, importing your raw CSV dataset via pgAdmin's import wizard, and executing the transformation scripts to clean and distribute the data into the normalized tables).
3. **Deploy Business Rules:**
   Run `2_procedures_triggers.sql` to compile the functions, triggers, and audit mechanisms.
4. **Run Analytics Queries:**
   Execute the queries in `3_analytics_queries.sql` to extract insights and generate reports.

---
