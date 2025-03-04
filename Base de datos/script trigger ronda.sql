DELIMITER //
CREATE TRIGGER before_ronda_insert
BEFORE INSERT ON Ronda
FOR EACH ROW
BEGIN
    SET NEW.num_ronda = (
        SELECT COALESCE(MAX(num_ronda), 0) + 1
        FROM Ronda
        WHERE id_partida = NEW.id_partida
    );
END//
DELIMITER ;