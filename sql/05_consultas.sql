-- =============================================================
-- BANCO DE DADOS I — ControlTrip
-- Script 05: Consultas / Relatórios
-- =============================================================

-- -------------------------------------------------------------
-- RELATÓRIO 1: Despesas Totais por Viagem
-- Mostra o custo total acumulado de cada viagem, detalhando o 
-- funcionário responsável, a cidade de destino, a moeda utilizada 
-- e o valor final convertido para a moeda nacional (BRL).
-- -------------------------------------------------------------
SELECT
    v.id                                                            AS viagem_id,
    f.nome                                                          AS funcionario_solicitante,
    c.nome                                                          AS cidade_destino,
    est.uf                                                          AS uf_destino,
    v.status                                                        AS status_viagem,
    m.unidade_monetaria                                             AS moeda_original,
    COALESCE(SUM(d.valor), 0)                                       AS total_moeda_original,
    m.cotacao_conversao                                             AS taxa_cambio,
    ROUND(COALESCE(SUM(d.valor), 0) * m.cotacao_conversao, 2)       AS total_convertido_brl
FROM viagem v
JOIN funcionario f  ON f.id = v.funcionarioid
JOIN cidade c       ON c.id = v.cidadeid
JOIN estado est     ON est.id = c.estadoid
JOIN moeda m        ON m.id = v.moedaid
LEFT JOIN despesa d ON d.viagemid = v.id
GROUP BY v.id, f.nome, c.nome, est.uf, v.status, m.unidade_monetaria, m.cotacao_conversao
ORDER BY total_convertido_brl DESC;

-- -------------------------------------------------------------
-- RELATÓRIO 2: Viagens por Funcionário e Setor
-- Lista todos os deslocamentos corporativos cadastrados no sistema, 
-- com o nome do funcionário responsável e seu respectivo setor,
-- permitindo auditar o volume de viagens por área da empresa.
-- -------------------------------------------------------------
SELECT
    s.nome                                                          AS setor_custo,
    f.nome                                                          AS funcionario,
    v.id                                                            AS viagem_id,
    c.nome                                                          AS cidade_destino,
    est.uf                                                          AS uf_destino,
    v.data_inicio_viagem                                            AS inicio,
    v.data_termino_fechamento                                       AS termino,
    (v.data_termino_fechamento - v.data_inicio_viagem)              AS duracao_dias,
    v.status                                                        AS status_viagem,
    v.justificativa
FROM viagem v
JOIN funcionario f  ON f.id = v.funcionarioid
JOIN setor s        ON s.id = v.setorid
JOIN cidade c       ON c.id = v.cidadeid
JOIN estado est     ON est.id = c.estadoid
ORDER BY s.nome, f.nome, v.data_inicio_viagem DESC;

-- -------------------------------------------------------------
-- RELATÓRIO 3: Gastos por Categoria de Despesa
-- Apresenta de forma agregada a distribuição de gastos da empresa
-- por tipo de consumo (Alimentação, Hospedagem, etc.) convertidos 
-- para BRL, auxiliando no controle de orçamentos e auditoria.
-- -------------------------------------------------------------
SELECT
    cat.nome_da_categoria                                           AS categoria,
    COUNT(d.id)                                                     AS quantidade_lancamentos,
    ROUND(SUM(d.valor * m.cotacao_conversao), 2)                    AS custo_total_brl,
    ROUND(AVG(d.valor * m.cotacao_conversao), 2)                    AS custo_medio_brl,
    ROUND(
        SUM(d.valor * m.cotacao_conversao) * 100.0 / 
        SUM(SUM(d.valor * m.cotacao_conversao)) OVER (), 2
    )                                                               AS percentual_representatividade
FROM despesa d
JOIN categoria cat ON cat.id = d.categoriaid
JOIN viagem v      ON v.id = d.viagemid
JOIN moeda m       ON m.id = v.moedaid
GROUP BY cat.id, cat.nome_da_categoria
ORDER BY custo_total_brl DESC;

-- -------------------------------------------------------------
-- RELATÓRIO 4: Viagens por Status e Ordem de Serviço (OS)
-- Sumariza o total de viagens e seu progresso atual agrupados 
-- por projeto/contrato (Ordem de Serviço). Isso permite que gerentes 
-- controlem o andamento logístico de suas OS.
-- -------------------------------------------------------------
SELECT
    o.id_os                                                         AS os_codigo,
    o.descricao                                                     AS os_descricao,
    COUNT(v.id)                                                     AS total_viagens,
    COUNT(v.id) FILTER (WHERE v.status = 'RASCUNHO')                AS em_rascunho,
    COUNT(v.id) FILTER (WHERE v.status = 'PENDENTE')                AS pendentes_aprovacao,
    COUNT(v.id) FILTER (WHERE v.status = 'APROVADO')                AS aprovadas_ativas,
    COUNT(v.id) FILTER (WHERE v.status = 'CONCLUIDO')               AS concluidas,
    COUNT(v.id) FILTER (WHERE v.status = 'REJEITADO')               AS rejeitadas
FROM os o
LEFT JOIN viagem v ON v.osid_os = o.id_os
GROUP BY o.id_os, o.descricao
ORDER BY total_viagens DESC, os_codigo;

-- -------------------------------------------------------------
-- RELATÓRIO 5: Despesas por Período Mensal e Moeda
-- Consolida os custos de viagens de forma temporal por mês, 
-- divididos por moeda de origem das despesas. Útil para conciliação 
-- de fluxo de caixa financeiro e compra de moeda estrangeira.
-- -------------------------------------------------------------
SELECT
    TO_CHAR(d.data, 'YYYY-MM')                                      AS mes_ano,
    m.unidade_monetaria                                             AS moeda,
    COUNT(d.id)                                                     AS quantidade_despesas,
    SUM(d.valor)                                                    AS total_moeda_original,
    ROUND(SUM(d.valor * m.cotacao_conversao), 2)                    AS total_convertido_brl
FROM despesa d
JOIN viagem v ON v.id = d.viagemid
JOIN moeda m  ON m.id = v.moedaid
GROUP BY TO_CHAR(d.data, 'YYYY-MM'), m.id, m.unidade_monetaria
ORDER BY mes_ano DESC, moeda;
