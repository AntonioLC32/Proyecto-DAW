<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function actualizarCategoria($data) {
    global $conn;
    $conn->begin_transaction();

    try {
        $required = ['id_categoria', 'nombre'];
        foreach ($required as $field) {
            if (!isset($data[$field])) {
                throw new Exception("Campo requerido faltante: $field");
            }
        }

        $id_categoria = $data['id_categoria'];
        $nombre = trim($data['nombre']);
        $nombreImagenBase = strtolower(str_replace(' ', '-', preg_replace('/[^A-Za-z0-9 ]/', '', $nombre)));
        $uploadDir = '../quizmania/src/assets/';
        $newImageName = null;

        $stmtOld = $conn->prepare("SELECT imagen FROM Categoria WHERE id_categoria = ?");
        $stmtOld->bind_param("i", $id_categoria);
        $stmtOld->execute();
        $resultOld = $stmtOld->get_result();
        $rowOld = $resultOld->fetch_assoc();

        if (!$rowOld) {
            throw new Exception("No se encontró la categoría con ID: $id_categoria");
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

            $newImageName = "assets/{$nombreImagenBase}.{$extension}";
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
            $stmt = $conn->prepare("UPDATE Categoria SET nombre = ?, imagen = ? WHERE id_categoria = ?");
            $stmt->bind_param("ssi", $nombre, $newImageName, $id_categoria);
        } else {
            $stmt = $conn->prepare("UPDATE Categoria SET nombre = ? WHERE id_categoria = ?");
            $stmt->bind_param("si", $nombre, $id_categoria);
        }

        if (!$stmt->execute()) {
            throw new Exception("Error al actualizar categoría");
        }

        $conn->commit();
        echo json_encode(['status' => 'success', 'mensaje' => 'Categoría actualizada']);
        
    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(400);
        echo json_encode(['status' => 'error', 'mensaje' => $e->getMessage()]);
    }
}
?>