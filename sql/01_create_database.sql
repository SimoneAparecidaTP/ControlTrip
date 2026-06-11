-- =============================================================
-- BANCO DE DADOS I — ControlTrip
-- Script 01: Criação do banco de dados
-- =============================================================

-- Remove o banco se já existir (uso em ambiente de desenvolvimento)
DROP DATABASE IF EXISTS controltrip;

-- Cria o banco de dados com suporte a acentuação
CREATE DATABASE controltrip
    WITH
    ENCODING    = 'UTF8'
    LC_COLLATE  = 'pt_BR.UTF-8'
    LC_CTYPE    = 'pt_BR.UTF-8';

COMMENT ON DATABASE controltrip IS 'Sistema de Controle de Viagens Corporativas e Reembolsos — ControlTrip';
