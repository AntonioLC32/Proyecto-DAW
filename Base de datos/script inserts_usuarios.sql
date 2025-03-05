-- Añadir el campo categoria_destacada para que se muestre la imagen en el ranking
ALTER TABLE Ranking ADD COLUMN categoria_destacada VARCHAR(50);

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

-- El nombre de categoria_destacada tiene que ser el mismo que la imagen o viceversa
INSERT INTO Ranking (id_usuario, rondas, puntos, posicion, categoria_destacada)
VALUES 
(1, 50, 15648, 1, 'Historia'),
(2, 45, 15648, 2, 'Ciencias'),
(3, 40, 15648, 3, 'Deportes'),
(4, 35, 15432, 4, 'Musica'),
(5, 30, 15210, 5, 'Entre'),
(6, 25, 15100, 6, 'Arte'),
(7, 20, 15000, 7, 'Geografia'),
(8, 15, 14850, 8, 'Mates'),
(9, 10, 14700, 9, 'Tecno'),
(10, 5, 14560, 10, 'Cultura');