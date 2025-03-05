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
            GROUP BY p.id_pregunta
            ORDER BY p.id_pregunta
        ";

        $result = $conn->query($sql);
        
        if (!$result) {
            throw new Exception("Error en la consulta: " . $conn->error);
        }

        $rows = [];
        while ($row = $result->fetch_assoc()) {
            // Estructurar según necesidades del frontend
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

?>