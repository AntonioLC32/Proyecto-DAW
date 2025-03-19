<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function obtenerPreguntas() {
    global $conn;

    try {
        // Consulta SQL para obtener preguntas con sus relaciones
        $sql = "
            SELECT 
                p.id_pregunta AS id,
                p.texto AS pregunta,
                t.dificultad,
                c.nombre AS categoria,
                GROUP_CONCAT(r.texto SEPARATOR '|') AS opciones,
                (SELECT texto FROM Respuesta WHERE id_pregunta = p.id_pregunta AND es_correcta = 1 LIMIT 1) AS correcta
            FROM Pregunta p
            JOIN Tarjeta t ON p.id_tarjeta = t.id_tarjeta
            JOIN Categoria c ON t.id_categoria = c.id_categoria
            LEFT JOIN Respuesta r ON p.id_pregunta = r.id_pregunta
            WHERE p.habilitado = 1
            GROUP BY p.id_pregunta
            ORDER BY p.id_pregunta
        ";

        $result = $conn->query($sql);
        
        if (!$result) {
            throw new Exception("Error en la consulta: " . $conn->error);
        }

        $rows = [];
        while ($row = $result->fetch_assoc()) {
           
            $rows[] = [
                'id' => $row['id'],
                'pregunta' => $row['pregunta'],
                'dificultad' => $row['dificultad'],
                'categoria' => $row['categoria'],
                'opciones' => $row['opciones'] ?? '',
                'correcta' => $row['correcta'] ?? '',
                'acciones' => [
                    'editar' => true,
                    'eliminar' => true,
                    'info' => false
                ]
            ];
        }

        echo json_encode([
            'status' => 'success',
            'data' => $rows
        ]);

    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'mensaje' => $e->getMessage()
        ]);
    }
}

function obtenerPreguntaJuego($data) {
    global $conn;

    try {
        $categoria = $data['categoria'];

        // Consulta para obtener una pregunta aleatoria de la categoría
        $sql_pregunta = "
            SELECT
                p.id_pregunta AS id,
                p.texto AS pregunta,
                t.dificultad,
                c.nombre AS categoria,
                (SELECT texto FROM Respuesta WHERE id_pregunta = p.id_pregunta AND es_correcta = 1 LIMIT 1) AS correcta
            FROM Pregunta p
            JOIN Tarjeta t ON p.id_tarjeta = t.id_tarjeta
            JOIN Categoria c ON t.id_categoria = c.id_categoria
            WHERE p.habilitado = 1 AND c.nombre = ?
            ORDER BY RAND()
            LIMIT 1
        ";

        $stmt_pregunta = $conn->prepare($sql_pregunta);
        $stmt_pregunta->bind_param('s', $categoria);
        $result_pregunta = $stmt_pregunta->execute() ? $stmt_pregunta->get_result() : false;

        if (!$result_pregunta) {
            throw new Exception("Error en la consulta de pregunta: " . $conn->error);
        }

        $pregunta = $result_pregunta->fetch_assoc();

        if ($pregunta) {
            // Consulta para obtener las respuestas de la pregunta
            $sql_respuestas = "
                SELECT texto
                FROM Respuesta
                WHERE id_pregunta = ? AND habilitado = 1
            ";

            $stmt_respuestas = $conn->prepare($sql_respuestas);
            $stmt_respuestas->bind_param('i', $pregunta['id']);
            $result_respuestas = $stmt_respuestas->execute() ? $stmt_respuestas->get_result() : false;

            if (!$result_respuestas) {
                throw new Exception("Error en la consulta de respuestas: " . $conn->error);
            }

            // Construir el array de opciones
            $opciones = [];
            while ($row = $result_respuestas->fetch_assoc()) {
                $opciones[] = $row['texto'];
            }

            // Estructurar el resultado
            $resultado = [
                'id' => $pregunta['id'],
                'pregunta' => $pregunta['pregunta'],
                'dificultad' => $pregunta['dificultad'],
                'categoria' => $pregunta['categoria'],
                'opciones' => $opciones, // Array de respuestas
                'correcta' => $pregunta['correcta']
            ];

            // Devolver el resultado en JSON
            echo json_encode([
                'status' => 'success',
                'data' => $resultado
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'mensaje' => 'No se encontró ninguna pregunta para la categoría especificada.'
            ]);
        }

    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'mensaje' => $e->getMessage()
        ]);
    }
}
?>