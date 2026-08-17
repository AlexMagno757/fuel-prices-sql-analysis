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

-- Query 4: Highway service stations selling GNV and their average product prices
SELECT rv.nomerevenda, l.municipio, e.estado_sigla, p.nomeproduto,
       AVG(pr.valor_venda) AS preco_medio,
       pr.unidade_medida, rv.nome_rua
FROM revenda rv
JOIN local l ON rv.cep = l.cep
JOIN estado e ON l.estado_sigla = e.estado_sigla
JOIN preco pr ON rv.cnpj_revenda = pr.cnpj_revenda
JOIN produto p ON pr.id_produto = p.id_produto
WHERE rv.nome_rua LIKE '%RODOVIA%'
  AND rv.cnpj_revenda IN (
      SELECT pr2.cnpj_revenda
      FROM preco pr2
      JOIN produto p2 ON pr2.id_produto = p2.id_produto
      WHERE p2.nomeproduto LIKE '%GNV%'
      GROUP BY pr2.cnpj_revenda
  )
GROUP BY rv.nomerevenda, l.municipio, e.estado_sigla, p.nomeproduto,
         pr.unidade_medida, rv.nome_rua
ORDER BY e.estado_sigla, l.municipio, rv.nomerevenda, p.nomeproduto;
