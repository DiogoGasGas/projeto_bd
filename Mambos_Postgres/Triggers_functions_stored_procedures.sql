--Triggers

CREATE OR REPLACE FUNCTION calc_num_dias_ferias()
RETURNS TRIGGER AS $$
BEGIN
    NEW.num_dias := NEW.data_fim - NEW.data_inicio;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calc_num_dias_ferias
BEFORE INSERT ON ferias
FOR EACH ROW
EXECUTE FUNCTION calc_num_dias_ferias();








CREATE OR REPLACE FUNCTION cria_utilizador()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO utilizadores (id_fun, password)
    VALUES (NEW.id_fun, 'password_temporaria');
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cria_utilizador
AFTER INSERT ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION cria_utilizador();










CREATE OR REPLACE FUNCTION delete_permissoes()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM permissoes WHERE id_fun = OLD.id_fun;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_delete_permissoes
AFTER DELETE ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION delete_permissoes();






ALTER TABLE departamentos ADD COLUMN num_funcionarios INT DEFAULT 0;

CREATE OR REPLACE FUNCTION incrementa_funcionarios()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_depart IS NOT NULL THEN
        UPDATE departamentos
        SET num_funcionarios = num_funcionarios + 1
        WHERE id_depart = NEW.id_depart;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_incrementa_funcionarios
AFTER INSERT ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION incrementa_funcionarios();



set search_path to bd054_schema, public;

CREATE OR REPLACE FUNCTION incrementa_funcionarios()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_depart IS NOT NULL THEN
        UPDATE departamentos
        SET num_funcionarios = num_funcionarios + 1
        WHERE id_depart = NEW.id_depart;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_incrementa_funcionarios
AFTER INSERT ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION incrementa_funcionarios();


set search_path to bd054_schema, public;


ALTER TABLE vagas ADD COLUMN num_candidatos INT DEFAULT 0;

CREATE OR REPLACE FUNCTION update_num_candidatos()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE vagas
    SET num_candidatos = num_candidatos + 1
    WHERE id_vaga = NEW.id_vaga;

    UPDATE vagas
    SET estado = 'Fechada'
    WHERE id_vaga = NEW.id_vaga AND num_candidatos >= 10;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_num_candidatos
AFTER INSERT ON candidato_a
FOR EACH ROW
EXECUTE FUNCTION update_num_candidatos();





CREATE OR REPLACE FUNCTION decrease_num_candidatos()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE vagas
    SET num_candidatos = CASE 
        WHEN num_candidatos > 0 THEN num_candidatos - 1
        ELSE 0 
    END
    WHERE id_vaga = OLD.id_vaga;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_decrease_num_candidatos
AFTER DELETE ON candidato_a
FOR EACH ROW
EXECUTE FUNCTION decrease_num_candidatos();




-- Functions

set search_path TO bd054_schema, public;
CREATE OR REPLACE FUNCTION calc_idade(data_nascimento DATE)
RETURNS INT AS $$
DECLARE
    idade INT;
BEGIN
    idade := DATE_PART('year', AGE(CURRENT_DATE, data_nascimento));
    RETURN idade;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION calcular_num_dias_ferias(p_id_fun INT, data_inicio DATE, data_fim DATE)
RETURNS INT AS $$
DECLARE
    v_num_dias_ferias INT;
BEGIN
    IF data_fim < data_inicio THEN
    RAISE EXCEPTION 'Data de fim (%) não pode ser anterior à data de início (%)', data_fim, data_inicio;
END IF;

    v_num_dias_ferias := data_fim - data_inicio +1;
-- insere-se o +1 para contar o dia de início como dia de férias
    RETURN v_num_dias_ferias;
END;
$$ LANGUAGE plpgsql;
    







set search_path to bd054_schema, public;
CREATE OR REPLACE FUNCTION calcular_total_dias_permitidos(p_id_fun INT)
RETURNS INT AS $$
DECLARE
    v_data_entrada DATE;
    v_meses_trabalhados INT;
    v_dias_tirados INT;
    v_total_dias_permitidos INT;
