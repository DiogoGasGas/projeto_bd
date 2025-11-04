-- DROP ALL TRIGGERS
DROP TRIGGER IF EXISTS trg_calc_num_dias_ferias ON ferias;
DROP TRIGGER IF EXISTS trg_cria_utilizador ON funcionarios;
DROP TRIGGER IF EXISTS trg_delete_permissoes ON funcionarios;
DROP TRIGGER IF EXISTS trg_incrementa_funcionarios ON funcionarios;
DROP TRIGGER IF EXISTS trg_update_num_candidatos ON candidato_a;
DROP TRIGGER IF EXISTS trg_decrease_num_candidatos ON candidato_a;

-- DROP ALL TRIGGER FUNCTIONS
DROP FUNCTION IF EXISTS calc_num_dias_ferias() CASCADE;
DROP FUNCTION IF EXISTS cria_utilizador() CASCADE;
DROP FUNCTION IF EXISTS delete_permissoes() CASCADE;
DROP FUNCTION IF EXISTS incrementa_funcionarios() CASCADE;
DROP FUNCTION IF EXISTS update_num_candidatos() CASCADE;
DROP FUNCTION IF EXISTS decrease_num_candidatos() CASCADE;

-- DROP ALL OTHER FUNCTIONS
DROP FUNCTION IF EXISTS calc_idade(DATE) CASCADE;
DROP FUNCTION IF EXISTS calcular_num_dias_ferias(INT, DATE, DATE) CASCADE;
DROP FUNCTION IF EXISTS calcular_total_dias_permitidos(INT) CASCADE;

-- DROP ALL PROCEDURES
DROP PROCEDURE IF EXISTS aprovar_ferias_proc(INT, DATE) CASCADE;
DROP PROCEDURE IF EXISTS adicionar_candidatura_proc(INT, INT, INT) CASCADE;
DROP PROCEDURE IF EXISTS adicionar_uma_formacao(INT, VARCHAR, VARCHAR, DATE, DATE, VARCHAR) CASCADE;
DROP PROCEDURE IF EXISTS adicionar_avaliacao(INT, INT, DATE, BYTEA, VARCHAR, VARCHAR) CASCADE;
DROP PROCEDURE IF EXISTS adicionar_funcionario_proc(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, INT) CASCADE;
