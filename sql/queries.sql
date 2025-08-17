-- Criar uma BD
CREATE DATABASE IF NOT EXISTS tests_db
USE tests_db;

-- 	Listar bases e tabelas:
SHOW DATABASES;
USE films;
SHOW TABLES;

-- 	Ver schema:
DESCRIBE movie_ratings;
SHOW CREATE TABLE movie_ratings;


-- Inserir / atualizar / apagar
INSERT INTO movie_ratings(user_name,movie_id,rating) VALUES ('Diogo', 999, 8.7);
UPDATE movie_ratings SET rating=9.2 WHERE id=1;
DELETE FROM movie_ratings WHERE id=1;


-- Transações
START TRANSACTION;
...queries...
COMMIT;  -- ou ROLLBACK;


-- Diagnóstico de permissões
SHOW GRANTS FOR CURRENT_USER();
SELECT CURRENT_USER(), USER();


----------------------------



B) Exploração por base de dados

1) Geral (serve para todas as BDs)

-- listar bases e privilégios
SHOW DATABASES;
SELECT CURRENT_USER() AS current_user;
SHOW GRANTS FOR CURRENT_USER();

-- dentro de uma BD:
USE <db>;
SHOW TABLES;
-- tamanho aproximado das tabelas (InnoDB)
SELECT
  table_name,
  ROUND((data_length+index_length)/1024/1024, 2) AS size_mb
FROM information_schema.tables
WHERE table_schema = DATABASE()
ORDER BY size_mb DESC;

-- colunas e tipos
SELECT column_name, data_type, is_nullable, column_key, column_default
FROM information_schema.columns
WHERE table_schema = DATABASE() AND table_name = '<tabela>'
ORDER BY ordinal_position;

-- DDL
SHOW CREATE TABLE <tabela>\G

-- 2) films (ex.: tabela movie_ratings)

USE films;
SHOW TABLES;
DESCRIBE movie_ratings;
SELECT * FROM movie_ratings LIMIT 10;

-- 3) sqlzoo (dataset Euro2012 clássico: game, goal, etc.)

USE sqlzoo;
SHOW TABLES;
SELECT * FROM game   LIMIT 5;
SELECT * FROM goal   LIMIT 5;
SELECT * FROM eteam  LIMIT 5;   -- se existir

4) motogp_db (os teus dados do projeto)

USE motogp_db;
SHOW TABLES;

-- lista colunas de todas as tabelas (resumo)
SELECT t.table_name, c.column_name, c.data_type
FROM information_schema.tables t
JOIN information_schema.columns c
  ON c.table_schema=t.table_schema AND c.table_name=t.table_name
WHERE t.table_schema = 'motogp_db'
ORDER BY t.table_name, c.ordinal_position;

5) datacamp

USE datacamp;
SHOW TABLES;
SELECT * FROM <tabela> LIMIT 10;


⸻

C) Exemplos prontos (CTEs, Window Functions, Joins, Escrita)

Podes copiar/colar por blocos. Ajusta nomes de tabelas/colunas conforme a tua BD.

1) Agregações básicas

-- Top 10 filmes por rating médio (films)
USE films;
SELECT movie_id, AVG(rating) AS avg_rating, COUNT(*) AS n_ratings
FROM movie_ratings
GROUP BY movie_id
HAVING COUNT(*) >= 5
ORDER BY avg_rating DESC, n_ratings DESC
LIMIT 10;

2) CTE + Window: ranking

WITH movie_stats AS (
  SELECT
    movie_id,
    AVG(rating) AS avg_rating,
    COUNT(*)    AS n_ratings
  FROM movie_ratings
  GROUP BY movie_id
)
SELECT
  movie_id, avg_rating, n_ratings,
  RANK() OVER (ORDER BY avg_rating DESC) AS rank_by_avg
FROM movie_stats
WHERE n_ratings >= 5
ORDER BY rank_by_avg;

3) Percentis com PERCENT_RANK/NTILE

WITH r AS (
  SELECT movie_id, rating
  FROM movie_ratings
)
SELECT
  movie_id,
  AVG(rating)                        AS avg_rating,
  NTILE(4) OVER (ORDER BY AVG(rating)) AS quartil  -- 1..4
FROM r
GROUP BY movie_id
ORDER BY quartil, avg_rating;

4) Rolling average (médias móveis) por utilizador

SELECT
  user_name,
  rating_date,
  rating,
  AVG(rating) OVER (
    PARTITION BY user_name
    ORDER BY rating_date
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
  ) AS avg_last_5
FROM movie_ratings
ORDER BY user_name, rating_date;

5) Deduplicação com Window

WITH ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_name, movie_id ORDER BY rating_date DESC) AS rn
  FROM movie_ratings
)
SELECT *
FROM ranked
WHERE rn = 1;

