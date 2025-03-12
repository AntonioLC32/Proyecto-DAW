<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

require '../config/db.php';

$usuario_id = 1; // ID fijo del usuario 1

$sql = "SELECT 
        id_usuario,
        id_categoria AS categoria, 
        puntos AS puntos_totales 
        FROM Estadisticas
        WHERE id_usuario = $usuario_id
        ORDER BY puntos DESC";

$result = $conn->query($sql);

$estadisticas = [];

if ($result === false) {
    echo json_encode(["error" => "Error en la consulta SQL", "detalle" => $conn->error]);
    exit;
}

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $estadisticas[] = [
            "categoria" => $row["categoria"],
            "puntos_totales" => $row["puntos_totales"]
        ];
    }
}

$conn->close();

echo json_encode($estadisticas);
?>
