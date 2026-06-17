-- =============================================================
-- BANCO DE DADOS I — ControlTrip
-- Script 05: Consultas / Relatórios
-- =============================================================

-- -------------------------------------------------------------
-- RELATÓRIO 1 (ORDER BY / WHERE)
-- Lista todas as solicitações de RDV com status 'PENDENTE',
-- exibindo solicitante, funcionários da viagem, justificativa,
-- data de solicitação e valor total em BRL.
-- Ordenado pela data de solicitação crescente.
-- -------------------------------------------------------------
SELECT
    v.id                                                        AS numero_rdv,
    f_sol.nome                                                  AS nome_solicitante,
    (SELECT STRING_AGG(f2.nome, ', ' ORDER BY f2.nome)
     FROM viagem_funcionario vf2
     JOIN funcionario f2 ON f2.id = vf2.funcionarioid
     WHERE vf2.viagemid = v.id)                                AS funcionario_viagem,
    v.justificativa,
    v.data_criacao                                              AS data_solicitacao,
    ROUND(
        COALESCE(
            (SELECT SUM(d.valor) FROM despesa d WHERE d.viagemid = v.id)
        , 0) * m.cotacao_conversao
    , 2)                                                        AS valor_total_solicitado_brl
FROM viagem v
JOIN funcionario f_sol ON f_sol.id = v.funcionarioid
JOIN moeda m           ON m.id = v.moedaid
WHERE v.status = 'PENDENTE'
ORDER BY v.data_criacao ASC;

-- -------------------------------------------------------------
-- RELATÓRIO 2 (JOIN)
-- Lista as RDV aprovadas com data de início no mês atual,
-- exibindo número do RDV, solicitante, funcionário, destino,
-- datas e valor aprovado em BRL.
-- Ordenado pela data de início crescente.
-- -------------------------------------------------------------
SELECT
    v.id                                                        AS numero_rdv,
    f_sol.nome                                                  AS nome_solicitante,
    (SELECT STRING_AGG(f2.nome, ', ' ORDER BY f2.nome)
     FROM viagem_funcionario vf2
     JOIN funcionario f2 ON f2.id = vf2.funcionarioid
     WHERE vf2.viagemid = v.id)                                AS nome_funcionario,
    c.nome || ' / ' || est.uf                                  AS destino,
    v.data_inicio_viagem                                        AS data_inicio,
    v.data_termino_fechamento                                   AS data_retorno,
    ROUND(
        COALESCE(SUM(d.valor), 0) * m.cotacao_conversao
    , 2)                                                        AS valor_aprovado_brl
FROM viagem v
JOIN funcionario f_sol ON f_sol.id = v.funcionarioid
JOIN cidade c          ON c.id = v.cidadeid
JOIN estado est        ON est.id = c.estadoid
JOIN moeda m           ON m.id = v.moedaid
LEFT JOIN despesa d    ON d.viagemid = v.id
WHERE v.status = 'APROVADO'
  AND EXTRACT(YEAR  FROM v.data_inicio_viagem) = EXTRACT(YEAR  FROM CURRENT_DATE)
  AND EXTRACT(MONTH FROM v.data_inicio_viagem) = EXTRACT(MONTH FROM CURRENT_DATE)
GROUP BY v.id, f_sol.nome, c.nome, est.uf,
         v.data_inicio_viagem, v.data_termino_fechamento, m.cotacao_conversao
ORDER BY v.data_inicio_viagem ASC;

-- -------------------------------------------------------------
-- RELATÓRIO 3 (JOIN)
-- Lista os itens de despesa de cada RDV aprovado com valor
-- convertido em BRL superior a R$ 50,00, exibindo número do
-- RDV, funcionário, tipo de despesa, descrição, moeda e valor.
-- Ordenado pelo número do RDV e tipo de despesa.
-- -------------------------------------------------------------
SELECT
    v.id                                                        AS numero_rdv,
    f.nome                                                      AS nome_funcionario,
    cat.nome_da_categoria                                       AS tipo_despesa,
    d.observacao                                                AS descricao,
    m.unidade_monetaria                                         AS moeda,
    ROUND(d.valor * m.cotacao_conversao, 2)                     AS valor_em_reais
FROM despesa d
JOIN viagem v      ON v.id = d.viagemid
JOIN funcionario f ON f.id = v.funcionarioid
JOIN categoria cat ON cat.id = d.categoriaid
JOIN moeda m       ON m.id = v.moedaid
WHERE v.status = 'APROVADO'
  AND (d.valor * m.cotacao_conversao) > 50
ORDER BY v.id ASC, cat.nome_da_categoria ASC;

-- -------------------------------------------------------------
-- RELATÓRIO 4 (Sumarização)
-- Para cada tipo de despesa, apresenta o total de ocorrências,
-- valor total e valor médio no semestre atual (Jan–Jun ou Jul–Dez).
-- Exibe apenas categorias com mais de 3 ocorrências no período.
-- Ordenado pelo valor total decrescente.
-- -------------------------------------------------------------
SELECT
    cat.nome_da_categoria                                       AS tipo_despesa,
    COUNT(d.id)                                                 AS total_ocorrencias,
    ROUND(SUM(d.valor * m.cotacao_conversao), 2)                AS valor_total_brl,
    ROUND(AVG(d.valor * m.cotacao_conversao), 2)                AS valor_medio_brl
FROM despesa d
JOIN categoria cat ON cat.id = d.categoriaid
JOIN viagem v      ON v.id = d.viagemid
JOIN moeda m       ON m.id = v.moedaid
WHERE d.data BETWEEN
    CASE WHEN EXTRACT(MONTH FROM CURRENT_DATE) <= 6
         THEN DATE_TRUNC('year', CURRENT_DATE)
         ELSE DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '6 months'
    END
  AND
    CASE WHEN EXTRACT(MONTH FROM CURRENT_DATE) <= 6
         THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '6 months' - INTERVAL '1 day'
         ELSE DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '12 months' - INTERVAL '1 day'
    END
GROUP BY cat.id, cat.nome_da_categoria
HAVING COUNT(d.id) > 3
ORDER BY valor_total_brl DESC;
