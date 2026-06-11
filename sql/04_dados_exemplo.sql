-- =============================================================
-- BANCO DE DADOS I — ControlTrip
-- Script 04: Dados de exemplo para testes e demonstração
-- =============================================================

BEGIN;

-- 1. Inserção de Funcionários
INSERT INTO funcionario (cpf, nome) VALUES
    ('11122233344', 'Ana Beatriz de Souza'),
    ('22233344455', 'Carlos Henrique Pereira'),
    ('33344455566', 'Juliana Maria da Silva'),
    ('44455566677', 'Roberto de Alencar Junior'),
    ('55566677788', 'Mariana Costa Mendes'),
    ('66677788899', 'Felipe Santos Oliveira'),
    ('77788899900', 'Luciana Duarte Fonseca');

-- 2. Inserção de Setores
INSERT INTO setor (nome) VALUES
    ('Tecnologia da Informação'),
    ('Comercial e Vendas'),
    ('Diretoria Executiva'),
    ('Financeiro e Controladoria'),
    ('Suporte ao Cliente');

-- 3. Inserção de Estados
INSERT INTO estado (nome, uf) VALUES
    ('Santa Catarina', 'SC'),
    ('São Paulo', 'SP'),
    ('Rio de Janeiro', 'RJ'),
    ('Paraná', 'PR'),
    ('Rio Grande do Sul', 'RS');

-- 4. Inserção de Cidades
INSERT INTO cidade (nome, estadoid) VALUES
    ('São Miguel do Oeste', 1),
    ('Chapecó', 1),
    ('Florianópolis', 1),
    ('São Paulo', 2),
    ('Campinas', 2),
    ('Rio de Janeiro', 3),
    ('Curitiba', 4),
    ('Porto Alegre', 5);

-- 5. Inserção de Categorias de Despesas
INSERT INTO categoria (nome_da_categoria) VALUES
    ('Alimentação'),
    ('Transporte'),
    ('Hospedagem'),
    ('Combustível'),
    ('Eventos / Feiras'),
    ('Outros');

-- 6. Inserção de Moedas
INSERT INTO moeda (unidade_monetaria, cotacao_conversao) VALUES
    ('BRL', 1.0000),  -- Moeda padrão local
    ('USD', 5.2500),  -- Dólar americano
    ('EUR', 5.6500);  -- Euro

-- 7. Inserção de Ordens de Serviço (OS)
INSERT INTO os (descricao) VALUES
    ('OS-101: Implantação de ERP na Filial Sul'),
    ('OS-102: Manutenção e Auditoria de Infraestrutura de Rede'),
    ('OS-103: Consultoria e Fechamento de Grandes Contas Comerciais'),
    ('OS-104: Treinamento de Cyber Security para Equipe Técnica'),
    ('OS-105: Prospecção de Novos Clientes Internacionais');

-- 8. Inserção de Viagens (Justificativas limitadas a 45 caracteres)
-- status: RASCUNHO, PENDENTE, APROVADO, REJEITADO, CONCLUIDO
INSERT INTO viagem (funcionarioid, cidadeid, setorid, osid_os, moedaid, status, justificativa, data_criacao, data_fechamento, data_inicio_viagem, data_termino_fechamento) VALUES
    -- Viagem 1 (Concluída - Ana Beatriz)
    (1, 4, 1, 1, 1, 'CONCLUIDO', 'Treinamento presencial na matriz SP.', '2026-04-10', '2026-04-30', '2026-04-15', '2026-04-18'),
    -- Viagem 2 (Concluída - Carlos Henrique)
    (2, 6, 2, 3, 1, 'CONCLUIDO', 'Visita comercial cliente RJ.', '2026-04-12', '2026-05-02', '2026-04-20', '2026-04-24'),
    -- Viagem 3 (Concluída em USD - Mariana Costa)
    (5, 4, 3, 5, 2, 'CONCLUIDO', 'Negociação internacional EUA.', '2026-05-01', '2026-05-20', '2026-05-05', '2026-05-10'),
    -- Viagem 4 (Aprovada - Juliana Maria)
    (3, 2, 5, 2, 1, 'APROVADO', 'Suporte técnico em Chapecó.', '2026-05-15', '2026-06-05', '2026-05-28', '2026-05-30'),
    -- Viagem 5 (Pendente - Felipe Santos)
    (6, 7, 1, 4, 1, 'PENDENTE', 'Palestra segurança Curitiba.', '2026-06-01', '2026-06-20', '2026-06-12', '2026-06-15'),
    -- Viagem 6 (Rascunho - Roberto de Alencar)
    (4, 3, 4, 1, 1, 'RASCUNHO', 'Auditoria em Florianópolis.', '2026-06-08', '2026-06-25', '2026-06-20', '2026-06-23'),
    -- Viagem 7 (Rejeitada - Luciana Duarte)
    (7, 8, 2, 3, 1, 'REJEITADO', 'Prospecção leads em POA.', '2026-05-02', '2026-05-22', '2026-05-10', '2026-05-12'),
    -- Viagem 8 (Concluída - Ana Beatriz)
    (1, 8, 1, 2, 1, 'CONCLUIDO', 'Configurar servidores em POA.', '2026-05-10', '2026-05-30', '2026-05-18', '2026-05-21');

