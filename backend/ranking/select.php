<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

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

// Consulta SQL para obtener los usuarios de la bbdd
$sql = "SELECT 
  u.nombre, 
  u.imagen, 
  RANK() OVER (ORDER BY r.puntos DESC) AS posicion,  
  r.puntos, 
  r.categoria_destacada, 
  c.imagen AS imagen_categoria
FROM ranking r
JOIN usuario u ON r.id_usuario = u.id_usuario
JOIN categoria c ON r.categoria_destacada = c.id_categoria";

$result = $conn->query($sql);

if (!$result) {
    echo json_encode(["error" => "Error en la consulta SQL: " . $conn->error]);
    exit;
}

$usuarios = [];

while ($row = $result->fetch_assoc()) {
  // Asegurar que los valores numéricos sean enteros
  $row['posicion'] = (int) $row['posicion'];
  $row['puntos'] = (int) $row['puntos'];
  $row['categoria_destacada'] = (int) $row['categoria_destacada'];
  $row['imagen'] = $row['imagen'] ?? '../../assets/users/default/default.png';

  $usuarios[] = $row;
}

$conn->close();

// Devolver los datos en formato JSON
echo json_encode($usuarios);
