<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require '../config/db.php';

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['email']) || empty($data['newPassword'])) {
    echo json_encode([
        "status" => "error",
        "mensaje" => "Datos incompletos"
    ]);
    exit;
}

$email = $data['email'];
$newPasswordPlain = $data['newPassword'];


$sql = "SELECT contraseña FROM usuario WHERE correo = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "status" => "error",
        "mensaje" => "Correo no registrado"
    ]);
    exit;
}

$row = $result->fetch_assoc();
$currentHashedPassword = $row['contraseña'];

if (password_verify($newPasswordPlain, $currentHashedPassword)) {
    echo json_encode([
        "status" => "error",
        "mensaje" => "La nueva contraseña debe ser diferente"
    ]);
    exit;
}

$newHashedPassword = password_hash($newPasswordPlain, PASSWORD_BCRYPT);

$updateSql = "UPDATE usuario SET contraseña = ? WHERE correo = ?";
$updateStmt = $conn->prepare($updateSql);
$updateStmt->bind_param("ss", $newHashedPassword, $email);
$updateStmt->execute();

if ($updateStmt->affected_rows > 0) {
    echo json_encode([
        "status" => "success",
        "mensaje" => "Contraseña actualizada"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "mensaje" => "Error en actualización"
    ]);
}

$stmt->close();
$updateStmt->close();
$conn->close();
?>