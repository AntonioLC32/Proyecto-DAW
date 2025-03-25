<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

// Consulta SQL para calcular el porcentaje de aciertos por dificultad
$sql = "
    SELECT 
        t.dificultad AS dificultad, 
        (SUM(hp.acertada) / COUNT(*) * 100) AS porcentaje
    FROM HistorialPreguntas hp
    INNER JOIN Pregunta p ON hp.id_pregunta = p.id_pregunta
    INNER JOIN Tarjeta t ON p.id_tarjeta = t.id_tarjeta
    GROUP BY t.dificultad
";

// Ejecutar la consulta
$result = $conn->query($sql);

$response = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Redondea el porcentaje a dos decimales
        $response[] = [
            "dificultad" => $row["dificultad"],
            "porcentaje" => round((float)$row["porcentaje"], 2)
        ];
    }
} else {
    $response = ["status" => "error", "mensaje" => "No se encontraron datos"];
}

$conn->close();

echo json_encode($response);
?>
