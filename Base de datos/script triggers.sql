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



-- 1. Crear procedimiento para actualizar el ranking
DELIMITER $$
CREATE PROCEDURE ActualizarRanking(IN usuario_id INT)
BEGIN
    DECLARE total_puntos INT;
    DECLARE categoria_top INT;
    
    -- Calcular puntos totales
    SELECT SUM(puntos) INTO total_puntos 
    FROM Estadisticas 
    WHERE id_usuario = usuario_id;
    
    -- Obtener categoría destacada
    SELECT id_categoria INTO categoria_top
    FROM Estadisticas
    WHERE id_usuario = usuario_id
    ORDER BY puntos DESC
    LIMIT 1;
    
    -- Actualizar o insertar en ranking
    INSERT INTO Ranking (id_usuario, puntos, categoria_destacada)
    VALUES (usuario_id, total_puntos, categoria_top)
    ON DUPLICATE KEY UPDATE
        puntos = total_puntos,
        categoria_destacada = categoria_top;
END$$
DELIMITER ;

-- 2. Triggers para actualización automática
-- Trigger para INSERT en Estadisticas
DELIMITER $$
CREATE TRIGGER AfterEstadisticasInsert
AFTER INSERT ON Estadisticas
FOR EACH ROW
BEGIN
    CALL ActualizarRanking(NEW.id_usuario);
    
    -- Actualizar posiciones globales
    UPDATE Ranking r
    JOIN (
        SELECT id_usuario, puntos, 
               RANK() OVER (ORDER BY puntos DESC) AS nueva_posicion
        FROM Ranking
    ) AS tmp ON r.id_usuario = tmp.id_usuario
    SET r.posicion = tmp.nueva_posicion;
END$$
DELIMITER ;

-- Trigger para UPDATE en Estadisticas
DELIMITER $$
CREATE TRIGGER AfterEstadisticasUpdate
AFTER UPDATE ON Estadisticas
FOR EACH ROW
BEGIN
    IF OLD.puntos <> NEW.puntos THEN
        CALL ActualizarRanking(NEW.id_usuario);
        
        -- Actualizar posiciones globales
        UPDATE Ranking r
        JOIN (
            SELECT id_usuario, puntos, 
                   RANK() OVER (ORDER BY puntos DESC) AS nueva_posicion
            FROM Ranking
        ) AS tmp ON r.id_usuario = tmp.id_usuario
        SET r.posicion = tmp.nueva_posicion;
    END IF;
END$$
DELIMITER ;

-- Trigger para DELETE en Estadisticas
DELIMITER $$
CREATE TRIGGER AfterEstadisticasDelete
AFTER DELETE ON Estadisticas
FOR EACH ROW
BEGIN
    CALL ActualizarRanking(OLD.id_usuario);
    
    -- Actualizar posiciones globales
    UPDATE Ranking r
    JOIN (
        SELECT id_usuario, puntos, 
               RANK() OVER (ORDER BY puntos DESC) AS nueva_posicion
        FROM Ranking
    ) AS tmp ON r.id_usuario = tmp.id_usuario
    SET r.posicion = tmp.nueva_posicion;
END$$
DELIMITER ;


