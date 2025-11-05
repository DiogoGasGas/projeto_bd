
CREATE OR REPLACE VIEW vw_funcionarios_departamentos AS
SELECT 
    f.id_fun,
    f.primeiro_nome || ' ' || f.ultimo_nome AS nome_funcionario,
    d.nome_depart AS departamento,
    d.num_funcionarios AS total_no_departamento
FROM funcionarios f
JOIN departamentos d ON f.id_depart = d.id_depart;


