-- =============================================================
-- BANCO DE DADOS I — ControlTrip
-- Script 03: Criação dos índices
-- =============================================================

-- Índices na tabela funcionario
CREATE INDEX idx_funcionario_nome 
    ON funcionario (nome);

-- Índices na tabela cidade
CREATE INDEX idx_cidade_estadoid 
    ON cidade (estadoid);

-- Índices na tabela viagem
CREATE INDEX idx_viagem_funcionarioid 
    ON viagem (funcionarioid);

CREATE INDEX idx_viagem_cidadeid 
    ON viagem (cidadeid);

CREATE INDEX idx_viagem_setorid 
    ON viagem (setorid);

CREATE INDEX idx_viagem_osid_os 
    ON viagem (osid_os);

CREATE INDEX idx_viagem_moedaid 
    ON viagem (moedaid);

CREATE INDEX idx_viagem_status 
    ON viagem (status);

CREATE INDEX idx_viagem_periodo 
    ON viagem (data_inicio_viagem, data_termino_fechamento, status);

-- Índices na tabela viagem_funcionario (Tabela Associativa N:M)
CREATE INDEX idx_vf_viagemid 
    ON viagem_funcionario (viagemid);

CREATE INDEX idx_vf_funcionarioid 
    ON viagem_funcionario (funcionarioid);

-- Índices na tabela despesa
CREATE INDEX idx_despesa_viagemid 
    ON despesa (viagemid);

CREATE INDEX idx_despesa_categoriaid 
    ON despesa (categoriaid);

CREATE INDEX idx_despesa_data 
    ON despesa (data);