-- 9. Inserção na Tabela Associativa Viagem_Funcionario (Passageiros/Acompanhantes)
INSERT INTO viagem_funcionario (viagemid, funcionarioid) VALUES
    (1, 1), -- Ana Beatriz na viagem 1 (responsável)
    (1, 3), -- Juliana Maria acompanhando a viagem 1
    (2, 2), -- Carlos Henrique na viagem 2
    (3, 5), -- Mariana Costa na viagem 3
    (3, 7), -- Luciana Duarte acompanhando Mariana na viagem internacional 3
    (4, 3), -- Juliana Maria na viagem 4
    (5, 6), -- Felipe Santos na viagem 5
    (6, 4), -- Roberto de Alencar na viagem 6
    (7, 7), -- Luciana Duarte na viagem 7
    (8, 1); -- Ana Beatriz na viagem 8

-- 10. Inserção de Despesas
-- pagamento: DINHEIRO, CARTAO_CORPORATIVO, REEMBOLSO
INSERT INTO despesa (viagemid, categoriaid, data, pagamento, valor, anexo, observacao) VALUES
    -- Despesas Viagem 1 (Ana Beatriz)
    (1, 3, '2026-04-15', 'CARTAO_CORPORATIVO', 450.00, '/anexos/recibo_hotel_1.pdf', 'Diárias no Hotel Express SP.'),
    (1, 1, '2026-04-15', 'REEMBOLSO', 75.50, '/anexos/nota_almoco_1.pdf', 'Almoço Executivo.'),
    (1, 2, '2026-04-16', 'DINHEIRO', 92.00, '/anexos/recibo_uber_1.pdf', 'Translados entre aeroporto e hotel.'),
    (1, 1, '2026-04-16', 'REEMBOLSO', 120.00, '/anexos/nota_jantar_1.pdf', 'Jantar de negócios.'),

    -- Despesas Viagem 2 (Carlos Henrique)
    (2, 3, '2026-04-20', 'CARTAO_CORPORATIVO', 680.00, '/anexos/recibo_hotel_2.pdf', 'Estadia Hotel Windsor RJ.'),
    (2, 2, '2026-04-20', 'REEMBOLSO', 110.00, '/anexos/recibo_taxi_2.pdf', 'Táxi aeroporto Santos Dumont.'),
    (2, 1, '2026-04-21', 'REEMBOLSO', 85.00, '/anexos/nota_almoco_2.pdf', 'Almoço no restaurante do cliente.'),

    -- Despesas Viagem 3 (Mariana Costa - Moeda USD)
    (3, 3, '2026-05-05', 'CARTAO_CORPORATIVO', 320.00, '/anexos/recibo_hotel_3.pdf', 'Estadia em Nova York - Valor em USD.'),
    (3, 1, '2026-05-06', 'REEMBOLSO', 65.00, '/anexos/nota_almoco_3.pdf', 'Almoço - Valor em USD.'),
    (3, 2, '2026-05-07', 'CARTAO_CORPORATIVO', 80.00, '/anexos/recibo_yellowcab_3.pdf', 'Táxi de Manhattan para o aeroporto JFK - Valor em USD.'),
    (3, 6, '2026-05-08', 'REEMBOLSO', 45.00, '/anexos/nota_outros_3.pdf', 'Chip de internet internacional - Valor em USD.'),

    -- Despesas Viagem 4 (Juliana Maria)
    (4, 3, '2026-05-28', 'CARTAO_CORPORATIVO', 220.00, '/anexos/recibo_hotel_4.pdf', 'Estadia Hotel Ibis Chapecó.'),
    (4, 4, '2026-05-29', 'REEMBOLSO', 150.00, '/anexos/nota_posto_4.pdf', 'Abastecimento veículo locado.'),

    -- Despesas Viagem 8 (Ana Beatriz)
    (8, 3, '2026-05-18', 'CARTAO_CORPORATIVO', 380.00, '/anexos/recibo_hotel_8.pdf', 'Estadia em Porto Alegre.'),
    (8, 2, '2026-05-19', 'REEMBOLSO', 95.00, '/anexos/recibo_taxi_8.pdf', 'Táxi da regional para o hotel.'),
    (8, 1, '2026-05-20', 'REEMBOLSO', 62.00, '/anexos/nota_almoco_8.pdf', 'Refeição - Almoço.');

COMMIT;
