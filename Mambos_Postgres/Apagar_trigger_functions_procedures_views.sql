SET search_path TO bd054_schema, public;

-- 1) Triggers
DROP TRIGGER IF EXISTS trg_calc_salario_liquido ON salario;
DROP TRIGGER IF EXISTS trg_validar_dias_ferias ON ferias;
DROP TRIGGER IF EXISTS trg_registrar_mudanca_cargo ON funcionarios;
DROP TRIGGER IF EXISTS trg_validar_idade_funcionario ON funcionarios;
DROP TRIGGER IF EXISTS trg_cria_utilizador ON funcionarios;
DROP TRIGGER IF EXISTS trg_delete_permissoes ON funcionarios;
DROP TRIGGER IF EXISTS trg_calcular_num_dias_ferias ON ferias;

-- 2) Procedures
DROP PROCEDURE IF EXISTS aprovar_ferias_proc(INT, DATE);
DROP PROCEDURE IF EXISTS adicionar_candidatura_proc(INT, INT, INT);
DROP PROCEDURE IF EXISTS adicionar_uma_formacao(INT, VARCHAR, VARCHAR, DATE, DATE, VARCHAR);
DROP PROCEDURE IF EXISTS adicionar_avaliacao(INT, INT, DATE, BYTEA, VARCHAR, VARCHAR);
DROP PROCEDURE IF EXISTS adicionar_funcionario_proc(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, INT);

-- 3) Functions (inclui funções de trigger)
DROP FUNCTION IF EXISTS calc_salario_liquido();
DROP FUNCTION IF EXISTS validar_dias_ferias();
DROP FUNCTION IF EXISTS registrar_mudanca_cargo();
DROP FUNCTION IF EXISTS validar_idade_funcionario();
DROP FUNCTION IF EXISTS cria_utilizador();
DROP FUNCTION IF EXISTS delete_permissoes();
DROP FUNCTION IF EXISTS calcular_num_total_funcionarios(INT);
DROP FUNCTION IF EXISTS calcular_num_funcionarios_departamento(INT);
DROP FUNCTION IF EXISTS calcular_num_aderentes_formacao(INT);
DROP FUNCTION IF EXISTS calc_idade(DATE);
DROP FUNCTION IF EXISTS calcular_num_dias_ferias();
DROP FUNCTION IF EXISTS calcular_total_dias_permitidos(INT);
DROP FUNCTION IF EXISTS descontos(NUMERIC);

-- 4) Views
DROP VIEW IF EXISTS vw_funcionarios_departamentos;  
DROP VIEW IF EXISTS vw_ferias_aprovadas;
DROP VIEW IF EXISTS vw_media_salarial_departamento;
DROP VIEW IF EXISTS vw_formacoes_funcionarios;
DROP VIEW IF EXISTS vw_vagas_candidatos;
DROP VIEW IF EXISTS vw_estatisticas_gerais;
DROP VIEW IF EXISTS vw_remun_completa;
