<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

// Consulta SQL para calcular el porcentaje de aciertos por categoría sin restricción de fecha
$sql = "
    SELECT 
        cat.nombre AS categoria, 
        (SUM(hp.acertada) / COUNT(*) * 100) AS porcentaje
    FROM HistorialPreguntas hp
    INNER JOIN Pregunta p ON hp.id_pregunta = p.id_pregunta
    INNER JOIN Tarjeta t ON p.id_tarjeta = t.id_tarjeta
    INNER JOIN Categoria cat ON t.id_categoria = cat.id_categoria
    GROUP BY cat.id_categoria, cat.nombre
";

// Ejecutar la consulta
$result = $conn->query($sql);

$response = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Se redondea el porcentaje a dos decimales para mejor presentación
        $response[] = [
            "categoria" => $row["categoria"],
            "porcentaje" => round((float)$row["porcentaje"], 2)
        ];
    }
} else {
    // En caso de no haber datos, se devuelve un mensaje de error o un array vacío
    $response = ["status" => "error", "mensaje" => "No se encontraron datos"];
}

$conn->close();

// Devolver la respuesta en formato JSON
echo json_encode($response);
?>
