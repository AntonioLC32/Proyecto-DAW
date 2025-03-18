<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

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

$sql = "SELECT 
        e.id_usuario AS id_usuario, -- Specify table alias for id_usuario
        e.id_categoria AS categoria, 
        r.puntos AS puntos_totales,
        r.rondas AS rondas_jugadas 
        FROM Estadisticas e
        JOIN Ranking r ON e.id_usuario = r.id_usuario
        WHERE e.id_usuario = ? -- Specify table alias in WHERE clause
        ORDER BY puntos_totales DESC";

$estadisticas = [];

if ($stmt = $conn->prepare($sql)) {
    $stmt->bind_param("i", $usuario_id); // Bind the parameter (integer type)
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result) {
        if ($result->num_rows === 0) {
            echo json_encode(["message" => "No hay estadísticas para este usuario."]);
            exit;
        }
        while ($row = $result->fetch_assoc()) {
            $estadisticas[] = [
                "categoria" => $row["categoria"],
                "puntos_totales" => $row["puntos_totales"],
                "rondas_jugadas" => $row["rondas_jugadas"]
            ];
        }
    } else {
        echo json_encode(["error" => "Error al obtener los resultados"]);
        exit;
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Error en la preparación de la consulta SQL", "detalle" => $conn->error]);
    exit;
}

$conn->close();

echo json_encode($estadisticas);
?>
