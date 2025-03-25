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

        // Consulta mejorada con joins correctos y selección de campos
        $sql_pregunta = "
            SELECT
                p.id_pregunta,
                p.texto AS pregunta,
                t.dificultad,
                c.nombre AS categoria,
                (SELECT texto 
                 FROM Respuesta 
                 WHERE id_pregunta = p.id_pregunta 
                 AND es_correcta = 1 
                 AND habilitado = 1 
                 LIMIT 1) AS correcta
            FROM Pregunta p
            JOIN Tarjeta t ON p.id_tarjeta = t.id_tarjeta
            JOIN Categoria c ON t.id_categoria = c.id_categoria
            WHERE p.habilitado = 1
            AND c.nombre = ?
            ORDER BY RAND()
            LIMIT 1
        ";

        $stmt_pregunta = $conn->prepare($sql_pregunta);
        if (!$stmt_pregunta) {
            throw new Exception("Error al preparar consulta: " . $conn->error);
        }
        
        $stmt_pregunta->bind_param('s', $categoria);
        if (!$stmt_pregunta->execute()) {
            throw new Exception("Error al ejecutar consulta: " . $stmt_pregunta->error);
        }
        
        $result_pregunta = $stmt_pregunta->get_result();
        $pregunta = $result_pregunta->fetch_assoc();
        $stmt_pregunta->close();

        if (!$pregunta) {
            throw new Exception("No hay preguntas disponibles para esta categoría");
        }

        // Consulta de respuestas mejorada
        $sql_respuestas = "
            SELECT texto 
            FROM Respuesta 
            WHERE id_pregunta = ? 
            AND habilitado = 1
            ORDER BY RAND()
        ";

        $stmt_respuestas = $conn->prepare($sql_respuestas);
        if (!$stmt_respuestas) {
            throw new Exception("Error al preparar consulta de respuestas: " . $conn->error);
        }
        
        $stmt_respuestas->bind_param('i', $pregunta['id_pregunta']);
        if (!$stmt_respuestas->execute()) {
            throw new Exception("Error al ejecutar consulta de respuestas: " . $stmt_respuestas->error);
        }
        
        $result_respuestas = $stmt_respuestas->get_result();
        $opciones = [];
        while ($row = $result_respuestas->fetch_assoc()) {
            $opciones[] = $row['texto'];
        }
        $stmt_respuestas->close();

        // Verificar que la respuesta correcta esté presente
        $correcta = $pregunta['correcta'];
        if (!in_array($correcta, $opciones)) {
            throw new Exception("La respuesta correcta no está entre las opciones disponibles");
        }

        // Mezclar opciones aleatoriamente
        shuffle($opciones);

        echo json_encode([
            'status' => 'success',
            'data' => [
                'id_pregunta' => $pregunta['id_pregunta'],
                'pregunta' => $pregunta['pregunta'],
                'dificultad' => $pregunta['dificultad'],
                'categoria' => $pregunta['categoria'],
                'opciones' => $opciones,
                'correcta' => $correcta
            ]
        ]);

    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'mensaje' => $e->getMessage()
        ]);
    }
}
?>