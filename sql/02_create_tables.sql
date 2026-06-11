-- =============================================================
-- BANCO DE DADOS I — ControlTrip
-- Script 02: Criação das tabelas e constraints de integridade
-- =============================================================

BEGIN;

-- -------------------------------------------------------------
-- Tabela: funcionario
-- -------------------------------------------------------------
CREATE TABLE funcionario (
    id   SERIAL      PRIMARY KEY, 
    cpf  CHAR(11)    NOT NULL, 
    nome VARCHAR(60) NOT NULL,

    CONSTRAINT uq_funcionario_cpf UNIQUE (cpf),
    CONSTRAINT ck_funcionario_cpf CHECK (cpf ~ '^\d{11}$')
);

COMMENT ON TABLE funcionario IS 'Cadastro centralizado de colaboradores da organização.';
COMMENT ON COLUMN funcionario.id IS 'ID único incremental do funcionário (Chave Primária).';
COMMENT ON COLUMN funcionario.cpf IS 'Número de inscrição no CPF (apenas 11 dígitos, único).';
COMMENT ON COLUMN funcionario.nome IS 'Nome completo do funcionário.';

-- -------------------------------------------------------------
-- Tabela: setor
-- -------------------------------------------------------------
CREATE TABLE setor (
    id   SERIAL      PRIMARY KEY, 
    nome VARCHAR(60) NOT NULL,

    CONSTRAINT uq_setor_nome UNIQUE (nome)
);

COMMENT ON TABLE setor IS 'Departamentos ou centros de custo da empresa.';
COMMENT ON COLUMN setor.id IS 'ID único incremental do setor (Chave Primária).';
COMMENT ON COLUMN setor.nome IS 'Nome descritivo do setor corporativo.';

-- -------------------------------------------------------------
-- Tabela: estado
-- -------------------------------------------------------------
CREATE TABLE estado (
    id   SERIAL      PRIMARY KEY, 
    nome VARCHAR(50) NOT NULL, 
    uf   CHAR(2)     NOT NULL,

    CONSTRAINT uq_estado_nome UNIQUE (nome),
    CONSTRAINT uq_estado_uf   UNIQUE (uf),
    CONSTRAINT ck_estado_uf   CHECK (uf ~ '^[A-Z]{2}$')
);

COMMENT ON TABLE estado IS 'Unidades Federativas para mapeamento geográfico e fiscal.';
COMMENT ON COLUMN estado.id IS 'ID único do estado (Chave Primária).';
COMMENT ON COLUMN estado.nome IS 'Nome por extenso do estado.';
COMMENT ON COLUMN estado.uf IS 'Sigla da Unidade Federativa (Ex: SC, SP, RJ).';

