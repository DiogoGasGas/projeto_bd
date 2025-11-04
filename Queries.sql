-- 1. Total da remuneração de cada funcionário

-- Objetivo: somar todas as remunerações (salário + benefícios) de cada funcionário
SELECT
  f.id_fun, f.primeiro_nome, f.ultimo_nome,                       -- nome do funcionário
  SUM(r.valor) AS total_remuneracao  -- soma de todas as remunerações associadas ao funcionário
FROM Funcionarios f
-- junta Funcionarios com Remuneracoes para obter os valores associados a cada funcionário
JOIN Remuneracoes r ON f.id_funcionario = r.id_funcionario
-- agrupa por funcionário para que a soma seja calculada individualmente por cada um
GROUP BY f.id_funcionario;


SELECT f.id_fun, f.primeiro_nome, f.ultimo_nome, (r.sum(valor) + r.salario_liquido) 
from funcionarios f, renumeracoes r


FODASE
-----------------------------------------------------------------------

--2. Número de funcionários por departamento

-- Objetivo: contar quantos funcionários existem em cada departamento
SELECT
  d.nome_departamento,              -- nome do departamento
  COUNT(f.id_funcionario) AS total_funcionarios -- número total de funcionários no departamento
FROM Departamentos d
-- LEFT JOIN permite listar também departamentos sem funcionários
LEFT JOIN Funcionarios f ON d.id_departamento = f.id_departamento
-- agrupa os resultados por departamento para fazer a contagem corretamente
GROUP BY d.id_departamento;

Fodase
-------------------------------------------------------------------------

--3 Funcionários que ganham acima da média geral

-- Objetivo: listar funcionários cujo salário base é superior à média global de salários
SELECT
  nome,                 -- nome do funcionário
  salario_base          -- salário base individual
FROM Funcionarios
-- subquery calcula a média global de salário_base na tabela Funcionarios
WHERE salario_base > (SELECT AVG(salario_base) FROM Funcionarios);


--------------------------------------------------------------------------

--4. Departamento com maior remuneração total

-- Objetivo: identificar os departamentos com a maior soma de remunerações por ordem decrescente
SELECT
  d.nome_departamento
FROM Departamentos d
-- junta Departamentos com Funcionarios para obter quem trabalha em cada departamento
JOIN Funcionarios f ON d.id_departamento = f.id_departamento
-- junta Funcionarios com Remuneracoes para obter os valores associados
JOIN Remuneracoes r ON f.id_funcionario = r.id_funcionario
-- agrupa os valores por departamento
GROUP BY d.id_departamento
-- ordena pela soma das remunerações de forma decrescente (maior para menor)
ORDER BY SUM(r.valor) DESC



------------------------------------------------------------------------------------

--5. Top 3 funcionários com maior total de remuneração

-- Objetivo: listar os funcionários com maior remuneração total de forma decrescente
SELECT
  f.nome,                        -- nome do funcionário
  SUM(r.valor) AS total_remuneracao -- soma de todas as remunerações associadas ao funcionário
FROM Funcionarios f
JOIN Remuneracoes r ON f.id_funcionario = r.id_funcionario
GROUP BY f.id_funcionario
-- ordena os resultados do maior para o menor valor total
ORDER BY total_remuneracao DESC


-------------------------------------------------------------------------------------

--6. Média de férias por departamento

-- Objetivo: calcular a média de dias de férias dos funcionários em cada departamento
SELECT
  d.nome_departamento,                    -- nome do departamento
  AVG(fer.dias) AS media_dias_ferias      -- média de dias de férias no departamento
FROM Departamentos d
JOIN Funcionarios f ON d.id_departamento = f.id_departamento
JOIN Ferias fer ON f.id_funcionario = fer.id_funcionario
-- agrupa por departamento para calcular a média de férias de cada um
GROUP BY d.id_departamento;

------------------------------------------------------------------------------

--7 .Comparação com média global nas formações

-- Objetivo: listar formações cujo número de aderentes está acima da média de todas as formações
SELECT
  f.id_formacao,
  f.nome_formacao,
  f.num_aderentes
FROM Formacoes f
-- compara cada formação com a média global de aderentes (subquery calcula essa média)
WHERE f.num_aderentes > (SELECT AVG(num_aderentes) FROM Formacoes)
ORDER BY f.num_aderentes DESC;

