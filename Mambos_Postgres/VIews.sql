
set search_path to bd054_schema, public;



-- View que apresenta a remuneração total dos funcionários

CREATE OR REPLACE VIEW vw_remun_completa AS
SELECT 
  f.id_fun,
  f.primeiro_nome || ' ' || f.ultimo_nome AS nome_completo, -- concatena o nome completo
  (salario_liquido) + COALESCE(SUM(b.valor), 0) AS remun_completa -- soma salário e benefícios

FROM funcionarios AS f
LEFT JOIN salario AS s 
ON f.id_fun = s.id_fun -- junta com tabela de salários
LEFT JOIN beneficios AS b
ON f.id_fun = b.id_fun -- junta com tabela de benefícios
GROUP BY f.id_fun, nome_completo, salario_liquido -- agrupa por funcionário
ORDER BY f.id_fun ASC; -- ordena por ID



-- View que mostra funcionários, seus departamentos e salários

CREATE OR REPLACE VIEW vw_funcionarios_departamentos AS
SELECT 
    f.id_fun,
    f.primeiro_nome || ' ' || f.ultimo_nome AS nome_funcionario, -- nome completo
    d.nome AS departamento, -- nome do departamento
    f.cargo AS cargo, -- cargo atual
    s.salario_liquido AS salario_liquido -- salário líquido do funcionário
FROM funcionarios f
JOIN departamentos d ON f.id_depart = d.id_depart
JOIN salario s ON f.id_fun = s.id_fun; -- junta salários ao funcionário



-- View que lista as férias aprovadas dos funcionários

CREATE OR REPLACE VIEW vw_ferias_aprovadas AS
SELECT 
    f.id_fun,
    f.primeiro_nome || ' ' || f.ultimo_nome AS nome_funcionario, -- nome completo
    fe.data_inicio,
    fe.data_fim,
    fe.num_dias AS num_dias_ferias -- duração das férias
FROM funcionarios f
JOIN ferias fe ON f.id_fun = fe.id_fun
WHERE fe.estado_aprov = 'Aprovado'; -- apenas férias aprovadas



-- View que calcula a média salarial por departamento

CREATE OR REPLACE VIEW vw_media_salarial_departamento AS
SELECT 
    d.id_depart,
    d.nome AS departamento,
    ROUND(AVG(s.salario_liquido), 2) AS media_salario -- média dos salários
FROM departamentos d
JOIN funcionarios f ON f.id_depart = d.id_depart
JOIN salario s ON s.id_fun = f.id_fun
GROUP BY d.id_depart, d.nome; -- agrupa por departamento



-- View que apresenta formações e número de aderentes por formação

CREATE OR REPLACE VIEW vw_formacoes_funcionarios AS
SELECT 
    f.id_fun,
    f.primeiro_nome || ' ' || f.ultimo_nome AS nome_funcionario,
    fo.id_for,
    fo.nome_formacao AS formacao,
    fo.data_inicio,
    fo.data_fim,
    calcular_num_aderentes_formacao(fo.id_for) AS total_aderentes -- chama função para contar aderentes
FROM funcionarios f
JOIN teve_formacao fa ON f.id_fun = fa.id_fun
JOIN formacoes fo ON fa.id_for = fo.id_for;



-- View que mostra vagas e o número de candidatos associados

CREATE OR REPLACE VIEW vw_vagas_candidatos AS
SELECT 
    v.id_vaga,
    v.estado, -- estado da vaga (ex: aberta, fechada)
    COUNT(c.id_cand) AS num_candidatos -- total de candidatos por vaga
FROM vagas v
LEFT JOIN candidato_a c ON v.id_vaga = c.id_vaga
GROUP BY v.id_vaga, v.estado;



-- View com estatísticas gerais do sistema

CREATE OR REPLACE VIEW vw_estatisticas_gerais AS
SELECT 
    (SELECT COUNT(*) FROM funcionarios) AS total_funcionarios,
    (SELECT COUNT(*) FROM departamentos) AS total_departamentos,
    (SELECT COUNT(*) FROM vagas) AS total_vagas,
    (SELECT COUNT(*) FROM formacoes) AS total_formacoes; -- número total de formações
