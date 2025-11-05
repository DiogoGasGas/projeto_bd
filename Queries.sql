-----------------------------------------------------------------------

--2. Número de funcionários por departamento (vista)

-- Objetivo: contar quantos funcionários existem em cada departamento
SELECT
  d.nome,              -- nome do departamento
  COUNT(f.id_fun) AS total_funcionarios -- número total de funcionários no departamento
FROM departamentos AS d
-- LEFT JOIN permite listar também departamentos sem funcionários
LEFT JOIN funcionarios AS f 
ON d.id_depart= f.id_depart
-- agrupa os resultados por departamento para fazer a contagem corretamente
GROUP BY d.id_depart;

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

-- 8. funcionários com benificio do tipo 'Seguro Saúde' com valor deste acima da média (vista)

SELECT 
f.id_fun,
f.primeiro_nome || ' ' || f.ultimo_nome AS nome_completo,
SUM(b.valor) AS tot_benef

FROM funcionarios AS f
JOIN beneficios AS b 
ON f.id_fun = b.id_fun
WHERE b.tipo = 'Seguro Saúde'
GROUP BY nome_completo, f.id_fun
HAVING SUM(b.valor) > (select AVG(valor) from beneficios where tipo = 'Seguro Saúde')
ORDER BY f.id_fun ASC;


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

SELECT f.id_fun,f.primeiro_nome, COUNT(d.id_fun) AS num_dependentes  
FROM funcionarios As f
LEFT JOIN dependentes AS d ON f.id_fun = d.id_fun  -- criar tabela incluindo todos os funcionários associando aos dependentes
GROUP BY f.id_fun, f.primeiro_nome
ORDER BY num_dependentes desc;  

------------------------------------------------------------------------------------

--14. Funcionário que não fizeram auto-avaliação
SELECT 
    f.primeiro_nome,
    f.ultimo_nome,
    av.autoavaliacao
from funcionarios AS f 
JOIN avaliacoes AS av ON f.id_fun = av.id_fun
WHERE av.autoavaliacao IS NULL;

------------------------------------------------------------------------------------

--15. Numero de faltas por departamento
SELECT 
    d.id_depart,
    d.nome,
    COUNT(fal.id_fun) AS total_faltas
FROM departamentos d
LEFT JOIN funcionarios AS f ON d.id_depart = f.id_depart
LEFT JOIN faltas AS fal ON f.id_fun = fal.id_fun
GROUP BY d.nome, d.id_depart
ORDER BY total_faltas DESC;

---------------------------------------------
--- 16- Departamentos cuja média salarial é maior que a média total, o seu número de funcionários e a sua média
  
SELECT 
    d.Nome,
    COUNT(f.ID_fun) AS Numero_Funcionarios,
    AVG(s.salario_bruto) AS Media_Salarial_Departamento
FROM 
    Departamentos d
JOIN 
    Funcionarios f ON d.ID_depart = f.ID_depart
JOIN 
    Remuneracoes r ON f.ID_fun = r.ID_fun
JOIN 
    Salario s ON r.ID_fun = s.ID_fun AND r.Data_inicio = s.Data_inicio
GROUP BY 
    d.Nome
HAVING 
    AVG(s.salario_bruto) > (
        SELECT AVG(salario_bruto) 
        FROM Salario
    )
ORDER BY 
    Media_Salarial_Departamento DESC;

---------------------------------------------
--- 17- Funcionários que já trabalharam na mesma empresa

SELECT h.nome_empresa, STRING_AGG(f.primeiro_nome || ' ' || f.ultimo_nome, ', ') AS funcionarios
FROM historico_empresas as h
JOIN funcionarios f ON f.id_fun = h.id_fun
group by h.nome_empresa
HAVING COUNT(f.id_fun) > 1;

------------------------------------------------------------------------------------------
--18. Funcionários sem faltas registadas

select f.primeiro_nome || ' ' || f.ultimo_nome AS nome_completo, count(fal.data) as total_faltas
from funcionarios f
left join faltas fal on f.id_fun = fal.id_fun
group by f.primeiro_nome, f.ultimo_nome
having count(fal.data) = 0

------------------------------------------------------------------------------------------
--19. Taxa de aderência a formações por departamento

SELECT 
    d.nome,
    ROUND((COUNT(DISTINCT teve.id_fun)::decimal / calcular_num_funcionarios_departamento(d.id_depart)::decimal) * 100, 2) AS taxa_adesao
FROM departamentos AS d
LEFT JOIN funcionarios AS f ON d.id_depart = f.id_depart
LEFT JOIN teve_formacao AS teve ON f.id_fun = teve.id_fun
GROUP BY d.nome, d.id_depart
ORDER BY taxa_adesao DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--20.funcionarios trabalharam na empresa Marques, auferem atualmente mais de 500 euros brutos e têm seguro de saúde
SELECT
DISTINCT(f.primeiro_nome || ' ' || f.ultimo_nome) As nome_completo,
h.nome_empresa AS trabalhou_em,
s.salario_bruto,
b.tipo
FROM funcionarios AS f
JOIN historico_empresas AS h 
    ON f.id_fun = h.id_fun
    AND (h.nome_empresa = 'Marques')
JOIN salario As s 
    ON f.id_fun = s.id_fun
    AND s.salario_bruto > 500 
JOIN beneficios AS b
    ON f.id_fun = b.id_fun 
    AND b.tipo = 'Seguro Saúde';
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 21.Listar os funcionários que ganham acima da média salarial do seu próprio departamento, indicando-o, mostrando também o número de formações concluídas.


SELECT 
f.id_fun,
f.primeiro_nome || ' ' || f.ultimo_nome AS nome_completo,
sal.salario_bruto,
d.nome,

(SELECT COUNT(*)
FROM teve_formacao as teve
JOIN formacoes as fo
ON teve.id_for = fo.id_for
AND (f.id_fun = teve.id_fun)
) As num_formacoes

FROM funcionarios AS f 
JOIN departamentos AS d
    ON f.id_depart = d.id_depart
JOIN salario as Sal 
    ON f.id_fun = sal.id_fun
    AND sal.salario_bruto > (                  
        SELECT AVG(s2.salario_bruto)          
        FROM funcionarios AS f2               
        JOIN salario AS s2 
            ON f2.id_fun = s2.id_fun
        WHERE f2.id_depart = f.id_depart);


-- nesta subquerry vamos filtrar os funcionários por departamento e daí calcular a média salarial por departamento
-- para depois comparar com o salário bruto do funcionário em questão
-- ou seja, para cada funcionário, vamos calcular a média salarial do departamento a que ele pertence
-- e verificar se o salário bruto dele é maior que essa 
-- daí ser necessário atribuir novas variaveis a funcionários e salários
-- uma vez que temos já funcionários e salários na query principal