-----------------------------------------------------------------------------

--8. Funcionários com benefícios acima da média

-- Objetivo: listar funcionários que recebem benefícios acima da média geral
SELECT
  f.nome,                        -- nome do funcionário
  SUM(r.valor) AS total_beneficio -- total de benefícios recebidos
FROM Funcionarios f
JOIN Remuneracoes r ON f.id_funcionario = r.id_funcionario
-- filtra apenas remunerações do tipo Benefício
WHERE r.tipo = 'Benefício'
GROUP BY f.id_funcionario
-- HAVING compara a soma dos benefícios de cada funcionário com a média global dos benefícios
HAVING total_beneficio > (SELECT AVG(valor) FROM Remuneracoes WHERE tipo = 'Benefício');


---------------------------------------------------------------------------------

--9. Funcionário com mais dias de férias

-- Objetivo: identificar o funcionário com mais dias de férias
SELECT
  f.nome,        -- nome do funcionário
  fer.dias       -- número de dias de férias
FROM Funcionarios f
JOIN Ferias fer ON f.id_funcionario = fer.id_funcionario
-- subquery identifica o valor máximo de dias de férias
WHERE fer.dias = (SELECT MAX(dias) FROM Ferias);

--------------------------------------------------------------------------------------------

--10. Média de pontuação de avaliação por departamento

-- Objetivo: calcular a média de pontuação de avaliação por departamento
SELECT
  d.nome_departamento,            -- nome do departamento
  AVG(a.pontuacao) AS media_pontuacao -- média da pontuação de avaliação dos funcionários do departamento
FROM Avaliacoes a
JOIN Funcionarios f ON a.id_funcionario = f.id_funcionario
JOIN Departamentos d ON f.id_departamento = d.id_departamento
-- agrupa por departamento para calcular a média de cada um
GROUP BY d.id_departamento;


----------------------------------------------------------------------

--11. Dependentes e funcionário respetivo

-- Objetivo: mostrar cada dependente com o respetivo funcionário titular e o departamento desse funcionário
SELECT
  d.nome           AS nome_dependente,      -- nome do dependente (atributo da entidade Dependentes)
  d.parentesco,                                 -- parentesco com o funcionário
  f.id_funcionario, f.nome  AS nome_funcionario, -- id e nome do funcionário titular
  dep.nome_departamento                         -- nome do departamento do funcionário
FROM Dependentes d
-- junta Dependentes com Funcionarios para saber quem é o titular
JOIN Funcionarios f ON d.id_funcionario = f.id_funcionario
-- junta Funcionarios com Departamentos para saber a qual departamento o titular pertence
JOIN Departamentos dep ON f.id_departamento = dep.id_departamento;


-----------------------------------------------------------------------------

--12. Vagas

-- Objetivo: calcular a média de candidatos por departamento, com o número de vagas em cada departamento
SELECT
  dep.nome_departamento,                        -- departamento
  COUNT(v.id_vaga) AS num_vagas,                -- quantas vagas existem no departamento
  AVG(v.num_candidatos) AS media_candidatos     -- média de candidatos por vaga nesse departamento
FROM Vagas v
-- assume-se que Vagas tem uma FK id_departamento (relação 'tem' com Departamentos)
JOIN Departamentos dep ON v.id_departamento = dep.id_departamento
GROUP BY dep.id_departamento
-- ordena para ver primeiro os departamentos com maior média de candidatos
ORDER BY media_candidatos DESC;

---------------------------------------------------------------------------------------

-- 13. Número de dependentes
-- Objetivo : Número de dependenntes de cada funcionário

SELECT 
  f.id_funcionario                            -- id do funcionário
  f.nome                                      -- nome do funcionário
  COUNT(d.id_funcionario) AS num_dependentes  -- contar o numero de pessoas associadas ao id do funcionário

FROM funcionarios As f
LEFT JOIN dependentes AS d ON f.id_funcionarios = d.id_funcionarios  -- criar tabela incluindo todos os funcionários associando aos dependentes
GROUP BY f.id_funcionario, f.nome
ORDER BY num_dependentes desc;

------------------------------------------------------------------------------------






