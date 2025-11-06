-----------------------------------------------------------------------

--1. Número de funcionários por departamento (vista)

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

--2 Funcionários que ganham acima da média geral (vista)

SELECT
  f.primeiro_nome || ' '|| f.ultimo_nome AS nome_completo,                 -- nome do funcionário
  s.salario_bruto         -- salário bruto individual
FROM funcionarios AS f
LEFT JOIN salario AS s
ON s.id_fun = f.id_fun
-- subquery calcula a média global de salário_base na tabela Funcionarios
WHERE s.salario_bruto > (
  SELECT 
  AVG(salario_bruto) 
  FROM salario);


--------------------------------------------------------------------------

--3. Departamentos e as suas remunerações (vista)

-- Objetivo: identificar os departamentos com a maior soma de remunerações por ordem decrescente
SELECT
  d.nome,
  SUM(s.salario_bruto) As tot_remun
FROM departamentos AS d
-- junta departamentos com funcionarios para obter quem trabalha em cada departamento
JOIN funcionarios AS f 
  ON d.id_depart = f.id_depart
-- associa funcionarios com remuneracoes para obter os valores associados
JOIN salario AS s 
  ON f.id_fun = s.id_fun
-- associar os valores por departamento
GROUP BY d.nome
-- ordena pela soma das remunerações de forma decrescente 
ORDER BY tot_remun DESC



------------------------------------------------------------------------------------

--4. Top 3 funcionários com maior total de remuneração (vista)

-- Objetivo: listar os 3 funcionários com maior salário líquido de forma decrescente
SELECT
  f.primeiro_nome,                        -- nome do funcionário
  SUM(s.salario_liquido) AS total_remuneracao -- soma de todas as remunerações associadas ao funcionário
FROM funcionarios AS f
JOIN salario AS s 
ON f.id_fun = s.id_fun
GROUP BY f.id_fun
-- ordena os resultados do maior para o menor valor total
ORDER BY total_remuneracao DESC
--limita aos 3 primeiros valores a tabela
LIMIT 3


-------------------------------------------------------------------------------------

--5. Média de férias por departamento (vista) 

-- Objetivo: calcular a média de dias de férias dos funcionários em cada departamento
SELECT
  d.nome,                    -- nome do departamento
  AVG(fer.num_dias) AS media_dias_ferias      -- média de dias de férias no departamento
FROM departamentos AS d
JOIN funcionarios AS f 
ON d.id_depart = f.id_depart
JOIN ferias AS fer 
ON f.id_fun = fer.id_fun
-- agrupa por departamento para calcular a média de férias de cada um
GROUP BY d.nome;

------------------------------------------------------------------------------

--6.Comparação com média global nas formações (vista)

-- Objetivo: listar formações cujo número de aderentes está acima da média de todas as formações
-- é usada a funcao calcular_num_aderentes_formacao para este efeito
SELECT
  f.id_for,
  f.nome_formacao,
  calcular_num_aderentes_formacao(f.id_for) AS num_aderentes
FROM formacoes AS f
-- compara cada formação com a média global de aderentes (subquery calcula essa média)
WHERE calcular_num_aderentes_formacao(f.id_for) >
  (SELECT AVG(calcular_num_aderentes_formacao(id_for)) FROM formacoes)
ORDER BY  calcular_num_aderentes_formacao(f.id_for) DESC;

-----------------------------------------------------------------------------

-- 7. funcionários com benificio do tipo 'Seguro Saúde' com valor deste acima da média (vista)

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

--8. Funcionário com mais dias de férias (vista)

-- Objetivo: identificar o/os funcionário com mais dias de férias
SELECT
  f.primeiro_nome,        -- nome do funcionário
  fer.num_dias       -- número de dias de férias
FROM funcionarios AS f
JOIN ferias AS fer ON 
f.id_fun = fer.id_fun
-- subquery identifica o valor máximo de dias de férias
WHERE fer.num_dias = (SELECT MAX(num_dias) FROM ferias);

--------------------------------------------------------------------------------------------

--9. Média de pontuação de avaliação por departamento

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

--10. Dependentes e funcionário respetivo (vista)

