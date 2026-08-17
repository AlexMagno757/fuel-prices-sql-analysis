SET search_path TO Combustivel;

-- Query 1: Complete statistics by city
SELECT 
    l.municipio,
    COUNT(DISTINCT rv.cnpj_revenda) AS total_postos,
    COUNT(DISTINCT p.id_produto) AS total_combustiveis,
    AVG(pr.valor_venda) AS preco_medio,
    MIN(pr.valor_venda) AS menor_preco,
    MAX(pr.valor_venda) AS maior_preco
FROM preco pr, revenda rv, local l, produto p
WHERE rv.cnpj_revenda = pr.cnpj_revenda
AND l.cep = rv.cep
AND p.id_produto = pr.id_produto
GROUP BY l.municipio
ORDER BY l.municipio ASC;

-- Query 2: Regional price difference (Max/Min variance by product)
SELECT SUB.NOMEPRODUTO,
       MAX(AVG_VALOR_PRECO) - MIN(AVG_VALOR_PRECO) AS DIFERENCA_REGIONAL
FROM (
    SELECT RE.NOME_REGIAO, PR.NOMEPRODUTO,
           AVG(P.VALOR_VENDA) AS AVG_VALOR_PRECO
    FROM PRECO P
    JOIN PRODUTO PR ON P.ID_PRODUTO = PR.ID_PRODUTO
    JOIN REVENDA R ON R.CNPJ_REVENDA = P.CNPJ_REVENDA
    JOIN LOCAL L ON L.CEP = R.CEP
    JOIN ESTADO E ON E.ESTADO_SIGLA = L.ESTADO_SIGLA
    JOIN REGIAO RE ON RE.REGIAO_SIGLA = E.REGIAO_SIGLA
    GROUP BY RE.NOME_REGIAO, PR.NOMEPRODUTO
) SUB
GROUP BY SUB.NOMEPRODUTO
ORDER BY DIFERENCA_REGIONAL DESC;

-- Query 3: Finding municipalities with high competition (more than 5 stations)
SELECT l.municipio, e.estado_sigla, COUNT(rv.cnpj_revenda) AS total_revendas
FROM local l
JOIN estado e ON l.estado_sigla = e.estado_sigla
JOIN revenda rv ON l.cep = rv.cep
GROUP BY l.municipio, e.estado_sigla
HAVING COUNT(rv.cnpj_revenda) > 5
ORDER BY total_revendas DESC;