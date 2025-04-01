<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function importCSVPreguntas() {
    global $conn;

    $file = realpath(__DIR__ . '/../../CSV/preguntas.csv');
    
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
            $texto = trim($data[1]);
            $id_tarjeta = (int)$data[2];
            $habilitado = 1;

            $stmt = $conn->prepare("INSERT INTO Pregunta (id_pregunta, texto, id_tarjeta, habilitado) 
                                   VALUES (?, ?, ?, ?) 
                                   ON DUPLICATE KEY UPDATE 
                                       texto = VALUES(texto), 
                                       id_tarjeta = VALUES(id_tarjeta),
                                       habilitado = VALUES(habilitado)");
            $stmt->bind_param("isii", $id, $texto, $id_tarjeta, $habilitado);

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


function insertPregunta($data) {
    global $conn;

    $texto = $data['texto'] ?? '';
    $categoriaNombre = $data['categoria'] ?? '';
    $dificultad = $data['dificultad'] ?? '';
    $respuestas = $data['respuestas'] ?? [];
    $respuesta_correcta = $data['respuesta_correcta'] ?? '';

    try {
        $conn->begin_transaction();

        // Obtener ID de categoría
        $stmtCategoria = $conn->prepare("SELECT id_categoria FROM Categoria WHERE nombre = ?");
        $stmtCategoria->bind_param("s", $categoriaNombre);
        $stmtCategoria->execute();
        $categoria = $stmtCategoria->get_result()->fetch_assoc();
        
        if (!$categoria) {
            throw new Exception("Categoría no encontrada");
        }
        $id_categoria = $categoria['id_categoria'];

        // Obtener tarjeta correspondiente
        $stmtTarjeta = $conn->prepare("SELECT id_tarjeta FROM Tarjeta WHERE id_categoria = ? AND dificultad = ?");
        $stmtTarjeta->bind_param("is", $id_categoria, $dificultad);
        $stmtTarjeta->execute();
        $tarjeta = $stmtTarjeta->get_result()->fetch_assoc();
        
        if (!$tarjeta) {
            throw new Exception("Tarjeta no encontrada");
        }
        $id_tarjeta = $tarjeta['id_tarjeta'];

        // Insertar pregunta
        $stmtPregunta = $conn->prepare("INSERT INTO Pregunta (texto, id_tarjeta) VALUES (?, ?)");
        $stmtPregunta->bind_param("si", $texto, $id_tarjeta);
        $stmtPregunta->execute();
        $id_pregunta = $stmtPregunta->insert_id;

        // Insertar respuestas
        foreach ($respuestas as $respuesta) {
            $es_correcta = (trim($respuesta) === $respuesta_correcta) ? 1 : 0;
            $stmtRespuesta = $conn->prepare("INSERT INTO Respuesta (texto, es_correcta, id_pregunta) VALUES (?, ?, ?)");
            $respuesta_trim = trim($respuesta);
            $stmtRespuesta->bind_param("sii", $respuesta_trim, $es_correcta, $id_pregunta);
            $stmtRespuesta->execute();
        }

        $conn->commit();
        echo json_encode(['status' => 'success', 'mensaje' => 'Pregunta creada']);
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(['status' => 'error', 'mensaje' => $e->getMessage()]);
    }
}

?>