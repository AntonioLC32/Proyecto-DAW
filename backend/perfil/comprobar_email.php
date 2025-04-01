<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require '../config/db.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['email']) || empty($data['email'])) {
    echo json_encode(["status" => "error", "mensaje" => "Correo no proporcionado"]);
    exit;
}

$email = $data['email'];

$sql = "SELECT id_usuario FROM Usuario WHERE correo = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    echo json_encode(["status" => "success", "mensaje" => "Correo encontrado"]);
} else {
    echo json_encode(["status" => "error", "mensaje" => "Correo no encontrado"]);
}

$stmt->close();
$conn->close();