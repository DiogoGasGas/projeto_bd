-- Mariana eu tirei estas cenas porque tava a dar merda. Mas acho que sei o que era hoje podemos ver isso.

set search_path to bd054_schema, public;

CREATE OR REPLACE FUNCTION validar_dias_ferias()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.num_dias > NEW.num_dias_permitidos THEN
        RAISE EXCEPTION 'O funcionário % não pode tirar % dias, máximo permitido é %', 
            NEW.id_fun, NEW.num_dias, NEW.num_dias_permitidos;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_dias_ferias
BEFORE INSERT OR UPDATE ON ferias
FOR EACH ROW
EXECUTE FUNCTION validar_dias_ferias();



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