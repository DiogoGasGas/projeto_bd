set search_path to bd054_schema, public;




-- triggers




-- Trigger que calcula o numero o numero de dias de ferias automaticamente
-- Tem que ser rodado antes do trigger de validar dias de ferias
CREATE OR REPLACE FUNCTION calcular_num_dias_ferias()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se as datas são válidas
    IF NEW.data_fim < NEW.data_inicio THEN
        RAISE EXCEPTION 
            'A data de fim (%) não pode ser anterior à data de início (%)',
            NEW.data_fim, NEW.data_inicio;
    END IF;

    -- Calcula o número de dias de férias automaticamente
    NEW.num_dias := NEW.data_fim - NEW.data_inicio + 1;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado 
CREATE TRIGGER trg_calcular_num_dias_ferias
BEFORE INSERT OR UPDATE ON ferias
FOR EACH ROW
EXECUTE FUNCTION calcular_num_dias_ferias();



--- trigger para validar dias de ferias
set search_path TO bd054_schema, public;
CREATE OR REPLACE FUNCTION validar_dias_ferias()
RETURNS TRIGGER AS $$
DECLARE
    v_dias_permitidos INT;
BEGIN
    -- Usa a função correta que calcula o total de dias permitidos
    v_dias_permitidos := calcular_total_dias_permitidos(NEW.id_fun);

    -- Verifica se o funcionário está a tentar tirar mais dias do que tem direito
    IF NEW.num_dias > v_dias_permitidos THEN
        RAISE EXCEPTION 
            'O funcionário % não pode tirar % dias, máximo permitido é %', 
            NEW.id_fun, NEW.num_dias, v_dias_permitidos;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_dias_ferias
BEFORE INSERT OR UPDATE ON ferias
FOR EACH ROW
EXECUTE FUNCTION validar_dias_ferias();






--- trigger para calcular salario liquido

CREATE OR REPLACE FUNCTION calc_salario_liquido()
RETURNS TRIGGER AS $$
DECLARE
    v_descontos NUMERIC;
    v_salario_liquido NUMERIC;
BEGIN
    -- Chama a função que calcula os descontos
    v_descontos := descontos(NEW.salario_bruto);

    -- Calcula o salário líquido
    v_salario_liquido := NEW.salario_bruto - v_descontos;

    -- Evita salário líquido negativo
    IF v_salario_liquido < 0 THEN
        RAISE EXCEPTION 
            'O salário líquido não pode ser negativo: bruto=%, descontos=%', 
            NEW.salario_bruto, v_descontos;
    END IF;

    -- Atualiza o campo da nova linha
    NEW.salario_liquido := v_salario_liquido;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado

CREATE TRIGGER trg_calc_salario_liquido
BEFORE INSERT OR UPDATE ON salario
FOR EACH ROW
EXECUTE FUNCTION calc_salario_liquido();









--- trigger para registar mudanca de cargo no historico_empresas

CREATE OR REPLACE FUNCTION registrar_mudanca_cargo()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o cargo foi alterado
    IF OLD.cargo IS DISTINCT FROM NEW.cargo THEN
        -- Regista a mudança na tabela de histórico
        INSERT INTO historico_empresas (id_fun, nome_empresa, nome_departamento, cargo, data_inicio, data_fim)
        VALUES (NEW.id_fun, 'Empresa Atual', 'Departamento Atual', NEW.cargo, CURRENT_DATE, NULL);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado à função
CREATE TRIGGER trg_registrar_mudanca_cargo
AFTER UPDATE ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION registrar_mudanca_cargo();









-- Trigger que impede de inserir funcionários com menos de 16 anos
CREATE OR REPLACE FUNCTION validar_idade_funcionario()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica a idade mínima
    IF NEW.data_nascimento > CURRENT_DATE - INTERVAL '16 years' THEN
        RAISE EXCEPTION 
            'O funcionário % tem idade inferior a 16 anos', 
            NEW.primeiro_nome || ' ' || NEW.ultimo_nome;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado
CREATE TRIGGER trg_validar_idade_funcionario
BEFORE INSERT ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION validar_idade_funcionario();





