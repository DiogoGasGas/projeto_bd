CREATE TRIGGER trg_calc_salario_liquido
BEFORE INSERT ON Salario
FOR EACH ROW
BEGIN
    SET NEW.salario_liquido = NEW.salario_bruto - NEW.descontos;
END;

-- Antes dos dados serem registados na tabela, a base de dados já sabe os novos valores de salario_bruto e dos descontos portanto antes de os registar vai calcular o novo salario_líquido 

CREATE TRIGGER trg_calc_num_dias_ferias
BEFORE INSERT ON Ferias
FOR EACH ROW
BEGIN
    SET NEW.num_dias = JULIANDAY(NEW.data_fim) - JULIANDAY(NEW.data_inicio);
END;

-- Antes de inserir os valores para a data_fim e data_inicio vai calcular o numero de ferias que foi pedido

CREATE TRIGGER trg_cria_utilizador
AFTER INSERT ON Funcionarios
FOR EACH ROW
BEGIN
    INSERT INTO Utilizadores (ID_Fun, Password)
    VALUES (NEW.ID_fun, 'password_temporaria');
END;


CREATE TRIGGER trg_data_registo
BEFORE INSERT ON Funcionarios
FOR EACH ROW
BEGIN
    SET NEW.data_registo = DATE('now');
END;


CREATE TRIGGER trg_calc_idade
BEFORE INSERT ON Funcionarios
FOR EACH ROW
BEGIN
    SET NEW.idade = EXTRACT(YEAR FROM AGE(CURRENT_DATE, NEW.data_nascimento));
END;

-- Extract Year e Age só existem em postgres para sqlite seria strftime e mais esquisito.


CREATE TRIGGER trg_delete_permissoes
AFTER DELETE ON Funcionarios
FOR EACH ROW
BEGIN
    DELETE FROM Permissoes WHERE ID_fun = OLD.ID_fun;
END;

-- old.id_fun  significa id fun associado ao funcionario que acabou de ser apagado, este trigger tira as permissoes desse funcionario assim que ele for eliminado

CREATE TRIGGER trg_update_num_candidatos
AFTER INSERT ON Candidato_a
FOR EACH ROW
BEGIN
    UPDATE Vagas
    SET num_candidatos = num_candidatos + 1
    WHERE ID_vaga = NEW.ID_vaga;
END;

-- se houver mais um candidato para aquela vaga, então o num_candidatos sobe 1 valor e vai muudar na linha da vaga que tem o id da vaga que houve mudança (new.id_vaga)

CREATE TRIGGER trg_decrease_num_candidatos
AFTER DELETE ON Candidato_a
FOR EACH ROW
BEGIN
    UPDATE Vagas
    SET num_candidatos = num_candidatos - 1
    WHERE ID_vaga = OLD.ID_vaga;
END;

-- faz o contrário para ficar mais completo

ALTER TABLE Departamentos ADD COLUMN num_funcionarios INT DEFAULT 0;

-- Quando entra um funcionário
CREATE TRIGGER trg_incrementa_funcionarios
AFTER INSERT ON Funcionarios
FOR EACH ROW
WHEN NEW.ID_depart IS NOT NULL
BEGIN
    UPDATE Departamentos
    SET num_funcionarios = num_funcionarios + 1
    WHERE ID_depart = NEW.ID_depart;
END;












POSTGRE:
CREATE OR REPLACE FUNCTION fn_calc_salario_liquido()
RETURNS TRIGGER AS $$
BEGIN
    NEW.salario_liquido := NEW.salario_bruto - NEW.descontos;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER trg_calc_salario_liquido
BEFORE INSERT ON Salario
FOR EACH ROW
EXECUTE FUNCTION fn_calc_salario_liquido();







CREATE OR REPLACE FUNCTION fn_calc_num_dias_ferias()
RETURNS TRIGGER AS $$
BEGIN
    NEW.num_dias := (NEW.data_fim - NEW.data_inicio);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calc_num_dias_ferias
