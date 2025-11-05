set search_path to bd054_schema, public;

-- faz uma tabela virtual com os atributos (id do fun, nome completo, nome do departamento, cargo e total de funcionarios no departamento)




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
create or replace view ferias_aprovadas as
select f.id_fun, f.primeiro_nome || ' ' || f.ultimo_nome as nome_funcionario,
       fe.data_inicio, fe.data_fim
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





set search_path to bd054_schema, public;
CREATE OR REPLACE VIEW vw_formacoes_funcionarios AS
SELECT 
    f.id_fun,
    f.primeiro_nome || ' ' || f.ultimo_nome AS nome_funcionario,
    fo.titulo AS formacao,
    fa.data_inicio,
    fa.data_fim
FROM funcionarios f
JOIN formacao_aderentes fa ON fa.id_fun = f.id_fun
JOIN formacoes fo ON fo.id_for = fa.id_for;



CREATE OR REPLACE VIEW vw_vagas_candidatos AS
SELECT 
    v.id_vaga,
    v.titulo AS vaga,
    v.estado,
    COUNT(c.id_cand) AS num_candidatos
FROM vagas v
LEFT JOIN candidato_a c ON v.id_vaga = c.id_vaga
GROUP BY v.id_vaga, v.titulo, v.estado;


set search_path to bd054_schema, public;
CREATE OR REPLACE VIEW vw_estatisticas_gerais AS
SELECT 
    (SELECT COUNT(*) FROM funcionarios) AS total_funcionarios,
    (SELECT COUNT(*) FROM departamentos) AS total_departamentos,
    (SELECT COUNT(*) FROM vagas) AS total_vagas,
    (SELECT COUNT(*) FROM formacoes) AS total_formacoes;


select view * from vw_funcionarios_departamentos;