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

// Se obtiene todas las categorías y se unen (LEFT JOIN) los puntos registrados en Estadisticas para el usuario.
// Si no existen datos en Estadisticas para alguna categoría, se mostrará 0.
$sql = "SELECT 
            c.id_categoria AS categoria, 
            IFNULL(e.puntos, 0) AS puntos_totales
        FROM Categoria c
        LEFT JOIN Estadisticas e ON c.id_categoria = e.id_categoria AND e.id_usuario = ?
        ORDER BY puntos_totales DESC";

if ($stmt = $conn->prepare($sql)) {
    $stmt->bind_param("i", $usuario_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $estadisticas = [];

    if ($result) {
        if ($result->num_rows === 0) {
            echo json_encode(["message" => "No hay estadísticas para este usuario."]);
            exit;
        }
        while ($row = $result->fetch_assoc()) {
            $estadisticas[] = [
                "categoria" => $row["categoria"],
                "puntos_totales" => (int)$row["puntos_totales"]
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