-- Objetivo: mostrar cada dependente com o respetivo funcionário titular e o departamento desse funcionário
SELECT
  f.id_fun, 
  f.primeiro_nome || ' '|| f.ultimo_nome AS nome_funcionario, -- id e nome do funcionário titular
  dep.nome   as nome_dep,                      -- nome do departamento do funcionário
  STRING_AGG(d.nome || ' (' || d.parentesco || ')', ', ') AS dependentes -- agrega todos os dependnetes numa unica linha
FROM dependentes AS d
-- junta Dependentes com Funcionarios para saber quem é o titular
JOIN Funcionarios f ON d.id_fun = f.id_fun
-- junta Funcionarios com Departamentos para saber a qual departamento o titular pertence
JOIN departamentos AS dep 
ON f.id_depart = dep.id_depart
GROUP BY f.id_fun, f.primeiro_nome, f.ultimo_nome, dep.nome -- necessário devido ao string_agg
ORDER BY nome_funcionario; -- orderna por ordem alfabética


-----------------------------------------------------------------------------

--11. Vagas

-- Objetivo: calcular a média de candidatos por departamento, com o número de vagas em cada departamento
SELECT
  dep.nome_departamento,                        -- departamento
  COUNT(v.id_vaga) AS num_vagas,                -- quantas vagas existem no departamento
  AVG(v.num_candidatos) AS media_candidatos     -- média de candidatos por vaga nesse departamento
FROM vagas AS v
-- assume-se que Vagas tem uma FK id_departamento (relação 'tem' com Departamentos)
JOIN departamentos AS dep
  ON v.id_depart = dep.id_depart
GROUP BY dep.id_depart  
-- ordena para ver primeiro os departamentos com maior média de candidatos
ORDER BY media_candidatos DESC;

---------------------------------------------------------------------------------------

-- 12. Número de dependentes (testar todas daqui para a frente)
-- Objetivo : Número de dependenntes de cada funcionário

SELECT f.id_fun,f.primeiro_nome, 
  COUNT(d.id_fun) AS num_dependentes  
FROM funcionarios As f
LEFT JOIN dependentes AS d 
  ON f.id_fun = d.id_fun  -- criar tabela incluindo todos os funcionários associando aos dependentes
GROUP BY f.id_fun, f.primeiro_nome
ORDER BY num_dependentes desc;  

------------------------------------------------------------------------------------

--13. Funcionário que não fizeram auto-avaliação
SELECT 
    f.primeiro_nome,
    f.ultimo_nome,
    av.autoavaliacao
FROM funcionarios AS f 
JOIN avaliacoes AS av ON f.id_fun = av.id_fun
WHERE av.autoavaliacao IS NULL;

------------------------------------------------------------------------------------

--14. Numero de faltas por departamento e (justificacao mais comum (adicionar))
SELECT 
    d.id_depart,
    d.nome,
    COUNT(fal.id_fun) AS total_faltas
FROM departamentos d
LEFT JOIN funcionarios AS f 
  ON d.id_depart = f.id_depart
LEFT JOIN faltas AS fal 
  ON f.id_fun = fal.id_fun
GROUP BY d.nome, d.id_depart
ORDER BY total_faltas DESC;

---------------------------------------------
--- 15- Departamentos cuja média salarial é maior que a média total, o seu número de funcionários e a sua média
  
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
--- 16- Funcionários que já trabalharam na mesma empresa

SELECT h.nome_empresa, STRING_AGG(f.primeiro_nome || ' ' || f.ultimo_nome, ', ') AS funcionarios
FROM historico_empresas as h
JOIN funcionarios f ON f.id_fun = h.id_fun
group by h.nome_empresa
HAVING COUNT(f.id_fun) > 1;

------------------------------------------------------------------------------------------
--17. Funcionários sem faltas registadas

select f.primeiro_nome || ' ' || f.ultimo_nome AS nome_completo, count(fal.data) as total_faltas
from funcionarios f
left join faltas fal on f.id_fun = fal.id_fun
group by f.primeiro_nome, f.ultimo_nome
having count(fal.data) = 0

------------------------------------------------------------------------------------------
--18. Taxa de aderência a formações por departamento

