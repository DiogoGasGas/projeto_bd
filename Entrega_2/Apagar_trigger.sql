SET search_path TO bd054_schema, public;

-- 1) Triggers
DROP TRIGGER IF EXISTS trg_calc_salario_liquido ON bd054_schema.salario;
DROP TRIGGER IF EXISTS trg_validar_dias_ferias ON bd054_schema.ferias;
DROP TRIGGER IF EXISTS trg_registrar_mudanca_cargo ON bd054_schema.funcionarios;
DROP TRIGGER IF EXISTS trg_validar_idade_funcionario ON bd054_schema.funcionarios;
DROP TRIGGER IF EXISTS trg_cria_utilizador ON bd054_schema.funcionarios;
DROP TRIGGER IF EXISTS trg_delete_permissoes ON bd054_schema.funcionarios;

-- 2) Procedures
DROP PROCEDURE IF EXISTS bd054_schema.aprovar_ferias_proc(INT, DATE);
DROP PROCEDURE IF EXISTS bd054_schema.adicionar_candidatura_proc(INT, INT, INT);
DROP PROCEDURE IF EXISTS bd054_schema.adicionar_uma_formacao(INT, VARCHAR, VARCHAR, DATE, DATE, VARCHAR);
DROP PROCEDURE IF EXISTS bd054_schema.adicionar_avaliacao(INT, INT, DATE, BYTEA, VARCHAR, VARCHAR);
DROP PROCEDURE IF EXISTS bd054_schema.adicionar_funcionario_proc(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, INT);

-- 3) Functions (inclui funções de trigger)
DROP FUNCTION IF EXISTS bd054_schema.calc_salario_liquido();
DROP FUNCTION IF EXISTS bd054_schema.validar_dias_ferias();
DROP FUNCTION IF EXISTS bd054_schema.registrar_mudanca_cargo();
DROP FUNCTION IF EXISTS bd054_schema.validar_idade_funcionario();
DROP FUNCTION IF EXISTS bd054_schema.cria_utilizador();
DROP FUNCTION IF EXISTS bd054_schema.delete_permissoes();

DROP FUNCTION IF EXISTS bd054_schema.calcular_num_total_funcionarios(INT);
DROP FUNCTION IF EXISTS bd054_schema.calcular_num_funcionarios_departamento(INT);
DROP FUNCTION IF EXISTS bd054_schema.calcular_num_aderentes_formacao(INT);
DROP FUNCTION IF EXISTS bd054_schema.calc_idade(DATE);
DROP FUNCTION IF EXISTS bd054_schema.calcular_num_dias_ferias(INT, DATE, DATE);
DROP FUNCTION IF EXISTS bd054_schema.calcular_total_dias_permitidos(INT);
