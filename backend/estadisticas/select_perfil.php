<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

require '../config/db.php';

$usuario_id = 1; // ID fijo del usuario 1

// SQL query with a placeholder for the user ID
$sql = "SELECT 
        u.nombre, 
        r.posicion, 
        r.puntos, 
        r.rondas AS juegos_jugados, 
        u.num_victorias as victorias, 
        r.categoria_destacada, 
        c.imagen AS imagen_categoria  -- Traemos la ruta de la imagen
        FROM Usuario u
        JOIN Ranking r ON u.id_usuario = r.id_usuario
        JOIN Categoria c ON r.categoria_destacada = c.id_categoria -- Relación con la tabla Categorias
        WHERE r.id_usuario = ?";


$stmt = $conn->prepare($sql);
$stmt->bind_param('i', $usuario_id); // 'i' for integer
$stmt->execute();
$result = $stmt->get_result();

if (!$result) {
        echo json_encode(["error" => "Error en la consulta SQL: " . $conn->error]);
        exit;
}

$row = $result->fetch_assoc();

if ($row) {
        // Ensure that the numeric values are integers
        $row['posicion'] = (int) $row['posicion'];
        $row['puntos'] = (int) $row['puntos'];
        $row['juegos_jugados'] = (int) $row['juegos_jugados'];
        $row['victorias'] = (int) $row['victorias'];
        $row['categoria_destacada'] = (int) $row['categoria_destacada'];

        $row['imagen_categoria'] = $row['imagen_categoria'] ?? '';

        echo json_encode([$row]);
} else {
        echo json_encode(["error" => "Usuario no encontrado."]);
}

$stmt->close();
$conn->close();
