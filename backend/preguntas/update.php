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
        // Obtener ID de categoría
        $stmtCategoria = $conn->prepare("SELECT id_categoria FROM Categoria WHERE nombre = ?");
        $stmtCategoria->bind_param("s", $data['categoria']);
        $stmtCategoria->execute();
        $categoria = $stmtCategoria->get_result()->fetch_assoc();
        if (!$categoria) throw new Exception("Categoría no encontrada");

        $id_categoria = $categoria['id_categoria'];

        // Obtener ID de tarjeta (según dificultad)
        $stmtTarjeta = $conn->prepare("SELECT id_tarjeta FROM Tarjeta WHERE id_categoria = ? AND dificultad = ?");
        $stmtTarjeta->bind_param("is", $id_categoria, $data['dificultad']);
        $stmtTarjeta->execute();
        $tarjeta = $stmtTarjeta->get_result()->fetch_assoc();
        if (!$tarjeta) throw new Exception("No existe tarjeta para esta categoría y dificultad");

        $id_tarjeta = $tarjeta['id_tarjeta'];

        // Actualizar la pregunta
        $stmtUpdatePregunta = $conn->prepare("UPDATE Pregunta SET texto = ?, id_tarjeta = ? WHERE id_pregunta = ?");
        $stmtUpdatePregunta->bind_param("sii", $data['pregunta'], $id_tarjeta, $data['id_pregunta']);
        $stmtUpdatePregunta->execute();

        // Obtener respuestas actuales
        $stmtRespuestas = $conn->prepare("SELECT id_respuesta FROM Respuesta WHERE id_pregunta = ?");
        $stmtRespuestas->bind_param("i", $data['id_pregunta']);
        $stmtRespuestas->execute();
        $result = $stmtRespuestas->get_result();

        $respuestas_actuales = [];
        while ($row = $result->fetch_assoc()) {
            $respuestas_actuales[] = $row['id_respuesta'];
        }

        $total_actuales = count($respuestas_actuales);
        $total_nuevas = count($data['opciones']);

        for ($i = 0; $i < max($total_actuales, $total_nuevas); $i++) {
            $opcion_trim = trim($data['opciones'][$i] ?? '');
            $es_correcta = ($opcion_trim === $data['correcta']) ? 1 : 0;

            if ($i < $total_actuales && $i < $total_nuevas) {
                // Actualizar respuesta existente
                $stmtUpdateRespuesta = $conn->prepare("UPDATE Respuesta SET texto = ?, es_correcta = ? WHERE id_respuesta = ?");
                $stmtUpdateRespuesta->bind_param("sii", $opcion_trim, $es_correcta, $respuestas_actuales[$i]);
                $stmtUpdateRespuesta->execute();
            } elseif ($i >= $total_actuales) {
                // Insertar nueva respuesta si hay más opciones que respuestas previas
                $stmtInsertRespuesta = $conn->prepare("INSERT INTO Respuesta (texto, es_correcta, id_pregunta) VALUES (?, ?, ?)");
                $stmtInsertRespuesta->bind_param("sii", $opcion_trim, $es_correcta, $data['id_pregunta']);
                $stmtInsertRespuesta->execute();
            } elseif ($i >= $total_nuevas) {
                // Eliminar respuestas sobrantes si hay menos opciones que respuestas previas
                $stmtDeleteRespuesta = $conn->prepare("DELETE FROM Respuesta WHERE id_respuesta = ?");
                $stmtDeleteRespuesta->bind_param("i", $respuestas_actuales[$i]);
                $stmtDeleteRespuesta->execute();
            }
        }

        $conn->commit();
        
        echo json_encode([
            'status' => 'success',
            'mensaje' => 'Pregunta y respuestas actualizadas correctamente'
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
