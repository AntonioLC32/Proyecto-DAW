<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include("../config/db.php");

// Consulta SQL para obtener los usuarios
$sql = "SELECT user AS nombre, ranking AS posicion, puntos, categoria_destacada FROM usuarios ORDER BY ranking ASC";

$result = $conn->query($sql);

$usuarios = [];

if ($result->num_rows > 0) {
    // Recorrer los resultados y añadirlos al array
    while ($row = $result->fetch_assoc()) {
        $usuarios[] = $row;
    }
}

$conn->close();

// Devolver los datos en formato JSON
echo json_encode($usuarios);
?>