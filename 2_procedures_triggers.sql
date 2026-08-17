SET search_path TO Combustivel;

-- 1. Stored Procedure: Mass price update
CREATE OR REPLACE FUNCTION FUNC_ATUALIZA_PRECO_COMBUSTIVEIS (IN PERC NUMERIC)
RETURNS VOID
AS $$
BEGIN
    UPDATE PRECO
    SET VALOR_COMPRA = VALOR_COMPRA + (VALOR_COMPRA * PERC/100);
END $$
LANGUAGE plpgsql;

-- 2. Stored Procedure: Prevent duplicate CEPs
CREATE OR REPLACE FUNCTION FUN_NOT_CEP_DUPLICADO
(IN L_CEP LOCAL.CEP%TYPE,
 IN L_MUNICIPIO LOCAL.MUNICIPIO%TYPE,
 IN L_ESTADO_SIGLA LOCAL.ESTADO_SIGLA%TYPE)
RETURNS TEXT AS $$
DECLARE L_COUNT INTEGER;
BEGIN
    SELECT COUNT(*) INTO L_COUNT
    FROM LOCAL WHERE CEP = L_CEP;

    IF L_COUNT = 0 THEN
        INSERT INTO LOCAL VALUES(L_CEP, L_MUNICIPIO, L_ESTADO_SIGLA);
    ELSE
        RAISE WARNING 'Cep ja existe: %', L_CEP;
    END IF;
END $$ LANGUAGE plpgsql;

-- 3. Trigger: Validate sales values
CREATE OR REPLACE FUNCTION fn_validar_valor_venda()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Valor_Venda <= 0 THEN
        RAISE EXCEPTION 'O valor de venda deve ser maior que zero.';
    END IF;

    IF NEW.Valor_Compra IS NOT NULL AND NEW.Valor_Venda < NEW.Valor_Compra THEN
        RAISE EXCEPTION 'O valor de venda (%.2f) não pode ser menor que o valor de compra (%.2f).',
        NEW.Valor_Venda, NEW.Valor_Compra;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_valor_venda
BEFORE INSERT OR UPDATE ON PRECO
FOR EACH ROW
EXECUTE FUNCTION fn_validar_valor_venda();

-- 4. Trigger: Audit log for price changes
CREATE TABLE PRECO_AUDITORIA (
    ID_Auditoria SERIAL PRIMARY KEY,
    CNPJ_Revenda VARCHAR(50) NOT NULL,
    ID_Produto INT NOT NULL,
    Data_Coleta DATE NOT NULL,
    Data_Alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Usuario_Alteracao VARCHAR(100) DEFAULT CURRENT_USER,
    Valor_Venda_Antigo NUMERIC(10,2),
    Valor_Venda_Novo NUMERIC(10,2),
    Valor_Compra_Antigo NUMERIC(10,2),
    Valor_Compra_Novo NUMERIC(10,2)
);

CREATE OR REPLACE FUNCTION fn_auditar_alteracao_preco()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Valor_Venda IS DISTINCT FROM NEW.Valor_Venda OR OLD.Valor_Compra IS DISTINCT FROM NEW.Valor_Compra THEN
        INSERT INTO PRECO_AUDITORIA (
            CNPJ_Revenda, ID_Produto, Data_Coleta, Valor_Venda_Antigo, Valor_Venda_Novo, Valor_Compra_Antigo, Valor_Compra_Novo
        ) VALUES (
            OLD.CNPJ_Revenda, OLD.ID_Produto, OLD.Data_Coleta, OLD.Valor_Venda, NEW.Valor_Venda, OLD.Valor_Compra, NEW.Valor_Compra
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditar_alteracao_preco
AFTER UPDATE ON PRECO
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_alteracao_preco();