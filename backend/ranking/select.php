<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require '../config/db.php';

// Consulta SQL para obtener los usuarios
$sql = "SELECT u.nombre, r.posicion, r.puntos, r.categoria_destacada 
        FROM Ranking r
        JOIN Usuario u ON r.id_usuario = u.id_usuario
        ORDER BY r.posicion ASC";

$result = $conn->query($sql);

if (!$result) {
    echo json_encode(["error" => "Error en la consulta SQL: " . $conn->error]);
    exit;
}

$usuarios = [];

while ($row = $result->fetch_assoc()) {
    $usuarios[] = $row;
}

$conn->close();

// Devolver los datos en formato JSON
echo json_encode($usuarios);
