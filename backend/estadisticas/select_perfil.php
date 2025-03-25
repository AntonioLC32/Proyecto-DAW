<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

require '../config/db.php';

if (!isset($_COOKIE['user'])) {
    echo json_encode(["error" => "Usuario no autenticado"]);
    exit;
}

$user = json_decode($_COOKIE['user'], true);

if (!$user || !isset($user['id_usuario'])) {
    echo json_encode(["error" => "Cookie de usuario inválida"]);
    exit;
}

$usuario_id = $user['id_usuario'];

$sql = "SELECT 
        u.nombre, 
        u.imagen, 
        r.posicion, 
        COALESCE(SUM(e.puntos), 0) AS puntos, 
        r.rondas AS rondasJugadas, 
        u.num_victorias as victorias, 
        COALESCE(r.categoria_destacada, 0) AS categoria_destacada, 
        COALESCE(c.imagen, '') AS imagen_categoria
FROM Usuario u
LEFT JOIN Ranking r ON u.id_usuario = r.id_usuario
LEFT JOIN Estadisticas e ON u.id_usuario = e.id_usuario
LEFT JOIN Categoria c ON r.categoria_destacada = c.id_categoria
WHERE u.id_usuario = ?
GROUP BY u.id_usuario, r.posicion, r.rondas, u.num_victorias, r.categoria_destacada, c.imagen";

$stmt = $conn->prepare($sql);
$stmt->bind_param('i', $usuario_id);
$stmt->execute();
$result = $stmt->get_result();

if (!$result) {
    echo json_encode(["error" => "Error en la consulta SQL: " . $conn->error]);
    exit;
}

$row = $result->fetch_assoc();

if ($row) {
    $row['posicion'] = (int) $row['posicion'];
    $row['puntos'] = (int) $row['puntos'];
    $row['rondasJugadas'] = (int) $row['rondasJugadas'];
    $row['victorias'] = (int) $row['victorias'];
    $row['categoria_destacada'] = (int) $row['categoria_destacada'];
    $row['imagen'] = $row['imagen'] ?? '../../assets/users/default/default.png';
    $row['imagen_categoria'] = $row['imagen_categoria'] ?? '';

    echo json_encode($row);
} else {
    echo json_encode(["error" => "Usuario no encontrado."]);
}

$stmt->close();
$conn->close();