-- -------------------------------------------------------------
-- Tabela: cidade
-- -------------------------------------------------------------
CREATE TABLE cidade (
    id        SERIAL      PRIMARY KEY, 
    nome      VARCHAR(60) NOT NULL, 
    estadoid  INT         NOT NULL,

    CONSTRAINT fk_cidade_estado FOREIGN KEY (estadoid) 
        REFERENCES estado (id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT uq_cidade_estado UNIQUE (nome, estadoid)
);

COMMENT ON TABLE cidade IS 'Municípios para definição de destinos e cálculo de diárias.';
COMMENT ON COLUMN cidade.id IS 'ID único da cidade (Chave Primária).';
COMMENT ON COLUMN cidade.nome IS 'Nome oficial do município.';
COMMENT ON COLUMN cidade.estadoid IS 'Chave estrangeira (FK) conectando a cidade ao seu respectivo estado.';

-- -------------------------------------------------------------
-- Tabela: categoria
-- -------------------------------------------------------------
CREATE TABLE categoria (
    id                SERIAL      PRIMARY KEY, 
    nome_da_categoria VARCHAR(30) NOT NULL,

    CONSTRAINT uq_categoria_nome UNIQUE (nome_da_categoria)
);

COMMENT ON TABLE categoria IS 'Classificação contábil da despesa (Alimentação, Transporte, Hospedagem).';
COMMENT ON COLUMN categoria.id IS 'ID único da categoria de gasto (Chave Primária).';
COMMENT ON COLUMN categoria.nome_da_categoria IS 'Descrição textual da categoria de despesa.';

-- -------------------------------------------------------------
-- Tabela: moeda
-- -------------------------------------------------------------
CREATE TABLE moeda (
    id                SERIAL        PRIMARY KEY, 
    unidade_monetaria VARCHAR(5)    NOT NULL, 
    cotacao_conversao NUMERIC(10,4) NOT NULL,

    CONSTRAINT uq_moeda_unidade UNIQUE (unidade_monetaria),
    CONSTRAINT ck_moeda_cotacao CHECK (cotacao_conversao > 0)
);

COMMENT ON TABLE moeda IS 'Tabela de indexação de moedas estrangeiras e taxas de conversão.';
COMMENT ON COLUMN moeda.id IS 'ID único da moeda (Chave Primária).';
COMMENT ON COLUMN moeda.unidade_monetaria IS 'Código internacional ou símbolo da moeda (Ex: BRL, USD, EUR).';
COMMENT ON COLUMN moeda.cotacao_conversao IS 'Fator multiplicador para conversão de valores para a moeda corrente padrão do ERP.';

-- -------------------------------------------------------------
-- Tabela: os (Ordem de Serviço)
-- -------------------------------------------------------------
CREATE TABLE os (
    id_os     SERIAL       PRIMARY KEY, 
    descricao VARCHAR(255) NOT NULL
);

COMMENT ON TABLE os IS 'Ordens de Serviço vinculadas a projetos ou contratos externos.';
COMMENT ON COLUMN os.id_os IS 'ID único da Ordem de Serviço (Chave Primária).';
COMMENT ON COLUMN os.descricao IS 'Detalhamento do escopo técnico ou comercial da Ordem de Serviço.';

-- -------------------------------------------------------------
-- Tabela: viagem
-- -------------------------------------------------------------
CREATE TABLE viagem (
    id                      SERIAL      PRIMARY KEY, 
    funcionarioid           INT         NOT NULL, 
    cidadeid                INT         NOT NULL, 
    setorid                 INT         NOT NULL, 
    osid_os                 INT         NOT NULL, 
    moedaid                 INT         NOT NULL, 
    status                  VARCHAR(20) NOT NULL DEFAULT 'RASCUNHO', 
    justificativa           VARCHAR(255) NOT NULL, 
    data_criacao            DATE        NOT NULL DEFAULT CURRENT_DATE, 
    data_fechamento         DATE        NOT NULL, 
    data_inicio_viagem      DATE        NOT NULL, 
    data_termino_fechamento DATE        NOT NULL,

    CONSTRAINT fk_viagem_funcionario FOREIGN KEY (funcionarioid) 
        REFERENCES funcionario (id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_viagem_cidade FOREIGN KEY (cidadeid) 
        REFERENCES cidade (id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_viagem_setor FOREIGN KEY (setorid) 
        REFERENCES setor (id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_viagem_os FOREIGN KEY (osid_os) 
        REFERENCES os (id_os) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_viagem_moeda FOREIGN KEY (moedaid) 
        REFERENCES moeda (id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT ck_viagem_status CHECK (status IN ('RASCUNHO', 'PENDENTE', 'APROVADO', 'REJEITADO', 'CONCLUIDO')),
    CONSTRAINT ck_viagem_datas_viagem CHECK (data_termino_fechamento >= data_inicio_viagem),
    CONSTRAINT ck_viagem_datas_prazo CHECK (data_fechamento >= data_criacao)
);

COMMENT ON TABLE viagem IS 'Entidade mestre que consolida o processo de deslocamento corporativo e adiantamentos.';
COMMENT ON COLUMN viagem.id IS 'ID único da requisição de viagem (Chave Primária).';
COMMENT ON COLUMN viagem.funcionarioid IS 'Chave estrangeira (FK) identificando o funcionário solicitante/responsável.';
COMMENT ON COLUMN viagem.cidadeid IS 'Chave estrangeira (FK) do município de destino principal.';
COMMENT ON COLUMN viagem.setorid IS 'Chave estrangeira (FK) do departamento que absorverá os custos (Centro de Custo).';
COMMENT ON COLUMN viagem.osid_os IS 'Chave estrangeira (FK) ligando a viagem a uma Ordem de Serviço activa.';
COMMENT ON COLUMN viagem.moedaid IS 'Chave estrangeira (FK) definindo a moeda oficial do acerto de contas.';
COMMENT ON COLUMN viagem.status IS 'Estado atual do workflow (Ex: RASCUNHO, PENDENTE, APROVADO, REJEITADO, CONCLUIDO).';
COMMENT ON COLUMN viagem.justificativa IS 'Argumentação de negócios para validação da gerência e auditoria.';
COMMENT ON COLUMN viagem.data_criacao IS 'Data de abertura do processo no sistema.';
COMMENT ON COLUMN viagem.data_fechamento IS 'Prazo limite do sistema para prestação de contas.';
COMMENT ON COLUMN viagem.data_inicio_viagem IS 'Data real de início do deslocamento.';
COMMENT ON COLUMN viagem.data_termino_fechamento IS 'Data de encerramento contábil e conciliação de saldos da viagem.';

-- -------------------------------------------------------------
-- Tabela: viagem_funcionario (Associativa N:M)
-- -------------------------------------------------------------
CREATE TABLE viagem_funcionario (
    viagemid      INT NOT NULL, 
    funcionarioid INT NOT NULL,

    CONSTRAINT pk_viagem_funcionario PRIMARY KEY (viagemid, funcionarioid),
    CONSTRAINT fk_vf_viagem FOREIGN KEY (viagemid) 
        REFERENCES viagem (id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_vf_funcionario FOREIGN KEY (funcionarioid) 
        REFERENCES funcionario (id) 
        ON DELETE RESTRICT
);

COMMENT ON TABLE viagem_funcionario IS 'Tabela de ligação N:M para rastrear múltiplos colaboradores compartilhando a mesma viagem.';
COMMENT ON COLUMN viagem_funcionario.viagemid IS 'Componente da PK Composta: Identificador da viagem associada.';
COMMENT ON COLUMN viagem_funcionario.funcionarioid IS 'Componente da PK Composta: Identificador do funcionário passageiro/acompanhante.';

-- -------------------------------------------------------------
-- Tabela: despesa
-- -------------------------------------------------------------
CREATE TABLE despesa (
    id          SERIAL        PRIMARY KEY, 
    viagemid    INT           NOT NULL, 
    categoriaid INT           NOT NULL, 
    data        DATE          NOT NULL, 
    pagamento   VARCHAR(25)   NOT NULL, 
    valor       NUMERIC(15,2) NOT NULL, 
    anexo       VARCHAR(255)  NOT NULL, 
    observacao  VARCHAR(80)   NOT NULL,

    CONSTRAINT fk_despesa_viagem FOREIGN KEY (viagemid) 
        REFERENCES viagem (id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_despesa_categoria FOREIGN KEY (categoriaid) 
        REFERENCES categoria (id) 
        ON DELETE RESTRICT,
    CONSTRAINT ck_despesa_valor CHECK (valor > 0),
    CONSTRAINT ck_despesa_pagamento CHECK (pagamento IN ('DINHEIRO', 'CARTAO_CORPORATIVO', 'REEMBOLSO'))
);

COMMENT ON TABLE despesa IS 'Lançamentos individuais de gastos vinculados a uma prestação de contas.';
COMMENT ON COLUMN despesa.id IS 'ID único incremental do lançamento de despesa (Chave Primária).';
COMMENT ON COLUMN despesa.viagemid IS 'Chave estrangeira (FK) vinculando o gasto ao processo de viagem mãe.';
COMMENT ON COLUMN despesa.categoriaid IS 'Chave estrangeira (FK) mapeando a natureza econômica da despesa.';
COMMENT ON COLUMN despesa.data IS 'Data real descrita no comprovante fiscal (nota fiscal/recibo).';
COMMENT ON COLUMN despesa.pagamento IS 'Método de liquidação financeira (Ex: DINHEIRO, CARTAO_CORPORATIVO, REEMBOLSO).';
COMMENT ON COLUMN despesa.valor IS 'Valor monetário exato do gasto (Armazenamento numérico com precisão fixa).';
COMMENT ON COLUMN despesa.anexo IS 'Caminho físico (path) ou hash do documento digitalizado para fins de auditoria fiscal.';
COMMENT ON COLUMN despesa.observacao IS 'Notas complementares para detalhamento de gastos atípicos.';

COMMIT;
