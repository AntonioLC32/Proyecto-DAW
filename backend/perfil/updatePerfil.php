<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function actualizarUsuario($data) {
    global $conn;
    $conn->begin_transaction();

    try {
        $required = ['id_usuario', 'nombre'];
        foreach ($required as $field) {
            if (!isset($data[$field])) {
                throw new Exception("Campo requerido faltante: $field");
            }
        }

        $id_usuario = $data['id_usuario'];
        $nombre = trim($data['nombre']);
        $nombreImagenBase = strtolower(str_replace(' ', '-', preg_replace('/[^A-Za-z0-9 ]/', '', $nombre)));
        $uploadDir = '../quizmania/src/assets/users/admin/';
        $newImageName = null;

        $stmtOld = $conn->prepare("SELECT imagen FROM Usuario WHERE id_usuario = ?");
        $stmtOld->bind_param("i", $id_usuario);
        $stmtOld->execute();
        $resultOld = $stmtOld->get_result();
        $rowOld = $resultOld->fetch_assoc();

        if (!$rowOld) {
            throw new Exception("No se encontró el usuario con ID: $id_usuario");
        }

        $oldImage = $rowOld['imagen'];
        $oldImagePath = $uploadDir . basename($oldImage);

        if (isset($data['file']) && !empty($data['file'])) {
            $base64Image = $data['file'];
            $extension = 'png';

            if (strpos($base64Image, 'data:image/') === 0) {
                list($meta, $base64Image) = explode(',', $base64Image, 2);
                preg_match('/data:image\/(.*?);base64/', $meta, $matches);
                if ($matches[1] ?? null) {
                    $extension = $matches[1];
                }
            }

            $newImageName = "assets/users/admin/{$nombreImagenBase}.{$extension}";
            $destination = $uploadDir . "{$nombreImagenBase}.{$extension}";
            if (!file_exists($uploadDir)) {
                mkdir($uploadDir, 0777, true);
            }

            $imageData = base64_decode($base64Image);
            if ($imageData === false) {
                throw new Exception("Error al procesar imagen");
            }

            file_put_contents($destination, $imageData);

            if (!empty($oldImage) && file_exists($oldImagePath)) {
                $oldBasename = basename($oldImage);
                $newBasename = basename($newImageName);
                if ($oldBasename !== $newBasename) {
                    unlink($oldImagePath);
                }
            }
        }

        if ($newImageName) {
            $stmt = $conn->prepare("UPDATE Usuario SET nombre = ?, imagen = ? WHERE id_usuario = ?");
            $stmt->bind_param("ssi", $nombre, $newImageName, $id_usuario);
        } else {
            $stmt = $conn->prepare("UPDATE Usuario SET nombre = ? WHERE id_usuario = ?");
            $stmt->bind_param("si", $nombre, $id_usuario);
        }
        
        if (!$stmt->execute()) {
            throw new Exception("Error al actualizar usuario");
        }
        
        $conn->commit();

        if (ob_get_length()) {
            ob_clean();
        }
        
        echo json_encode(['status' => 'success', 'mensaje' => 'Usuario actualizado']);
        
    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(400);
        echo json_encode(['status' => 'error', 'mensaje' => $e->getMessage()]);
    }
}
?>
