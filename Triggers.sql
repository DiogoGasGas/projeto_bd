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