-- Trigger que cria automaticamente um utilizador ao inserir um funcionário
CREATE OR REPLACE FUNCTION cria_utilizador()
RETURNS TRIGGER AS $$
BEGIN
    -- Insere o novo utilizador com password temporária
    INSERT INTO utilizadores (id_fun, password)
    VALUES (NEW.id_fun, 'password_temporaria');
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado
CREATE TRIGGER trg_cria_utilizador
AFTER INSERT ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION cria_utilizador();
-- Elimina as permissões associadas ao funcionário ao apagar o funcionário





-- Trigger que remove permissões associadas a um funcionário eliminado
CREATE OR REPLACE FUNCTION delete_permissoes()
RETURNS TRIGGER AS $$
BEGIN
    -- Apaga as permissões do funcionário removido
    DELETE FROM permissoes WHERE id_fun = OLD.id_fun;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado
CREATE TRIGGER trg_delete_permissoes
AFTER DELETE ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION delete_permissoes();
-- trigger para calcular num dias ferias








-- Trigger que valida a coerência das datas entre pais e dependentes
CREATE OR REPLACE FUNCTION validar_datas_dependentes()
RETURNS TRIGGER AS $$
DECLARE
    v_data_pai DATE;  -- Guarda a data de nascimento do pai/mãe
BEGIN
    -- Obtém a data de nascimento do pai/mãe a partir da tabela 'funcionarios'
    SELECT data_nascimento INTO v_data_pai
    FROM funcionarios
    WHERE id_fun = NEW.id_pai;

    -- Verifica se o pai/mãe é mais novo ou tem a mesma idade que o dependente
    IF v_data_pai >= NEW.data_nascimento THEN
        RAISE EXCEPTION 
            'O pai/mãe não pode ser mais novo que o dependente (ID %)', NEW.id_pai;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado
CREATE TRIGGER trg_validar_datas_dependentes
BEFORE INSERT OR UPDATE ON dependentes
FOR EACH ROW
EXECUTE FUNCTION validar_datas_dependentes();




-- Trigger que valida as datas de início e fim na tabela 'remuneracoes'
CREATE OR REPLACE FUNCTION validar_datas_remuneracoes()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se a data de início vem antes da data de fim
    IF NEW.data_inicio >= NEW.data_fim THEN
        RAISE EXCEPTION 
            'A data de início (%) deve ser anterior à data de fim (%)',
            NEW.data_inicio, NEW.data_fim;
    END IF;

    -- Garante que a data de início não está no futuro
    IF NEW.data_inicio > CURRENT_DATE THEN
        RAISE EXCEPTION 
            'A data de início (%) não pode ser no futuro', NEW.data_inicio;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado
CREATE TRIGGER trg_validar_datas_remuneracoes
BEFORE INSERT OR UPDATE ON remuneracoes
FOR EACH ROW
EXECUTE FUNCTION validar_datas_remuneracoes();











-- functions

-- Função para calcular o total de dias de férias permitidos para um funcionário

CREATE OR REPLACE FUNCTION calcular_total_dias_permitidos(p_id_fun INT)
RETURNS INT AS $$
DECLARE
    v_data_entrada DATE;
    v_meses_trabalhados INT;
    v_dias_tirados INT;
    v_total_dias_permitidos INT;
BEGIN
    -- Obter a data de entrada mais recente do funcionário
    SELECT MAX(data_inicio)
    INTO v_data_entrada
    FROM historico_empresas
    WHERE id_fun = p_id_fun;

    IF v_data_entrada IS NULL THEN
        RAISE EXCEPTION 'Funcionário % não tem histórico de entrada.', p_id_fun;
    END IF;

    -- Calcular meses trabalhados desde a data de entrada, assumindo meses complestos em vez dos 22 dias.
    v_meses_trabalhados := 
        (DATE_PART('year', CURRENT_DATE) - DATE_PART('year', v_data_entrada)) * 12
        + (DATE_PART('month', CURRENT_DATE) - DATE_PART('month', v_data_entrada));

    -- Calcular total de dias de férias já tirados (apenas os aprovados)
    SELECT COALESCE(SUM(data_fim - data_inicio + 1), 0)
    INTO v_dias_tirados
    FROM ferias
    WHERE id_fun = p_id_fun
      AND estado_aprov = 'Aprovado';

    -- Cada mês trabalhado dá direito a 2 dias de férias
    v_total_dias_permitidos := v_meses_trabalhados * 2 - v_dias_tirados;

    -- Garante que não dá negativo
    IF v_total_dias_permitidos < 0 THEN
        v_total_dias_permitidos := 0;
    END IF;

    RETURN v_total_dias_permitidos;
