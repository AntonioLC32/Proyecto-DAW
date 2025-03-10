<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

require '../config/db.php';

$usuario_id = 1; 

$sql = "SELECT 
    u.nombre,  
    u.contraseña,  
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
        echo json_encode(["error" => "No se encontraron datos para el usuario."]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["error" => "Error en la consulta SQL."]);
}

$conn->close();
?>