BEFORE INSERT ON Ferias
FOR EACH ROW
EXECUTE FUNCTION fn_calc_num_dias_ferias();





CREATE OR REPLACE FUNCTION fn_cria_utilizador()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Utilizadores (ID_Fun, Password)
    VALUES (NEW.ID_fun, 'password_temporaria');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cria_utilizador
AFTER INSERT ON Funcionarios
FOR EACH ROW
EXECUTE FUNCTION fn_cria_utilizador();





ALTER TABLE Funcionarios ADD COLUMN data_registo DATE;

CREATE OR REPLACE FUNCTION fn_data_registo()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_registo := CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_data_registo
BEFORE INSERT ON Funcionarios
FOR EACH ROW
EXECUTE FUNCTION fn_data_registo();





ALTER TABLE Funcionarios ADD COLUMN idade INT;

CREATE OR REPLACE FUNCTION fn_calc_idade()
RETURNS TRIGGER AS $$
BEGIN
    NEW.idade := EXTRACT(YEAR FROM AGE(CURRENT_DATE, NEW.data_nascimento));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calc_idade
BEFORE INSERT ON Funcionarios
FOR EACH ROW
EXECUTE FUNCTION fn_calc_idade();




CREATE OR REPLACE FUNCTION fn_delete_permissoes()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM Permissoes WHERE ID_fun = OLD.ID_fun;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_delete_permissoes
AFTER DELETE ON Funcionarios
FOR EACH ROW
EXECUTE FUNCTION fn_delete_permissoes();





ALTER TABLE Vagas ADD COLUMN num_candidatos INT DEFAULT 0;

CREATE OR REPLACE FUNCTION fn_update_num_candidatos()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Vagas
    SET num_candidatos = num_candidatos + 1
    WHERE ID_vaga = NEW.ID_vaga;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_num_candidatos
AFTER INSERT ON Candidato_a
FOR EACH ROW
EXECUTE FUNCTION fn_update_num_candidatos();



CREATE TRIGGER trg_decrementa_funcionarios
AFTER DELETE ON Funcionarios
FOR EACH ROW
WHEN OLD.ID_depart IS NOT NULL
BEGIN
    UPDATE Departamentos
    SET num_funcionarios = CASE 
        WHEN num_funcionarios > 0 THEN num_funcionarios - 1 
        ELSE 0 
    END
    WHERE ID_depart = OLD.ID_depart;
END;

-- Primeiro adiciona a coluna num_candidatos
ALTER TABLE Vagas ADD COLUMN num_candidatos INT DEFAULT 0;

-- Sempre que entra candidato
CREATE TRIGGER trg_update_num_candidatos
AFTER INSERT ON Candidato_a
FOR EACH ROW
BEGIN
    UPDATE Vagas
    SET num_candidatos = num_candidatos + 1
    WHERE ID_vaga = NEW.ID_vaga;

    UPDATE Vagas
    SET Estado = 'Fechada'
    WHERE ID_vaga = NEW.ID_vaga AND num_candidatos >= 10;
END;

-- Sempre que sai candidato
CREATE TRIGGER trg_decrease_num_candidatos
AFTER DELETE ON Candidato_a
FOR EACH ROW
BEGIN
    UPDATE Vagas
    SET num_candidatos = CASE 
        WHEN num_candidatos > 0 THEN num_candidatos - 1 
        ELSE 0 
    END
    WHERE ID_vaga = OLD.ID_vaga;
END;







CREATE OR REPLACE FUNCTION fn_decrease_num_candidatos()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Vagas
    SET num_candidatos = GREATEST(num_candidatos - 1, 0)
    WHERE ID_vaga = OLD.ID_vaga;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_decrease_num_candidatos
AFTER DELETE ON Candidato_a
FOR EACH ROW
EXECUTE FUNCTION fn_decrease_num_candidatos();





