<?php
declare(strict_types=1);

error_reporting(E_ALL);
ini_set('display_errors', '1');

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function actualizarCategoria(array $input): void {
    global $conn;

    // Verificar que existan los datos necesarios
    if (!isset($input['id_categoria'], $input['nombre'])) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Datos insuficientes']);
        exit;
    }

    $id_categoria = $input['id_categoria'];
    $nombre = $input['nombre'];
    $image = isset($input['file']) ? (string)$input['file'] : '';

    // Directorio de subida (ruta local)
    $uploadDir = __DIR__ . "/../../quizmania/src/assets/";
    // Asegurarse de que el directorio exista; si no, crearlo
    if (!is_dir($uploadDir)) {
        if (!mkdir($uploadDir, 0755, true)) {
            echo json_encode(['status' => 'error', 'mensaje' => 'No se pudo crear el directorio de subida']);
            exit;
        }
    }

    try {
        // Obtener la imagen actual de la categoría desde la BD
        $query = $conn->prepare("SELECT imagen FROM categorias WHERE id = ?");
        if (!$query) {
            echo json_encode(['status' => 'error', 'mensaje' => 'Error en la consulta: ' . implode(" - ", $conn->errorInfo())]);
            exit;
        }
        $query->execute([$id_categoria]);
        $categoria = $query->fetch(PDO::FETCH_ASSOC);

        if (!$categoria) {
            echo json_encode(['status' => 'error', 'mensaje' => 'Categoría no encontrada']);
            exit;
        }

        // Mantener la imagen actual si no se envía una nueva
        $nombreImagen = $categoria['imagen'];

        // Si se ha enviado una nueva imagen en Base64, procesarla
        if (!empty($image)) {
            // Se espera que la cadena Base64 tenga el formato: data:image/extension;base64,....
            $parts = explode(',', $image);
            if (count($parts) === 2) {
                // Obtener el tipo de imagen desde la cabecera
                if (preg_match('/data:image\/(.*?);base64/', $parts[0], $matches)) {
                    $extension = $matches[1];
                } else {
                    echo json_encode(['status' => 'error', 'mensaje' => 'Tipo de imagen no válido']);
                    exit;
                }
                $data = base64_decode($parts[1]);
                if ($data === false) {
                    echo json_encode(['status' => 'error', 'mensaje' => 'Error al decodificar la imagen']);
                    exit;
                }

                // Definir un nuevo nombre de imagen basado en el nombre de la categoría
                $sanitizedNombre = preg_replace('/[^a-zA-Z0-9_-]/', '', $nombre);
                if (empty($sanitizedNombre)) {
                    $sanitizedNombre = (string)time(); // fallback
                }
                $newImageName = $sanitizedNombre . '.' . $extension;
                $rutaImagen = $uploadDir . $newImageName;

                // Borrar la imagen antigua si existe en el directorio y es distinta a la nueva
                if (!empty($categoria['imagen'])) {
                    $oldImagePath = $uploadDir . basename($categoria['imagen']);
                    if (file_exists($oldImagePath) && $oldImagePath !== $rutaImagen) {
                        unlink($oldImagePath);
                    }
                }

                // Guardar la nueva imagen en la carpeta local
                if (file_put_contents($rutaImagen, $data) !== false) {
                    // Guardar la ruta relativa en la BD (por ejemplo, "assets/nombre.ext")
                    $nombreImagen = "assets/" . $newImageName;
                } else {
                    echo json_encode(['status' => 'error', 'mensaje' => 'Error al guardar la nueva imagen']);
                    exit;
                }
            } else {
                echo json_encode(['status' => 'error', 'mensaje' => 'Formato de imagen inválido']);
                exit;
            }
        }

        // Actualizar la base de datos con el nuevo nombre e imagen
        $updateQuery = $conn->prepare("UPDATE categorias SET nombre = ?, imagen = ? WHERE id = ?");
        if (!$updateQuery) {
            echo json_encode(['status' => 'error', 'mensaje' => 'Error en la consulta de actualización: ' . implode(" - ", $conn->errorInfo())]);
            exit;
        }
        $updateQuery->execute([$nombre, $nombreImagen, $id_categoria]);

        echo json_encode(['status' => 'success', 'mensaje' => 'Categoría actualizada correctamente']);
    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Error en la actualización: ' . $e->getMessage()]);
    }
}
?>
