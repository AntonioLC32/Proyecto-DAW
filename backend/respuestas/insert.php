<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function importCSVRespuestas() {
    global $conn;

    $file = realpath(__DIR__ . '/../../CSV/respuestas.csv');
    
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
    if ($encabezados === false || count($encabezados) < 4) {
        fclose($handle);
        echo json_encode(['status' => 'error', 'mensaje' => 'Encabezados CSV inválidos']);
        exit;
    }

    $conn->begin_transaction();
    $insertados = 0;
    $errores = [];

    try {
        while (($data = fgetcsv($handle, 1000, ";")) !== false) {
            if (count($data) < 4 || !is_numeric($data[0]) || !is_numeric($data[3])) {
                $errores[] = "Fila inválida: " . implode(";", $data);
                continue;
            }

            $id = (int)$data[0];
            $texto = trim($data[1]);
            $es_correcta = strtolower($data[2]) === 'true' ? 1 : 0;
            $id_pregunta = (int)$data[3];
            $habilitado = 1;

            // Verificar si el id_pregunta existe en la tabla Pregunta
            $stmt_check = $conn->prepare("SELECT id_pregunta FROM Pregunta WHERE id_pregunta = ?");
            $stmt_check->bind_param("i", $id_pregunta);
            $stmt_check->execute();
            $stmt_check->store_result();

            if ($stmt_check->num_rows === 0) {
                $errores[] = "ID de pregunta no encontrado: $id_pregunta en la fila $id";
                $stmt_check->close();
                continue;
            }
            $stmt_check->close();

            // Insertar la respuesta
            $stmt = $conn->prepare("INSERT INTO Respuesta (id_respuesta, texto, es_correcta, id_pregunta, habilitado) 
                                   VALUES (?, ?, ?, ?, ?) 
                                   ON DUPLICATE KEY UPDATE 
                                       texto = VALUES(texto), 
                                       es_correcta = VALUES(es_correcta), 
                                       id_pregunta = VALUES(id_pregunta),
                                       habilitado = VALUES(habilitado)");
            $stmt->bind_param("isiii", $id, $texto, $es_correcta, $id_pregunta, $habilitado);

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