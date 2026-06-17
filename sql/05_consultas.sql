-- =============================================================
-- BANCO DE DADOS I — ControlTrip
-- NOVOS RELATÓRIOS SOLICITADOS
-- =============================================================

-- -------------------------------------------------------------
-- RELATÓRIO 1 (ORDER BY / WHERE): Solicitações Pendentes
-- -------------------------------------------------------------
SELECT
    v.id                                                            AS rdv_numero,
    -- Nota: Se o seu banco tiver uma coluna para o 'solicitante' diferente do 'viajante',
    -- substitua 'f.nome' abaixo pela coluna/join correspondente.
    f.nome                                                          AS funcionario_solicitante,
    f.nome                                                          AS funcionario_viajante,
    v.justificativa,
    v.data_inicio_viagem                                            AS data_solicitacao, -- Adaptado (use a coluna real de solicitação se houver)
    ROUND(COALESCE(SUM(d.valor * m.cotacao_conversao), 0), 2)       AS valor_total_solicitado
FROM viagem v
JOIN funcionario f  ON f.id = v.funcionarioid
LEFT JOIN despesa d ON d.viagemid = v.id
LEFT JOIN moeda m   ON m.id = v.moedaid
WHERE v.status = 'PENDENTE' -- Ajustar para o termo exato do seu banco (ex: 'Pendente de Aprovação')
GROUP BY v.id, f.nome, v.justificativa, v.data_inicio_viagem
ORDER BY data_solicitacao ASC;


-- -------------------------------------------------------------
-- RELATÓRIO 2 (JOIN): RDVs Aprovados no Mês Atual
-- -------------------------------------------------------------
SELECT
    v.id                                                            AS numero_rdv,
    f.nome                                                          AS funcionario_solicitante, -- Adaptado
    f.nome                                                          AS funcionario_viajante,
    c.nome                                                          AS destino_viagem,
    v.data_inicio_viagem                                            AS data_inicio,
    v.data_termino_fechamento                                       AS data_retorno,
    ROUND(COALESCE(SUM(d.valor * m.cotacao_conversao), 0), 2)       AS valor_aprovado
FROM viagem v
JOIN funcionario f  ON f.id = v.funcionarioid
JOIN cidade c       ON c.id = v.cidadeid
LEFT JOIN despesa d ON d.viagemid = v.id
LEFT JOIN moeda m   ON m.id = v.moedaid
WHERE v.status = 'APROVADO'
  -- Filtro para o mês atual dinâmico (Ano 2026)
  AND v.data_inicio_viagem >= DATE_TRUNC('month', CURRENT_DATE)
  AND v.data_inicio_viagem < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP BY v.id, f.nome, c.nome, v.data_inicio_viagem, v.data_termino_fechamento
ORDER BY data_inicio ASC;


-- -------------------------------------------------------------
-- RELATÓRIO 3 (CORRIGIDO): Itens de Despesa (> R$ 50,00) de RDVs Aprovados
-- -------------------------------------------------------------
SELECT
    v.id                                                            AS numero_rdv,
    f.nome                                                          AS nome_funcionario,
    cat.nome_da_categoria                                           AS tipo_despesa,
    cat.nome_da_categoria                                           AS descricao, -- Usando a categoria como descrição
    m.unidade_monetaria                                             AS moeda_utilizada,
    ROUND(d.valor * m.cotacao_conversao, 2)                         AS valor_convertido_reais
FROM despesa d
JOIN viagem v      ON v.id = d.viagemid
JOIN funcionario f ON f.id = v.funcionarioid
JOIN categoria cat ON cat.id = d.categoriaid
JOIN moeda m       ON m.id = v.moedaid
WHERE v.status = 'APROVADO'
  -- Exibir apenas despesas com valor convertido superior a R$ 50,00
  AND (d.valor * m.cotacao_conversao) > 50.00
ORDER BY numero_rdv ASC, tipo_despesa ASC;


-- -------------------------------------------------------------
-- RELATÓRIO 4 (CORRIGIDO): Tipo de Despesa no Semestre Atual
-- -------------------------------------------------------------
SELECT
    cat.nome_da_categoria                                           AS tipo_despesa,
    COUNT(d.id)                                                     AS total_ocorrencias,
    ROUND(SUM(d.valor * m.cotacao_conversao), 2)                    AS valor_total_gasto,
    ROUND(AVG(d.valor * m.cotacao_conversao), 2)                    AS valor_medio_por_ocorrencia
FROM despesa d
JOIN categoria cat ON cat.id = d.categoriaid
JOIN viagem v      ON v.id = d.viagemid
JOIN moeda m       ON m.id = v.moedaid
WHERE 
    -- Lógica para o Semestre Atual:
    -- Se o mês atual for de 1 a 6 (1º Semestre), filtra de Janeiro a Junho.
    -- Se for de 7 a 12 (2º Semestre), filtra de Julho a Dezembro.
    d.data >= CASE 
                WHEN EXTRACT(MONTH FROM CURRENT_DATE) <= 6 THEN DATE_TRUNC('year', CURRENT_DATE)
                ELSE DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '6 months'
              END
  AND d.data < CASE 
                WHEN EXTRACT(MONTH FROM CURRENT_DATE) <= 6 THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '6 months'
                ELSE DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '12 months'
              END
GROUP BY cat.id, cat.nome_da_categoria
HAVING COUNT(d.id) > 3 -- Apenas com mais de 3 ocorrências no período
ORDER BY valor_total_gasto DESC;
