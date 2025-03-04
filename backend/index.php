<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // Permite peticiones desde cualquier dominio
header('Access-Control-Allow-Methods: GET, POST, OPTIONS'); // Métodos permitidos
header('Access-Control-Allow-Headers: Content-Type, Authorization'); // Cabeceras permitidas

// Respuesta simple
$response = [
  'status' => 'success',
  'mensaje' => 'Conexión exitosa desde PHP!'
];

echo json_encode($response);
?>
