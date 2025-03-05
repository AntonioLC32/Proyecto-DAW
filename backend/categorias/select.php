<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function obtenerCategorias() {
    global $conn;

    try {
        // Consulta SQL para obtener todas las categorías
        $sql = "
            SELECT 
                id_categoria AS id,
                nombre,
                imagen
            FROM Categoria
            ORDER BY id_categoria
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
                'nombre' => $row['nombre'],
                'imagen' => $row['imagen'],
                'acciones' => [
                    'editar' => true,
                    'eliminar' => false,
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