END;
$$ LANGUAGE plpgsql;





-- Função para calcular o total de descontos sobre o salário bruto
CREATE OR REPLACE FUNCTION descontos(p_salario_bruto NUMERIC)
RETURNS NUMERIC AS $$
DECLARE
    v_descontos NUMERIC;  -- Guarda o valor total dos descontos
BEGIN
    -- Aplica uma taxa de 11% de Segurança Social e 12% de IRS
    v_descontos := p_salario_bruto * (0.11 + 0.12);

    -- Retorna o valor total dos descontos calculado
    RETURN v_descontos;
END;
$$ LANGUAGE plpgsql;








-- Função que calcula o número total de funcionários na base de dados
CREATE OR REPLACE FUNCTION calcular_num_total_funcionarios()
RETURNS INT AS $$
DECLARE
    v_num_total_funcionarios INT;  -- Guarda o total de funcionários
BEGIN
    -- Conta todos os registos na tabela 'funcionarios'
    SELECT COUNT(*) INTO v_num_total_funcionarios
    FROM funcionarios;

    -- Retorna o total calculado
    RETURN v_num_total_funcionarios;
END;
$$ LANGUAGE plpgsql;




-- Função que calcula o número de funcionários de um determinado departamento
CREATE OR REPLACE FUNCTION calcular_num_funcionarios_departamento(p_id_depart INT)
RETURNS INT AS $$
DECLARE
    v_num_funcionarios_departamento INT;  -- Guarda o total de funcionários do departamento
BEGIN
    -- Conta quantos funcionários pertencem ao departamento indicado
    SELECT COUNT(*) INTO v_num_funcionarios_departamento
    FROM funcionarios
    WHERE id_depart = p_id_depart;

    -- Retorna o total calculado
    RETURN v_num_funcionarios_departamento;
END;
$$ LANGUAGE plpgsql;








-- Função que calcula o número de funcionários que aderiram a uma formação
CREATE OR REPLACE FUNCTION calcular_num_aderentes_formacao(p_id_for INT)
RETURNS INT AS $$
DECLARE
    v_num_aderentes_formacao INT;  -- Guarda o total de aderentes
BEGIN
    -- Conta quantos funcionários participaram na formação indicada
    SELECT COUNT(*) INTO v_num_aderentes_formacao
    FROM teve_formacao
    WHERE id_for = p_id_for;

    -- Retorna o total calculado
    RETURN v_num_aderentes_formacao;
END;
$$ LANGUAGE plpgsql;







-- Função que calcula a idade de uma pessoa com base na data de nascimento
CREATE OR REPLACE FUNCTION calc_idade(data_nascimento DATE)
RETURNS INT AS $$
DECLARE
    idade INT;  -- Guarda o valor da idade calculada
BEGIN
    -- Calcula a diferença em anos entre a data atual e a data de nascimento
    idade := DATE_PART('year', AGE(CURRENT_DATE, data_nascimento));

    -- Retorna a idade
    RETURN idade;
END;
$$ LANGUAGE plpgsql;



    







-- procedures