BEGIN
    -- Pega a ultima data de entrada que o funciona´rio já teve numa empresa que é a data de entrada nesta empresa
    SELECT MAX(data_inicio)
    INTO v_data_entrada
    FROM historico_empresas
    WHERE id_fun = p_id_fun;

    IF v_data_entrada IS NULL THEN
        RAISE EXCEPTION 'Funcionário % não tem histórico de entrada', p_id_fun;
    END IF;

    -- Calcular meses trabalhados desde a data de entrada
    v_meses_trabalhados := (DATE_PART('year', CURRENT_DATE) - DATE_PART('year', v_data_entrada)) * 12
                          + (DATE_PART('month', CURRENT_DATE) - DATE_PART('month', v_data_entrada));

    -- Dias de férias já tirados
    SELECT COALESCE(SUM(calcular_num_dias_ferias(id_fun, data_inicio, data_fim)), 0)
    INTO v_dias_tirados
    FROM ferias
    WHERE id_fun = p_id_fun
      AND estado_aprov = 'Aprovado';

    -- Total de dias permitidos para o funcionário tirar
    v_total_dias_permitidos := v_meses_trabalhados * 2 - v_dias_tirados;

    IF v_total_dias_permitidos < 0 THEN
        v_total_dias_permitidos := 0;
    END IF;

    RETURN v_total_dias_permitidos;
END;
$$ LANGUAGE plpgsql;



-- procedures

CREATE OR REPLACE PROCEDURE aprovar_ferias_proc(p_id_fun INT, p_data_inicio DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ferias
    SET estado_aprov = 'Aprovado'
    WHERE id_fun = p_id_fun AND data_inicio = p_data_inicio;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Férias não encontradas para o funcionário % na data %', p_id_fun, p_data_inicio;
    END IF;
END;
$$;



set search_path to bd054_schema, public;
CREATE OR REPLACE PROCEDURE adicionar_candidatura_proc(
    p_id_cand INT, 
    p_id_vaga INT, 
    p_id_recrutador INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO candidato_a(id_cand, id_vaga, id_recrutador)
    VALUES (p_id_cand, p_id_vaga, p_id_recrutador);
END;
$$;


set search_path to bd054_schema, public;
CREATE OR REPLACE PROCEDURE adicionar_uma_formacao(
    p_id_for INT,
    p_nome_formacao VARCHAR,
    p_descricao_formacao VARCHAR,
    p_data_inicio DATE,
    p_data_fim DATE,
    p_estado VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_estado NOT IN ('Planeada', 'Em curso', 'Concluida', 'Cancelada') THEN
        RAISE EXCEPTION 'Estado inválido: %', p_estado;
    END IF;

    -- Validação das datas
    IF p_data_fim IS NOT NULL AND p_data_fim <= p_data_inicio THEN
        RAISE EXCEPTION 'Data de fim (%) deve ser maior que data de início (%)', p_data_fim, p_data_inicio;
    END IF;
    INSERT INTO formacoes(id_for, nome_formacao, descricao_formacao, data_inicio, data_fim, estado)
    VALUES (p_id_for, p_nome_formacao, p_descricao_formacao, p_data_inicio, p_data_fim, p_estado);
END;
$$;




set search_path to bd054_schema, public;
drop procedure adicionar_avaliacao;



set search_path to bd054_schema, public;

CREATE OR REPLACE PROCEDURE adicionar_avaliacao(
    p_id_fun INT,
    p_id_av INT,
    p_data DATE,
    p_avaliacao BYTEA,
    p_criterios VARCHAR,
    p_autoavaliacao varchar 
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM funcionarios WHERE id_fun = p_id_fun) THEN
    RAISE EXCEPTION 'O funcionário com id_fun % já existe', p_id_fun;
    END IF;
    IF data IS NOT NULL and data > CURRENT_DATE THEN
        RAISE EXCEPTION 'A data da avaliação (%) não pode ser no futuro', p_data;
    END IF;


    INSERT INTO avaliacoes(id_fun, id_av, data, avaliacao, criterios, autoavaliacao)
    VALUES (p_id_fun, p_id_av, p_data, p_avaliacao, p_criterios, p_autoavaliacao);
END;
$$;

set search_path to bd054_schema, public;
CREATE OR REPLACE PROCEDURE adicionar_funcionario_proc(
    p_nif VARCHAR,
    p_primeiro_nome VARCHAR,
    p_ultimo_nome VARCHAR,
    p_nome_rua VARCHAR,
    p_nome_localidade VARCHAR,
    p_codigo_postal VARCHAR,
    p_num_telemovel VARCHAR,
    p_email VARCHAR,
    p_data_nascimento DATE,
    p_cargo VARCHAR,
    p_id_depart INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funcionarios(
        nif, primeiro_nome, ultimo_nome, nome_rua, nome_localidade,
        codigo_postal, num_telemovel, email, data_nascimento, cargo, id_depart
    )
    VALUES (
        p_nif, p_primeiro_nome, p_ultimo_nome, p_nome_rua, p_nome_localidade,
        p_codigo_postal, p_num_telemovel, p_email, p_data_nascimento, p_cargo, p_id_depart
    );
END;
$$;















