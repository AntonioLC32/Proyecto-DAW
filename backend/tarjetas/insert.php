<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function importCSVTarjetas() {
    global $conn;

    $file = realpath(__DIR__ . '/../../CSV/tarjetas.csv');
    
    if (!$file) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Archivo no encontrado']);
        exit;
    }

    $handle = fopen($file, "r");
    if ($handle === false) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Error al abrir el archivo']);
        exit;
    }

    $encabezados = fgetcsv($handle, 1000, ";");
    if ($encabezados === false || count($encabezados) < 3) {
        fclose($handle);
        echo json_encode(['status' => 'error', 'mensaje' => 'Encabezados CSV inválidos']);
        exit;
    }

    $conn->begin_transaction();
    $insertados = 0;
    $errores = [];

    try {
        while (($data = fgetcsv($handle, 1000, ";")) !== false) {
            if (count($data) < 3 || !is_numeric($data[0]) || !is_numeric($data[2])) {
                $errores[] = "Fila inválida: " . implode(";", $data);
                continue;
            }

            $id = (int)$data[0];
            $dificultad = trim($data[1]);
            $id_categoria = (int)$data[2];

            $stmt = $conn->prepare("INSERT INTO Tarjeta (id_tarjeta, dificultad, id_categoría) 
                                   VALUES (?, ?, ?) 
                                   ON DUPLICATE KEY UPDATE 
                                       dificultad = VALUES(dificultad), 
                                       id_categoría = VALUES(id_categoría)");
            $stmt->bind_param("isi", $id, $dificultad, $id_categoria);

            if (!$stmt->execute()) {
                $errores[] = "Error en ID $id: " . $stmt->error;
            } else {
                $insertados++;
            }
            $stmt->close();
        }

        $conn->commit();
        $respuesta = [
            'status' => 'success',
            'insertados' => $insertados,
            'errores' => $errores,
            'mensaje' => "Proceso completado. Filas afectadas: $insertados"
        ];

    } catch (Exception $e) {
        $conn->rollback();
        $respuesta = [
            'status' => 'error',
            'mensaje' => "Error en transacción: " . $e->getMessage()
        ];
    }

    fclose($handle);
    echo json_encode($respuesta);
}


?>