6) Self-join e janelas (SQLZoo – goal vs game)

USE sqlzoo;
-- jogos com resultado e contagem de golos por equipa
SELECT
  g.id, g.mdate, g.team1, g.team2, g.score1, g.score2,
  SUM(CASE WHEN gl.team=g.team1 THEN 1 ELSE 0 END) AS goals_team1,
  SUM(CASE WHEN gl.team=g.team2 THEN 1 ELSE 0 END) AS goals_team2
FROM game g
LEFT JOIN goal gl ON gl.matchid = g.id
GROUP BY g.id, g.mdate, g.team1, g.team2, g.score1, g.score2
ORDER BY g.mdate DESC
LIMIT 20;

7) CTE multi-passo (SQLZoo – artilheiros por seleção)

WITH goals AS (
  SELECT team, player, COUNT(*) AS n_goals
  FROM goal
  GROUP BY team, player
),
top_team AS (
  SELECT team, player, n_goals,
         RANK() OVER (PARTITION BY team ORDER BY n_goals DESC) AS r
  FROM goals
)
SELECT team, player, n_goals
FROM top_team
WHERE r = 1
ORDER BY n_goals DESC, team;

8) motogp_db – podium rate por piloto (exemplo genérico)

USE motogp_db;
/* Ajusta nomes: races/events/results/riders */
WITH results AS (
  SELECT rider_id, position
  FROM race_results
  WHERE class = 'MotoGP'          -- se aplicável
),
agg AS (
  SELECT
    rider_id,
    COUNT(*)                                   AS races,
    SUM(CASE WHEN position <= 3 THEN 1 ELSE 0 END) AS podiums
  FROM results
  GROUP BY rider_id
)
SELECT
  r.rider_id,
  a.rider_name,                     -- junta à tabela de riders se existir
  races, podiums,
  ROUND(podiums*100.0/races, 2) AS podium_rate_pct
FROM agg
JOIN riders a ON a.id = r.rider_id
ORDER BY podium_rate_pct DESC
LIMIT 20;

9) Janelas temporais (motogp: forma recente)

WITH ranked AS (
  SELECT
    rider_id, event_date,
    position,
    ROW_NUMBER() OVER (PARTITION BY rider_id ORDER BY event_date DESC) AS rn
  FROM race_results
)
SELECT rider_id,
       AVG(position) AS avg_pos_last_5
FROM ranked
WHERE rn <= 5
GROUP BY rider_id
ORDER BY avg_pos_last_5;

10) Upserts (INSERT…ON DUPLICATE KEY)

USE films;
INSERT INTO movie_ratings (user_name, movie_id, rating, rating_date)
VALUES ('Diogo', 123, 8.9, NOW())
ON DUPLICATE KEY UPDATE
  rating = VALUES(rating),
  rating_date = VALUES(rating_date);

11) Atualizações condicionais

UPDATE movie_ratings
SET rating = rating + 0.2
WHERE movie_id = 123
  AND user_name = 'Diogo';

12) Deletes seguros

DELETE FROM movie_ratings
WHERE movie_id = 123
  AND user_name = 'Diogo'
LIMIT 1;

13) Criar tabela derivada (DDL)

CREATE TABLE IF NOT EXISTS movie_ratings_daily AS
SELECT
  DATE(rating_date) AS day,
  COUNT(*)          AS n_ratings,
  AVG(rating)       AS avg_rating
FROM movie_ratings
GROUP BY DATE(rating_date);

14) Índices que realmente ajudam

-- procurar ratings por movie_id e ordenar por data?
CREATE INDEX IF NOT EXISTS idx_movie_ratings_movie_date
ON movie_ratings (movie_id, rating_date);

-- deduplicação por (user_name, movie_id)?
CREATE UNIQUE INDEX IF NOT EXISTS uq_user_movie
ON movie_ratings (user_name, movie_id);

15) Planos de execução

EXPLAIN ANALYZE
SELECT movie_id, AVG(rating)
FROM movie_ratings
GROUP BY movie_id
HAVING COUNT(*) >= 5;


⸻

D) Transações, segurança e boas práticas

Transações

START TRANSACTION;

UPDATE movie_ratings
SET rating = 9.5
WHERE id = 42;

-- Valida antes de fechar
SELECT * FROM movie_ratings WHERE id = 42;

COMMIT;   -- ou ROLLBACK;

Privilégios mínimos (se criares um user “app”)

-- (corre como root)
CREATE USER IF NOT EXISTS 'app'@'%' IDENTIFIED BY 'senha_segura';
GRANT SELECT, INSERT, UPDATE, DELETE ON films.* TO 'app'@'%';
FLUSH PRIVILEGES;




