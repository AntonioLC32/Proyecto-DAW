-- Inserts en la tabla Usuario
INSERT INTO Usuario (nombre, correo, contraseña, num_derrotas, num_victorias, fecha_registro, habilitado)
VALUES 
('PEPE_123ASD', 'pepe123@example.com', 'hashed_password_1', 5, 10, NOW(), TRUE),
('ANANAS', 'pepesito@example.com', 'hashed_password_2', 3, 15, NOW(), TRUE),
('JHON DURAN', 'pepe@example.com', 'hashed_password_3', 7, 8, NOW(), TRUE),
('MARIA_ABCD', 'maria@example.com', 'hashed_password_4', 2, 20, NOW(), TRUE),
('JUAN_XYZ', 'juan@example.com', 'hashed_password_5', 6, 12, NOW(), TRUE),
('ANA_321', 'ana@example.com', 'hashed_password_6', 4, 18, NOW(), TRUE),
('LUIS_654', 'luis@example.com', 'hashed_password_7', 8, 7, NOW(), TRUE),
('CARLA_987', 'carla@example.com', 'hashed_password_8', 1, 22, NOW(), TRUE),
('PEDRO_KLK', 'pedro@example.com', 'hashed_password_9', 9, 5, NOW(), TRUE),
('SOFIA_GHI', 'sofia@example.com', 'hashed_password_10', 10, 3, NOW(), TRUE);

UPDATE Usuario 
SET imagen = 'https://www.qanimals.com/wp-content/uploads/2024/10/pexels-river-augustin-1370012990-28934371.jpg', 
    ult_conexion = NOW()
WHERE id_usuario = 1;


-- El nombre de categoria_destacada tiene que ser el mismo que la imagen o viceversa
INSERT INTO Ranking (id_usuario, rondas, puntos, posicion, categoria_destacada)
VALUES 
(1, 50, 15648, 1, 2),  -- Historia
(2, 45, 15348, 2, 1),  -- Ciencias
(3, 40, 15048, 3, 4),  -- Deportes
(4, 35, 14432, 4, 10), -- Música
(5, 30, 14210, 5, 6),  -- Entretenimiento
(6, 25, 14100, 6, 5),  -- Arte y Literatura
(7, 20, 13000, 7, 3),  -- Geografía
(8, 15, 12850, 8, 8),  -- Matemáticas
(9, 10, 12700, 9, 7),  -- Tecnología
(10, 5, 12560, 10, 9); -- Cultura General