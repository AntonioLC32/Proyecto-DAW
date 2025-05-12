-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 12-05-2025 a las 16:10:31
-- Versión del servidor: 8.0.31
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `quizmania`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarEstadoPartidaSP` (IN `p_id_partida` INT, IN `p_estado` ENUM('activa','finalizada'))   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Verificar existencia de la partida
    IF NOT EXISTS (SELECT 1 FROM Partida WHERE id_partida = p_id_partida) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La partida no existe';
    END IF;
    
    -- Actualizar estado
    UPDATE Partida 
    SET estado = p_estado 
    WHERE id_partida = p_id_partida;
    
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarRanking` (IN `usuario_id` INT)   BEGIN
    DECLARE total_puntos INT;
    DECLARE categoria_top INT;
    DECLARE total_rondas INT;
    
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
    
    -- Calcular rondas totales
    SELECT COUNT(*) INTO total_rondas
    FROM Participante p
    JOIN Ronda r ON p.id_partida = r.id_partida
    WHERE p.id_usuario = usuario_id;
    
    -- Actualizar o insertar en ranking
    INSERT INTO Ranking (id_usuario, puntos, categoria_destacada, rondas)
    VALUES (usuario_id, total_puntos, categoria_top, total_rondas)
    ON DUPLICATE KEY UPDATE
        puntos = total_puntos,
        categoria_destacada = categoria_top,
        rondas = total_rondas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarVidasPartida` (IN `p_id_partida` INT, IN `p_cambio` TINYINT)   BEGIN
    DECLARE current_vidas TINYINT;
    DECLARE current_modo ENUM('solitario','multijugador');
    
    START TRANSACTION;
    
    SELECT vidas, modo INTO current_vidas, current_modo 
    FROM Partida 
    WHERE id_partida = p_id_partida
    FOR UPDATE;
    
    IF current_modo != 'solitario' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Solo partidas en solitario tienen vidas';
    END IF;
    
    UPDATE Partida 
    SET vidas = GREATEST(0, LEAST(3, current_vidas + p_cambio))
    WHERE id_partida = p_id_partida;
    
    -- Actualizar estado si llega a 0 vidas
    IF (current_vidas + p_cambio) <= 0 THEN
        UPDATE Partida SET estado = 'finalizada' 
        WHERE id_partida = p_id_partida;
    END IF;
    
    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `id_categoria` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `imagen` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`id_categoria`, `nombre`, `imagen`) VALUES
(1, 'Ciencia', 'assets/ciencia.png'),
(2, 'Historia', 'assets/historia.png'),
(3, 'Geografía', 'assets/geografia.png'),
(4, 'Deportes', 'assets/deportes.png'),
(5, 'Arte y Literatura', 'assets/arte.png'),
(6, 'Entretenimiento', 'assets/entre.png'),
(7, 'Tecnología', 'assets/tecno.png'),
(8, 'Matemáticas', 'assets/mates.png'),
(9, 'Cultura General', 'assets/cultura.png'),
(10, 'Música', 'assets/musica.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comodin`
--

