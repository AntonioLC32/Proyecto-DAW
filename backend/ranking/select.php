<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require '../config/db.php';

// Consulta SQL para obtener los usuarios de la bbdd
$sql = "SELECT 
  u.nombre, 
  RANK() OVER (ORDER BY r.puntos DESC) AS posicion,  
  r.puntos, 
  r.categoria_destacada, 
  c.imagen 
FROM ranking r
JOIN usuario u ON r.id_usuario = u.id_usuario
JOIN categoria c ON r.categoria_destacada = c.id_categoria;";

$result = $conn->query($sql);

if (!$result) {
    echo json_encode(["error" => "Error en la consulta SQL: " . $conn->error]);
    exit;
}

$usuarios = [];

while ($row = $result->fetch_assoc()) {
  // Asegurrar que los valores numericos sean enteros
  $row['posicion'] = (int) $row['posicion'];
  $row['puntos'] = (int) $row['puntos'];
  $row['categoria_destacada'] = (int) $row['categoria_destacada'];

  $usuarios[] = $row;
}

$conn->close();

// Devolver los datos en formato JSON
echo json_encode($usuarios);