-- Procedimento armazenado que aprova um pedido de férias específico
CREATE OR REPLACE PROCEDURE aprovar_ferias_proc(p_id_fun INT, p_data_inicio DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Atualiza o estado das férias para 'Aprovado'
    UPDATE ferias
    SET estado_aprov = 'Aprovado'
    WHERE id_fun = p_id_fun AND data_inicio = p_data_inicio;

    -- Caso não exista um registo correspondente, lança uma exceção
    IF NOT FOUND THEN
        RAISE EXCEPTION 
            'Férias não encontradas para o funcionário % na data %', 
            p_id_fun, p_data_inicio;
    END IF;
END;
$$;



-- Procedimento armazenado que adiciona uma nova candidatura a uma vaga
CREATE OR REPLACE PROCEDURE adicionar_candidatura_proc(
    p_id_cand INT,          -- ID do candidato
    p_id_vaga INT,          -- ID da vaga
    p_id_recrutador INT DEFAULT NULL  -- ID opcional do recrutador
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insere uma nova candidatura na tabela 'candidato_a'
    INSERT INTO candidato_a(id_cand, id_vaga, id_recrutador)
    VALUES (p_id_cand, p_id_vaga, p_id_recrutador);
END;
$$;



--  Procedimento que adiciona uma nova formação
CREATE OR REPLACE PROCEDURE adicionar_uma_formacao(
    p_id_for INT,                   -- ID da formação
    p_nome_formacao VARCHAR,        -- Nome da formação
    p_descricao_formacao VARCHAR,   -- Descrição da formação
    p_data_inicio DATE,             -- Data de início
    p_data_fim DATE,                -- Data de fim
    p_estado VARCHAR                -- Estado da formação
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verifica se o estado é válido
    IF p_estado NOT IN ('Planeada', 'Em curso', 'Concluida', 'Cancelada') THEN
        RAISE EXCEPTION 'Estado inválido: %', p_estado;
    END IF;

    -- Valida se a data de fim é posterior à data de início
    IF p_data_fim IS NOT NULL AND p_data_fim <= p_data_inicio THEN
        RAISE EXCEPTION 'Data de fim (%) deve ser maior que data de início (%)', p_data_fim, p_data_inicio;
    END IF;

    -- Insere a formação na tabela
    INSERT INTO formacoes(id_for, nome_formacao, descricao_formacao, data_inicio, data_fim, estado)
    VALUES (p_id_for, p_nome_formacao, p_descricao_formacao, p_data_inicio, p_data_fim, p_estado);
END;
$$;







--  Procedimento que adiciona uma nova avaliação de funcionário
CREATE OR REPLACE PROCEDURE adicionar_avaliacao(
    p_id_fun INT,          -- ID do funcionário
    p_id_av INT,           -- ID da avaliação
    p_data DATE,           -- Data da avaliação
    p_avaliacao BYTEA,     -- Documento da avaliação
    p_criterios VARCHAR,   -- Critérios usados
    p_autoavaliacao VARCHAR -- Autoavaliação do funcionário
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Valida se a data não é futura
    IF p_data IS NOT NULL AND p_data > CURRENT_DATE THEN
        RAISE EXCEPTION 'A data da avaliação (%) não pode ser no futuro', p_data;
    END IF;

    -- Insere a nova avaliação na tabela
    INSERT INTO avaliacoes(id_fun, id_av, data, avaliacao, criterios, autoavaliacao)
    VALUES (p_id_fun, p_id_av, p_data, p_avaliacao, p_criterios, p_autoavaliacao);
END;
$$;






--  Procedimento que adiciona um novo funcionário
CREATE OR REPLACE PROCEDURE adicionar_funcionario_proc(
    p_nif VARCHAR,              -- NIF do funcionário
    p_primeiro_nome VARCHAR,    -- Primeiro nome
    p_ultimo_nome VARCHAR,      -- Último nome
    p_nome_rua VARCHAR,         -- Rua
    p_nome_localidade VARCHAR,  -- Localidade
    p_codigo_postal VARCHAR,    -- Código postal
    p_num_telemovel VARCHAR,    -- Telemóvel
    p_email VARCHAR,            -- Email
    p_data_nascimento DATE,     -- Data de nascimento
    p_cargo VARCHAR,            -- Cargo
    p_id_depart INT             -- ID do departamento
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM funcionarios WHERE nif = p_nif) THEN
    RAISE EXCEPTION 'Já existe um funcionário com o NIF %', p_nif;
    END IF;

    -- Insere um novo funcionário na tabela
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












-- views



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
