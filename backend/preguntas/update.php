<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require 'config/db.php';

function updatePregunta($data) {
    global $conn;

    $required = ['id_pregunta', 'pregunta', 'categoria', 'dificultad', 'opciones', 'correcta'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            throw new Exception("Campo requerido faltante: $field");
        }
    }

    $conn->begin_transaction();

    try {

        $stmtCategoria = $conn->prepare("SELECT id_categoria FROM Categoria WHERE nombre = ?");
        $stmtCategoria->bind_param("s", $data['categoria']);
        $stmtCategoria->execute();
        $categoria = $stmtCategoria->get_result()->fetch_assoc();
        
        if (!$categoria) {
            throw new Exception("Categoría no encontrada");
        }
        $id_categoria = $categoria['id_categoria'];

        $stmtTarjeta = $conn->prepare("SELECT id_tarjeta FROM Tarjeta WHERE id_categoria = ? AND dificultad = ?");
        $stmtTarjeta->bind_param("is", $id_categoria, $data['dificultad']);
        $stmtTarjeta->execute();
        $tarjeta = $stmtTarjeta->get_result()->fetch_assoc();
        
        if (!$tarjeta) {
            throw new Exception("No existe tarjeta para esta categoría y dificultad");
        }
        $id_tarjeta = $tarjeta['id_tarjeta'];

        $stmtUpdatePregunta = $conn->prepare("UPDATE Pregunta SET texto = ?, id_tarjeta = ? WHERE id_pregunta = ?");
        $stmtUpdatePregunta->bind_param("sii", $data['pregunta'], $id_tarjeta, $data['id_pregunta']);
        $stmtUpdatePregunta->execute();

        $stmtDeleteRespuestas = $conn->prepare("DELETE FROM Respuesta WHERE id_pregunta = ?");
        $stmtDeleteRespuestas->bind_param("i", $data['id_pregunta']);
        $stmtDeleteRespuestas->execute();

        if (!in_array($data['correcta'], $data['opciones'])) {
            throw new Exception("La respuesta correcta no existe en las opciones proporcionadas");
        }

        foreach ($data['opciones'] as $opcion) {
            $opcion_trim = trim($opcion);
            $es_correcta = ($opcion_trim === $data['correcta']) ? 1 : 0;
            
            $stmtInsertRespuesta = $conn->prepare("INSERT INTO Respuesta (texto, es_correcta, id_pregunta) VALUES (?, ?, ?)");
            $stmtInsertRespuesta->bind_param("sii", $opcion_trim, $es_correcta, $data['id_pregunta']);
            $stmtInsertRespuesta->execute();
        }

        $conn->commit();
        
        echo json_encode([
            'status' => 'success',
            'mensaje' => 'Pregunta actualizada correctamente'
        ]);

    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'mensaje' => 'Error al actualizar: ' . $e->getMessage()
        ]);
    }
}


function deshabilitarPregunta($data) {
    global $conn;

    try {
        // Validación de campos requeridos
        if (!isset($data['id_pregunta']) || !is_numeric($data['id_pregunta'])) {
            throw new Exception("ID de pregunta inválido o faltante");
        }

        $id_pregunta = $data['id_pregunta'];

        $conn->begin_transaction();

        // 1. Deshabilitar respuestas asociadas
        $stmtUpdateRespuestas = $conn->prepare("UPDATE Respuesta SET habilitado = 0 WHERE id_pregunta = ?");
        $stmtUpdateRespuestas->bind_param("i", $id_pregunta);
        $stmtUpdateRespuestas->execute();

        // 2. Deshabilitar la pregunta principal
        $stmtUpdatePregunta = $conn->prepare("UPDATE Pregunta SET habilitado = 0 WHERE id_pregunta = ?");
        $stmtUpdatePregunta->bind_param("i", $id_pregunta);
        $stmtUpdatePregunta->execute();

        // Verificar si se afectó alguna fila
        if ($stmtUpdatePregunta->affected_rows === 0) {
            throw new Exception("No se encontró la pregunta con ID: $id_pregunta");
        }

        $conn->commit();

        echo json_encode([
            'status' => 'success',
            'mensaje' => 'Pregunta y respuestas deshabilitadas correctamente'
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
