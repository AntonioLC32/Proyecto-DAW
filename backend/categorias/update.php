<?php
// Habilitar reporte de errores para depuración
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function actualizarCategoria($data) {
    global $conn;

    try {
        // Validar campos requeridos
        $required = ['id_categoria', 'nombre'];
        foreach ($required as $field) {
            if (!isset($data[$field])) {
                throw new Exception("Campo requerido faltante: $field");
            }
        }

        $id_categoria = $data['id_categoria'];
        $nombre = $data['nombre'];

        // Iniciar transacción
        $conn->begin_transaction();

        // 1. Obtener la imagen antigua para eliminarla
        $stmtOld = $conn->prepare("SELECT imagen FROM Categoria WHERE id_categoria = ?");
        $stmtOld->bind_param("i", $id_categoria);
        $stmtOld->execute();
        $resultOld = $stmtOld->get_result();
        $rowOld = $resultOld->fetch_assoc();

        if (!$rowOld) {
            throw new Exception("No se encontró la categoría con ID: $id_categoria");
        }

        $oldImage = $rowOld['imagen'];
        $uploadDir = '../../assets/';
        $oldImagePath = $uploadDir . $oldImage;

        // 2. Manejar la nueva imagen si se proporciona
        $newImageName = null;
        if (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
            // Crear un nombre único para la nueva imagen
            $newImageName = time() . '_' . basename($_FILES['file']['name']);
            $destination = $uploadDir . $newImageName;

            // Mover el archivo subido a la carpeta de assets
            if (!move_uploaded_file($_FILES['file']['tmp_name'], $destination)) {
                throw new Exception("Error al subir la nueva imagen.");
            }

            // Eliminar la imagen antigua si existe
            if (file_exists($oldImagePath)) {
                unlink($oldImagePath);
            }
        }

        // 3. Actualizar la categoría en la base de datos
        if ($newImageName) {
            $sql = "UPDATE Categoria SET nombre = ?, imagen = ? WHERE id_categoria = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("ssi", $nombre, $newImageName, $id_categoria);
        } else {
            $sql = "UPDATE Categoria SET nombre = ? WHERE id_categoria = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("si", $nombre, $id_categoria);
        }

        if (!$stmt->execute()) {
            throw new Exception("Error al ejecutar la consulta: " . $stmt->error);
        }

        // Confirmar la transacción
        $conn->commit();

        echo json_encode([
            'status' => 'success',
            'mensaje' => 'Categoría actualizada correctamente.'
        ]);

    } catch (Exception $e) {
        // Revertir la transacción en caso de error
        if ($conn) {
            $conn->rollback();
        }
        http_response_code(400); // Bad Request
        echo json_encode([
            'status' => 'error',
            'mensaje' => $e->getMessage()
        ]);
    }
}

// Manejo de la solicitud
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Obtener los datos del formulario (en este caso, JSON)
        $input = json_decode(file_get_contents("php://input"), true); // Datos enviados por JSON
        $file = $_FILES['file'] ?? null; // Archivo de imagen

        // Combinar datos y archivo
        $data = array_merge($input, ['file' => $file]);

        if (isset($data['action']) && $data['action'] === 'actualizarCategorias') {
            actualizarCategoria($data);
        } else {
            throw new Exception("Acción no válida");
        }
    } catch (Exception $e) {
        http_response_code(400); // Bad Request
        echo json_encode([
            'status' => 'error',
            'mensaje' => $e->getMessage()
        ]);
    }
} else {
    http_response_code(405); // Método no permitido
    echo json_encode([
        'status' => 'error',
        'mensaje' => 'Método no permitido'
    ]);
}
?>