CREATE TABLE `comodin` (
  `id_comodin` int NOT NULL,
  `id_partida` int NOT NULL,
  `nombre` enum('50/50','quitar respuesta','pasar pregunta') NOT NULL,
  `cantidad_maxima` tinyint UNSIGNED DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estadisticas`
--

CREATE TABLE `estadisticas` (
  `id_usuario` int NOT NULL,
  `id_categoria` int NOT NULL,
  `puntos` int UNSIGNED DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `estadisticas`
--

INSERT INTO `estadisticas` (`id_usuario`, `id_categoria`, `puntos`) VALUES
(16, 1, 90),
(16, 2, 190),
(16, 3, 170),
(16, 4, 100),
(16, 5, 140),
(16, 6, 220),
(16, 7, 100),
(16, 8, 140),
(16, 9, 290),
(16, 10, 150),
(21, 2, 30),
(21, 6, 10),
(21, 10, 20),
(22, 2, 20),
(22, 4, 20),
(22, 5, 10),
(22, 7, 40),
(23, 9, 30);

--
-- Disparadores `estadisticas`
--
DELIMITER $$
CREATE TRIGGER `AfterEstadisticasDelete` AFTER DELETE ON `estadisticas` FOR EACH ROW BEGIN
    CALL ActualizarRanking(OLD.id_usuario);
    
    -- Actualizar posiciones globales
    UPDATE Ranking r
    JOIN (
        SELECT id_usuario, puntos, 
               RANK() OVER (ORDER BY puntos DESC) AS nueva_posicion
        FROM Ranking
    ) AS tmp ON r.id_usuario = tmp.id_usuario
    SET r.posicion = tmp.nueva_posicion;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `AfterEstadisticasInsert` AFTER INSERT ON `estadisticas` FOR EACH ROW BEGIN
    CALL ActualizarRanking(NEW.id_usuario);
    
    -- Actualizar posiciones globales
    UPDATE Ranking r
    JOIN (
        SELECT id_usuario, puntos, 
               RANK() OVER (ORDER BY puntos DESC) AS nueva_posicion
        FROM Ranking
    ) AS tmp ON r.id_usuario = tmp.id_usuario
    SET r.posicion = tmp.nueva_posicion;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `AfterEstadisticasUpdate` AFTER UPDATE ON `estadisticas` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historialpreguntas`
--

CREATE TABLE `historialpreguntas` (
  `id_historial` int NOT NULL,
  `id_partida` int NOT NULL,
  `id_pregunta` int NOT NULL,
  `acertada` tinyint(1) NOT NULL,
  `fecha` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `historialpreguntas`
--

INSERT INTO `historialpreguntas` (`id_historial`, `id_partida`, `id_pregunta`, `acertada`, `fecha`) VALUES
(1, 30, 157, 0, '2025-03-25 15:48:46'),
(2, 30, 102, 1, '2025-03-25 15:49:25'),
(3, 30, 44, 1, '2025-03-25 15:50:59'),
(4, 31, 77, 1, '2025-03-25 15:53:35'),
(5, 31, 28, 0, '2025-03-25 15:53:51'),
(6, 31, 191, 1, '2025-03-25 15:54:15'),
(7, 31, 189, 1, '2025-03-25 15:54:32'),
(8, 31, 28, 0, '2025-03-25 15:54:48'),
(9, 33, 115, 1, '2025-03-25 16:04:49'),
(10, 34, 175, 1, '2025-03-25 16:20:55'),
(11, 34, 155, 0, '2025-03-25 16:35:28'),
(12, 34, 122, 1, '2025-03-25 16:35:44'),
(13, 35, 117, 0, '2025-03-25 16:39:37'),
(14, 35, 47, 0, '2025-03-25 16:39:53'),
(15, 36, 109, 0, '2025-03-25 17:24:14'),
(16, 36, 143, 1, '2025-03-25 17:25:18'),
(17, 36, 96, 1, '2025-03-25 17:25:40'),
(18, 36, 46, 1, '2025-03-25 17:25:54'),
(19, 36, 166, 0, '2025-03-25 17:26:09'),
(20, 36, 75, 1, '2025-03-25 17:26:22'),
(21, 37, 174, 0, '2025-03-25 17:35:18'),
(22, 37, 112, 1, '2025-03-25 17:36:37'),
(23, 37, 112, 1, '2025-03-25 17:36:42'),
(24, 37, 112, 0, '2025-03-25 17:37:30'),
(25, 38, 108, 0, '2025-03-25 17:44:03'),
(26, 38, 196, 0, '2025-03-25 17:49:31'),
(27, 39, 159, 1, '2025-03-25 17:51:13'),
(28, 39, 179, 0, '2025-03-25 17:55:16'),
(29, 39, 118, 0, '2025-03-25 17:55:29'),
(30, 40, 118, 0, '2025-03-25 17:57:13'),
(31, 40, 179, 0, '2025-03-25 17:57:13'),
(32, 41, 121, 0, '2025-03-25 17:59:58'),
(33, 41, 1, 0, '2025-03-25 18:00:15'),
(34, 42, 16, 0, '2025-03-25 18:04:36'),
(35, 42, 21, 0, '2025-03-25 18:04:57'),
(36, 43, 8, 0, '2025-03-25 18:06:41'),
(37, 43, 92, 0, '2025-03-25 18:06:54'),
(38, 43, 95, 1, '2025-03-25 18:07:07'),
(39, 44, 25, 0, '2025-03-25 18:09:54'),
(40, 44, 179, 0, '2025-03-25 18:12:39'),
(41, 45, 86, 0, '2025-03-25 18:14:37'),
(42, 45, 26, 0, '2025-03-25 18:14:49'),
(43, 46, 4, 0, '2025-03-25 18:16:54'),
(44, 46, 45, 1, '2025-03-25 18:17:32'),
(45, 50, 15, 0, '2025-03-25 18:24:03'),
(46, 51, 49, 0, '2025-03-25 18:52:35'),
(47, 51, 146, 1, '2025-03-25 18:53:07'),
(48, 51, 35, 1, '2025-03-25 18:53:27'),
(49, 51, 57, 1, '2025-03-25 18:53:46'),
(50, 51, 92, 1, '2025-03-25 18:53:59'),
(51, 51, 126, 1, '2025-03-25 18:54:16'),
(52, 51, 129, 0, '2025-03-25 18:54:30'),
(53, 51, 47, 1, '2025-03-25 18:54:42'),
(54, 51, 81, 1, '2025-03-25 18:54:55'),
(55, 51, 108, 0, '2025-03-25 18:55:12'),
(56, 53, 27, 1, '2025-03-26 15:07:28'),
(57, 55, 71, 0, '2025-03-26 15:30:33'),
(58, 55, 161, 0, '2025-03-26 15:31:17'),
(59, 55, 199, 1, '2025-03-26 15:31:32'),
(60, 56, 59, 0, '2025-03-26 15:42:01'),
(61, 56, 117, 0, '2025-03-26 15:45:23'),
(62, 56, 117, 1, '2025-03-26 15:45:54'),
(63, 57, 117, 0, '2025-03-26 15:46:33'),
(64, 57, 182, 0, '2025-03-26 15:46:33'),
(65, 58, 63, 0, '2025-03-26 15:47:09'),
(66, 58, 123, 0, '2025-03-26 15:47:56'),
(67, 58, 135, 1, '2025-03-26 15:48:08'),
(68, 60, 33, 1, '2025-03-26 18:02:34'),
(69, 61, 67, 1, '2025-03-26 18:19:05'),
(70, 61, 77, 1, '2025-03-26 18:19:17'),
(71, 61, 110, 0, '2025-03-26 18:19:30'),
(72, 61, 171, 1, '2025-03-26 18:19:47'),
(73, 61, 39, 1, '2025-03-26 18:20:02'),
(74, 61, 15, 0, '2025-03-26 18:20:16'),
(75, 61, 208, 1, '2025-03-26 18:20:32'),
(76, 61, 150, 1, '2025-03-26 18:20:50'),
(77, 62, 37, 0, '2025-03-27 15:02:00'),
(78, 62, 37, 0, '2025-03-27 15:03:10'),
(79, 63, 98, 0, '2025-03-27 15:07:07'),
(80, 64, 111, 0, '2025-03-27 15:11:35'),
(81, 65, 43, 0, '2025-03-27 15:19:01'),
(82, 65, 63, 0, '2025-03-27 15:20:40'),
(83, 66, 80, 0, '2025-03-27 15:24:47'),
(84, 66, 171, 0, '2025-03-27 15:25:45'),
(85, 67, 181, 0, '2025-03-27 15:27:43'),
(86, 67, 181, 0, '2025-03-27 15:27:43'),
(87, 68, 165, 0, '2025-03-27 15:28:03'),
(88, 68, 38, 0, '2025-03-27 15:52:32'),
(89, 69, 114, 0, '2025-03-27 15:53:58'),
(90, 69, 111, 0, '2025-03-27 15:59:35'),
(91, 69, 89, 1, '2025-03-27 16:00:54'),
(92, 70, 186, 0, '2025-03-27 16:01:45'),
(93, 70, 114, 0, '2025-03-27 16:02:16'),
(94, 71, 45, 0, '2025-03-27 16:03:12'),
(95, 71, 62, 0, '2025-03-27 16:03:36'),
(96, 72, 180, 0, '2025-03-27 16:28:47'),
(97, 72, 180, 0, '2025-03-27 16:35:11'),
(98, 74, 184, 0, '2025-03-27 16:40:04'),
(99, 74, 115, 0, '2025-03-27 16:40:58'),
(100, 75, 52, 0, '2025-03-27 16:42:10'),
(101, 75, 115, 0, '2025-03-27 16:42:10'),
(102, 76, 189, 1, '2025-03-27 17:49:01'),
(103, 78, 99, 0, '2025-04-01 13:28:53'),
(104, 79, 65, 0, '2025-04-01 13:30:06'),
(105, 79, 88, 1, '2025-04-01 13:30:25'),
(106, 80, 15, 0, '2025-04-01 13:31:31'),
(107, 80, 15, 0, '2025-04-01 13:31:47'),
(108, 81, 155, 1, '2025-04-01 13:33:01'),
(109, 81, 198, 0, '2025-04-01 13:33:19'),
(110, 81, 18, 1, '2025-04-01 13:35:53'),
(111, 81, 187, 0, '2025-04-01 13:37:52'),
(112, 81, 118, 1, '2025-04-01 13:38:06'),
(113, 81, 143, 1, '2025-04-01 13:38:34'),
(114, 82, 67, 0, '2025-04-01 13:41:03'),
(115, 82, 67, 0, '2025-04-01 13:41:14'),
(116, 83, 77, 1, '2025-04-01 13:41:43'),
(117, 83, 71, 0, '2025-04-01 13:42:15'),
(118, 83, 202, 0, '2025-04-01 13:44:32'),
(119, 83, 202, 1, '2025-04-01 13:44:46'),
(120, 85, 137, 0, '2025-04-01 13:47:50'),
(121, 85, 169, 0, '2025-04-01 13:51:51'),
(122, 86, 169, 0, '2025-04-03 13:28:42'),
(123, 86, 113, 1, '2025-04-03 13:29:24'),
(124, 87, 205, 0, '2025-04-03 13:30:10'),
(125, 87, 152, 0, '2025-04-03 13:30:49'),
(126, 88, 85, 1, '2025-04-03 13:31:55'),
(127, 89, 148, 1, '2025-04-03 13:48:48'),
(128, 89, 84, 0, '2025-04-03 13:49:09'),
(129, 89, 12, 1, '2025-04-03 13:49:24'),
(130, 90, 22, 0, '2025-04-29 13:25:41'),
(131, 90, 86, 0, '2025-04-29 13:25:59'),
(132, 91, 56, 0, '2025-04-29 13:26:42'),
(133, 91, 190, 0, '2025-04-29 13:27:01'),
(134, 92, 16, 1, '2025-04-29 13:30:22'),
(135, 92, 46, 0, '2025-04-29 13:30:40'),
(136, 92, 66, 0, '2025-04-29 13:30:52'),
(137, 93, 201, 0, '2025-04-29 13:32:13'),
(138, 93, 201, 0, '2025-04-29 13:32:44'),
(139, 94, 176, 1, '2025-04-29 13:33:23'),
(140, 94, 205, 1, '2025-04-29 13:34:54'),
(141, 94, 118, 0, '2025-04-29 13:36:08'),
(142, 94, 118, 0, '2025-04-29 13:37:49'),
(143, 94, 35, 1, '2025-04-29 13:38:02'),
(144, 95, 164, 0, '2025-04-29 13:38:47'),
(145, 95, 173, 1, '2025-04-29 13:39:34'),
(146, 95, 181, 1, '2025-04-29 13:40:30'),
(147, 95, 112, 1, '2025-04-29 13:41:02'),
(148, 95, 40, 1, '2025-04-29 13:44:19'),
(149, 97, 102, 0, '2025-04-29 13:44:41'),
(150, 97, 102, 0, '2025-04-29 13:45:51'),
(151, 98, 87, 1, '2025-04-29 13:54:44'),
(152, 99, 160, 1, '2025-04-29 13:55:12'),
(153, 99, 144, 1, '2025-04-29 13:55:37'),
(154, 99, 106, 1, '2025-04-29 13:56:09'),
(155, 99, 61, 0, '2025-04-29 13:57:38'),
(156, 99, 61, 1, '2025-04-29 13:58:46'),
(157, 99, 190, 0, '2025-04-29 13:59:03'),
(158, 101, 187, 1, '2025-04-29 14:01:04'),
(159, 101, 182, 0, '2025-04-29 14:01:16'),
(160, 101, 139, 0, '2025-04-29 14:02:24'),
(161, 101, 7, 1, '2025-04-29 14:02:39'),
(162, 101, 177, 1, '2025-04-29 14:02:54'),
(163, 102, 117, 1, '2025-04-29 14:04:12'),
(164, 103, 116, 0, '2025-04-29 14:06:05'),
(165, 103, 116, 1, '2025-04-29 14:06:27'),
(166, 104, 106, 1, '2025-04-29 14:06:47'),
(167, 104, 157, 0, '2025-04-29 14:13:56'),
(168, 104, 47, 1, '2025-04-29 14:14:10'),
(169, 104, 157, 0, '2025-04-29 14:19:04'),
(170, 105, 3, 0, '2025-04-29 14:19:23'),
(171, 105, 3, 0, '2025-04-29 14:20:34'),
(172, 106, 25, 0, '2025-04-29 14:22:55'),
(173, 106, 55, 0, '2025-04-29 14:23:56'),
(174, 107, 147, 0, '2025-04-29 14:25:05'),
(175, 107, 103, 0, '2025-04-29 14:26:25'),
(176, 107, 5, 1, '2025-04-29 14:26:42'),
(177, 108, 115, 0, '2025-04-29 14:26:59'),
(178, 108, 129, 0, '2025-04-29 14:27:15'),
(179, 109, 90, 1, '2025-04-29 14:28:42'),
(180, 109, 13, 1, '2025-04-29 14:29:50'),
(181, 109, 147, 0, '2025-04-29 14:30:05'),
(182, 109, 137, 0, '2025-04-29 14:31:20'),
(183, 110, 148, 1, '2025-05-05 15:38:25'),
(184, 110, 206, 0, '2025-05-05 15:38:48'),
(185, 110, 10, 1, '2025-05-05 15:39:22'),
(186, 110, 166, 1, '2025-05-05 15:40:35'),
(187, 110, 209, 0, '2025-05-05 15:41:11'),
(188, 111, 170, 1, '2025-05-05 15:41:51'),
(189, 112, 17, 0, '2025-05-05 17:11:23'),
(190, 113, 29, 0, '2025-05-07 15:20:18'),
(191, 113, 6, 1, '2025-05-07 15:20:32'),
(192, 113, 16, 1, '2025-05-07 15:20:44'),
(193, 113, 178, 0, '2025-05-07 15:21:00'),
(194, 113, 59, 1, '2025-05-07 15:21:14'),
(195, 114, 185, 0, '2025-05-07 15:21:51'),
(196, 114, 101, 1, '2025-05-07 15:22:10'),
(197, 114, 170, 1, '2025-05-07 15:22:25'),
(198, 114, 157, 0, '2025-05-07 15:22:39'),
(199, 114, 20, 1, '2025-05-07 15:22:53'),
(200, 114, 125, 1, '2025-05-07 15:23:06'),
(201, 114, 43, 1, '2025-05-07 15:23:20'),
(202, 115, 146, 0, '2025-05-07 15:23:55'),
(203, 115, 117, 1, '2025-05-07 15:24:09'),
(204, 116, 91, 1, '2025-05-07 15:28:13');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `participante`
--

CREATE TABLE `participante` (
  `id_usuario` int NOT NULL,
  `id_partida` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `participante`
--

INSERT INTO `participante` (`id_usuario`, `id_partida`) VALUES
(16, 13),
(16, 14),
(16, 15),
(16, 16),
(16, 17),
(16, 18),
(16, 19),
(16, 20),
(16, 21),
(16, 22),
(16, 23),
(16, 24),
(16, 25),
(16, 26),
(16, 27),
(16, 28),
(16, 29),
(16, 30),
(16, 31),
(16, 32),
(16, 33),
(16, 34),
(16, 35),
(16, 36),
(16, 37),
(16, 38),
(16, 39),
(16, 40),
(16, 41),
(16, 42),
(16, 43),
(16, 44),
(16, 45),
(16, 46),
(16, 47),
(16, 48),
(16, 49),
(16, 50),
(16, 51),
(16, 52),
(16, 53),
(16, 54),
(16, 55),
(16, 56),
(16, 57),
(16, 58),
(16, 59),
(16, 60),
(16, 61),
(16, 62),
(16, 63),
(16, 64),
(16, 65),
(16, 66),
(16, 67),
(16, 68),
(16, 69),
(16, 70),
(16, 71),
(16, 72),
(16, 73),
(16, 74),
(16, 75),
(16, 76),
(16, 77),
(16, 78),
(16, 79),
(16, 80),
(16, 81),
(16, 82),
(16, 83),
(16, 84),
(16, 85),
(16, 86),
(16, 87),
(16, 88),
(16, 89),
(16, 90),
(16, 91),
(16, 92),
(16, 93),
(16, 94),
(16, 95),
(16, 96),
(16, 97),
(16, 98),
(16, 99),
(16, 100),
(16, 101),
(16, 102),
(16, 103),
(16, 104),
(16, 105),
(16, 106),
(16, 107),
(16, 108),
(16, 109),
(16, 110),
(16, 111),
(16, 112),
(21, 113),
(22, 114),
(23, 115),
(16, 116);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partida`
--

CREATE TABLE `partida` (
  `id_partida` int NOT NULL,
  `modo` enum('solitario','multijugador') NOT NULL,
  `vidas` tinyint UNSIGNED DEFAULT '3',
  `estado` enum('activa','finalizada') DEFAULT 'activa',
  `ganador` int DEFAULT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `partida`
--

INSERT INTO `partida` (`id_partida`, `modo`, `vidas`, `estado`, `ganador`, `fecha`) VALUES
(13, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:18:36'),
(14, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:24:06'),
(15, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:25:36'),
(16, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:36:00'),
(17, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:36:30'),
(18, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:36:44'),
(19, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:39:08'),
(20, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:40:06'),
(21, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:43:24'),
(22, 'solitario', 3, 'finalizada', NULL, '2025-03-20 17:44:24'),
(23, 'solitario', 3, 'finalizada', NULL, '2025-03-20 18:23:09'),
(24, 'solitario', 3, 'finalizada', NULL, '2025-03-20 18:42:19'),
(25, 'solitario', 3, 'finalizada', NULL, '2025-03-20 18:42:31'),
(26, 'solitario', 3, 'finalizada', NULL, '2025-03-20 18:46:43'),
(27, 'solitario', 3, 'finalizada', NULL, '2025-03-20 19:03:44'),
(28, 'solitario', 3, 'finalizada', NULL, '2025-03-20 19:49:38'),
(29, 'solitario', 3, 'finalizada', NULL, '2025-03-25 16:15:50'),
(30, 'solitario', 3, 'finalizada', NULL, '2025-03-25 16:48:34'),
(31, 'solitario', 3, 'finalizada', NULL, '2025-03-25 16:53:06'),
(32, 'solitario', 3, 'finalizada', NULL, '2025-03-25 16:58:12'),
(33, 'solitario', 3, 'activa', NULL, '2025-03-25 17:00:40'),
(34, 'solitario', 3, 'finalizada', NULL, '2025-03-25 17:00:48'),
(35, 'solitario', 0, 'finalizada', NULL, '2025-03-25 17:39:27'),
(36, 'solitario', 0, 'finalizada', NULL, '2025-03-25 18:23:49'),
(37, 'solitario', 0, 'finalizada', NULL, '2025-03-25 18:34:12'),
(38, 'solitario', 0, 'finalizada', NULL, '2025-03-25 18:42:54'),
(39, 'solitario', 0, 'finalizada', NULL, '2025-03-25 18:50:50'),
(40, 'solitario', 0, 'finalizada', NULL, '2025-03-25 18:55:49'),
(41, 'solitario', 0, 'finalizada', NULL, '2025-03-25 18:57:15'),
(42, 'solitario', 0, 'finalizada', NULL, '2025-03-25 19:03:27'),
(43, 'solitario', 0, 'finalizada', NULL, '2025-03-25 19:06:15'),
(44, 'solitario', 0, 'finalizada', NULL, '2025-03-25 19:08:30'),
(45, 'solitario', 0, 'finalizada', NULL, '2025-03-25 19:14:26'),
(46, 'solitario', 2, 'finalizada', NULL, '2025-03-25 19:16:41'),
(47, 'solitario', 3, 'finalizada', NULL, '2025-03-25 19:18:28'),
(48, 'solitario', 3, 'finalizada', NULL, '2025-03-25 19:20:58'),
(49, 'solitario', 3, 'finalizada', NULL, '2025-03-25 19:21:22'),
(50, 'solitario', 2, 'finalizada', NULL, '2025-03-25 19:23:06'),
(51, 'solitario', 0, 'finalizada', NULL, '2025-03-25 19:52:18'),
(52, 'solitario', 3, 'activa', NULL, '2025-03-25 20:00:22'),
(53, 'solitario', 3, 'finalizada', NULL, '2025-03-26 16:06:46'),
(54, 'solitario', 3, 'activa', NULL, '2025-03-26 16:20:36'),
(55, 'solitario', 1, 'finalizada', NULL, '2025-03-26 16:23:27'),
(56, 'solitario', 0, 'finalizada', NULL, '2025-03-26 16:37:43'),
(57, 'solitario', 0, 'finalizada', NULL, '2025-03-26 16:46:21'),
(58, 'solitario', 0, 'finalizada', NULL, '2025-03-26 16:46:35'),
(59, 'solitario', 3, 'finalizada', NULL, '2025-03-26 19:01:50'),
(60, 'solitario', 3, 'finalizada', NULL, '2025-03-26 19:01:56'),
(61, 'solitario', 0, 'finalizada', NULL, '2025-03-26 19:18:52'),
(62, 'solitario', 0, 'finalizada', NULL, '2025-03-27 16:01:44'),
(63, 'solitario', 2, 'finalizada', NULL, '2025-03-27 16:03:12'),
(64, 'solitario', 2, 'finalizada', NULL, '2025-03-27 16:10:24'),
(65, 'solitario', 0, 'finalizada', NULL, '2025-03-27 16:18:50'),
(66, 'solitario', 0, 'finalizada', NULL, '2025-03-27 16:20:43'),
(67, 'solitario', 0, 'finalizada', NULL, '2025-03-27 16:27:28'),
(68, 'solitario', 0, 'finalizada', NULL, '2025-03-27 16:27:46'),
(69, 'solitario', 0, 'finalizada', NULL, '2025-03-27 16:53:03'),
(70, 'solitario', 0, 'finalizada', NULL, '2025-03-27 17:01:27'),
(71, 'solitario', 0, 'finalizada', NULL, '2025-03-27 17:02:54'),
(72, 'solitario', 0, 'finalizada', NULL, '2025-03-27 17:28:09'),
(73, 'solitario', 3, 'finalizada', NULL, '2025-03-27 17:35:13'),
(74, 'solitario', 0, 'finalizada', NULL, '2025-03-27 17:39:47'),
(75, 'solitario', 0, 'finalizada', NULL, '2025-03-27 17:41:26'),
(76, 'solitario', 3, 'finalizada', NULL, '2025-03-27 17:42:12'),
(77, 'solitario', 3, 'finalizada', NULL, '2025-04-01 15:21:59'),
(78, 'solitario', 2, 'finalizada', NULL, '2025-04-01 15:28:36'),
(79, 'solitario', 2, 'finalizada', NULL, '2025-04-01 15:29:31'),
(80, 'solitario', 0, 'finalizada', NULL, '2025-04-01 15:31:16'),
(81, 'solitario', 0, 'finalizada', NULL, '2025-04-01 15:32:47'),
(82, 'solitario', 0, 'finalizada', NULL, '2025-04-01 15:40:51'),
(83, 'solitario', 0, 'finalizada', NULL, '2025-04-01 15:41:16'),
(84, 'solitario', 3, 'finalizada', NULL, '2025-04-01 15:47:17'),
(85, 'solitario', 1, 'finalizada', NULL, '2025-04-01 15:47:37'),
(86, 'solitario', 2, 'finalizada', NULL, '2025-04-03 15:28:19'),
(87, 'solitario', 0, 'finalizada', NULL, '2025-04-03 15:29:40'),
(88, 'solitario', 3, 'finalizada', NULL, '2025-04-03 15:31:08'),
(89, 'solitario', 2, 'finalizada', NULL, '2025-04-03 15:48:38'),
(90, 'solitario', 0, 'finalizada', NULL, '2025-04-29 15:25:26'),
(91, 'solitario', 0, 'finalizada', NULL, '2025-04-29 15:26:25'),
(92, 'solitario', 0, 'finalizada', NULL, '2025-04-29 15:30:10'),
(93, 'solitario', 0, 'finalizada', NULL, '2025-04-29 15:31:19'),
(94, 'solitario', 0, 'finalizada', NULL, '2025-04-29 15:33:03'),
(95, 'solitario', 2, 'finalizada', NULL, '2025-04-29 15:38:22'),
(96, 'solitario', 3, 'activa', NULL, '2025-04-29 15:40:03'),
(97, 'solitario', 0, 'finalizada', NULL, '2025-04-29 15:44:24'),
(98, 'solitario', 3, 'activa', NULL, '2025-04-29 15:45:54'),
(99, 'solitario', 0, 'finalizada', NULL, '2025-04-29 15:54:53'),
(100, 'solitario', 3, 'activa', NULL, '2025-04-29 15:55:57'),
(101, 'solitario', 0, 'finalizada', NULL, '2025-04-29 15:59:22'),
(102, 'solitario', 3, 'finalizada', NULL, '2025-04-29 16:03:53'),
(103, 'solitario', 2, 'finalizada', NULL, '2025-04-29 16:04:16'),
(104, 'solitario', 0, 'finalizada', NULL, '2025-04-29 16:06:31'),
(105, 'solitario', 0, 'finalizada', NULL, '2025-04-29 16:19:06'),
(106, 'solitario', 0, 'finalizada', NULL, '2025-04-29 16:20:36'),
(107, 'solitario', 1, 'finalizada', NULL, '2025-04-29 16:24:00'),
(108, 'solitario', 0, 'finalizada', NULL, '2025-04-29 16:26:46'),
(109, 'solitario', 0, 'finalizada', NULL, '2025-04-29 16:28:25'),
(110, 'solitario', 0, 'finalizada', NULL, '2025-05-05 17:38:14'),
(111, 'solitario', 3, 'finalizada', NULL, '2025-05-05 17:41:37'),
(112, 'solitario', 2, 'finalizada', NULL, '2025-05-05 19:11:03'),
(113, 'solitario', 1, 'finalizada', NULL, '2025-05-07 17:20:07'),
(114, 'solitario', 1, 'finalizada', NULL, '2025-05-07 17:21:38'),
(115, 'solitario', 2, 'finalizada', NULL, '2025-05-07 17:23:40'),
(116, 'solitario', 3, 'finalizada', NULL, '2025-05-07 17:27:26');

--
-- Disparadores `partida`
--
DELIMITER $$
CREATE TRIGGER `ActualizarEstadoPartida` BEFORE UPDATE ON `partida` FOR EACH ROW BEGIN
    IF NEW.vidas <= 0 THEN
        SET NEW.estado = 'finalizada';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pregunta`
--

CREATE TABLE `pregunta` (
  `id_pregunta` int NOT NULL,
  `texto` text NOT NULL,
  `habilitado` tinyint(1) DEFAULT '1',
  `id_tarjeta` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `pregunta`
--

INSERT INTO `pregunta` (`id_pregunta`, `texto`, `habilitado`, `id_tarjeta`) VALUES
(1, '¿Cuál es el planeta más cercano al sol?', 1, 1),
(2, '¿Qué gas es el principal componente de la atmósfera terrestre?', 1, 2),
(3, '¿Qué físico introdujo la noción de \"espaciotiempo\" como un continuo cuatridimensional en el que ocurren los eventos físicos?', 1, 3),
(4, '¿En qué año llegó Cristóbal Colón a América por primera vez?', 1, 4),
(5, '¿En qué año comenzó la Revolución Francesa?', 1, 5),
(6, '¿Quién fue el líder militar que dirigió el Imperio Mongol durante su apogeo?', 1, 6),
(7, '¿Cuál es el río más largo del mundo?', 1, 7),
(8, '¿Cuál es el mar más grande del mundo?', 1, 8),
(9, '¿En qué país se encuentra el desierto de Atacama?', 1, 9),
(10, '¿En qué deporte se utiliza una pelota y una raqueta?', 1, 10),
(11, '¿Qué atleta es conocido como el \"Relámpago de Jamaica\" y ha ganado múltiples medallas olímpicas?', 1, 11),
(12, '¿Cuál fue el primer club de fútbol en ganar la Liga de Campeones de la UEFA bajo su nombre actual?', 1, 12),
(13, '¿Quién pinto la mona lisa?', 1, 13),
(14, '¿Qué pintor es conocido por su estilo surrealista y su famoso cuadro \"La persistencia de la memoria\"?', 1, 14),
(15, '¿Quién fue el autor de \"En busca del tiempo perdido\", una de las obras más importantes de la literatura francesa?', 1, 15),
(16, '¿Quién interpretó a Tony Stark (Iron Man) en las películas del Universo Cinematográfico de Marvel?', 1, 16),
(17, '¿Qué director es reconocido por dirigir la trilogía de \"El Señor de los Anillos\"?', 1, 17),
(18, '¿Cuál es el título de la serie alemana de ciencia ficción y misterio que involucra viajes en el tiempo y una intrincada red de conexiones familiares?', 1, 18),
(19, '¿Qué sistema operativo utiliza el iPhone?', 1, 19),
(20, '¿Qué significa HTML en el contexto del desarrollo web?', 1, 20),
(21, 'En ciberseguridad, ¿qué técnica consiste en interceptar y, en ocasiones, alterar la comunicación entre dos partes sin que estas lo detecten?', 1, 21),
(22, '¿Cuál es el valor de 9²?', 1, 22),
(23, 'Si un triángulo tiene un ángulo de 90° y los otros dos ángulos miden 45° cada uno, ¿cómo se llama este triángulo?', 1, 23),
(24, '¿Cuál es el valor de la expresión 2/5×3/4?', 1, 24),
(25, '¿Cuál es la capital de Francia?', 1, 25),
(26, '¿Qué autor escribió \"Cien años de soledad\"?', 1, 26),
(27, '¿Cuál fue el primer país en conceder el derecho al voto a las mujeres?', 1, 27),
(28, '¿Quién es conocido como el \"Rey del Pop\"?', 1, 28),
(29, '¿Qué banda lanzó el álbum \"The Dark Side of the Moon\" en 1973?', 1, 29),
(30, '¿Cuál de las siguientes obras fue compuesta por Igor Stravinsky?', 1, 30),
(31, '¿Cuál es la fórmula química del agua?', 1, 1),
(32, '¿Qué es un neutrino?', 1, 2),
(33, '¿Cuál es el valor aproximado de la constante de Planck (h)?', 1, 3),
(34, '¿Quién fue el primer presidente de los Estados Unidos?', 1, 4),
(35, '¿En qué año se derribó el Muro de Berlín?', 1, 5),
(36, '¿Qué tratado puso fin oficialmente a la Primera Guerra Mundial?', 1, 6),
(37, '¿Cuál es la capital de Japón?', 1, 7),
(38, '¿Cuál es el país más extenso del mundo en términos de superficie?', 1, 8),
(39, '¿Cuál es el punto de la Tierra que, medido desde el centro del planeta, se encuentra más alejado?', 1, 9),
(40, '¿Cuántos jugadores integran un equipo de fútbol durante un partido?', 1, 10),
(41, '¿Quién ostenta el récord de mayor cantidad de títulos de Grand Slam en el tenis masculino en la era Open?', 1, 11),
(42, '¿Qué selección nacional ha ganado el mayor número de títulos en la historia de la Copa América?', 1, 12),
(43, '¿Quién escribió la novela 1984?', 1, 13),
(44, '¿Qué movimiento artístico, surgido en Francia a finales del siglo XIX, se caracteriza por capturar la impresión visual de un instante, especialmente en cuanto a la luz y el color?', 1, 14),
(45, '¿Cuál es la obra literaria de James Joyce considerada un hito del modernismo, que narra un solo día en la vida de los habitantes de Dublín?', 1, 15),
(46, '¿En qué película animada se narra la aventura de un pez payaso en busca de su hijo?', 1, 16),
(47, '¿Qué director es conocido por sus películas de culto como \"Pulp Fiction\" y \"Kill Bill\"?', 1, 17),
(48, '¿Qué película obtuvo el récord de 11 premios Oscar en la ceremonia de 2004?', 1, 18),
(49, '¿Qué empresa desarrolló el sistema operativo Windows?', 1, 19),
(50, '¿Cuál fue la primera red social en alcanzar los 1.000 millones de usuarios activos?', 1, 20),
(51, '¿Qué tipo de inteligencia artificial se basa en redes neuronales profundas para aprender de grandes cantidades de datos?', 1, 21),
(52, '¿Cuánto es 7 × 8?', 1, 22),
(53, '¿Cuál es el resultado de la raíz cuadrada de 196?', 1, 23),
(54, '¿Cuál es el valor de ln(e⁵)?', 1, 24),
(55, '¿Qué país es conocido como la \"tierra del sol naciente\"?', 1, 25),
(56, '¿En qué año se fundó la Organización de las Naciones Unidas (ONU)?', 1, 26),
(57, '¿En qué año se fundó la Organización Mundial de la Salud (OMS)?', 1, 27),
(58, '¿Qué instrumento musical tiene teclas blancas y negras?', 1, 28),
(59, '¿Cuál de estos géneros musicales es originario de Jamaica?', 1, 29),
(60, '¿Quién fue el compositor de la famosa ópera \"La Traviata\"?', 1, 30),
(61, '¿Cuál es el metal más abundante en la corteza terrestre?', 1, 1),
(62, '¿Cuál de las siguientes unidades se usa para medir la intensidad de corriente eléctrica?', 1, 2),
(63, '¿Qué científica recibió dos premios Nobel en distintas disciplinas?', 1, 3),
(64, '¿En qué país tuvo lugar la Revolución Industrial?', 1, 4),
(65, '¿Qué evento marcó el inicio de la Segunda Guerra Mundial?', 1, 5),
(66, '¿Quién fue el primer emperador de China?', 1, 6),
(67, '¿En qué continente se encuentra Egipto?', 1, 7),
(68, '¿Cuál es el país con más husos horarios en el mundo, considerando sus territorios de ultramar?', 1, 8),
(69, '¿Cuál es el lago más profundo del mundo?', 1, 9),
(70, '¿Cuántos anillos olímpicos hay en la bandera de los Juegos Olímpicos?', 1, 10),
(71, '¿En qué país se originó el baloncesto?', 1, 11),
(72, '¿Cuántas veces ha ganado la Selección de Rugby de Nueva Zelanda la Copa del Mundo (hasta 2023)?', 1, 12),
(73, '¿Quién pintó el fresco de la Capilla Sixtina en el Vaticano?', 1, 13),
(74, '¿Cuál de estas novelas fue escrita por Jane Austen?', 1, 14),
(75, '¿Quién compuso la ópera El barbero de Sevilla?', 1, 15),
(76, '¿Cómo se llama el mejor amigo de Shrek en la película Shrek?', 1, 16),
(77, '¿En qué serie aparece el personaje Walter White, un profesor de química convertido en narcotraficante?', 1, 17),
(78, '¿Cuál de estos directores ha ganado más premios Oscar a Mejor Dirección?', 1, 18),
(79, '¿Qué significa la sigla \"USB\" en tecnología?', 1, 19),
(80, '¿Qué empresa desarrolló el sistema operativo Android?', 1, 20),
(81, '¿Qué científico es considerado el padre de la computación moderna?', 1, 21),
(82, '¿Cuál es el resultado de la siguiente operación siguiendo el orden de las operaciones? 3+5×2', 1, 22),
(83, '¿Cuál es el resultado de la siguiente ecuación? 3(x−2)=2x+4', 1, 23),
(84, '', 1, 24),
(85, '¿Cuál es el idioma con mayor cantidad de hablantes nativos en el mundo?', 1, 25),
(86, '¿Qué civilización construyó Machu Picchu?', 1, 26),
(87, '¿Qué tratado, firmado en 1648, puso fin a la Guerra de los Treinta Años?', 1, 27),
(88, '¿Qué instrumento musical se toca soplando aire a través de una lengüeta?', 1, 28),
(89, '¿Quién fue el cantante principal de la banda de rock Nirvana?', 1, 29),
(90, '¿Qué compositor alemán compuso \"El Anillo del Nibelungo\"?', 1, 30),
(91, '¿Cuál es el órgano más grande del cuerpo humano?', 1, 1),
(92, '¿Cuál es el nombre de la partícula subatómica con carga negativa?', 1, 2),
(93, '¿Cuál es la ecuación que representa la Teoría de la Relatividad Especial de Einstein?', 1, 3),
(94, '¿En qué año se firmó la Declaración de Independencia de los Estados Unidos?', 1, 4),
(95, '¿Cuál de las siguientes batallas se considera un punto de inflexión en el Frente Oriental durante la Segunda Guerra Mundial?', 1, 5),
(96, '¿Qué reforma implementada por el emperador Diocleciano reorganizó el Imperio Romano en un sistema conocido como Tetrarquía?', 1, 6),
(97, '¿Cuál es la capital de Australia?', 1, 7),
(98, '¿Cuál es el río más largo de Europa?', 1, 8),
(99, '¿Qué país posee la mayor cantidad de islas en el mundo?', 1, 9),
(100, '¿Qué país ha ganado más Copas del Mundo de fútbol?', 1, 10),
(101, '¿Qué nadador ostenta el récord de mayor cantidad de medallas olímpicas ganadas?', 1, 11),
(102, '¿En qué año se celebró la primera edición de la Copa del Mundo de Rugby?', 1, 12),
(103, '¿Quién escribió Don Quijote de la Mancha?', 1, 13),
(104, '¿Cuál es el movimiento artístico asociado con Pablo Picasso y Georges Braque?', 1, 14),
(105, '¿Cuál es la epopeya más antigua de la literatura mundial conocida?', 1, 15),
(106, '¿Cómo se llama el superhéroe alter ego de Bruce Wayne?', 1, 16),
(107, '¿En qué año se estrenó la primera película de Harry Potter?', 1, 17),
(108, '¿Quién compuso la banda sonora de la trilogía de El Señor de los Anillos?', 1, 18),
(109, '¿Qué es un SSD en el ámbito de la informática?', 1, 19),
(110, '¿Cuál de los siguientes protocolos se utiliza para la transferencia segura de archivos a través de Internet?', 1, 20),
(111, '¿En qué año se lanzó la primera versión del lenguaje de programación Python?', 1, 21),
(112, '¿Cuánto es 15 - 7?', 1, 22),
(113, '¿Cuál es el valor de 2⁵?', 1, 23),
(114, '¿Cuántas combinaciones se pueden formar al elegir 3 elementos de un conjunto de 7?', 1, 24),
(115, '¿Qué país es famoso por sus tulipanes y molinos de viento?', 1, 25),
(116, '¿Cuál es el animal nacional de Escocia?', 1, 26),
(117, '¿Cuál es la obra literaria considerada la primera novela del mundo, escrita durante el período Heian en Japón?', 1, 27),
(118, '¿Cuál es la banda británica conocida por éxitos como \"Hey Jude\" y \"Let It Be\"?', 1, 28),
(119, '¿Qué artista de reggae es reconocido mundialmente por temas como \"No Woman, No Cry\"?', 1, 29),
(120, '¿Cuál fue el primer videoclip musical transmitido en MTV?', 1, 30),
(121, '¿Qué planeta es conocido como el \"planeta rojo\"?', 1, 1),
(122, '¿Cuál es la velocidad aproximada de la luz en el vacío?', 1, 2),
(123, 'En mecánica cuántica, ¿qué fenómeno permite que una partícula atraviese una barrera de potencial sin poseer la energía clásica suficiente?', 1, 3),
(124, '¿Qué civilización construyó las pirámides de Giza?', 1, 4),
(125, '¿Qué civilización construyó la ciudad de Tenochtitlán?', 1, 5),
(126, '¿En qué año cayó Constantinopla en manos del Imperio Otomano?', 1, 6),
(127, '¿Cuál es la capital de Canadá?', 1, 7),
(128, '¿Cuál es el lago de agua dulce más grande del mundo por superficie?', 1, 8),
(129, '¿Cuál es la cordillera continental más extensa del mundo?', 1, 9),
(130, '¿Cuántos jugadores conforman un equipo de voleibol en la cancha durante un partido?', 1, 10),
(131, '¿Qué país ha ganado la mayor cantidad de medallas en la historia de los Juegos Olímpicos de Invierno?', 1, 11),
(132, '¿En qué año se fundó la National Football League (NFL)?', 1, 12),
(133, '¿Quién pintó \"La noche estrellada\"?', 1, 13),
(134, '¿Quién es el autor de \"El retrato de Dorian Gray\"?', 1, 14),
(135, '¿Qué poeta chileno ganó el Premio Nobel de Literatura en 1971?', 1, 15),
(136, '¿Quién interpretó a Jack Dawson en la película \"Titanic\"?', 1, 16),
(137, '¿Qué director es reconocido por su estilo visual peculiar en películas como \"El Gran Hotel Budapest\"?', 1, 17),
(138, '¿Qué película española ganó el Oscar a Mejor Película Extranjera en el año 2000?', 1, 18),
(139, '¿Qué significa la sigla \"RAM\" en informática?', 1, 19),
(140, '¿Qué dispositivo permite a una computadora conectarse a una red inalámbrica?', 1, 20),
(141, '¿Qué es la tecnología \"blockchain\" y para qué se utiliza principalmente?', 1, 21),
(142, '¿Cuánto es 9 × 6?', 1, 22),
(143, '¿Cuál es el valor de la raíz cuadrada de 64?', 1, 23),
(144, '¿Qué número falta en la siguiente secuencia: 2, 6, 12, 20, ... ?', 1, 24),
(145, '¿Quién inventó la imprenta?', 1, 25),
(146, '¿De qué país es originario el tango?', 1, 26),
(147, '¿En qué año se firmó el Tratado de Tordesillas?', 1, 27),
(148, '¿Cuál es el nombre artístico del rapero conocido como \"Slim Shady\"?', 1, 28),
(149, '¿Qué grupo musical es conocido por la canción \"Hotel California\"?', 1, 29),
(150, '¿Qué compositor clásico escribió la ópera \"La flauta mágica\"?', 1, 30),
(151, '¿Qué elemento químico tiene el símbolo \"O\"?', 1, 1),
(152, '¿Qué unidad se utiliza para medir la fuerza en el Sistema Internacional?', 1, 2),
(153, '¿Cuál de las siguientes no es una interacción fundamental de la naturaleza?', 1, 3),
(154, '¿Quién fue el líder de la Revolución Rusa de 1917?', 1, 4),
(155, '¿En qué año se derribó el Muro de Berlín?', 1, 5),
(156, '¿Cuál fue el evento desencadenante de la Primera Guerra Mundial?', 1, 6),
(157, '¿Cuál es el país más poblado del mundo?', 1, 7),
(158, '¿Cuál es el desierto no polar más extenso del mundo?', 1, 8),
(159, '¿Cuál es la península más extensa del mundo?', 1, 9),
(160, '¿Cuántos jugadores conforman un equipo de rugby union en el campo?', 1, 10),
(161, '¿En qué año se disputó la primera temporada de Fórmula 1?', 1, 11),
(162, '¿En qué año se celebraron los primeros Juegos Paralímpicos?', 1, 12),
(163, '¿Quién pintó \"El Guernica\"?', 1, 13),
(164, '¿Cuál es la obra de teatro que narra la tragedia del príncipe danés?', 1, 14),
(165, '¿Quién escribió la novela \"Rayuela\"?', 1, 15),
(166, '¿En qué película animada aparece un vaquero de juguete llamado Woody?', 1, 16),
(167, '¿Qué película de 1994, basada en una novela de Stephen King, narra la historia de dos hombres encarcelados?', 1, 17),
(168, '¿En qué año se estrenó la película Metropolis, dirigida por Fritz Lang y considerada un hito del cine de ciencia ficción mudo?', 1, 18),
(169, '¿Qué componente de un ordenador se encarga de ejecutar las instrucciones de un programa?', 1, 19),
(170, '¿Qué lenguaje de programación fue creado por James Gosling y lanzado en 1995?', 1, 20),
(171, 'En el desarrollo de software, ¿qué significa la sigla \"API\"?', 1, 21),
(172, '¿Cuánto es 20 ÷ 5?', 1, 22),
(173, 'Si Ana tiene 3 veces más lápices que Carlos y Carlos tiene 5 lápices, ¿cuántos lápices tiene Ana?', 1, 23),
(174, '¿Cuál es el siguiente número en la secuencia: 3, 5, 9, 17, ... ?', 1, 24),
(175, '¿Qué país es conocido por el baile flamenco?', 1, 25),
(176, '¿Cuál es la moneda oficial de Japón?', 1, 26),
(177, '¿Qué famosa catedral gótica, situada en el centro de París y escenario central en la novela de Victor Hugo sobre un jorobado, es reconocida mundialmente por su imponente arquitectura?', 1, 27),
(178, '¿Qué género musical, caracterizado por su improvisación y ritmos sincopados, se originó en Nueva Orleans?', 1, 28),
(179, '¿Qué cantante estadounidense es conocida como \"La Voz del Soul\"?', 1, 29),
(180, '¿Qué innovador músico de jazz, pionero del free jazz, es reconocido por su álbum \"Free Jazz: A Collective Improvisation\"?', 1, 30),
(181, '¿Qué órgano del cuerpo humano es responsable de bombear la sangre?', 1, 1),
(182, '¿Cuál es el metal líquido a temperatura ambiente?', 1, 2),
(183, '¿Cuál es el nombre del proceso por el cual las plantas convierten la luz solar en energía química?', 1, 3),
(184, '¿En qué año se libró la Batalla de Hastings?', 1, 4),
(185, '¿Quién fue el primer emperador de Roma?', 1, 5),
(186, '¿Quién es reconocido como el iniciador de la Reforma Protestante al clavar sus 95 tesis en 1517?', 1, 6),
(187, '¿Cuál es el país más grande de América del Sur en términos de superficie?', 1, 7),
(188, '¿Qué océano baña la costa oeste de los Estados Unidos?', 1, 8),
(189, '¿Cuál es el nombre del punto más profundo del océano conocido hasta ahora?', 1, 9),
(190, '¿En qué deporte se utiliza el término \"love\" para indicar un puntaje de cero?', 1, 10),
(191, '¿Cuántos minutos dura un partido oficial de la NBA?', 1, 11),
(192, '¿Quién ostenta el récord del mayor número de pole positions en la historia de la Fórmula 1?', 1, 12),
(193, '¿Quién escribió \"El Principito\"?', 1, 13),
(194, '¿Qué novela, escrita por F. Scott Fitzgerald, es considerada una crítica a la alta sociedad estadounidense de los años 1920?', 1, 14),
(195, '¿Qué poeta inglés es conocido por su obra \"Paradise Lost\"?', 1, 15),
(196, '¿En qué película animada de Disney se escucha la canción \"Let It Go\"?', 1, 16),
(197, '¿En qué película de 2010, dirigida por Christopher Nolan, se explora el concepto de soñar dentro de sueños?', 1, 17),
(198, '¿Qué película de animación japonesa, dirigida por Hayao Miyazaki, ganó el Oscar a la Mejor Película de Animación en 2003?', 1, 18),
(199, '¿Qué tecnología inalámbrica se utiliza comúnmente para realizar pagos sin contacto mediante dispositivos móviles?', 1, 19),
(200, '¿Qué significa la sigla \"IoT\" en el contexto de la tecnología?', 1, 20),
(201, '¿Qué software, utilizado en centros de datos, permite la virtualización de servidores creando múltiples máquinas virtuales en un solo servidor físico?', 1, 21),
(202, '¿Cuánto es 12 + 8?', 1, 22),
(203, 'Si un triángulo tiene dos ángulos de 35° cada uno, ¿cuánto mide el tercer ángulo?', 1, 23),
(204, '¿Cuál es el siguiente número en la secuencia: 4, 7, 11, 16, ... ?', 1, 24),
(205, '¿Cuál es el lugar más frío de la tierra?', 1, 25),
(206, '¿En qué ciudad se originaron los juegos olímpicos?', 1, 26),
(207, '¿Cómo se llama el himno nacional de Francia?', 1, 27),
(208, '¿Quién es conocido como el \"Padre del Blues\"?', 1, 28),
(209, '¿Qué instrumento de viento es fundamental en el jazz tradicional de Nueva Orleans?', 1, 29),
(210, '¿Qué compositor y pianista estadounidense fusionó el jazz con elementos de la música clásica y es autor de \"Rhapsody in Blue\"?', 1, 30),
(213, 'adgsedgsg', 1, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ranking`
--

CREATE TABLE `ranking` (
  `id_usuario` int NOT NULL,
  `rondas` int DEFAULT NULL,
  `puntos` int DEFAULT NULL,
  `posicion` int UNSIGNED DEFAULT NULL,
  `categoria_destacada` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `ranking`
--

INSERT INTO `ranking` (`id_usuario`, `rondas`, `puntos`, `posicion`, `categoria_destacada`) VALUES
(16, 209, 1590, 1, 9),
(21, 4, 60, 3, 2),
(22, 6, 90, 2, 7),
(23, 1, 30, 4, 9);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `respuesta`
--

CREATE TABLE `respuesta` (
  `id_respuesta` int NOT NULL,
  `texto` text NOT NULL,
  `es_correcta` tinyint(1) NOT NULL DEFAULT '0',
  `habilitado` tinyint(1) DEFAULT '1',
  `id_pregunta` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `respuesta`
--

INSERT INTO `respuesta` (`id_respuesta`, `texto`, `es_correcta`, `habilitado`, `id_pregunta`) VALUES
(1, 'Venus', 0, 1, 1),
(2, 'Marte', 0, 1, 1),
(3, 'Mercurio', 1, 1, 1),
(4, 'Júpiter', 0, 1, 1),
(5, 'Oxígeno', 0, 1, 2),
(6, 'Dióxido de carbono', 0, 1, 2),
(7, 'Nitrógeno', 1, 1, 2),
(8, 'Helio', 0, 1, 2),
(9, 'Albert Einstein', 0, 1, 3),
(10, 'Hermann Minkowski', 1, 1, 3),
(11, 'Max Planck', 0, 1, 3),
(12, 'Niels Bohr', 0, 1, 3),
(13, '1492', 1, 1, 4),
(14, '1487', 0, 1, 4),
(15, '1512', 0, 1, 4),
(16, '1678', 0, 1, 4),
(17, '1776', 0, 1, 5),
(18, '1789', 1, 1, 5),
(19, '1804', 0, 1, 5),
(20, '1812', 0, 1, 5),
(21, 'Genghis Khan', 1, 1, 6),
(22, 'Tamerlán', 0, 1, 6),
(23, 'Kublai Khan', 0, 1, 6),
(24, 'Atila el Huno', 0, 1, 6),
(25, 'Amazonas', 0, 1, 7),
(26, 'Yangtsé', 0, 1, 7),
(27, 'Misisipi', 0, 1, 7),
(28, 'Nilo', 1, 1, 7),
(29, 'Mar Arábigo', 1, 1, 8),
(30, 'Mar Mediterraneo', 0, 1, 8),
(31, 'Mar Negro', 0, 1, 8),
(32, 'Mar Adriático', 0, 1, 8),
(33, 'Argentina', 0, 1, 9),
(34, 'Chile', 1, 1, 9),
(35, 'Perú', 0, 1, 9),
(36, 'Bolivia', 0, 1, 9),
(37, 'Fútbol', 0, 1, 10),
(38, 'Tenis', 1, 1, 10),
(39, 'Baloncesto', 0, 1, 10),
(40, 'Rugby', 0, 1, 10),
(41, 'Usain Bolt', 1, 1, 11),
(42, 'Michael Phelps', 0, 1, 11),
(43, 'Nathon Allen', 0, 1, 11),
(44, 'Aleen Bailey', 0, 1, 11),
(45, 'Real Madrid', 0, 1, 12),
(46, 'AC Milan', 0, 1, 12),
(47, 'Manchester United', 0, 1, 12),
(48, 'Olympique de Marsella', 1, 1, 12),
(49, 'Vicent Van Gogh', 0, 1, 13),
(50, 'Pablo Picasso', 0, 1, 13),
(51, 'Leonardo Da Vinci', 1, 1, 13),
(52, 'Miguel Ángel', 0, 1, 13),
(53, 'Pablo Picasso', 0, 1, 14),
(54, 'Vincent van Gogh', 0, 1, 14),
(55, 'Claude Monet', 0, 1, 14),
(56, 'Salvador Dalí', 1, 1, 14),
(57, 'Albert Camus', 0, 1, 15),
(58, 'Marcel Proust', 1, 1, 15),
(59, 'Jean-Paul Sartre', 0, 1, 15),
(60, 'Victor Hugo', 0, 1, 15),
(61, 'Chris Evans', 0, 1, 16),
(62, 'Robert Downey Jr.', 1, 1, 16),
(63, 'Chris Hemsworth', 0, 1, 16),
(64, 'Mark Ruffalo', 0, 1, 16),
(65, 'Steven Spielberg', 0, 1, 17),
(66, 'Peter Jackson', 1, 1, 17),
(67, 'James Cameron', 0, 1, 17),
(68, 'Ridley Scott', 0, 1, 17),
(69, 'Dark', 1, 1, 18),
(70, 'Babylon Berlin', 0, 1, 18),
(71, 'Deutschland 83', 0, 1, 18),
(72, 'Perfume', 0, 1, 18),
(73, 'Android', 0, 1, 19),
(74, 'Windows Phone', 0, 1, 19),
(75, 'BlackBerry OS', 0, 1, 19),
(76, 'iOS', 1, 1, 19),
(77, 'HighText Machine Language', 0, 1, 20),
(78, 'Home Tool Markup Language', 0, 1, 20),
(79, 'HyperText Markup Language', 1, 1, 20),
(80, 'Hyperlinking Text Management Language', 0, 1, 20),
(81, 'Ataque de fuerza bruta', 0, 1, 21),
(82, 'Ataque de intermediario (Man-in-the-Middle)', 1, 1, 21),
(83, 'Phishing', 0, 1, 21),
(84, 'Denegación de servicio (DDoS)', 0, 1, 21),
(85, '81', 1, 1, 22),
(86, '72', 0, 1, 22),
(87, '92', 0, 1, 22),
(88, '99', 0, 1, 22),
(89, 'Triángulo equilátero', 0, 1, 23),
(90, 'Triángulo isósceles', 0, 1, 23),
(91, 'Triángulo escaleno', 0, 1, 23),
(92, 'Triángulo rectángulo isósceles', 1, 1, 23),
(93, '6/10', 1, 1, 24),
(94, '6/9', 0, 1, 24),
(95, '6/20', 0, 1, 24),
(96, '12/20', 0, 1, 24),
(97, 'Madrid', 0, 1, 25),
(98, 'París', 1, 1, 25),
(99, 'Roma', 0, 1, 25),
(100, 'Berlín', 0, 1, 25),
(101, 'Gabriel García Márquez', 1, 1, 26),
(102, 'Julio Cortázar', 0, 1, 26),
(103, 'Mario Vargas Llosa', 0, 1, 26),
(104, 'Isabel Allende', 0, 1, 26),
(105, 'Reino Unido', 0, 1, 27),
(106, 'Estados Unidos', 0, 1, 27),
(107, 'Australia', 0, 1, 27),
(108, 'Nueva Zelanda', 1, 1, 27),
(109, 'Michael Jackson', 1, 1, 28),
(110, 'Elvis Presley', 0, 1, 28),
(111, 'Freddie Mercury', 0, 1, 28),
(112, 'Prince', 0, 1, 28),
(113, 'Pink Floyd', 1, 1, 29),
(114, 'The Beatles', 0, 1, 29),
(115, 'Led Zeppelin', 0, 1, 29),
(116, 'The Rolling Stones', 0, 1, 29),
(117, 'La consagración de la primavera', 1, 1, 30),
(118, 'Claro de Luna', 0, 1, 30),
(119, 'La Traviata', 0, 1, 30),
(120, 'El Mesías', 0, 1, 30),
(121, 'CO₂', 0, 1, 31),
(122, 'O₂', 0, 1, 31),
(123, 'H₂O', 1, 1, 31),
(124, 'NaCl', 0, 1, 31),
(125, 'Una partícula subatómica sin carga eléctrica', 1, 1, 32),
(126, 'Una partícula subatómica con carga positiva', 0, 1, 32),
(127, 'Un tipo de radiación electromagnética', 0, 1, 32),
(128, 'Un átomo inestable', 0, 1, 32),
(129, '1.38 × 10⁻²³ J/K', 0, 1, 33),
(130, '9.81 m/s²', 0, 1, 33),
(131, '3.00 × 10⁸ m/s', 0, 1, 33),
(132, '6.63 × 10⁻³⁴ J·s', 1, 1, 33),
(133, 'George Washington', 1, 1, 34),
(134, 'Abraham Lincoln', 0, 1, 34),
(135, 'Thomas Jefferson', 0, 1, 34),
(136, 'John Adams', 0, 1, 34),
(137, '1993', 0, 1, 35),
(138, '1987', 0, 1, 35),
(139, '1991', 0, 1, 35),
(140, '1989', 1, 1, 35),
(141, 'Tratado de Brest-Litovsk', 0, 1, 36),
(142, 'Tratado de Versalles', 1, 1, 36),
(143, 'Tratado de Trianon', 0, 1, 36),
(144, 'Tratado de Utrecht', 0, 1, 36),
(145, 'Bangkok', 0, 1, 37),
(146, 'Pekín', 0, 1, 37),
(147, 'Tokio', 1, 1, 37),
(148, 'Seúl', 0, 1, 37),
(149, 'Canadá', 0, 1, 38),
(150, 'China', 0, 1, 38),
(151, 'Estados Unidos', 0, 1, 38),
(152, 'Rusia', 1, 1, 38),
(153, 'Monte Everest', 0, 1, 39),
(154, 'Aconcagua', 0, 1, 39),
(155, 'Chimborazo', 1, 1, 39),
(156, 'Denali', 0, 1, 39),
(157, '9', 0, 1, 40),
(158, '11', 1, 1, 40),
(159, '10', 0, 1, 40),
(160, '12', 0, 1, 40),
(161, 'Roger Federer', 0, 1, 41),
(162, 'Rafael Nadal', 0, 1, 41),
(163, 'Pete Sampras', 0, 1, 41),
(164, 'Novak Djokovic', 1, 1, 41),
(165, 'Argentina', 0, 1, 42),
(166, 'Uruguay', 1, 1, 42),
(167, 'Brasil', 0, 1, 42),
(168, 'Chile', 0, 1, 42),
(169, 'George Orwell', 1, 1, 43),
(170, 'Aldous Huxley', 0, 1, 43),
(171, 'Ray Bradbury', 0, 1, 43),
(172, 'Franz Kafka', 0, 1, 43),
(173, 'Realismo', 0, 1, 44),
(174, 'Impresionismo', 1, 1, 44),
(175, 'Expresionismo', 0, 1, 44),
(176, 'Surrealismo', 0, 1, 44),
(177, 'Finnegans Wake', 0, 1, 45),
(178, 'Dubliners', 0, 1, 45),
(179, 'Retrato del artista adolescente', 0, 1, 45),
(180, 'Ulises', 1, 1, 45),
(181, 'Toy Story', 0, 1, 46),
(182, 'Shrek', 0, 1, 46),
(183, 'Buscando a Nemo', 1, 1, 46),
(184, 'Cars', 0, 1, 46),
(185, 'Martin Scorsese', 0, 1, 47),
(186, 'Quentin Tarantino', 1, 1, 47),
(187, 'Steven Soderbergh', 0, 1, 47),
(188, 'Guy Ritchie', 0, 1, 47),
(189, 'Titanic', 0, 1, 48),
(190, 'Ben-Hur', 0, 1, 48),
(191, 'La La Land', 0, 1, 48),
(192, 'El Señor de los Anillos: El Retorno del Rey', 1, 1, 48),
(193, 'Microsoft', 1, 1, 49),
(194, 'IBM', 0, 1, 49),
(195, 'Apple', 0, 1, 49),
(196, 'Google', 0, 1, 49),
(197, 'Facebook', 1, 1, 50),
(198, 'Twitter', 0, 1, 50),
(199, 'Instagram', 0, 1, 50),
(200, 'MySpace', 0, 1, 50),
(201, 'Algoritmos genéticos', 0, 1, 51),
(202, 'Machine Learning', 0, 1, 51),
(203, 'Deep Learning', 1, 1, 51),
(204, 'Procesamiento de lenguaje natural', 0, 1, 51),
(205, '54', 0, 1, 52),
(206, '56', 1, 1, 52),
(207, '64', 0, 1, 52),
(208, '48', 0, 1, 52),
(209, '11', 0, 1, 53),
(210, '12', 0, 1, 53),
(211, '14', 1, 1, 53),
(212, '13,5', 0, 1, 53),
(213, '1', 0, 1, 54),
(214, '5', 1, 1, 54),
(215, '0', 0, 1, 54),
(216, 'e', 0, 1, 54),
(217, 'China', 0, 1, 55),
(218, 'Tailandia', 0, 1, 55),
(219, 'Corea del Sur', 0, 1, 55),
(220, 'Japón', 1, 1, 55),
(221, '1945', 1, 1, 56),
(222, '1919', 0, 1, 56),
(223, '1960', 0, 1, 56),
(224, '1951', 0, 1, 56),
(225, '1948', 1, 1, 57),
(226, '1939', 0, 1, 57),
(227, '1955', 0, 1, 57),
(228, '1951', 0, 1, 57),
(229, 'Guitarra', 0, 1, 58),
(230, 'Piano', 1, 1, 58),
(231, 'Violín', 0, 1, 58),
(232, 'Batería', 0, 1, 58),
(233, 'Tango', 0, 1, 59),
(234, 'Salsa', 0, 1, 59),
(235, 'Reggae', 1, 1, 59),
(236, 'Blues', 0, 1, 59),
(237, 'Giuseppe Verdi', 1, 1, 60),
(238, 'Ludwig van Beethoven', 0, 1, 60),
(239, 'Johann Sebastian Bach', 0, 1, 60),
(240, 'Richard Wagner', 0, 1, 60),
(241, 'Aluminio', 1, 1, 61),
(242, 'Oro', 0, 1, 61),
(243, 'Cobre', 0, 1, 61),
(244, 'Hierro', 0, 1, 61),
(245, 'Ohmios', 0, 1, 62),
(246, 'Voltios', 0, 1, 62),
(247, 'Amperios', 1, 1, 62),
(248, 'Vatios', 0, 1, 62),
(249, 'Marie Curie', 1, 1, 63),
(250, 'Dorothy Crowfoot Hodgkin', 0, 1, 63),
(251, 'Rosalind Franklin', 0, 1, 63),
(252, 'Barbara McClintock', 0, 1, 63),
(253, 'Estados Unidos', 0, 1, 64),
(254, 'Alemania', 0, 1, 64),
(255, 'Francia', 0, 1, 64),
(256, 'Reino Unido', 1, 1, 64),
(257, 'La invasión de Polonia por Alemania', 1, 1, 65),
(258, 'El ataque a Pearl Harbor', 0, 1, 65),
(259, 'La firma del Tratado de Versalles', 0, 1, 65),
(260, 'La Guerra Civil Española', 0, 1, 65),
(261, 'Kublai Khan', 0, 1, 66),
(262, 'Qin Shi Huang', 1, 1, 66),
(263, 'Sun Yat-sen', 0, 1, 66),
(264, 'Confucio', 0, 1, 66),
(265, 'Asia', 0, 1, 67),
(266, 'Europa', 0, 1, 67),
(267, 'África', 1, 1, 67),
(268, 'América', 0, 1, 67),
(269, 'Francia', 1, 1, 68),
(270, 'Rusia', 0, 1, 68),
(271, 'Estados Unidos', 0, 1, 68),
(272, 'China', 0, 1, 68),
(273, 'Lago Victoria', 0, 1, 69),
(274, 'Lago Superior', 0, 1, 69),
(275, 'Lago Baikal', 1, 1, 69),
(276, 'Lago Titicaca', 0, 1, 69),
(277, '4', 0, 1, 70),
(278, '5', 1, 1, 70),
(279, '6', 0, 1, 70),
(280, '3', 0, 1, 70),
(281, 'Canadá', 0, 1, 71),
(282, 'Estados Unidos', 1, 1, 71),
(283, 'Reino Unido', 0, 1, 71),
(284, 'Grecia', 0, 1, 71),
(285, '3', 1, 1, 72),
(286, '2', 0, 1, 72),
(287, '4', 0, 1, 72),
(288, '5', 0, 1, 72),
(289, 'Caravaggio', 0, 1, 73),
(290, 'Miguel Ángel', 1, 1, 73),
(291, 'Rafael', 0, 1, 73),
(292, 'Leonardo da Vinci', 0, 1, 73),
(293, 'Orgullo y prejuicio', 1, 1, 74),
(294, 'Cumbres Borrascosas', 0, 1, 74),
(295, 'Crimen y castigo', 0, 1, 74),
(296, 'Matar a un ruiseñor', 0, 1, 74),
(297, 'Wolfgang Amadeus Mozart', 0, 1, 75),
(298, 'Ludwig van Beethoven', 0, 1, 75),
(299, 'Giuseppe Verdi', 0, 1, 75),
(300, 'Gioachino Rossini', 1, 1, 75),
(301, 'Gato con Botas', 0, 1, 76),
(302, 'Asno', 0, 1, 76),
(303, 'Burro', 1, 1, 76),
(304, 'Pinocho', 0, 1, 76),
(305, 'Breaking Bad', 1, 1, 77),
(306, 'The Wire', 0, 1, 77),
(307, 'Better Call Saul', 0, 1, 77),
(308, 'Narcos', 0, 1, 77),
(309, 'Steven Spielberg', 0, 1, 78),
(310, 'Christopher Nolan', 0, 1, 78),
(311, 'John Ford', 1, 1, 78),
(312, 'Martin Scorsese', 0, 1, 78),
(313, 'Universal System Bus', 0, 1, 79),
(314, 'United Software Base', 0, 1, 79),
(315, 'Universal Serial Bus', 1, 1, 79),
(316, 'Ultimate Standard Board', 0, 1, 79),
(317, 'Apple', 0, 1, 80),
(318, 'Microsoft', 0, 1, 80),
(319, 'IBM', 0, 1, 80),
(320, 'Google', 1, 1, 80),
(321, 'Alan Turing', 1, 1, 81),
(322, 'Charles Babbage', 0, 1, 81),
(323, 'John von Neumann', 0, 1, 81),
(324, 'Claude Shannon', 0, 1, 81),
(325, '13', 1, 1, 82),
(326, '16', 0, 1, 82),
(327, '10', 0, 1, 82),
(328, '8', 0, 1, 82),
(329, '10', 1, 1, 83),
(330, '8', 0, 1, 83),
(331, '6', 0, 1, 83),
(332, '4', 0, 1, 83),
(333, '', 0, 1, 84),
(334, '', 0, 1, 84),
(335, '', 0, 1, 84),
(336, '', 0, 1, 84),
(337, 'Inglés', 0, 1, 85),
(338, 'Español', 0, 1, 85),
(339, 'Hindi', 0, 1, 85),
(340, 'Chino mandarín', 1, 1, 85),
(341, 'Inca', 1, 1, 86),
(342, 'Azteca', 0, 1, 86),
(343, 'Maya', 0, 1, 86),
(344, 'Olmeca', 0, 1, 86),
(345, 'Tratado de Versalles', 0, 1, 87),
(346, 'Tratado de Westfalia', 1, 1, 87),
(347, 'Tratado de Tordesillas', 0, 1, 87),
(348, 'Tratado de Utrecht', 0, 1, 87),
(349, 'Guitarra', 0, 1, 88),
(350, 'Clarinete', 1, 1, 88),
(351, 'Trompeta', 0, 1, 88),
(352, 'Batería', 0, 1, 88),
(353, 'Dave Grohl', 0, 1, 89),
(354, 'Kurt Cobain', 1, 1, 89),
(355, 'Eddie Vedder', 0, 1, 89),
(356, 'Chris Cornell', 0, 1, 89),
(357, 'Richard Strauss', 0, 1, 90),
(358, 'Johannes Brahms', 0, 1, 90),
(359, 'Gustav Mahler', 0, 1, 90),
(360, 'Richard Wagner', 1, 1, 90),
(361, 'Hígado', 0, 1, 91),
(362, 'Pulmones', 0, 1, 91),
(363, 'Corazón', 0, 1, 91),
(364, 'Piel', 1, 1, 91),
(365, 'Protón', 0, 1, 92),
(366, 'Neutrón', 0, 1, 92),
(367, 'Electrón', 1, 1, 92),
(368, 'Quark', 0, 1, 92),
(369, 'F=ma', 0, 1, 93),
(370, 'E=mc²', 1, 1, 93),
(371, 'PV=nRT', 0, 1, 93),
(372, 'a² + b² = c²', 0, 1, 93),
(373, '1776', 1, 1, 94),
(374, '1783', 0, 1, 94),
(375, '1765', 0, 1, 94),
(376, '1801', 0, 1, 94),
(377, 'Batalla de Leningrado', 0, 1, 95),
(378, 'Batalla de Moscú', 0, 1, 95),
(379, 'Batalla de Stalingrado', 1, 1, 95),
(380, 'Batalla de Kursk', 0, 1, 95),
(381, 'Tetrarquía', 1, 1, 96),
(382, 'Edicto de Milán', 0, 1, 96),
(383, 'Pax Romana', 0, 1, 96),
(384, 'Reforma de Constantino', 0, 1, 96),
(385, 'Melbourne', 0, 1, 97),
(386, 'Sídney', 0, 1, 97),
(387, 'Canberra', 1, 1, 97),
(388, 'Brisbane', 0, 1, 97),
(389, 'Rin', 0, 1, 98),
(390, 'Danubio', 0, 1, 98),
(391, 'Loira', 0, 1, 98),
(392, 'Volga', 1, 1, 98),
(393, 'Noruega', 0, 1, 99),
(394, 'Indonesia', 0, 1, 99),
(395, 'Suecia', 1, 1, 99),
(396, 'Finlandia', 0, 1, 99),
(397, 'Argentina', 0, 1, 100),
(398, 'Brasil', 1, 1, 100),
(399, 'Alemania', 0, 1, 100),
(400, 'Italia', 0, 1, 100),
(401, 'Mark Spitz', 0, 1, 101),
(402, 'Ryan Lochte', 0, 1, 101),
(403, 'Michael Phelps', 1, 1, 101),
(404, 'Ian Thorpe', 0, 1, 101),
(405, '1991', 0, 1, 102),
(406, '1987', 1, 1, 102),
(407, '1995', 0, 1, 102),
(408, '1983', 0, 1, 102),
(409, 'Gabriel García Márquez', 0, 1, 103),
(410, 'Miguel de Cervantes', 1, 1, 103),
(411, 'Lope de Vega', 0, 1, 103),
(412, 'William Shakespeare', 0, 1, 103),
(413, 'Impresionismo', 0, 1, 104),
(414, 'Expresionismo', 0, 1, 104),
(415, 'Cubismo', 1, 1, 104),
(416, 'Surrealismo', 0, 1, 104),
(417, 'La Ilíada', 0, 1, 105),
(418, 'La Odisea', 0, 1, 105),
(419, 'La Eneida', 0, 1, 105),
(420, 'El poema de Gilgamesh', 1, 1, 105),
(421, 'Superman', 0, 1, 106),
(422, 'Batman', 1, 1, 106),
(423, 'Iron Man', 0, 1, 106),
(424, 'Spider-Man', 0, 1, 106),
(425, '1999', 0, 1, 107),
(426, '2001', 1, 1, 107),
(427, '2003', 0, 1, 107),
(428, '2005', 0, 1, 107),
(429, 'Hans Zimmer', 0, 1, 108),
(430, 'Howard Shore', 1, 1, 108),
(431, 'John Williams', 0, 1, 108),
(432, 'James Newton Howard', 0, 1, 108),
(433, 'Un disco duro de estado sólido', 1, 1, 109),
(434, 'Un disco duro mecánico', 0, 1, 109),
(435, 'Una memoria volátil', 0, 1, 109),
(436, 'Un procesador gráfico', 0, 1, 109),
(437, 'SFTP', 1, 1, 110),
(438, 'SMTP', 0, 1, 110),
(439, 'Telnet', 0, 1, 110),
(440, 'FTP', 0, 1, 110),
(441, '1985', 0, 1, 111),
(442, '1991', 1, 1, 111),
(443, '2000', 0, 1, 111),
(444, '1995', 0, 1, 111),
(445, '6', 0, 1, 112),
(446, '7', 0, 1, 112),
(447, '8', 1, 1, 112),
(448, '9', 0, 1, 112),
(449, '16', 0, 1, 113),
(450, '32', 1, 1, 113),
(451, '64', 0, 1, 113),
(452, '128', 0, 1, 113),
(453, '35', 1, 1, 114),
(454, '21', 0, 1, 114),
(455, '42', 0, 1, 114),
(456, '49', 0, 1, 114),
(457, 'Bélgica', 0, 1, 115),
(458, 'Holanda', 1, 1, 115),
(459, 'Alemania', 0, 1, 115),
(460, 'Francia', 0, 1, 115),
(461, 'León', 0, 1, 116),
(462, 'Dragón', 0, 1, 116),
(463, 'Unicornio', 1, 1, 116),
(464, 'Águila', 0, 1, 116),
(465, 'Genji Monogatari', 1, 1, 117),
(466, 'El Decamerón', 0, 1, 117),
(467, 'Los Cuentos de Canterbury', 0, 1, 117),
(468, 'Don Quijote de la Mancha', 0, 1, 117),
(469, 'The Rolling Stones', 0, 1, 118),
(470, 'The Beatles', 1, 1, 118),
(471, 'Queen', 0, 1, 118),
(472, 'Pink Floyd', 0, 1, 118),
(473, 'Peter Tosh', 0, 1, 119),
(474, 'Jimmy Cliff', 0, 1, 119),
(475, 'Bob Marley', 1, 1, 119),
(476, 'Burning Spear', 0, 1, 119),
(477, 'Thriller de Michael Jackson', 0, 1, 120),
(478, 'Video Killed the Radio Star de The Buggles', 1, 1, 120),
(479, 'Take On Me de A-ha', 0, 1, 120),
(480, 'Like a Virgin de Madonna', 0, 1, 120),
(481, 'Venus', 0, 1, 121),
(482, 'Marte', 1, 1, 121),
(483, 'Júpiter', 0, 1, 121),
(484, 'Saturno', 0, 1, 121),
(485, '150,000 km/s', 0, 1, 122),
(486, '300,000 km/s', 1, 1, 122),
(487, '600,000 km/s', 0, 1, 122),
(488, '450,000 km/s', 0, 1, 122),
(489, 'Efecto túnel', 1, 1, 123),
(490, 'Colapso de la función de onda', 0, 1, 123),
(491, 'Principio de superposición', 0, 1, 123),
(492, 'Resonancia cuántica', 0, 1, 123),
(493, 'Egipcia', 1, 1, 124),
(494, 'Azteca', 0, 1, 124),
(495, 'China', 0, 1, 124),
(496, 'Griega', 0, 1, 124),
(497, 'Tolteca', 0, 1, 125),
(498, 'Azteca', 1, 1, 125),
(499, 'Inca', 0, 1, 125),
(500, 'Maya', 0, 1, 125),
(501, '1299', 0, 1, 126),
(502, '1453', 1, 1, 126),
(503, '1517', 0, 1, 126),
(504, '1683', 0, 1, 126),
(505, 'Toronto', 0, 1, 127),
(506, 'Montreal', 0, 1, 127),
(507, 'Ottawa', 1, 1, 127),
(508, 'Vancouver', 0, 1, 127),
(509, 'Lago Superior', 1, 1, 128),
(510, 'Lago Victoria', 0, 1, 128),
(511, 'Lago Baikal', 0, 1, 128),
(512, 'Lago Michigan', 0, 1, 128),
(513, 'Montañas Rocosas', 0, 1, 129),
(514, 'Himalaya', 0, 1, 129),
(515, 'Alpes', 0, 1, 129),
(516, 'Los Andes', 1, 1, 129),
(517, '4', 0, 1, 130),
(518, '5', 0, 1, 130),
(519, '6', 1, 1, 130),
(520, '7', 0, 1, 130),
(521, 'Rusia', 0, 1, 131),
(522, 'Noruega', 1, 1, 131),
(523, 'Estados Unidos', 0, 1, 131),
(524, 'Dinamarca', 0, 1, 131),
(525, '1919', 0, 1, 132),
(526, '1925', 0, 1, 132),
(527, '1920', 1, 1, 132),
(528, '1930', 0, 1, 132),
(529, 'Vincent van Gogh', 1, 1, 133),
(530, 'Pablo Picasso', 0, 1, 133),
(531, 'Claude Monet', 0, 1, 133),
(532, 'Salvador Dalí', 0, 1, 133),
(533, 'Charles Dickens', 0, 1, 134),
(534, 'Oscar Wilde', 1, 1, 134),
(535, 'Mark Twain', 0, 1, 134),
(536, 'Edgar Allan Poe', 0, 1, 134),
(537, 'Gabriela Mistral', 0, 1, 135),
(538, 'Pablo Neruda', 1, 1, 135),
(539, 'Nicanor Parra', 0, 1, 135),
(540, 'Vicente Huidobro', 0, 1, 135),
(541, 'Brad Pitt', 0, 1, 136),
(542, 'Johnny Depp', 0, 1, 136),
(543, 'Leonardo DiCaprio', 1, 1, 136),
(544, 'Tom Cruise', 0, 1, 136),
(545, 'Wes Anderson', 1, 1, 137),
(546, 'Quentin Tarantino', 0, 1, 137),
(547, 'Martin Scorsese', 0, 1, 137),
(548, 'Steven Spielberg', 0, 1, 137),
(549, 'Mar adentro', 0, 1, 138),
(550, 'Todo sobre mi madre', 1, 1, 138),
(551, 'Volver', 0, 1, 138),
(552, 'El laberinto del fauno', 0, 1, 138),
(553, 'Read Access Memory', 0, 1, 139),
(554, 'Random Access Memory', 1, 1, 139),
(555, 'Rapid Application Mode', 0, 1, 139),
(556, 'Real-time Array Memory', 0, 1, 139),
(557, 'Cable Ethernet', 0, 1, 140),
(558, 'Router', 0, 1, 140),
(559, 'Adaptador Wi-Fi', 1, 1, 140),
(560, 'Switch', 0, 1, 140),
(561, 'Un lenguaje de programación para aplicaciones web', 0, 1, 141),
(562, 'Un sistema operativo basado en nodos distribuidos', 0, 1, 141),
(563, 'Una cadena de bloques descentralizada utilizada para registrar transacciones de criptomonedas', 1, 1, 141),
(564, 'Una base de datos centralizada para almacenar registros financieros', 0, 1, 141),
(565, '14', 0, 1, 142),
(566, '15', 1, 1, 142),
(567, '16', 0, 1, 142),
(568, '17', 0, 1, 142),
(569, '7', 0, 1, 143),
(570, '8', 1, 1, 143),
(571, '12', 0, 1, 143),
(572, '6', 0, 1, 143),
(573, '30', 1, 1, 144),
(574, '28', 0, 1, 144),
(575, '32', 0, 1, 144),
(576, '31', 0, 1, 144),
(577, 'Leonardo da Vinci', 0, 1, 145),
(578, 'Johannes Gutenberg', 1, 1, 145),
(579, 'Thomas Edison', 0, 1, 145),
(580, 'Galileo Galilei', 0, 1, 145),
(581, 'México', 0, 1, 146),
(582, 'Argentina', 1, 1, 146),
(583, 'España', 0, 1, 146),
(584, 'Brasil', 0, 1, 146),
(585, '1492', 0, 1, 147),
(586, '1494', 1, 1, 147),
(587, '1500', 0, 1, 147),
(588, '1517', 0, 1, 147),
(589, 'Dr. Dre', 0, 1, 148),
(590, '50 Cent', 0, 1, 148),
(591, 'Eminem', 1, 1, 148),
(592, 'Snoop Dogg', 0, 1, 148),
(593, 'The Rolling Stones', 0, 1, 149),
(594, 'The Eagles', 1, 1, 149),
(595, 'Fleetwood Mac', 0, 1, 149),
(596, 'Led Zeppelin', 0, 1, 149),
(597, 'Giuseppe Verdi', 0, 1, 150),
(598, 'Ludwig van Beethoven', 0, 1, 150),
(599, 'Wolfgang Amadeus Mozart', 1, 1, 150),
(600, 'Richard Wagner', 0, 1, 150),
(601, 'Oro', 1, 1, 151),
(602, 'Osmio', 0, 1, 151),
(603, 'Oxalato', 0, 1, 151),
(604, 'Oxígeno', 1, 1, 151),
(605, 'Joule', 0, 1, 152),
(606, 'Newton', 1, 1, 152),
(607, 'Pascal', 0, 1, 152),
(608, 'Watt', 0, 1, 152),
(609, 'Fuerza gravitatoria', 0, 1, 153),
(610, 'Fuerza electromagnética', 0, 1, 153),
(611, 'Fuerza nuclear fuerte', 0, 1, 153),
(612, 'Fuerza centrífuga', 1, 1, 153),
(613, 'Vladimir Lenin', 1, 1, 154),
(614, 'Josef Stalin', 0, 1, 154),
(615, 'León Trotsky', 0, 1, 154),
(616, 'Nicolás II', 0, 1, 154),
(617, '1987', 0, 1, 155),
(618, '1989', 1, 1, 155),
(619, '1991', 0, 1, 155),
(620, '1993', 0, 1, 155),
(621, 'El asesinato del archiduque Francisco Fernando', 1, 1, 156),
(622, 'La invasión de Polonia', 0, 1, 156),
(623, 'El hundimiento del Lusitania', 0, 1, 156),
(624, 'La Revolución Rusa', 0, 1, 156),
(625, 'India', 1, 1, 157),
(626, 'China', 0, 1, 157),
(627, 'Indonesia', 0, 1, 157),
(628, 'Estados Unidos', 0, 1, 157),
(629, 'Desierto del Sahara', 1, 1, 158),
(630, 'Desierto de Gobi', 0, 1, 158),
(631, 'Desierto de Arabia', 0, 1, 158),
(632, 'Desierto del Kalahari', 0, 1, 158),
(633, 'Península Escandinava', 0, 1, 159),
(634, 'Península Ibérica', 0, 1, 159),
(635, 'Península Arábiga', 1, 1, 159),
(636, 'Península Indochina', 0, 1, 159),
(637, '13', 0, 1, 160),
(638, '15', 1, 1, 160),
(639, '17', 0, 1, 160),
(640, '11', 0, 1, 160),
(641, '1948', 0, 1, 161),
(642, '1950', 1, 1, 161),
(643, '1952', 0, 1, 161),
(644, '1954', 0, 1, 161),
(645, '1956', 0, 1, 162),
(646, '1960', 1, 1, 162),
(647, '1964', 0, 1, 162),
(648, '1968', 0, 1, 162),
(649, 'Salvador Dalí', 0, 1, 163),
(650, 'Francisco de Goya', 0, 1, 163),
(651, 'Pablo Picasso', 1, 1, 163),
(652, 'Joan Miró', 0, 1, 163),
(653, 'Hamlet', 1, 1, 164),
(654, 'Macbeth', 0, 1, 164),
(655, 'Romeo y Julieta', 0, 1, 164),
(656, 'Othello', 0, 1, 164),
(657, 'Julio Cortázar', 1, 1, 165),
(658, 'Gabriel García Márquez', 0, 1, 165),
(659, 'Mario Vargas Llosa', 0, 1, 165),
(660, 'Carlos Fuentes', 0, 1, 165),
(661, 'Cars', 0, 1, 166),
(662, 'Toy Story', 1, 1, 166),
(663, 'Monsters, Inc.', 0, 1, 166),
(664, 'Up', 0, 1, 166),
(665, 'Pulp Fiction', 0, 1, 167),
(666, 'The Shawshank Redemption', 1, 1, 167),
(667, 'Forrest Gump', 0, 1, 167),
(668, 'Se7en', 0, 1, 167),
(669, '1900', 0, 1, 168),
(670, '1910', 0, 1, 168),
(671, '1927', 1, 1, 168),
(672, '1941', 0, 1, 168),
(673, 'GPU', 0, 1, 169),
(674, 'CPU', 1, 1, 169),
(675, 'RAM', 0, 1, 169),
(676, 'SSD', 0, 1, 169),
(677, 'C#', 0, 1, 170),
(678, 'Java', 1, 1, 170),
(679, 'Python', 0, 1, 170),
(680, 'JavaScript', 0, 1, 170),
(681, 'Automatic Programming Interface', 0, 1, 171),
(682, 'Application Performance Index', 0, 1, 171),
(683, 'Application Programming Interface', 1, 1, 171),
(684, 'Advanced Process Integration', 0, 1, 171),
(685, '3', 0, 1, 172),
(686, '4', 1, 1, 172),
(687, '5', 0, 1, 172),
(688, '6', 0, 1, 172),
(689, '10', 0, 1, 173),
(690, '15', 1, 1, 173),
(691, '20', 0, 1, 173),
(692, '25', 0, 1, 173),
(693, '31', 0, 1, 174),
(694, '33', 1, 1, 174),
(695, '35', 0, 1, 174),
(696, '37', 0, 1, 174),
(697, 'Italia', 0, 1, 175),
(698, 'España', 1, 1, 175),
(699, 'México', 0, 1, 175),
(700, 'Argentina', 0, 1, 175),
(701, 'Dólar', 0, 1, 176),
(702, 'Yuan', 0, 1, 176),
(703, 'Yen', 1, 1, 176),
(704, 'Won', 0, 1, 176),
(705, 'Catedral de Chartres', 0, 1, 177),
(706, 'Catedral de Reims', 0, 1, 177),
(707, 'Catedral de Amiens', 0, 1, 177),
(708, 'Catedral de Notre-Dame', 1, 1, 177),
(709, 'Rock', 0, 1, 178),
(710, 'Pop', 0, 1, 178),
(711, 'Jazz', 1, 1, 178),
(712, 'Blues', 0, 1, 178),
(713, 'Whitney Houston', 0, 1, 179),
(714, 'Aretha Franklin', 1, 1, 179),
(715, 'Tina Turner', 0, 1, 179),
(716, 'Mariah Carey', 0, 1, 179),
(717, 'Miles Davis', 0, 1, 180),
(718, 'John Coltrane', 0, 1, 180),
(719, 'Ornette Coleman', 1, 1, 180),
(720, 'Charles Mingus', 0, 1, 180),
(721, 'Pulmones', 0, 1, 181),
(722, 'Hígado', 0, 1, 181),
(723, 'Corazón', 1, 1, 181),
(724, 'Riñón', 0, 1, 181),
(725, 'Mercurio', 1, 1, 182),
(726, 'Plomo', 0, 1, 182),
(727, 'Aluminio', 0, 1, 182),
(728, 'Hierro', 0, 1, 182),
(729, 'Quimiosíntesis', 0, 1, 183),
(730, 'Fotosíntesis', 1, 1, 183),
(731, 'Fermentación', 0, 1, 183),
(732, 'Respiración celular', 0, 1, 183),
(733, '1066', 1, 1, 184),
(734, '1215', 0, 1, 184),
(735, '1415', 0, 1, 184),
(736, '1815', 0, 1, 184),
(737, 'Julio César', 0, 1, 185),
(738, 'Augusto', 1, 1, 185),
(739, 'Nerón', 0, 1, 185),
(740, 'Trajano', 0, 1, 185),
(741, 'Martín Lutero', 1, 1, 186),
(742, 'Juan Calvino', 0, 1, 186),
(743, 'Enrique VIII', 0, 1, 186),
(744, 'Ulrico Zuinglio', 0, 1, 186),
(745, 'Argentina', 0, 1, 187),
(746, 'Brasil', 1, 1, 187),
(747, 'Perú', 0, 1, 187),
(748, 'Colombia', 0, 1, 187),
(749, 'Atlántico', 0, 1, 188),
(750, 'Índico', 0, 1, 188),
(751, 'Pacífico', 1, 1, 188),
(752, 'Ártico', 0, 1, 188),
(753, 'Fosa de las Marianas', 1, 1, 189),
(754, 'Fosa de Puerto Rico', 0, 1, 189),
(755, 'Fosa de Tonga', 0, 1, 189),
(756, 'Fosa de Filipinas', 0, 1, 189),
(757, 'Fútbol', 0, 1, 190),
(758, 'Tenis', 1, 1, 190),
(759, 'Bádminton', 0, 1, 190),
(760, 'Baloncesto', 0, 1, 190),
(761, '40', 0, 1, 191),
(762, '42', 0, 1, 191),
(763, '48', 1, 1, 191),
(764, '60', 0, 1, 191),
(765, 'Michael Schumacher', 0, 1, 192),
(766, 'Lewis Hamilton', 1, 1, 192),
(767, 'Ayrton Senna', 0, 1, 192),
(768, 'Sebastian Vettel', 0, 1, 192),
(769, 'Antoine de Saint-Exupéry', 1, 1, 193),
(770, 'Víctor Hugo', 0, 1, 193),
(771, 'Jules Verne', 0, 1, 193),
(772, 'Gabriel García Márquez', 0, 1, 193),
(773, 'El gran Gatsby', 1, 1, 194),
(774, 'Matar a un ruiseñor', 0, 1, 194),
(775, '1984', 0, 1, 194),
(776, 'Fahrenheit 451', 0, 1, 194),
(777, 'William Shakespeare', 0, 1, 195),
(778, 'John Milton', 1, 1, 195),
(779, 'Geoffrey Chaucer', 0, 1, 195),
(780, 'John Donne', 0, 1, 195),
(781, 'Moana', 0, 1, 196),
(782, 'Enredados', 0, 1, 196),
(783, 'Frozen', 1, 1, 196),
(784, 'La Bella y la Bestia', 0, 1, 196),
(785, 'Inception', 1, 1, 197),
(786, 'Interstellar', 0, 1, 197),
(787, 'The Prestige', 0, 1, 197),
(788, 'Memento', 0, 1, 197),
(789, 'El viaje de Chihiro', 1, 1, 198),
(790, 'La princesa Mononoke', 0, 1, 198),
(791, 'Mi vecino Totoro', 0, 1, 198),
(792, 'El castillo ambulante', 0, 1, 198),
(793, 'Bluetooth', 0, 1, 199),
(794, 'NFC', 1, 1, 199),
(795, 'Wi-Fi', 0, 1, 199),
(796, 'Infrarrojo', 0, 1, 199),
(797, 'Internet of Technology', 0, 1, 200),
(798, 'Internet of Things', 1, 1, 200),
(799, 'Interconnection of Tools', 0, 1, 200),
(800, 'Innovation of Technology', 0, 1, 200),
(801, 'Hypervisor', 1, 1, 201),
(802, 'Docker', 0, 1, 201),
(803, 'Kubernetes', 0, 1, 201),
(804, 'VPN', 0, 1, 201),
(805, '18', 0, 1, 202),
(806, '20', 1, 1, 202),
(807, '22', 0, 1, 202),
(808, '24', 0, 1, 202),
(809, '20', 0, 1, 203),
(810, '21', 0, 1, 203),
(811, '22', 1, 1, 203),
(812, '24', 0, 1, 203),
(813, '100°', 0, 1, 204),
(814, '105°', 0, 1, 204),
(815, '110°', 1, 1, 204),
(816, '115°', 0, 1, 204),
(817, 'La Antártida', 1, 1, 205),
(818, 'Siberia', 0, 1, 205),
(819, 'Groenlandia', 0, 1, 205),
(820, 'El Ártico', 0, 1, 205),
(821, 'Olimpia', 1, 1, 206),
(822, 'Atenas', 0, 1, 206),
(823, 'Delfos', 0, 1, 206),
(824, 'Esparta', 0, 1, 206),
(825, 'La Marsellesa', 1, 1, 207),
(826, 'La Liberté', 0, 1, 207),
(827, 'Le Chant du Départ', 0, 1, 207),
(828, 'La Carmagnole', 0, 1, 207),
(829, 'Robert Johnson', 0, 1, 208),
(830, 'B.B. King', 0, 1, 208),
(831, 'Muddy Waters', 0, 1, 208),
(832, 'W. C. Handy', 1, 1, 208),
(833, 'Saxofón', 0, 1, 209),
(834, 'Clarinete', 0, 1, 209),
(835, 'Trompeta', 1, 1, 209),
(836, 'Flauta', 0, 1, 209),
(837, 'Duke Ellington', 0, 1, 210),
(838, 'George Gershwin', 1, 1, 210),
(839, 'Scott Joplin', 0, 1, 210),
(840, 'Leonard Bernstein', 0, 1, 210),
(872, 'a', 0, 1, 213),
(873, 'b', 0, 1, 213),
(874, 'c', 0, 1, 213),
(875, 'd', 0, 1, 213);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ronda`
--

CREATE TABLE `ronda` (
  `id_partida` int NOT NULL,
  `num_ronda` int NOT NULL,
  `tiempo` time NOT NULL,
  `id_categoria` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `ronda`
--

INSERT INTO `ronda` (`id_partida`, `num_ronda`, `tiempo`, `id_categoria`) VALUES
(15, 1, '00:01:00', 7),
(15, 2, '00:01:00', 2),
(18, 1, '00:01:00', 6),
(18, 2, '00:01:00', 3),
(20, 1, '00:01:00', 8),
(20, 2, '00:01:00', 3),
(21, 1, '00:01:00', 10),
(21, 2, '00:01:00', 2),
(22, 1, '00:01:00', 10),
(22, 2, '00:01:00', 7),
(22, 3, '00:01:00', 1),
(25, 1, '00:01:00', 8),
(26, 1, '00:01:00', 6),
(27, 1, '00:01:00', 6),
(27, 2, '00:01:00', 9),
(27, 3, '00:01:00', 1),
(27, 4, '00:01:00', 6),
(27, 5, '00:01:00', 8),
(27, 6, '00:01:00', 7),
(27, 7, '00:01:00', 2),
(27, 8, '00:01:00', 4),
(27, 9, '00:01:00', 9),
(27, 10, '00:01:00', 1),
(27, 11, '00:01:00', 7),
(27, 12, '00:01:00', 8),
(27, 13, '00:01:00', 6),
(27, 14, '00:01:00', 3),
(27, 15, '00:01:00', 3),
(27, 16, '00:01:00', 9),
(27, 17, '00:01:00', 2),
(27, 18, '00:01:00', 7),
(27, 19, '00:01:00', 3),
(27, 20, '00:01:00', 9),
(27, 21, '00:01:00', 5),
(27, 22, '00:01:00', 5),
(27, 23, '00:01:00', 3),
(28, 1, '00:01:00', 6),
(28, 2, '00:01:00', 6),
(28, 3, '00:01:00', 2),
(29, 1, '00:01:00', 5),
(29, 2, '00:01:00', 9),
(29, 3, '00:01:00', 4),
(29, 4, '00:01:00', 10),
(29, 5, '00:01:00', 6),
(29, 6, '00:01:00', 2),
(29, 7, '00:01:00', 8),
(29, 8, '00:01:00', 8),
(29, 9, '00:01:00', 9),
(29, 10, '00:01:00', 5),
(30, 1, '00:01:00', 3),
(30, 2, '00:01:00', 4),
(30, 3, '00:01:00', 5),
(31, 1, '00:01:00', 6),
(31, 2, '00:01:00', 6),
(31, 3, '00:01:00', 10),
(31, 4, '00:01:00', 4),
(31, 5, '00:01:00', 3),
(31, 6, '00:01:00', 10),
(33, 1, '00:01:00', 9),
(34, 1, '00:01:00', 9),
(34, 2, '00:01:00', 2),
(34, 3, '00:01:00', 1),
(35, 1, '00:01:00', 9),
(35, 2, '00:01:00', 6),
(36, 1, '00:01:00', 7),
(36, 2, '00:01:00', 8),
(36, 3, '00:01:00', 2),
(36, 4, '00:01:00', 6),
(36, 5, '00:01:00', 6),
(36, 6, '00:01:00', 5),
(39, 1, '00:01:00', 3),
(39, 2, '00:00:08', 10),
(39, 3, '00:00:04', 10),
(41, 1, '00:00:05', 1),
(41, 2, '00:00:04', 1),
(42, 1, '00:00:11', 7),
(43, 1, '00:00:04', 3),
(43, 2, '00:00:05', 1),
(43, 3, '00:00:05', 2),
(44, 1, '00:00:05', 10),
(45, 1, '00:00:04', 9),
(45, 2, '00:00:03', 9),
(46, 1, '00:00:06', 2),
(46, 2, '00:00:09', 5),
(50, 1, '00:00:03', 5),
(51, 1, '00:00:08', 7),
(51, 2, '00:00:12', 9),
(51, 3, '00:00:04', 2),
(51, 4, '00:00:10', 9),
(51, 5, '00:00:05', 1),
(51, 6, '00:00:08', 2),
(51, 7, '00:00:05', 3),
(51, 8, '00:00:04', 6),
(51, 9, '00:00:05', 7),
(51, 10, '00:00:08', 6),
(53, 1, '00:00:35', 9),
(55, 1, '00:00:07', 4),
(55, 2, '00:00:49', 4),
(55, 3, '00:00:06', 7),
(56, 1, '00:00:06', 10),
(56, 2, '00:00:15', 9),
(56, 3, '00:00:45', 9),
(58, 1, '00:00:22', 1),
(58, 2, '00:00:35', 1),
(58, 3, '00:00:04', 5),
(60, 1, '00:00:28', 1),
(61, 1, '00:00:07', 3),
(61, 2, '00:00:04', 6),
(61, 3, '00:00:05', 7),
(61, 4, '00:00:09', 7),
(61, 5, '00:00:06', 3),
(61, 6, '00:00:06', 5),
(61, 7, '00:00:08', 10),
(61, 8, '00:00:08', 10),
(62, 1, '00:00:10', 3),
(63, 1, '00:00:17', 3),
(63, 2, '00:00:17', 3),
(64, 1, '00:00:42', 7),
(64, 2, '00:00:43', 4),
(65, 1, '00:00:50', 5),
(66, 1, '00:00:31', 7),
(66, 2, '00:00:50', 7),
(68, 1, '00:00:07', 5),
(68, 2, '00:00:21', 3),
(69, 1, '00:00:57', 8),
(69, 2, '00:00:20', 9),
(69, 3, '00:00:19', 7),
(69, 4, '00:00:08', 10),
(70, 1, '00:00:29', 2),
(70, 2, '00:00:23', 8),
(71, 1, '00:00:31', 5),
(71, 2, '00:00:11', 1),
(72, 1, '00:00:40', 10),
(73, 1, '00:00:26', 10),
(74, 1, '00:00:12', 2),
(76, 1, '00:00:06', 3),
(78, 1, '00:00:08', 3),
(79, 1, '00:00:32', 2),
(79, 2, '00:00:52', 10),
(80, 1, '00:00:06', 5),
(81, 1, '00:00:05', 2),
(81, 2, '00:00:23', 6),
(81, 3, '00:00:08', 6),
(81, 4, '00:00:05', 3),
(81, 5, '00:00:20', 10),
(81, 6, '00:00:33', 8),
(82, 1, '00:00:55', 3),
(83, 1, '00:00:05', 6),
(83, 2, '00:00:37', 4),
(83, 3, '00:00:06', 7),
(85, 1, '00:00:46', 6),
(85, 2, '00:00:53', 7),
(86, 1, '00:00:05', 7),
(86, 2, '00:00:32', 8),
(86, 3, '00:00:03', 10),
(87, 1, '00:00:22', 9),
(87, 2, '00:00:21', 1),
(88, 1, '00:00:44', 9),
(89, 1, '00:00:03', 10),
(89, 2, '00:00:12', 8),
(89, 3, '00:00:07', 4),
(90, 1, '00:00:07', 8),
(90, 2, '00:00:10', 9),
(91, 1, '00:00:23', 9),
(91, 2, '00:00:10', 4),
(92, 1, '00:00:16', 6),
(92, 2, '00:00:09', 6),
(92, 3, '00:00:04', 2),
(93, 1, '00:00:07', 8),
(94, 1, '00:00:19', 9),
(94, 2, '00:00:05', 9),
(94, 3, '00:00:11', 6),
(94, 4, '00:00:05', 2),
(95, 1, '00:00:18', 5),
(95, 2, '00:00:33', 8),
(95, 3, '00:00:07', 1),
(95, 4, '00:00:11', 8),
(95, 5, '00:00:04', 4),
(97, 1, '00:00:05', 4),
(98, 1, '00:00:17', 9),
(99, 1, '00:00:11', 4),
(99, 2, '00:00:17', 8),
(99, 3, '00:00:23', 6),
(99, 4, '00:00:06', 4),
(101, 1, '00:00:10', 3),
(101, 2, '00:00:03', 1),
(101, 3, '00:00:57', 7),
(101, 4, '00:00:07', 3),
(101, 5, '00:00:06', 9),
(102, 1, '00:00:07', 9),
(103, 1, '00:00:07', 10),
(104, 1, '00:00:09', 6),
(104, 2, '00:00:04', 3),
(104, 3, '00:00:05', 6),
(105, 1, '00:00:06', 1),
(107, 1, '00:00:27', 9),
(107, 2, '00:00:07', 2),
(108, 1, '00:00:05', 9),
(108, 2, '00:00:08', 3),
(109, 1, '00:00:10', 10),
(109, 2, '00:00:02', 5),
(109, 3, '00:00:07', 9),
(110, 1, '00:00:04', 10),
(110, 2, '00:00:11', 9),
(110, 3, '00:00:23', 4),
(110, 4, '00:00:39', 6),
(110, 5, '00:00:23', 10),
(111, 1, '00:00:08', 7),
(112, 1, '00:00:13', 6),
(113, 1, '00:00:05', 10),
(113, 2, '00:00:06', 2),
(113, 3, '00:00:04', 6),
(113, 4, '00:00:07', 10),
(113, 5, '00:00:04', 10),
(114, 1, '00:00:07', 2),
(114, 2, '00:00:09', 4),
(114, 3, '00:00:05', 7),
(114, 4, '00:00:04', 3),
(114, 5, '00:00:06', 7),
(114, 6, '00:00:05', 2),
(114, 7, '00:00:05', 5),
(115, 1, '00:00:09', 9),
(115, 2, '00:00:07', 9),
(116, 1, '00:00:39', 1);

--
-- Disparadores `ronda`
--
DELIMITER $$
CREATE TRIGGER `before_ronda_insert` BEFORE INSERT ON `ronda` FOR EACH ROW BEGIN
    SET NEW.num_ronda = (
        SELECT COALESCE(MAX(num_ronda), 0) + 1
        FROM Ronda
        WHERE id_partida = NEW.id_partida
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tarjeta`
--

CREATE TABLE `tarjeta` (
  `id_tarjeta` int NOT NULL,
  `dificultad` enum('Fácil','Media','Difícil') NOT NULL,
  `id_categoria` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `tarjeta`
--

INSERT INTO `tarjeta` (`id_tarjeta`, `dificultad`, `id_categoria`) VALUES
(1, 'Fácil', 1),
(2, 'Media', 1),
(3, 'Difícil', 1),
(4, 'Fácil', 2),
(5, 'Media', 2),
(6, 'Difícil', 2),
(7, 'Fácil', 3),
(8, 'Media', 3),
(9, 'Difícil', 3),
(10, 'Fácil', 4),
(11, 'Media', 4),
(12, 'Difícil', 4),
(13, 'Fácil', 5),
(14, 'Media', 5),
(15, 'Difícil', 5),
(16, 'Fácil', 6),
(17, 'Media', 6),
(18, 'Difícil', 6),
(19, 'Fácil', 7),
(20, 'Media', 7),
(21, 'Difícil', 7),
(22, 'Fácil', 8),
(23, 'Media', 8),
(24, 'Difícil', 8),
(25, 'Fácil', 9),
(26, 'Media', 9),
(27, 'Difícil', 9),
(28, 'Fácil', 10),
(29, 'Media', 10),
(30, 'Difícil', 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traducciones`
--

CREATE TABLE `traducciones` (
  `id_traduccion` int NOT NULL,
  `texto_original` text NOT NULL,
  `idioma_origen` varchar(5) NOT NULL,
  `idioma_destino` varchar(5) NOT NULL,
  `texto_traducido` text NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `traducciones`
--

INSERT INTO `traducciones` (`id_traduccion`, `texto_original`, `idioma_origen`, `idioma_destino`, `texto_traducido`, `fecha_creacion`) VALUES
(1, '¿Cuál es el planeta más cercano al sol?', 'ES', 'EN', 'What is the closest planet to the sun?', '2025-03-27 15:48:10'),
(2, 'Estados Unidos', 'ES', 'EN', 'United States', '2025-03-27 15:52:12'),
(3, 'China', 'ES', 'EN', 'China', '2025-03-27 15:52:12'),
(4, 'Rusia', 'ES', 'EN', 'Russia', '2025-03-27 15:52:12'),
(5, 'Canadá', 'ES', 'EN', 'Canada', '2025-03-27 15:52:12'),
(6, 'Media', 'ES', 'EN', 'Normal', '2025-03-27 15:52:12'),
(7, '¿Cuál es el país más extenso del mundo en términos de superficie?', 'ES', 'EN', 'What is the largest country in the world in terms of surface area?', '2025-03-27 15:52:12'),
(8, 'Jules Verne', 'ES', 'EN', 'Jules Verne', '2025-03-27 15:52:42'),
(9, 'Víctor Hugo', 'ES', 'EN', 'Victor Hugo', '2025-03-27 15:52:42'),
(10, 'Fácil', 'ES', 'EN', 'Easy', '2025-03-27 15:52:42'),
(11, 'Gabriel García Márquez', 'ES', 'EN', 'Gabriel García Márquez', '2025-03-27 15:52:42'),
(12, '¿Quién escribió \"El Principito\"?', 'ES', 'EN', 'Who wrote \"The Little Prince\"?', '2025-03-27 15:52:42'),
(13, 'Antoine de Saint-Exupéry', 'ES', 'EN', 'Antoine de Saint-Exupéry', '2025-03-27 15:52:42'),
(14, '¿Cuántas combinaciones se pueden formar al elegir 3 elementos de un conjunto de 7?', 'ES', 'EN', 'How many combinations can be formed by choosing 3 elements from a set of 7?', '2025-03-27 15:53:12'),
(15, '42', 'ES', 'EN', '42', '2025-03-27 15:53:12'),
(16, 'Difícil', 'ES', 'EN', 'Hard', '2025-03-27 15:53:12'),
(17, '21', 'ES', 'EN', '21', '2025-03-27 15:53:12'),
(18, '35', 'ES', 'EN', '35', '2025-03-27 15:53:12'),
(19, '49', 'ES', 'EN', '49', '2025-03-27 15:53:12'),
(20, 'Inca', 'ES', 'EN', 'Inca', '2025-03-27 15:57:44'),
(21, 'Olmeca', 'ES', 'EN', 'Olmeca', '2025-03-27 15:57:44'),
(22, '¿Qué civilización construyó Machu Picchu?', 'ES', 'EN', 'Which civilization built Machu Picchu?', '2025-03-27 15:57:44'),
(23, 'Maya', 'ES', 'EN', 'Maya', '2025-03-27 15:57:44'),
(24, 'Azteca', 'ES', 'EN', 'Azteca', '2025-03-27 15:57:44'),
(25, '¿En qué año se lanzó la primera versión del lenguaje de programación Python?', 'ES', 'EN', 'In what year was the first version of the Python programming language released?', '2025-03-27 15:59:18'),
(26, 'Kurt Cobain', 'ES', 'EN', 'Kurt Cobain', '2025-03-27 16:00:48'),
(28, 'Dave Grohl', 'ES', 'EN', 'Dave Grohl', '2025-03-27 16:00:48'),
(29, 'Chris Cornell', 'ES', 'EN', 'Chris Cornell', '2025-03-27 16:00:48'),
(30, '¿Quién fue el cantante principal de la banda de rock Nirvana?', 'ES', 'EN', 'Who was the lead singer of the rock band Nirvana?', '2025-03-27 16:00:48'),
(31, 'Eddie Vedder', 'ES', 'EN', 'Eddie Vedder', '2025-03-27 16:00:48'),
(32, 'Pulp Fiction', 'ES', 'EN', 'Pulp Fiction', '2025-03-27 16:01:06'),
(33, 'Forrest Gump', 'ES', 'EN', 'Forrest Gump', '2025-03-27 16:01:06'),
(34, 'The Shawshank Redemption', 'ES', 'EN', 'The Shawshank Redemption', '2025-03-27 16:01:06'),
(36, 'Se7en', 'ES', 'EN', 'Se7en', '2025-03-27 16:01:06'),
(37, '¿Qué película de 1994, basada en una novela de Stephen King, narra la historia de dos hombres encarcelados?', 'ES', 'EN', 'Which 1994 film, based on a Stephen King novel, tells the story of two men in prison?', '2025-03-27 16:01:06'),
(38, 'Martín Lutero', 'ES', 'EN', 'Martin Luther', '2025-03-27 16:01:36'),
(39, 'Juan Calvino', 'ES', 'EN', 'John Calvin', '2025-03-27 16:01:36'),
(40, 'Enrique VIII', 'ES', 'EN', 'Henry VIII', '2025-03-27 16:01:36'),
(42, 'Ulrico Zuinglio', 'ES', 'EN', 'Ulrich Zwingli', '2025-03-27 16:01:36'),
(43, '¿Quién es reconocido como el iniciador de la Reforma Protestante al clavar sus 95 tesis en 1517?', 'ES', 'EN', 'Who is recognized as the initiator of the Protestant Reformation by nailing down his 95 theses in 1517?', '2025-03-27 16:01:36'),
(44, 'Retrato del artista adolescente', 'ES', 'EN', 'Portrait of the adolescent artist', '2025-03-27 16:03:05'),
(45, 'Ulises', 'ES', 'EN', 'Ulises', '2025-03-27 16:03:05'),
(47, 'Finnegans Wake', 'ES', 'EN', 'Finnegans Wake', '2025-03-27 16:03:05'),
(48, 'Dubliners', 'ES', 'EN', 'Dubliners', '2025-03-27 16:03:05'),
(49, '¿Cuál es la obra literaria de James Joyce considerada un hito del modernismo, que narra un solo día en la vida de los habitantes de Dublín?', 'ES', 'EN', 'What is the literary work by James Joyce considered a landmark of modernism, which narrates a single day in the life of the inhabitants of Dublin?', '2025-03-27 16:03:05'),
(50, 'Vatios', 'ES', 'EN', 'Watts', '2025-03-27 16:03:27'),
(51, 'Amperios', 'ES', 'EN', 'Ampere', '2025-03-27 16:03:27'),
(53, 'Voltios', 'ES', 'EN', 'Volts', '2025-03-27 16:03:27'),
(54, 'Ohmios', 'ES', 'EN', 'Ohms', '2025-03-27 16:03:27'),
(55, '¿Cuál de las siguientes unidades se usa para medir la intensidad de corriente eléctrica?', 'ES', 'EN', 'Which of the following units is used to measure electric current intensity?', '2025-03-27 16:03:27'),
(56, 'Pink Floyd', 'ES', 'EN', 'Pink Floyd', '2025-03-27 16:03:49'),
(57, 'Led Zeppelin', 'ES', 'EN', 'Led Zeppelin', '2025-03-27 16:03:49'),
(58, 'The Beatles', 'ES', 'EN', 'The Beatles', '2025-03-27 16:03:49'),
(60, 'The Rolling Stones', 'ES', 'EN', 'The Rolling Stones', '2025-03-27 16:03:49'),
(61, '¿Qué banda lanzó el álbum \"The Dark Side of the Moon\" en 1973?', 'ES', 'EN', 'Which band released the album \"The Dark Side of the Moon\" in 1973?', '2025-03-27 16:03:49'),
(62, '¿Cuántos jugadores conforman un equipo de voleibol en la cancha durante un partido?', 'ES', 'EN', 'How many players make up a volleyball team on the court during a match?', '2025-03-27 16:35:10'),
(63, 'Blues', 'ES', 'EN', 'Blues', '2025-03-27 16:35:27'),
(64, 'Pop', 'ES', 'EN', 'Pop', '2025-03-27 16:35:27'),
(65, 'Jazz', 'ES', 'EN', 'Jazz', '2025-03-27 16:35:27'),
(67, 'Rock', 'ES', 'EN', 'Rock', '2025-03-27 16:35:27'),
(68, '¿Qué género musical, caracterizado por su improvisación y ritmos sincopados, se originó en Nueva Orleans?', 'ES', 'EN', 'Which musical genre, characterized by improvisation and syncopated rhythms, originated in New Orleans?', '2025-03-27 16:35:27'),
(69, 'Modo solitario', 'ES', 'EN', 'Solitaire mode', '2025-03-27 17:30:19'),
(70, 'Responde preguntas de todo tipo.', 'ES', 'EN', 'Answers questions of all kinds.', '2025-03-27 17:30:19'),
(71, 'Modo multijugador', 'ES', 'EN', 'Multiplayer mode', '2025-03-27 17:30:19'),
(72, 'El juego termina cuando pierdas todas tus vidas.', 'ES', 'EN', 'The game ends when you lose all your lives.', '2025-03-27 17:30:19'),
(73, 'Acierta tantas preguntas como puedas y supérate a ti mismo.', 'ES', 'EN', 'Get as many questions right as you can and surpass yourself.', '2025-03-27 17:30:19'),
(74, 'Tienes 3 vidas y pierdes una cada vez que fallas.', 'ES', 'EN', 'You have 3 lives and lose one each time you fail.', '2025-03-27 17:30:19'),
(75, 'Cada categoría tiene una corona propia.', 'ES', 'EN', 'Each category has its own crown.', '2025-03-27 17:30:20'),
(76, 'Pista', 'ES', 'EN', 'Track', '2025-03-27 17:30:20'),
(77, 'Cada 3 preguntas correctas, en la siguiente puedes ganar una corona.', 'ES', 'EN', 'Every 3 correct questions, in the next one you can win a crown.', '2025-03-27 17:30:20'),
(78, 'Consigue las 10 coronas y gana la partida.', 'ES', 'EN', 'Get all 10 crowns and win the game.', '2025-03-27 17:30:20'),
(79, 'Comodines', 'ES', 'EN', 'Wildcards', '2025-03-27 17:30:20'),
(80, 'Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta.', 'ES', 'EN', 'Two incorrect options will be eliminated from the options to choose from in the question.', '2025-03-27 17:30:20'),
(81, 'Salto', 'ES', 'EN', 'Jump', '2025-03-27 17:30:20'),
(82, '¡A JUGAR!', 'ES', 'EN', 'PLAY!', '2025-03-27 17:30:20'),
(83, 'Inicia sesión', 'ES', 'EN', 'Login', '2025-03-27 17:30:20'),
(84, 'Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta.', 'ES', 'EN', '1 incorrect option will be eliminated from the options to choose from in the question.', '2025-03-27 17:30:20'),
(85, 'Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta).', 'ES', 'EN', 'Skip the current question and continue with another question (does not count as correct).', '2025-03-27 17:30:20'),
(86, 'Todos los derechos reservados.', 'ES', 'EN', 'All rights reserved.', '2025-03-27 17:38:19'),
(87, 'Política de Privacidad', 'ES', 'EN', 'Privacy Policy', '2025-03-27 17:38:19'),
(88, 'Términos y Condiciones', 'ES', 'EN', 'Terms and Conditions', '2025-03-27 17:38:19'),
(89, 'Política de Privacidad', 'ES', 'DE', 'Datenschutzbestimmungen', '2025-03-27 17:44:48'),
(90, 'Términos y Condiciones', 'ES', 'DE', 'Bedingungen und Konditionen', '2025-03-27 17:44:48'),
(91, 'Modo solitario', 'ES', 'DE', 'Solitaire-Modus', '2025-03-27 17:44:48'),
(92, 'Todos los derechos reservados.', 'ES', 'DE', 'Alle Rechte vorbehalten.', '2025-03-27 17:44:48'),
(93, 'Acierta tantas preguntas como puedas y supérate a ti mismo.', 'ES', 'DE', 'Beantworten Sie so viele Fragen wie möglich richtig und übertreffen Sie sich selbst.', '2025-03-27 17:44:48'),
(94, 'Tienes 3 vidas y pierdes una cada vez que fallas.', 'ES', 'DE', 'Du hast 3 Leben und verlierst jedes Mal ein Leben, wenn du scheiterst.', '2025-03-27 17:44:48'),
(95, 'Modo multijugador', 'ES', 'DE', 'Multiplayer-Modus', '2025-03-27 17:44:49'),
(96, 'El juego termina cuando pierdas todas tus vidas.', 'ES', 'DE', 'Das Spiel endet, wenn du alle Leben verloren hast.', '2025-03-27 17:44:49'),
(97, 'Cada 3 preguntas correctas, en la siguiente puedes ganar una corona.', 'ES', 'DE', 'Für jeweils 3 richtige Fragen kannst du in der nächsten Runde eine Krone gewinnen.', '2025-03-27 17:44:49'),
(98, 'Responde preguntas de todo tipo.', 'ES', 'DE', 'Sie beantwortet Fragen aller Art.', '2025-03-27 17:44:49'),
(99, 'Cada categoría tiene una corona propia.', 'ES', 'DE', 'Jede Kategorie hat ihre eigene Krone.', '2025-03-27 17:44:49'),
(100, 'Consigue las 10 coronas y gana la partida.', 'ES', 'DE', 'Sammle alle 10 Kronen und gewinne das Spiel.', '2025-03-27 17:44:49'),
(101, 'Comodines', 'ES', 'DE', 'Wildcards', '2025-03-27 17:44:50'),
(105, 'Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta.', 'ES', 'DE', '1 falsche Option wird aus der Auswahl der Frage gestrichen.', '2025-03-27 17:44:50'),
(106, 'Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta.', 'ES', 'DE', 'Zwei falsche Antwortmöglichkeiten werden aus der Auswahl der Frage gestrichen.', '2025-03-27 17:44:50'),
(108, 'Pista', 'ES', 'DE', 'Spur', '2025-03-27 17:44:50'),
(109, '¡A JUGAR!', 'ES', 'DE', 'SPIELEN!', '2025-03-27 17:44:50'),
(110, 'Salto', 'ES', 'DE', 'Springen', '2025-03-27 17:44:50'),
(111, 'Inicia sesión', 'ES', 'DE', 'Einloggen', '2025-03-27 17:44:50'),
(113, 'Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta).', 'ES', 'DE', 'Die aktuelle Frage überspringen und mit einer anderen Frage fortfahren (zählt nicht als richtig).', '2025-03-27 17:44:50'),
(115, 'INSTRUCCIONES', 'ES', 'EN', 'INSTRUCTIONS', '2025-03-27 17:48:21'),
(116, 'Pista: Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta.', 'ES', 'EN', 'Hint: 1 incorrect option will be eliminated from the options to choose from in the question.', '2025-03-27 17:50:28'),
(117, 'Salto: Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta).', 'ES', 'EN', 'Skip: Skip the current question and continue with another question (does not count as correct).', '2025-03-27 17:50:28'),
(118, '50/50: Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta.', 'ES', 'EN', '50/50: 2 incorrect options will be eliminated from the options to be chosen from the question.', '2025-03-27 17:50:42'),
(119, 'Cambiar Imagen', 'ES', 'EN', 'Change Image', '2025-03-27 18:04:56'),
(120, 'Confirmar Cambio', 'ES', 'EN', 'Confirm Change', '2025-03-27 18:04:56'),
(121, 'Ajustes de la cuenta', 'ES', 'EN', 'Account settings', '2025-03-27 18:04:56'),
(122, 'PERFIL', 'ES', 'EN', 'PROFILE', '2025-03-27 18:04:56'),
(123, 'Resumen de tus estadísticas', 'ES', 'EN', 'Summary of your statistics', '2025-03-27 18:04:56'),
(124, '¡Comparte tu perfil con tus amigos!', 'ES', 'EN', 'Share your profile with your friends!', '2025-03-27 18:04:56'),
(125, 'Correo Electrónico', 'ES', 'EN', 'E-mail address', '2025-03-27 18:04:56'),
(126, 'Guardar Ajustes', 'ES', 'EN', 'Save Settings', '2025-03-27 18:04:56'),
(127, 'Puntos Última Partida', 'ES', 'EN', 'Points Last Game', '2025-03-27 18:04:56'),
(128, 'Nombre de usuario', 'ES', 'EN', 'User name', '2025-03-27 18:04:56'),
(129, 'Te has olvidado de tu contraseña?', 'ES', 'EN', 'Forgot your password?', '2025-03-27 18:04:56'),
(130, 'Pos. Última Partida', 'ES', 'EN', 'Pos. Last Game', '2025-03-27 18:04:56'),
(131, 'Ver tus estadísticas completas', 'ES', 'EN', 'View your complete statistics', '2025-03-27 18:04:57'),
(132, 'Cargando...', 'ES', 'EN', 'Loading...', '2025-03-27 18:04:57'),
(133, 'Cargando traducciones...', 'ES', 'EN', 'Loading translations...', '2025-03-27 18:04:57'),
(134, 'Categoría Destacada', 'ES', 'EN', 'Featured Category', '2025-03-27 18:05:19'),
(135, 'Última posición:', 'ES', 'EN', 'Last position:', '2025-03-27 18:12:02'),
(136, 'Puntos', 'ES', 'EN', 'Points', '2025-03-27 18:12:02'),
(137, 'Ránking Global', 'ES', 'EN', 'Global Ranking', '2025-03-27 18:12:02'),
(138, 'Jugador', 'ES', 'EN', 'Player', '2025-03-27 18:12:02'),
(139, 'Posición', 'ES', 'EN', 'Position', '2025-03-27 18:12:02'),
(140, 'ESTADÍSTICAS', 'ES', 'EN', 'STATISTICS', '2025-03-27 18:12:02'),
(141, 'No hay jugadores en el ranking.', 'ES', 'EN', 'There are no players in the ranking.', '2025-03-27 18:12:02'),
(142, 'Tus Estadísticas', 'ES', 'EN', 'Your Statistics', '2025-03-27 18:14:36'),
(143, 'Puntos Totales:', 'ES', 'EN', 'Total Points:', '2025-03-27 18:14:36'),
(144, 'Derrotas:', 'ES', 'EN', 'Defeats:', '2025-03-27 18:14:36'),
(145, 'Rondas Jugadas:', 'ES', 'EN', 'Rounds Played:', '2025-03-27 18:14:36'),
(146, 'Categoria Destacada:', 'ES', 'EN', 'Featured Category:', '2025-03-27 18:14:36'),
(147, 'Victorias:', 'ES', 'EN', 'Victories:', '2025-03-27 18:14:36'),
(148, 'No hay estadísticas para este usuario.', 'ES', 'EN', 'There are no statistics for this user.', '2025-03-27 18:14:36'),
(149, 'pts', 'ES', 'EN', 'pts', '2025-03-27 18:14:36'),
(150, 'Categoría:', 'ES', 'EN', 'Category:', '2025-03-27 18:14:36'),
(151, 'Cerrar Sesión', 'ES', 'EN', 'Logout', '2025-04-01 13:28:15'),
(152, 'ADMIN', 'ES', 'EN', 'ADMIN', '2025-04-01 13:28:15'),
(153, 'RANKING', 'ES', 'EN', 'RANKING', '2025-04-01 13:28:15'),
(154, 'Noruega', 'ES', 'EN', 'Norway', '2025-04-01 13:28:46'),
(155, '¿Qué país posee la mayor cantidad de islas en el mundo?', 'ES', 'EN', 'Which country has the most islands in the world?', '2025-04-01 13:28:46'),
(156, 'Finlandia', 'ES', 'EN', 'Finland', '2025-04-01 13:28:47'),
(157, 'Indonesia', 'ES', 'EN', 'Indonesia', '2025-04-01 13:28:47'),
(158, 'Suecia', 'ES', 'EN', 'Sweden', '2025-04-01 13:28:47'),
(159, 'La Guerra Civil Española', 'ES', 'EN', 'Spanish Civil War', '2025-04-01 13:29:46'),
(160, 'El ataque a Pearl Harbor', 'ES', 'EN', 'The attack on Pearl Harbor', '2025-04-01 13:29:46'),
(161, 'La invasión de Polonia por Alemania', 'ES', 'EN', 'Germany\'s invasion of Poland', '2025-04-01 13:29:46'),
(163, 'La firma del Tratado de Versalles', 'ES', 'EN', 'The signing of the Treaty of Versailles', '2025-04-01 13:29:46'),
(164, '¿Qué evento marcó el inicio de la Segunda Guerra Mundial?', 'ES', 'EN', 'What event marked the beginning of World War II?', '2025-04-01 13:29:46'),
(165, 'Batería', 'ES', 'EN', 'Battery', '2025-04-01 13:30:19'),
(166, 'Guitarra', 'ES', 'EN', 'Guitar', '2025-04-01 13:30:19'),
(167, 'Trompeta', 'ES', 'EN', 'Trumpet', '2025-04-01 13:30:19'),
(168, 'Clarinete', 'ES', 'EN', 'Clarinet', '2025-04-01 13:30:19'),
(170, '¿Qué instrumento musical se toca soplando aire a través de una lengüeta?', 'ES', 'EN', 'What musical instrument is played by blowing air through a reed?', '2025-04-01 13:30:20'),
(171, 'Ronda', 'ES', 'EN', 'Round', '2025-04-01 13:31:13'),
(172, 'Arte y Literatura', 'ES', 'EN', 'Art and Literature', '2025-04-01 13:31:26'),
(173, 'Jean-Paul Sartre', 'ES', 'EN', 'Jean-Paul Sartre', '2025-04-01 13:31:26'),
(174, '¿Quién fue el autor de \"En busca del tiempo perdido\", una de las obras más importantes de la literatura francesa?', 'ES', 'EN', 'Who was the author of \"In Search of Lost Time\", one of the most important works of French literature?', '2025-04-01 13:31:26'),
(175, 'Marcel Proust', 'ES', 'EN', 'Marcel Proust', '2025-04-01 13:31:26'),
(177, 'Albert Camus', 'ES', 'EN', 'Albert Camus', '2025-04-01 13:31:26'),
(178, 'Ciencia', 'ES', 'EN', 'Science', '2025-04-01 13:32:44'),
(179, 'Júpiter', 'ES', 'EN', 'Jupiter', '2025-04-01 13:32:44'),
(180, 'Marte', 'ES', 'EN', 'Mars', '2025-04-01 13:32:44'),
(181, '¿Qué planeta es conocido como el \"planeta rojo\"?', 'ES', 'EN', 'Which planet is known as the \"red planet\"?', '2025-04-01 13:32:44'),
(182, 'Venus', 'ES', 'EN', 'Venus', '2025-04-01 13:32:44'),
(183, 'Saturno', 'ES', 'EN', 'Saturn', '2025-04-01 13:32:44'),
(185, 'Historia', 'ES', 'EN', 'History', '2025-04-01 13:32:58'),
(186, '¿En qué año se derribó el Muro de Berlín?', 'ES', 'EN', 'In what year was the Berlin Wall torn down?', '2025-04-01 13:32:58'),
(187, 'Entretenimiento', 'ES', 'EN', 'Entertainment', '2025-04-01 13:33:11'),
(188, 'El castillo ambulante', 'ES', 'EN', 'The traveling castle', '2025-04-01 13:33:11'),
(189, 'El viaje de Chihiro', 'ES', 'EN', 'Chihiro\'s Journey', '2025-04-01 13:33:11'),
(190, 'Mi vecino Totoro', 'ES', 'EN', 'My Neighbor Totoro', '2025-04-01 13:33:11'),
(191, 'La princesa Mononoke', 'ES', 'EN', 'Princess Mononoke', '2025-04-01 13:33:11'),
(192, '¿Qué película de animación japonesa, dirigida por Hayao Miyazaki, ganó el Oscar a la Mejor Película de Animación en 2003?', 'ES', 'EN', 'Which Japanese animated film, directed by Hayao Miyazaki, won the Oscar for Best Animated Film in 2003?', '2025-04-01 13:33:11'),
(193, 'Babylon Berlin', 'ES', 'EN', 'Babylon Berlin', '2025-04-01 13:35:47'),
(194, 'Deutschland 83', 'ES', 'EN', 'Deutschland 83', '2025-04-01 13:35:47'),
(195, 'Dark', 'ES', 'EN', 'Dark', '2025-04-01 13:35:47'),
(197, '¿Cuál es el título de la serie alemana de ciencia ficción y misterio que involucra viajes en el tiempo y una intrincada red de conexiones familiares?', 'ES', 'EN', 'What is the title of the German science fiction/mystery series involving time travel and an intricate web of family connections?', '2025-04-01 13:35:47'),
(198, 'Perú', 'ES', 'EN', 'Peru', '2025-04-01 13:36:04'),
(199, 'Geografía', 'ES', 'EN', 'Geography', '2025-04-01 13:36:04'),
(200, '¿Cuál es el país más grande de América del Sur en términos de superficie?', 'ES', 'EN', 'What is the largest country in South America in terms of surface area?', '2025-04-01 13:36:04'),
(201, 'Brasil', 'ES', 'EN', 'Brazil', '2025-04-01 13:36:04'),
(202, 'Argentina', 'ES', 'EN', 'Argentina', '2025-04-01 13:36:04'),
(203, 'Colombia', 'ES', 'EN', 'Colombia', '2025-04-01 13:36:04'),
(205, 'Música', 'ES', 'EN', 'Music', '2025-04-01 13:38:03'),
(206, 'Queen', 'ES', 'EN', 'Queen', '2025-04-01 13:38:03'),
(207, '¿Cuál es la banda británica conocida por éxitos como \"Hey Jude\" y \"Let It Be\"?', 'ES', 'EN', 'Which British band is known for hits such as \"Hey Jude\" and \"Let It Be\"?', '2025-04-01 13:38:03'),
(208, 'Matemáticas', 'ES', 'EN', 'Mathematics', '2025-04-01 13:38:29'),
(209, '¿Cuál es el valor de la raíz cuadrada de 64?', 'ES', 'EN', 'What is the square root value of 64?', '2025-04-01 13:38:29'),
(210, 'Deportes', 'ES', 'EN', 'Sports', '2025-04-01 13:38:44'),
(211, '¿Cuántos jugadores conforman un equipo de rugby union en el campo?', 'ES', 'EN', 'How many players make up a rugby union team on the field?', '2025-04-01 13:38:44'),
(212, 'América', 'ES', 'EN', 'America', '2025-04-01 13:40:59'),
(213, '¿En qué continente se encuentra Egipto?', 'ES', 'EN', 'On which continent is Egypt located?', '2025-04-01 13:40:59'),
(214, 'África', 'ES', 'EN', 'Africa', '2025-04-01 13:40:59'),
(215, 'Europa', 'ES', 'EN', 'Europa', '2025-04-01 13:40:59'),
(217, 'Asia', 'ES', 'EN', 'Asia', '2025-04-01 13:40:59'),
(218, 'Better Call Saul', 'ES', 'EN', 'Better Call Saul', '2025-04-01 13:41:40'),
(219, 'Breaking Bad', 'ES', 'EN', 'Breaking Bad', '2025-04-01 13:41:40'),
(220, 'Narcos', 'ES', 'EN', 'Narcos', '2025-04-01 13:41:40'),
(222, 'The Wire', 'ES', 'EN', 'The Wire', '2025-04-01 13:41:40'),
(223, '¿En qué serie aparece el personaje Walter White, un profesor de química convertido en narcotraficante?', 'ES', 'EN', 'In which series does the character Walter White, a chemistry teacher turned drug dealer, appear?', '2025-04-01 13:41:40'),
(224, 'Grecia', 'ES', 'EN', 'Greece', '2025-04-01 13:41:54'),
(225, 'Reino Unido', 'ES', 'EN', 'United Kingdom', '2025-04-01 13:41:54'),
(226, '¿En qué país se originó el baloncesto?', 'ES', 'EN', 'In which country did basketball originate?', '2025-04-01 13:41:54'),
(227, '¿Cuánto es 12 + 8?', 'ES', 'EN', 'How much is 12 + 8?', '2025-04-01 13:44:32'),
(228, 'Tecnología', 'ES', 'EN', 'Technology', '2025-04-01 13:44:43'),
(229, 'Fuerza centrífuga', 'ES', 'EN', 'Centrifugal force', '2025-04-01 13:44:56'),
(230, 'Fuerza gravitatoria', 'ES', 'EN', 'Gravitational force', '2025-04-01 13:44:56'),
(231, 'Fuerza electromagnética', 'ES', 'EN', 'Electromagnetic force', '2025-04-01 13:44:56'),
(233, '¿Cuál de las siguientes no es una interacción fundamental de la naturaleza?', 'ES', 'EN', 'Which of the following is not a fundamental interaction of nature?', '2025-04-01 13:44:56'),
(234, 'Fuerza nuclear fuerte', 'ES', 'EN', 'Strong nuclear force', '2025-04-01 13:44:56'),
(235, 'Tema seleccionado:', 'ES', 'EN', 'Selected topic:', '2025-04-01 13:47:18'),
(236, 'GIRA', 'ES', 'EN', 'SPIN', '2025-04-01 13:47:18'),
(237, 'Aceptar', 'ES', 'EN', 'Accept', '2025-04-01 13:47:18'),
(238, '¿Estás seguro que quieres rendirte?', 'ES', 'EN', 'Are you sure you want to give up?', '2025-04-01 13:47:18'),
(239, 'GIRAR', 'ES', 'EN', 'TURN', '2025-04-01 13:47:30'),
(240, 'Martin Scorsese', 'ES', 'EN', 'Martin Scorsese', '2025-04-01 13:47:47'),
(241, 'Steven Spielberg', 'ES', 'EN', 'Steven Spielberg', '2025-04-01 13:47:47'),
(242, 'Quentin Tarantino', 'ES', 'EN', 'Quentin Tarantino', '2025-04-01 13:47:47'),
(243, 'Wes Anderson', 'ES', 'EN', 'Wes Anderson', '2025-04-01 13:47:47'),
(245, '¿Qué director es reconocido por su estilo visual peculiar en películas como \"El Gran Hotel Budapest\"?', 'ES', 'EN', 'Which director is known for his distinctive visual style in films such as \"The Grand Budapest Hotel\"?', '2025-04-01 13:47:47'),
(246, 'GPU', 'ES', 'EN', 'GPU', '2025-04-01 13:51:47'),
(247, 'SSD', 'ES', 'EN', 'SSD', '2025-04-01 13:51:47'),
(248, 'CPU', 'ES', 'EN', 'CPU', '2025-04-01 13:51:47'),
(250, 'RAM', 'ES', 'EN', 'RAM', '2025-04-01 13:51:47'),
(251, '¿Qué componente de un ordenador se encarga de ejecutar las instrucciones de un programa?', 'ES', 'EN', 'Which component of a computer is responsible for executing the instructions of a program?', '2025-04-01 13:51:47'),
(252, 'IMPORTAR CSV', 'ES', 'EN', 'IMPORT CSV', '2025-04-01 13:52:45'),
(253, 'PREGUNTAS', 'ES', 'EN', 'QUESTIONS', '2025-04-01 13:52:45'),
(254, 'CATEGORÍAS', 'ES', 'EN', 'CATEGORIES', '2025-04-01 13:52:45'),
(255, 'USUARIOS', 'ES', 'EN', 'USERS', '2025-04-01 13:52:45'),
(256, 'DATOS GENERALES', 'ES', 'EN', 'GENERAL DATA', '2025-04-01 13:52:45'),
(257, 'MENU', 'ES', 'EN', 'MENU', '2025-04-01 13:52:45'),
(258, 'SALIR', 'ES', 'EN', 'EXIT', '2025-04-01 13:52:46'),
(259, 'Rondas Jugadas', 'ES', 'EN', 'Rounds Played', '2025-04-01 13:56:10'),
(260, 'Victorias', 'ES', 'EN', 'Victories', '2025-04-01 13:56:10'),
(261, 'Derrotas', 'ES', 'EN', 'Defeats', '2025-04-01 13:56:10'),
(262, 'Última posición', 'ES', 'EN', 'Last position', '2025-04-01 13:56:10'),
(263, 'Puntos Totales', 'ES', 'EN', 'Total Points', '2025-04-01 13:56:10'),
(264, 'No hay estadísticas para este usuario', 'ES', 'EN', 'There are no statistics for this user', '2025-04-01 13:56:10'),
(275, 'Ingresa tu contraseña', 'ES', 'EN', 'Enter your password', '2025-04-01 14:10:16'),
(276, 'Ingresa tu nombre de usuario', 'ES', 'EN', 'Enter your username', '2025-04-01 14:10:16'),
(277, 'Iniciar sesión', 'ES', 'EN', 'Login', '2025-04-01 14:10:16'),
(278, 'Error al iniciar sesión', 'ES', 'EN', 'Error logging in', '2025-04-01 14:13:51'),
(279, '¿No tienes una cuenta?', 'ES', 'EN', 'Don\'t have an account?', '2025-04-01 14:13:51'),
(280, 'La contraseña debe tener al menos 6 caracteres', 'ES', 'EN', 'The password must be at least 6 characters long', '2025-04-01 14:13:51'),
(281, 'Regístrate', 'ES', 'EN', 'Register', '2025-04-01 14:15:16'),
(282, 'Registro de Usuario', 'ES', 'EN', 'User Registration', '2025-04-01 14:15:34'),
(283, 'Vista previa', 'ES', 'EN', 'Preview', '2025-04-01 14:15:34'),
(284, 'Subir imagen', 'ES', 'EN', 'Upload image', '2025-04-01 14:15:35'),
(285, 'Confirmar Contraseña', 'ES', 'EN', 'Confirm Password', '2025-04-01 14:15:35'),
(286, 'REGISTRARSE', 'ES', 'EN', 'REGISTER', '2025-04-01 14:15:35'),
(287, '¿Ya tienes una cuenta?', 'ES', 'EN', 'Already have an account?', '2025-04-01 14:15:35'),
(288, 'Ingresa tu correo electrónico', 'ES', 'EN', 'Enter your email address', '2025-04-01 14:15:35'),
(289, 'Repite tu contraseña', 'ES', 'EN', 'Repeat your password', '2025-04-01 14:15:35'),
(290, 'Error en el registro', 'ES', 'EN', 'Error in registration', '2025-04-01 14:15:35'),
(291, 'Las contraseñas no coinciden', 'ES', 'EN', 'Passwords do not match', '2025-04-01 14:15:35'),
(292, 'Crea una contraseña', 'ES', 'EN', 'Create a password', '2025-04-01 14:15:35'),
(293, 'Contraseña', 'ES', 'EN', 'Password', '2025-04-01 14:18:08'),
(294, 'Importa datos de respuestas', 'ES', 'EN', 'Import response data', '2025-04-01 14:20:26'),
(295, 'Importa datos de tarjetas', 'ES', 'EN', 'Import card data', '2025-04-01 14:20:26'),
(296, 'Importa datos de categorías', 'ES', 'EN', 'Import category data', '2025-04-01 14:20:26'),
(297, 'Importa datos de preguntas', 'ES', 'EN', 'Import question data', '2025-04-01 14:20:26'),
(298, 'Tarjetas', 'ES', 'EN', 'Cards', '2025-04-01 14:20:26'),
(299, 'Respuestas', 'ES', 'EN', 'Responses', '2025-04-01 14:20:26'),
(300, 'Hubo un error en la respuesta del servidor.', 'ES', 'EN', 'There was an error in the server response.', '2025-04-01 14:20:26'),
(301, 'Error al importar el archivo CSV.', 'ES', 'EN', 'Error importing CSV file.', '2025-04-01 14:20:26'),
(302, 'Participación Usuarios Semanal', 'ES', 'EN', 'User Participation Weekly', '2025-04-01 14:27:02'),
(303, '% Aciertos por Categoría', 'ES', 'EN', '% Hits by Category', '2025-04-01 14:27:02'),
(304, 'Usuarios Únicos', 'ES', 'EN', 'Single Users', '2025-04-01 14:27:02'),
(305, 'Partidas Jugadas Diarias', 'ES', 'EN', 'Games Played Daily', '2025-04-01 14:27:02'),
(306, 'Aciertos', 'ES', 'EN', 'Hits', '2025-04-01 14:27:02'),
(307, '% Aciertos por Dificultad', 'ES', 'EN', '% Hits per Difficulty', '2025-04-01 14:27:02'),
(308, 'Partidas Jugadas', 'ES', 'EN', 'Games Played', '2025-04-01 14:27:02'),
(309, 'Miércoles', 'ES', 'EN', 'Wednesday', '2025-04-01 14:27:02'),
(310, 'Martes', 'ES', 'EN', 'Tuesday', '2025-04-01 14:27:02'),
(311, 'Lunes', 'ES', 'EN', 'Monday', '2025-04-01 14:27:02'),
(312, 'Domingo', 'ES', 'EN', 'Sunday', '2025-04-01 14:27:03'),
(313, 'Sábado', 'ES', 'EN', 'Saturday', '2025-04-01 14:27:03'),
(314, 'Cultura General', 'ES', 'EN', 'General Culture', '2025-04-01 14:27:03'),
(315, 'Viernes', 'ES', 'EN', 'Friday', '2025-04-01 14:27:06'),
(316, 'Jueves', 'ES', 'EN', 'Thursday', '2025-04-01 14:27:06'),
(317, 'Usuarios Totales', 'ES', 'EN', 'Total Users', '2025-04-01 14:31:45'),
(318, 'GESTIÓN DE USUARIOS', 'ES', 'EN', 'USER MANAGEMENT', '2025-04-01 14:31:45'),
(319, 'Usuarios Conectados', 'ES', 'EN', 'Connected Users', '2025-04-01 14:31:45'),
(320, 'ID', 'ES', 'EN', 'ID', '2025-04-01 14:31:45'),
(321, 'USER', 'ES', 'EN', 'USER', '2025-04-01 14:31:45'),
(322, 'CORREO', 'ES', 'EN', 'MAIL', '2025-04-01 14:31:45'),
(323, 'ACCIONES', 'ES', 'EN', 'ACTIONS', '2025-04-01 14:31:46'),
(324, 'Seleccionar Imagen', 'ES', 'EN', 'Select Image', '2025-04-01 14:31:46'),
(325, '¿Deshabilitar al usuario', 'ES', 'EN', 'Disable user', '2025-04-01 14:31:46'),
(326, 'Por favor selecciona un archivo de imagen válido.', 'ES', 'EN', 'Please select a valid image file.', '2025-04-01 14:31:46'),
(327, 'Error al actualizar usuario', 'ES', 'EN', 'Error updating user', '2025-04-01 14:31:46'),
(328, 'Usuario deshabilitado correctamente', 'ES', 'EN', 'User disabled correctly', '2025-04-01 14:31:48'),
(329, 'Error al deshabilitar el usuario', 'ES', 'EN', 'Error when disabling the user', '2025-04-01 14:31:48'),
(330, 'Error de conexión', 'ES', 'EN', 'Connection error', '2025-04-01 14:31:48'),
(331, 'Usuario actualizado correctamente', 'ES', 'EN', 'User updated correctly', '2025-04-01 14:31:48'),
(332, 'GESTIÓN DE CATEGORÍAS', 'ES', 'EN', 'CATEGORY MANAGEMENT', '2025-04-01 14:38:47'),
(333, 'Preguntas por categoría', 'ES', 'EN', 'Questions by category', '2025-04-01 14:38:47'),
(334, 'GUARDAR', 'ES', 'EN', 'SAVE', '2025-04-01 14:38:47'),
(335, 'NOMBRE', 'ES', 'EN', 'NAME', '2025-04-01 14:38:47'),
(336, 'IMAGEN', 'ES', 'EN', 'IMAGE', '2025-04-01 14:38:47'),
(337, 'Categoría actualizada correctamente', 'ES', 'EN', 'Category correctly updated', '2025-04-01 14:38:47'),
(338, 'Error al actualizar categoría', 'ES', 'EN', 'Error updating category', '2025-04-01 14:38:47'),
(339, 'Science', 'ES', 'EN', 'Science', '2025-04-01 14:44:49'),
(341, 'DIFICULTAD', 'ES', 'EN', 'DIFFICULTY', '2025-04-01 14:59:27'),
(342, 'PREGUNTA', 'ES', 'EN', 'QUESTION', '2025-04-01 14:59:27'),
(343, 'AÑADIR PREGUNTA', 'ES', 'EN', 'ADD QUESTION', '2025-04-01 14:59:27'),
(344, 'GESTIÓN DE PREGUNTAS', 'ES', 'EN', 'QUESTION MANAGEMENT', '2025-04-01 14:59:28'),
(345, 'Buscar pregunta...', 'ES', 'EN', 'Search question...', '2025-04-01 14:59:28'),
(346, 'CATEGORÍA', 'ES', 'EN', 'CATEGORY', '2025-04-01 14:59:28'),
(348, 'Respuesta correcta', 'ES', 'EN', 'Correct answer', '2025-04-01 14:59:28'),
(350, 'Pregunta deshabilitada correctamente', 'ES', 'EN', 'Question successfully disabled', '2025-04-01 14:59:28'),
(351, 'Opciones', 'ES', 'EN', 'Options', '2025-04-01 14:59:28'),
(352, 'Error al crear la pregunta', 'ES', 'EN', 'Error creating the question', '2025-04-01 14:59:28'),
(353, '¡Pregunta añadida exitosamente!', 'ES', 'EN', 'Question successfully added!', '2025-04-01 14:59:28'),
(354, 'Error al actualizar la pregunta', 'ES', 'EN', 'Error updating the question', '2025-04-01 14:59:28'),
(355, '¡Pregunta actualizada correctamente!', 'ES', 'EN', 'Question updated correctly!', '2025-04-01 14:59:28'),
(356, 'Escribe la pregunta', 'ES', 'EN', 'Write the question', '2025-04-01 14:59:29'),
(357, 'Selecciona la dificultad', 'ES', 'EN', 'Select difficulty', '2025-04-01 14:59:29'),
(358, 'Selecciona una categoría', 'ES', 'EN', 'Select a category', '2025-04-01 14:59:29'),
(359, 'Escribe la respuesta correcta', 'ES', 'EN', 'Write the correct answer', '2025-04-01 14:59:29'),
(360, 'Escribe las respuestas (separadas por |)', 'ES', 'EN', 'Write the answers (separated by |)', '2025-04-01 14:59:29'),
(361, 'Error al deshabilitar la pregunta', 'ES', 'EN', 'Error disabling the question', '2025-04-01 14:59:31'),
(362, 'Error: La respuesta correcta no está en las primeras 4 opciones', 'ES', 'EN', 'Error: The correct answer is not in the first 4 options.', '2025-04-01 14:59:31'),
(363, 'Escribe la pregunta en español', 'ES', 'EN', 'Write the question in Spanish', '2025-04-01 15:09:31'),
(364, 'Cancelar', 'ES', 'EN', 'Cancel', '2025-04-01 16:26:37'),
(365, 'Recuperar Contraseña', 'ES', 'EN', 'Recover Password', '2025-04-01 16:26:37'),
(366, 'Enviar', 'ES', 'EN', 'Send to', '2025-04-01 16:26:37'),
(367, 'Correo no encontrado', 'ES', 'EN', 'Mail not found', '2025-04-01 16:26:37'),
(368, 'Error al verificar el correo', 'ES', 'EN', 'Error verifying email', '2025-04-01 16:26:37'),
(369, '¿Te has olvidado de tu contraseña?', 'ES', 'EN', 'Forgot your password?', '2025-04-01 16:26:37'),
(370, 'Por favor complete todos los campos', 'ES', 'EN', 'Please complete all fields', '2025-04-01 17:44:32'),
(371, 'Usuario o contraseña incorrectos', 'ES', 'EN', 'Incorrect username or password', '2025-04-01 17:44:32'),
(372, 'Ha ocurrido un error, intente nuevamente', 'ES', 'EN', 'An error has occurred, try again', '2025-04-01 17:44:32'),
(373, 'La contraseña no cumple con los requisitos mínimos', 'ES', 'EN', 'Password does not meet the minimum requirements', '2025-04-01 17:44:32'),
(374, 'La Antártida', 'ES', 'EN', 'Antarctica', '2025-04-03 13:29:50'),
(376, 'Siberia', 'ES', 'EN', 'Siberia', '2025-04-03 13:29:50'),
(377, '¿Cuál es el lugar más frío de la tierra?', 'ES', 'EN', 'What is the coldest place on earth?', '2025-04-03 13:29:50'),
(378, 'Pascal', 'ES', 'EN', 'Pascal', '2025-04-03 13:30:24'),
(379, 'Joule', 'ES', 'EN', 'Joule', '2025-04-03 13:30:24'),
(380, 'Watt', 'ES', 'EN', 'Watt', '2025-04-03 13:30:24'),
(381, '¿Qué unidad se utiliza para medir la fuerza en el Sistema Internacional?', 'ES', 'EN', 'What unit is used to measure force in the International System?', '2025-04-03 13:30:24'),
(382, 'Mar Mediterraneo', 'ES', 'EN', 'Mediterranean Sea', '2025-04-03 13:30:59'),
(383, 'Mar Arábigo', 'ES', 'EN', 'Arabian Sea', '2025-04-03 13:30:59'),
(385, 'Mar Adriático', 'ES', 'EN', 'Adriatic Sea', '2025-04-03 13:30:59'),
(386, 'Mar Negro', 'ES', 'EN', 'Black Sea', '2025-04-03 13:30:59'),
(387, '¿Cuál es el mar más grande del mundo?', 'ES', 'EN', 'What is the largest sea in the world?', '2025-04-03 13:30:59'),
(388, 'Inglés', 'ES', 'EN', 'English', '2025-04-03 13:31:17'),
(389, 'Chino mandarín', 'ES', 'EN', 'Mandarin Chinese', '2025-04-03 13:31:17'),
(390, 'Hindi', 'ES', 'EN', 'Hindi', '2025-04-03 13:31:17'),
(391, '¿Cuál es el idioma con mayor cantidad de hablantes nativos en el mundo?', 'ES', 'EN', 'What is the language with the largest number of native speakers in the world?', '2025-04-03 13:31:17'),
(393, 'Español', 'ES', 'EN', 'Spanish', '2025-04-03 13:31:17');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `correo` varchar(255) NOT NULL,
  `contraseña` char(60) NOT NULL,
  `num_derrotas` int UNSIGNED DEFAULT '0',
  `num_victorias` int UNSIGNED DEFAULT '0',
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  `habilitado` tinyint(1) DEFAULT '1',
  `rol` varchar(20) DEFAULT 'jugador',
  `ult_conexion` datetime DEFAULT NULL,
  `imagen` varchar(255) DEFAULT NULL
) ;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombre`, `correo`, `contraseña`, `num_derrotas`, `num_victorias`, `fecha_registro`, `habilitado`, `rol`, `ult_conexion`, `imagen`) VALUES
(1, 'PEPE_123ASD', 'pepe123@example.com', '1234', 5, 10, '2025-03-06 16:16:53', 1, 'jugador', '2025-03-06 16:25:55', 'https://www.qanimals.com/wp-content/uploads/2024/10/pexels-river-augustin-1370012990-28934371.jpg'),
(2, 'ANANAS', 'pepesito@example.com', 'hashed_password_2', 3, 15, '2025-03-06 16:16:53', 1, 'jugador', NULL, NULL),
(3, 'JHON DURAN', 'pepe@example.com', 'hashed_password_3', 7, 8, '2025-03-06 16:16:53', 1, 'jugador', NULL, NULL),
(4, 'MARIA_ABCD', 'maria@example.com', 'hashed_password_4', 2, 20, '2025-03-06 16:16:53', 1, 'jugador', NULL, NULL),
(5, 'JUAN_XYZ', 'juan@example.com', 'hashed_password_5', 6, 12, '2025-03-06 16:16:53', 1, 'jugador', NULL, NULL),
(6, 'ANA_321', 'ana@example.com', 'hashed_password_6', 4, 18, '2025-03-06 16:16:53', 1, 'jugador', NULL, NULL),
(7, 'LUIS_654', 'luis@example.com', 'hashed_password_7', 8, 7, '2025-03-06 16:16:53', 1, 'jugador', NULL, NULL),
(8, 'CARLA_987', 'carla@example.com', 'hashed_password_8', 1, 22, '2025-03-06 16:16:53', 1, 'jugador', NULL, NULL),
(9, 'PEDRO_KLK', 'pedro@example.com', 'hashed_password_9', 9, 5, '2025-03-06 16:16:53', 1, 'jugador', NULL, NULL),
(10, 'SOFIA_GHI', 'sofia@example.com', 'hashed_password_10', 10, 3, '2025-03-06 16:16:53', 1, 'jugador', NULL, NULL),
(14, 'Prueba', 'antoniolucenilla32@alumnes.ilerna.com', '$2y$10$3hLlv4cM7Y9w6OMDpasnV.WDIuQqE8LUFubYPHBXYf8kOu.vIu3.G', 0, 0, '2025-03-11 17:15:05', 1, 'jugador', '2025-03-13 19:05:01', 'assets/users/prueba/prueba.png'),
(16, 'admin', 'antoniolucenilla32@gmail.com', '$2y$10$36EzMQP8fVDUE7ks1gVPbu.bfP7w.CHKzt8mfehN1qEOIW4K0UQNS', 0, 0, '2025-03-12 16:39:17', 1, 'admin', '2025-05-08 16:59:28', 'assets/users/admin/admin.png'),
(19, 'prueba2', 'asd123@asd.com', '$2y$10$CRIahW75xSXXQIX9aYAfie6iMEsKK6YzH0hsQyMKaZk5yCDBc4aXi', 0, 0, '2025-03-18 16:07:42', 1, 'jugador', '2025-03-18 16:07:42', 'assets/users/default/default.png'),
(20, 'qwe', 'qwe@qwe.com', '$2y$10$g9PtzySoDGslOnj0Qa4A1.ICWdiK7yrG5W.BazDLvEVC62H5CSIDa', 0, 0, '2025-03-25 15:47:53', 1, 'jugador', '2025-03-25 15:47:53', 'assets/users/default/default.png'),
(21, 'Imma', 'imma@gmail.com', '$2y$10$iZdiLudR5qwbKMCyosm4A.0p4jyjwiBVv/W5IZQdHiHz3.5AMLXNu', 0, 0, '2025-05-07 17:20:05', 1, 'jugador', '2025-05-07 17:21:18', 'assets/users/default/default.png'),
(22, 'antonio', 'antonio@gmail.com', '$2y$10$od4LxD5IhKfygbhi4i/Dr.3.jJ8SZ2kUrymuEMEYuGn/xSdcNzENi', 0, 0, '2025-05-07 17:21:36', 1, 'jugador', '2025-05-07 17:23:24', 'assets/users/default/default.png'),
(23, 'andres', 'andres@gmail.com', '$2y$10$O3ppIqcIeC8nkeXCNCK7IuR8kY/B0ljWEuEGwiCWRew8VP8HIS5jm', 0, 0, '2025-05-07 17:23:38', 1, 'jugador', '2025-05-07 17:24:13', 'assets/users/default/default.png');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`id_categoria`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `comodin`
--
ALTER TABLE `comodin`
  ADD PRIMARY KEY (`id_comodin`),
  ADD KEY `id_partida` (`id_partida`);

--
-- Indices de la tabla `estadisticas`
--
ALTER TABLE `estadisticas`
  ADD PRIMARY KEY (`id_usuario`,`id_categoria`),
  ADD KEY `id_categoria` (`id_categoria`),
  ADD KEY `idx_estadisticas_usuario` (`id_usuario`);

--
-- Indices de la tabla `historialpreguntas`
--
ALTER TABLE `historialpreguntas`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `id_partida` (`id_partida`),
  ADD KEY `id_pregunta` (`id_pregunta`);

--
-- Indices de la tabla `participante`
--
ALTER TABLE `participante`
  ADD PRIMARY KEY (`id_usuario`,`id_partida`),
  ADD KEY `id_partida` (`id_partida`);

--
-- Indices de la tabla `partida`
--
ALTER TABLE `partida`
  ADD PRIMARY KEY (`id_partida`),
  ADD KEY `ganador` (`ganador`);

--
-- Indices de la tabla `pregunta`
--
ALTER TABLE `pregunta`
  ADD PRIMARY KEY (`id_pregunta`),
  ADD KEY `id_tarjeta` (`id_tarjeta`);

--
-- Indices de la tabla `ranking`
--
ALTER TABLE `ranking`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `categoria_destacada` (`categoria_destacada`);

--
-- Indices de la tabla `respuesta`
--
ALTER TABLE `respuesta`
  ADD PRIMARY KEY (`id_respuesta`),
  ADD KEY `id_pregunta` (`id_pregunta`);

--
-- Indices de la tabla `ronda`
--
ALTER TABLE `ronda`
  ADD PRIMARY KEY (`id_partida`,`num_ronda`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `tarjeta`
--
ALTER TABLE `tarjeta`
  ADD PRIMARY KEY (`id_tarjeta`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `traducciones`
--
ALTER TABLE `traducciones`
  ADD PRIMARY KEY (`id_traduccion`),
  ADD UNIQUE KEY `unica_traduccion` (`texto_original`(255),`idioma_origen`,`idioma_destino`);
ALTER TABLE `traducciones` ADD FULLTEXT KEY `idx_texto_original` (`texto_original`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `nombre` (`nombre`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `id_categoria` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `comodin`
--
ALTER TABLE `comodin`
  MODIFY `id_comodin` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `historialpreguntas`
--
ALTER TABLE `historialpreguntas`
  MODIFY `id_historial` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=205;

--
-- AUTO_INCREMENT de la tabla `partida`
--
ALTER TABLE `partida`
  MODIFY `id_partida` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- AUTO_INCREMENT de la tabla `pregunta`
--
ALTER TABLE `pregunta`
  MODIFY `id_pregunta` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=214;

--
-- AUTO_INCREMENT de la tabla `respuesta`
--
ALTER TABLE `respuesta`
  MODIFY `id_respuesta` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=876;

--
-- AUTO_INCREMENT de la tabla `tarjeta`
--
ALTER TABLE `tarjeta`
  MODIFY `id_tarjeta` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `traducciones`
--
ALTER TABLE `traducciones`
  MODIFY `id_traduccion` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=394;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `comodin`
--
ALTER TABLE `comodin`
  ADD CONSTRAINT `comodin_ibfk_1` FOREIGN KEY (`id_partida`) REFERENCES `partida` (`id_partida`) ON DELETE CASCADE;

--
-- Filtros para la tabla `estadisticas`
--
ALTER TABLE `estadisticas`
  ADD CONSTRAINT `estadisticas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `estadisticas_ibfk_2` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE CASCADE;

--
-- Filtros para la tabla `historialpreguntas`
--
ALTER TABLE `historialpreguntas`
  ADD CONSTRAINT `historialpreguntas_ibfk_1` FOREIGN KEY (`id_partida`) REFERENCES `partida` (`id_partida`) ON DELETE CASCADE,
  ADD CONSTRAINT `historialpreguntas_ibfk_2` FOREIGN KEY (`id_pregunta`) REFERENCES `pregunta` (`id_pregunta`) ON DELETE CASCADE;

--
-- Filtros para la tabla `participante`
--
ALTER TABLE `participante`
  ADD CONSTRAINT `participante_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `participante_ibfk_2` FOREIGN KEY (`id_partida`) REFERENCES `partida` (`id_partida`) ON DELETE CASCADE;

--
-- Filtros para la tabla `partida`
--
ALTER TABLE `partida`
  ADD CONSTRAINT `partida_ibfk_1` FOREIGN KEY (`ganador`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `pregunta`
--
ALTER TABLE `pregunta`
  ADD CONSTRAINT `pregunta_ibfk_1` FOREIGN KEY (`id_tarjeta`) REFERENCES `tarjeta` (`id_tarjeta`);

--
-- Filtros para la tabla `ranking`
--
ALTER TABLE `ranking`
  ADD CONSTRAINT `ranking_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `ranking_ibfk_2` FOREIGN KEY (`categoria_destacada`) REFERENCES `categoria` (`id_categoria`) ON DELETE CASCADE;

--
-- Filtros para la tabla `respuesta`
--
ALTER TABLE `respuesta`
  ADD CONSTRAINT `respuesta_ibfk_1` FOREIGN KEY (`id_pregunta`) REFERENCES `pregunta` (`id_pregunta`) ON DELETE CASCADE;

--
-- Filtros para la tabla `ronda`
--
ALTER TABLE `ronda`
  ADD CONSTRAINT `ronda_ibfk_1` FOREIGN KEY (`id_partida`) REFERENCES `partida` (`id_partida`) ON DELETE CASCADE,
  ADD CONSTRAINT `ronda_ibfk_2` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE CASCADE;

--
-- Filtros para la tabla `tarjeta`
--
ALTER TABLE `tarjeta`
  ADD CONSTRAINT `tarjeta_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