SELECT 
    d.nome,
    
    ROUND((COUNT(DISTINCT teve.id_fun)::decimal / calcular_num_funcionarios_departamento(d.id_depart)::decimal) * 100, 2) AS taxa_adesao
    -- Round arredonda a 2 casas decimais, o count com recurso ao distinct conta os funcionários que participaram em pelo menos uma formação, 
    -- dividindo-se pelo numero total de pessoas no departamento
FROM departamentos AS d
LEFT JOIN funcionarios AS f 
  ON d.id_depart = f.id_depart
  -- associar funcionários por departamento
LEFT JOIN teve_formacao AS teve 
  ON f.id_fun = teve.id_fun
  -- associar funcionários pelas presenças a formações que tiveram
GROUP BY d.nome, d.id_depart
ORDER BY taxa_adesao DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--19.funcionarios trabalharam na empresa Marques, auferem atualmente mais de 870 euros brutos e têm seguro de saúde
SELECT
DISTINCT(f.primeiro_nome || ' ' || f.ultimo_nome) As nome_completo,
  -- o distinct é necessário uma vez que um funcionário pode aparecer repetido em benefícios diferentes ou empresas
h.nome_empresa AS trabalhou_em,
s.salario_bruto,
b.tipo
FROM funcionarios AS f
JOIN historico_empresas AS h 
    ON f.id_fun = h.id_fun
  -- associar os funcionários ao seu histórico
    AND (h.nome_empresa = 'Marques')
  -- filtrar apenas para a empresa Marques
JOIN salario As s 
    ON f.id_fun = s.id_fun
  -- associar funcionários ao seu salário
    AND s.salario_bruto > 870 
  -- filtrar para salários superiores a 870 euros
JOIN beneficios AS b
    ON f.id_fun = b.id_fun 
    AND b.tipo = 'Seguro Saúde';
  -- definir benefício pretendido
--------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 20.Listar os funcionários que ganham acima da média salarial do seu próprio departamento, indicando-o, mostrando também o número de formações concluídas.


SELECT 
f.id_fun,
f.primeiro_nome || ' ' || f.ultimo_nome AS nome_completo,
sal.salario_bruto,
d.nome,

(SELECT COUNT(*)
FROM teve_formacao AS teve
JOIN formacoes AS fo
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

-------------------------------------------------------------------------------------------------------------------------------
--21. Funcionarios auferem salário mais de 1500 euros, têm um total de férias atribuidas entre 10 e 15, com numero de dependentes do sexo feminino.

SELECT 
f.primeiro_nome || ' ' || f.ultimo_nome AS nome_completo,
s.salario_liquido,
SUM(calcular_num_dias_ferias(f.id_fun, fe.data_inicio, fe.data_fim)) as ferias_aprovadas,
COUNT(d.sexo) AS num_dep_Fem

FROM funcionarios AS f 
LEFT JOIN salario AS s 
  ON f.id_fun = s.id_fun 
AND s.salario_liquido > 1500
JOIN ferias as fe 
  ON f.id_fun = fe.id_fun
JOIN dependentes AS d 
  ON f.id_fun = d.id_fun 
WHERE  d.sexo = 'Feminino'
GROUP BY nome_completo, s.salario_liquido;


-------------------------------------------------------------------------------------------------------------------------------
-- 22. Média de dependentes femininos por departamento

SELECT 
d.nome,
f.id_depart, 
-- num_fem calculado abaixo, coalesce para cotar pessoas sem dependentes cmo zero, não como null
COALESCE(AVG(dep.num_fem),0) AS media_fem
-- subquerry usada para da entidade dependentes ser filtrada apenas pessoas do sexo feminino e associar ao id_fun
-- daqui se cria num_fem usado para caclular a média acima referida
FROM (
  SELECT 
  de.id_fun, 
  COUNT(*) 
AS num_fem
  
  FROM dependentes AS de
  WHERE de.sexo = 'Feminino' 
  GROUP BY de.id_fun
) AS dep

-- left joins usados para associar id_depart e nome do departamento à média, agrupando os com o group by
-- left join, não join, para garantir que mesmo departamentos sem dependentes femininos são incluídos  

LEFT JOIN funcionarios AS f 
ON f.id_fun = dep.id_fun
LEFT JOIN departamentos as d 
ON d.id_depart = f.id_depart
GROUP BY d.nome, f.id_depart;


