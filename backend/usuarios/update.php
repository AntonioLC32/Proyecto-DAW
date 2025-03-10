<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require 'config/db.php';

function deshabilitarUsuario($data) {
    global $conn;

    try {
        // Validación de campos requeridos
        if (!isset($data['id_usuario']) || !is_numeric($data['id_usuario'])) {
            throw new Exception("ID de usuario inválido o faltante");
        }

        $id_usuario = $data['id_usuario'];

        $stmtUpdateUsuario = $conn->prepare("UPDATE Usuario SET habilitado = 0 WHERE id_usuario = ?");
        $stmtUpdateUsuario->bind_param("i", $id_usuario);
        $stmtUpdateUsuario->execute();

        // Verificar si se afectó alguna fila
        if ($stmtUpdateUsuario->affected_rows === 0) {
            throw new Exception("No se encontró la pregunta con ID: $id_usuario");
        }

        $conn->commit();

        echo json_encode([
            'status' => 'success',
            'mensaje' => 'Usuario deshabilitado correctamente'
        ]);

    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'mensaje' => $e->getMessage()
        ]);
    }
}

?>