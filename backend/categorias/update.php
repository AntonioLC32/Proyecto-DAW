<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function actualizarCategoria() {
    global $conn;

    try {
        // Obtener los datos enviados en el cuerpo de la solicitud
        $input = json_decode(file_get_contents('php://input'), true);

        // Validar que los datos necesarios estén presentes
        if (empty($input['id']) || empty($input['nombre'])) {
            throw new Exception("Datos incompletos: se requieren 'id' y 'nombre'.");
        }

        $id = $input['id'];
        $nombre = $input['nombre'];
        $imagen = $input['imagen'] ?? null; // La imagen es opcional

        // Construir la consulta SQL para actualizar la categoría
        $sql = "UPDATE Categoria SET nombre = ?";
        $params = [$nombre];

        // Si se proporciona una imagen, agregarla a la consulta
        if ($imagen) {
            $sql .= ", imagen = ?";
            $params[] = $imagen;
        }

        $sql .= " WHERE id_categoria = ?";
        $params[] = $id;

        // Preparar y ejecutar la consulta
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            throw new Exception("Error al preparar la consulta: " . $conn->error);
        }

        // Vincular los parámetros dinámicamente
        $types = str_repeat('s', count($params)); // Todos los parámetros son strings
        $stmt->bind_param($types, ...$params);

        if (!$stmt->execute()) {
            throw new Exception("Error al ejecutar la consulta: " . $stmt->error);
        }

        // Verificar si se actualizó alguna fila
        if ($stmt->affected_rows === 0) {
            throw new Exception("No se encontró la categoría con ID $id o no se realizaron cambios.");
        }

        // Devolver una respuesta exitosa
        echo json_encode([
            'status' => 'success',
            'mensaje' => 'Categoría actualizada correctamente.'
        ]);

    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'mensaje' => $e->getMessage()
        ]);
    }
}

// Llamar a la función actualizarCategoria si la acción es correcta
if ($_GET['action'] === 'actualizarCategoria') {
    actualizarCategoria();
} else {
    echo json_encode([
        'status' => 'error',
        'mensaje' => 'Acción no válida'
    ]);
}
?>