<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

require '../config/db.php';

if (!isset($_COOKIE['user'])) {
    echo json_encode(["error" => "Usuario no autenticado"]);
    exit;
}

// Decodificar la cookie 'user'
$user = json_decode($_COOKIE['user'], true);

if (!$user || !isset($user['id_usuario'])) {
    echo json_encode(["error" => "Cookie de usuario inválida"]);
    exit;
}

$usuario_id = $user['id_usuario'];

$sql = "SELECT 
    u.nombre,  
    u.correo, 
    r.posicion, 
    r.puntos, 
    r.categoria_destacada, 
    c.imagen AS imagen_categoria 
FROM Usuario u
JOIN Ranking r ON u.id_usuario = r.id_usuario
JOIN Categoria c ON r.categoria_destacada = c.id_categoria 
WHERE r.id_usuario = ?";

if ($stmt = $conn->prepare($sql)) {
    $stmt->bind_param("i", $usuario_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $perfil = $result->fetch_assoc();
        echo json_encode($perfil);
    } else {
        error_log("No se encontraron datos para el usuario con ID: " . $usuario_id);
        echo json_encode(["error" => "No se encontraron datos para el usuario con ID: " . $usuario_id]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Error en la consulta SQL."]);
}

$conn->close();
