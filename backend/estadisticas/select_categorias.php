<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

require '../config/db.php';
$sql = "SELECT 
        c.id_categoria,
        c.imagen AS imagen_categoria
        FROM Categorias c";


$result = $conn->query($sql);
$categorias = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $categorias[] = [
            "id_categoria" => $row["id_categoria"],
            "imagen_categoria" => $row["imagen_categoria"]
        ];
    }
}

echo json_encode($categorias);
