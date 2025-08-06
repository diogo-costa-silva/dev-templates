/*
╔══════════════════════════════════════╗
║   🧠 TEMPLATE GERAL PARA PROJETOS SQL ║
╚══════════════════════════════════════╝
Autor: Diogo Costa Silva
Fonte: [ex: SQLZoo | DataCamp | Curso X | Projeto Pessoal]
Data: [YYYY-MM-DD]
Base de Dados: [nome_da_base_de_dados]
*/

-- 🔧 CONFIGURAÇÃO INICIAL
-- ========================

-- Mostrar todas as bases de dados
SHOW DATABASES;

-- Apagar e recriar a base de dados (⚠️ cuidado com dados reais!)
DROP DATABASE IF EXISTS [nome_da_base_de_dados];
CREATE DATABASE [nome_da_base_de_dados];
USE [nome_da_base_de_dados];

-- IMPORTAÇÃO DE DADOS
-- ====================
-- 📌 Ex: importação via DBeaver com ficheiro.sql
-- (executa antes de continuar)

-- ESTRUTURA DAS TABELAS
-- ======================

-- Ver estrutura das tabelas
DESCRIBE [tabela_1];
DESCRIBE [tabela_2];
-- ...

-- EXPLORAÇÃO INICIAL
-- ===================

-- Ver primeiras linhas de cada tabela
SELECT * FROM [tabela_1] LIMIT 10;
SELECT * FROM [tabela_2] LIMIT 10;

-- Contar número de registos
SELECT COUNT(*) FROM [tabela_1];
SELECT COUNT(*) FROM [tabela_2];

-- CONSULTAS E EXERCÍCIOS
-- =======================

/*
--------------------------------------------------
🧩 BLOCO 1: Título ou Objetivo da Query
[ex: "Listar todos os países com população > 100M"]
--------------------------------------------------
*/

SELECT ...
FROM ...
WHERE ...;

/*
--------------------------------------------------
🔗 BLOCO 2: Exemplo de JOIN ou Subquery
[ex: "Listar todos os golos da Alemanha com info de estádio"]
--------------------------------------------------
*/

SELECT ...
FROM [tabela_1]
JOIN [tabela_2] ON ...
WHERE ...;

/*
--------------------------------------------------
📊 BLOCO 3: Agregações, GROUP BY, HAVING, etc.
[ex: "Contar golos por jogador"]
--------------------------------------------------
*/

SELECT player, COUNT(*) AS golos
FROM goal
GROUP BY player
ORDER BY golos DESC;

/*
--------------------------------------------------
🎯 BLOCO 4: Queries mais avançadas (subqueries, CTEs, etc.)
--------------------------------------------------
*/

-- Exemplo com subquery
SELECT ...
FROM ...
WHERE coluna IN (
    SELECT ...
    FROM ...
    WHERE ...
);
