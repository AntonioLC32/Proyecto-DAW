<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

require '../config/db.php';

$usuario_id = 1; // ID fijo del usuario 1

$sql = "SELECT u.nombre, r.posicion, r.puntos, r.rondas AS juegos_jugados, u.num_victorias as victorias, r.categoria_destacada 
        FROM Usuario u
        JOIN Ranking r ON u.id_usuario = r.id_usuario
        WHERE id = $usuario_id";
$result = $conn->query($sql);


?>
