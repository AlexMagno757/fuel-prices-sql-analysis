SET search_path TO Combustivel;

-- 1. Create Staging Table for raw CSV data
CREATE TABLE temp2 (
    col1  TEXT, col2  TEXT, col3  TEXT, col4  TEXT,
    col5  TEXT, col6  TEXT, col7  TEXT, col8  TEXT,
    col9  TEXT, col10 TEXT, col11 TEXT, col12 TEXT,
    col13 TEXT, col14 TEXT, col15 TEXT, col16 TEXT
);

-- Note: At this point, the raw CSV file should be imported into 'temp2'.

-- 2. Populate REGIAO 
INSERT INTO REGIAO (Regiao_Sigla, Nome_Regiao)
VALUES 
    ('N', 'NORTE'), ('S', 'SUL'), ('NE', 'NORDESTE'),
    ('CO', 'CENTRO_OESTE'), ('SE', 'SUDESTE')
ON CONFLICT (Regiao_Sigla) DO NOTHING;

-- 3. Populate ESTADO (Extracting unique states and linking to regions)
INSERT INTO ESTADO (Estado_Sigla, Regiao_Sigla)
SELECT DISTINCT
       TRIM(col2) AS Estado_Sigla,
       TRIM(col1) AS Regiao_Sigla
FROM temp2
WHERE TRIM(col1) IN (SELECT Regiao_Sigla FROM REGIAO)
ON CONFLICT (Estado_Sigla) DO NOTHING;

-- 4. Populate LOCAL (Extracting cities and validating states)
INSERT INTO LOCAL (Cep, Municipio, Estado_Sigla)
SELECT DISTINCT
       TRIM(col10) AS Cep,
       TRIM(col3) AS Municipio,
       TRIM(col2) AS Estado_Sigla
FROM temp2
WHERE TRIM(col2) IN (SELECT Estado_Sigla FROM ESTADO)
ON CONFLICT (Cep) DO NOTHING;

-- 5. Populate REVENDA (Cleaning strings and linking to LOCAL via CEP)
INSERT INTO REVENDA (
    CNPJ_Revenda, NomeRevenda, Nome_Rua, Numero, 
    Bairro, Complemento, Bandeira, Cep
)
SELECT DISTINCT
       LEFT(TRIM(col5),50) AS CNPJ_Revenda,      
       TRIM(col4) AS NomeRevenda,
       TRIM(col6) AS Nome_Rua,
       TRIM(col7) AS Numero,
       TRIM(col9) AS Bairro,
       TRIM(col8) AS Complemento,
       TRIM(col16) AS Bandeira,
       LEFT(TRIM(col10),18) AS Cep
FROM temp2
WHERE LEFT(TRIM(col10),18) IN (SELECT Cep FROM LOCAL)
ON CONFLICT (CNPJ_Revenda) DO NOTHING;

-- 6. Populate PRODUTO (Extracting unique fuel types)
INSERT INTO PRODUTO (NomeProduto)
SELECT DISTINCT TRIM(col11) AS NomeProduto
FROM temp2
ON CONFLICT (NomeProduto) DO NOTHING;

-- 7. Populate PRECO (Transforming strings to DATE and NUMERIC, joining with PRODUTO)
INSERT INTO PRECO (
    CNPJ_Revenda, ID_Produto, Data_Coleta, 
    Valor_Venda, Valor_Compra, Unidade_Medida
)
SELECT DISTINCT
       LEFT(TRIM(t.col5),50) AS CNPJ_Revenda,                 
       p.ID_Produto,
       TO_DATE(TRIM(t.col12), 'DD/MM/YYYY') AS Data_Coleta,
       CAST(REPLACE(TRIM(t.col13), ',', '.') AS NUMERIC(10,2)) AS Valor_Venda,
       CAST(REPLACE(TRIM(t.col14), ',', '.') AS NUMERIC(10,2)) AS Valor_Compra,
       TRIM(t.col15) AS Unidade_Medida
FROM temp2 t
JOIN PRODUTO p ON p.NomeProduto = TRIM(t.col11);