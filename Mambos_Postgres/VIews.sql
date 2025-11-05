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
create or replace view 



calcular_num_funcionarios_departamento(d.id_depart) AS total_no_departamento