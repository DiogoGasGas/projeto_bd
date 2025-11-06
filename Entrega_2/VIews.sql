

-- faz uma tabela virtual com os atributos (id do fun, nome completo, nome do departamento, cargo e total de funcionarios no departamento)


-- Obtém se os funcionários que a sua remuneração total
CREATE OR REPLACE VIEW vw_remun_completa AS
SELECT 
  f.id_fun,
  f.primeiro_nome || ' ' || f.ultimo_nome AS nome_completo,
  (salario_liquido)+ COALESCE(sum(b.valor),0) as remun_completa

FROM funcionarios As f 
LEFT JOIN salario AS s 
ON f.id_fun = s.id_fun
LEFT JOIN beneficios as b
ON f.id_fun = b.id_fun
GROUP BY f.id_fun, nome_completo, salario_liquido
ORDER By f.id_fun ASC;







set search_path to bd054_schema, public;

CREATE OR REPLACE VIEW vw_funcionarios_departamentos AS
SELECT 
    f.id_fun,
    f.primeiro_nome || ' ' || f.ultimo_nome AS nome_funcionario,
    d.nome AS departamento,
    f.cargo AS cargo,
    s.salario_liquido AS salario_liquido
FROM funcionarios f
JOIN departamentos d ON f.id_depart = d.id_depart
JOIN salario s ON f.id_fun = s.id_fun;






SET search_path TO bd054_schema, public;
create or replace view vw_ferias_aprovadas as
select f.id_fun, f.primeiro_nome || ' ' || f.ultimo_nome as nome_funcionario,
       fe.data_inicio, fe.data_fim, fe.num_dias as num_dias_ferias
from funcionarios f
join ferias fe on f.id_fun = fe.id_fun
where fe.estado_aprov = 'Aprovado';



SET search_path TO bd054_schema, public;
CREATE OR REPLACE VIEW vw_media_salarial_departamento AS
SELECT 
    d.id_depart,
    d.nome AS departamento,
    ROUND(AVG(s.salario_liquido), 2) AS media_salario
FROM departamentos d
JOIN funcionarios f ON f.id_depart = d.id_depart
JOIN salario s ON s.id_fun = f.id_fun
GROUP BY d.id_depart, d.nome;






SET search_path TO bd054_schema, public;

CREATE OR REPLACE VIEW vw_formacoes_funcionarios AS

SELECT 
    f.id_fun,
    f.primeiro_nome || ' ' || f.ultimo_nome AS nome_funcionario,
    fo.id_for,
    fo.nome_formacao AS formacao,
    fo.data_inicio,
    fo.data_fim,
    calcular_num_aderentes_formacao(fo.id_for) AS total_aderentes
FROM funcionarios f
JOIN teve_formacao fa ON f.id_fun = fa.id_fun
JOIN formacoes fo ON fa.id_for = fo.id_for;





set search_path to bd054_schema, public;
CREATE OR REPLACE VIEW vw_vagas_candidatos AS
SELECT 
    v.id_vaga,
    v.estado,
    COUNT(c.id_cand) AS num_candidatos
FROM vagas v
LEFT JOIN candidato_a c ON v.id_vaga = c.id_vaga
GROUP BY v.id_vaga, v.estado;



set search_path to bd054_schema, public;
CREATE OR REPLACE VIEW vw_estatisticas_gerais AS
SELECT 
    (SELECT COUNT(*) FROM funcionarios) AS total_funcionarios,
    (SELECT COUNT(*) FROM departamentos) AS total_departamentos,
    (SELECT COUNT(*) FROM vagas) AS total_vagas,
    (SELECT COUNT(*) FROM formacoes) AS total_formacoes;


