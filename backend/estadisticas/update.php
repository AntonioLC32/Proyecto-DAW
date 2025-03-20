<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require 'config/db.php';

function actualizarEstadisticas($data) {
    global $conn;

    // Validar campos requeridos
    $campos_requeridos = ['id_usuario', 'nombre_categoria', 'puntos'];
    foreach ($campos_requeridos as $campo) {
        if (!isset($data[$campo])){
            echo json_encode(['status' => 'error', 'mensaje' => "Campo $campo es requerido"]);
            exit;
        }
    }

    $sql_categoria = "SELECT id_categoria FROM Categoria WHERE nombre = ?";
    $stmt_cat = $conn->prepare($sql_categoria);
    $stmt_cat->bind_param("s", $data['nombre_categoria']);
    $stmt_cat->execute();
    $result_cat = $stmt_cat->get_result();
    
    if ($result_cat->num_rows === 0) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Categoría no encontrada']);
        exit;
    }
    
    $categoria = $result_cat->fetch_assoc();
    $id_categoria = $categoria['id_categoria'];

    try {
        $sql = "INSERT INTO Estadisticas (id_usuario, id_categoria, puntos)
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE puntos = puntos + VALUES(puntos)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("iii", $data['id_usuario'], $id_categoria, $data['puntos']);
        
        if ($stmt->execute()) {
            echo json_encode(['status' => 'success']);
        } else {
            throw new Exception("Error al ejecutar la consulta: " . $stmt->error);
        }
    } catch (Exception $e) {
        error_log($e->getMessage());
        echo json_encode(['status' => 'error', 'mensaje' => 'Error en el servidor']);
    }
}


?>