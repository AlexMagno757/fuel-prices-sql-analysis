DROP SCHEMA IF EXISTS Combustivel CASCADE;
CREATE SCHEMA Combustivel;
SET search_path TO Combustivel;

-- Table: REGIAO
CREATE TABLE REGIAO (
    Regiao_Sigla CHAR(2) PRIMARY KEY,
    Nome_Regiao VARCHAR(20) NOT NULL
);

-- Table: ESTADO
CREATE TABLE ESTADO (
    Estado_Sigla CHAR(2) PRIMARY KEY,
    Regiao_Sigla CHAR(2) NOT NULL,
    CONSTRAINT fk_regiao FOREIGN KEY (Regiao_Sigla)
        REFERENCES REGIAO (Regiao_Sigla)
);

-- Table: LOCAL
CREATE TABLE LOCAL (
    Cep VARCHAR(18) PRIMARY KEY,
    Municipio VARCHAR(100) NOT NULL,
    Estado_Sigla CHAR(2) NOT NULL,
    CONSTRAINT fk_estado FOREIGN KEY (Estado_Sigla)
        REFERENCES ESTADO (Estado_Sigla)
);

-- Table: REVENDA
CREATE TABLE REVENDA (
    CNPJ_Revenda VARCHAR(50) PRIMARY KEY,
    NomeRevenda VARCHAR(250) NOT NULL,
    Nome_Rua VARCHAR(250) NOT NULL,
    Numero VARCHAR(150),
    Bairro VARCHAR(100),
    Complemento VARCHAR(250),
    Bandeira VARCHAR(250),
    Cep VARCHAR(18) NOT NULL,
    CONSTRAINT fk_local FOREIGN KEY (Cep)
        REFERENCES LOCAL (Cep)
);

-- Table: PRODUTO
CREATE TABLE PRODUTO (
    ID_Produto SERIAL PRIMARY KEY,
    NomeProduto VARCHAR(300) NOT NULL UNIQUE
);

-- Table: PRECO
CREATE TABLE PRECO (
    CNPJ_Revenda VARCHAR(50) NOT NULL, 
    ID_Produto INT NOT NULL,
    Data_Coleta DATE NOT NULL,
    Valor_Venda NUMERIC(10,2) NOT NULL,
    Valor_Compra NUMERIC(10,2),
    Unidade_Medida VARCHAR(20) NOT NULL,
    CONSTRAINT pk_preco PRIMARY KEY (CNPJ_Revenda, ID_Produto, Data_Coleta),
    CONSTRAINT fk_revenda FOREIGN KEY (CNPJ_Revenda)
        REFERENCES REVENDA (CNPJ_Revenda),
    CONSTRAINT fk_produto FOREIGN KEY (ID_Produto)
        REFERENCES PRODUTO (ID_Produto)
);