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

// Imprimir el contenido de la cookie para depuración
echo "Contenido de la cookie 'user':\n";
print_r($user); // Imprime el array de la cookie
echo "\n";

if (!$user || !isset($user['id_usuario'])) {
    echo json_encode(["error" => "Cookie de usuario inválida"]);
    exit;
}

$usuario_id = $user['id_usuario'];

$sql = "SELECT 
        id_usuario,
        id_categoria AS categoria, 
        puntos AS puntos_totales 
        FROM Estadisticas
        WHERE id_usuario = ?
        ORDER BY puntos DESC LIMIT 1";

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
