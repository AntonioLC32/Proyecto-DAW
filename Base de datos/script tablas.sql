CREATE DATABASE IF NOT EXISTS quizmania;
USE quizmania;
-- Tablas independientes
CREATE TABLE Categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
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
    habilitado BOOLEAN DEFAULT TRUE,
    rol VARCHAR(20) DEFAULT 'jugador',
    ult_conexion DATETIME DEFAULT NULL,
    imagen VARCHAR(255)
);
-- Tablas dependientes de Categoría/Partida
CREATE TABLE Ranking (
    id_usuario INT PRIMARY KEY,
    rondas INT,
    puntos INT,
    posicion INT UNSIGNED,
    categoria_destacada INT,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (categoria_destacada) REFERENCES Categoria(id_categoria) ON DELETE CASCADE
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
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
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
    id_categoria INT NOT NULL,
    PRIMARY KEY (id_partida, num_ronda),
    FOREIGN KEY (id_partida) REFERENCES Partida(id_partida) ON DELETE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria) ON DELETE CASCADE
);

-- Tabla dependiente de Partida
CREATE TABLE Comodin (
    id_comodin INT AUTO_INCREMENT PRIMARY KEY,
    id_partida INT NOT NULL,
    nombre ENUM('50/50','quitar respuesta','pasar pregunta') NOT NULL,
    cantidad_maxima TINYINT UNSIGNED DEFAULT 1,
    FOREIGN KEY (id_partida) REFERENCES Partida(id_partida) ON DELETE CASCADE
);

CREATE TABLE Estadisticas (
    id_usuario INT NOT NULL,
    id_categoria INT NOT NULL,
    puntos INT UNSIGNED DEFAULT 0,
    PRIMARY KEY (id_usuario, id_categoria),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria) ON DELETE CASCADE
);


CREATE TABLE HistorialPreguntas (
  id_historial INT AUTO_INCREMENT PRIMARY KEY,
  id_partida INT NOT NULL,
  id_pregunta INT NOT NULL,
  acertada TINYINT(1) NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_partida) REFERENCES Partida(id_partida) ON DELETE CASCADE,
  FOREIGN KEY (id_pregunta) REFERENCES Pregunta(id_pregunta) ON DELETE CASCADE
);

CREATE TABLE Traducciones (
    id_traduccion INT AUTO_INCREMENT PRIMARY KEY,
    texto_original TEXT NOT NULL,
    idioma_origen VARCHAR(5) NOT NULL,
    idioma_destino VARCHAR(5) NOT NULL,
    texto_traducido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unica_traduccion (texto_original(255), idioma_origen, idioma_destino)
);

-- Añadir índice para búsquedas más rápidas
ALTER TABLE Traducciones ADD FULLTEXT INDEX idx_texto_original (texto_original);


CREATE INDEX idx_usuario_fecha_registro ON Usuario(fecha_registro);
CREATE INDEX idx_usuario_rol ON Usuario(rol);
CREATE INDEX idx_usuario_victorias ON Usuario(num_victorias);
CREATE INDEX idx_usuario_ult_conexion ON Usuario(ult_conexion);

CREATE INDEX idx_ranking_puntos ON Ranking(puntos);
CREATE INDEX idx_ranking_posicion ON Ranking(posicion);

CREATE INDEX idx_partida_estado ON Partida(estado);
CREATE INDEX idx_partida_modo ON Partida(modo);
CREATE INDEX idx_partida_fecha ON Partida(fecha);

CREATE INDEX idx_tarjeta_dificultad ON Tarjeta(dificultad);

CREATE INDEX idx_pregunta_habilitado ON Pregunta(habilitado);

CREATE INDEX idx_respuesta_correcta ON Respuesta(es_correcta);
CREATE INDEX idx_respuesta_habilitado ON Respuesta(habilitado);

CREATE INDEX idx_participante_partida ON Participante(id_partida);

CREATE INDEX idx_historial_resultado ON Historial(resultado);
CREATE INDEX idx_historial_fecha ON Historial(fecha);

CREATE INDEX idx_comodin_nombre ON Comodin(nombre);

CREATE INDEX idx_estadisticas_puntos ON Estadisticas(puntos);

CREATE INDEX idx_historial_partida ON HistorialPreguntas (id_partida);
CREATE INDEX idx_historial_pregunta ON HistorialPreguntas (id_pregunta);
CREATE INDEX idx_historial_partida_pregunta ON HistorialPreguntas (id_partida, id_pregunta);
