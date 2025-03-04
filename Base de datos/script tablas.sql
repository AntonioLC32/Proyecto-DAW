CREATE DATABASE IF NOT EXISTS quizmania;
USE quizmania;
-- Tablas independientes
CREATE TABLE Categoría (
    id_categoría INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    imagen VARCHAR(255)
);

-- Tabla dependiente de Ranking
CREATE TABLE Usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    correo varchar(255) NOT NULL UNIQUE CHECK (correo LIKE '%@%.%'),
    contraseña CHAR(60) NOT NULL,
    num_derrotas INT UNSIGNED DEFAULT 0,
    num_victorias INT UNSIGNED DEFAULT 0,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    habilitado BOOLEAN DEFAULT TRUE
);
-- Tablas dependientes de Categoría/Partida
CREATE TABLE Ranking (
    id_usuario INT PRIMARY KEY,
    rondas INT,
    puntos INT,
    posicion INT UNSIGNED,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);


CREATE TABLE Partida (
    id_partida INT AUTO_INCREMENT PRIMARY KEY,
    modo ENUM('solitario','multijugador') NOT NULL,
    vidas TINYINT UNSIGNED DEFAULT 3,
    estado ENUM('activa','finalizada') DEFAULT 'activa',
    ganador INT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ganador) REFERENCES Usuario(id_usuario)
);

-- Tablas dependientes de Categoría
CREATE TABLE Tarjeta (
    id_tarjeta INT AUTO_INCREMENT PRIMARY KEY,
    dificultad ENUM('Fácil','Media','Difícil') NOT NULL,
    id_categoría INT NOT NULL,
    FOREIGN KEY (id_categoría) REFERENCES Categoría(id_categoría)
);

-- Tablas dependientes de Tarjeta
CREATE TABLE Pregunta (
    id_pregunta INT AUTO_INCREMENT PRIMARY KEY,
    texto TEXT NOT NULL,
    habilitado BOOLEAN DEFAULT TRUE,
    id_tarjeta INT NOT NULL,
    FOREIGN KEY (id_tarjeta) REFERENCES Tarjeta(id_tarjeta)
);

CREATE TABLE Respuesta (
    id_respuesta INT AUTO_INCREMENT PRIMARY KEY,
    texto TEXT NOT NULL,
    es_correcta BOOLEAN NOT NULL DEFAULT FALSE,
    habilitado BOOLEAN DEFAULT TRUE,
    id_pregunta INT NOT NULL,
    FOREIGN KEY (id_pregunta) REFERENCES Pregunta(id_pregunta) ON DELETE CASCADE
);

-- Tabla de unión (N:M)
CREATE TABLE Participante (
    id_usuario INT NOT NULL,
    id_partida INT NOT NULL,
    PRIMARY KEY (id_usuario, id_partida),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_partida) REFERENCES Partida(id_partida) ON DELETE CASCADE
);

-- Tablas dependientes de Partida y Categoría
CREATE TABLE Ronda (
    id_partida INT NOT NULL,
    num_ronda INT NOT NULL,
    tiempo TIME NOT NULL,
    id_categoría INT NOT NULL,
    PRIMARY KEY (id_partida, num_ronda),
    FOREIGN KEY (id_partida) REFERENCES Partida(id_partida) ON DELETE CASCADE,
    FOREIGN KEY (id_categoría) REFERENCES Categoría(id_categoría) ON DELETE CASCADE
);

-- Tabla dependiente de Usuario
CREATE TABLE Historial (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    resultado ENUM('victoria','derrota','empate') NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla dependiente de Partida
CREATE TABLE Comodín (
    id_comodín INT AUTO_INCREMENT PRIMARY KEY,
    id_partida INT NOT NULL,
    nombre ENUM('50/50','quitar respuesta','pasar pregunta') NOT NULL,
    cantidad_maxima TINYINT UNSIGNED DEFAULT 1,
    FOREIGN KEY (id_partida) REFERENCES Partida(id_partida) ON DELETE CASCADE
);