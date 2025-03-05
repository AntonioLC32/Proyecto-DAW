<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Asegúrate de que config/db.php configure la variable global $conn correctamente
require 'config/db.php';

function updatePregunta($data) {
    global $conn;

    // Validar campos requeridos (se esperan los siguientes campos: id_pregunta, pregunta, categoria, dificultad, opciones y correcta)
    $required = ['id_pregunta', 'pregunta', 'categoria', 'dificultad', 'opciones', 'correcta'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            throw new Exception("Campo requerido faltante: $field");
        }
    }

    $conn->begin_transaction();

    try {
        // 1. Obtener ID de la categoría
        $stmtCategoria = $conn->prepare("SELECT id_categoria FROM Categoria WHERE nombre = ?");
        $stmtCategoria->bind_param("s", $data['categoria']);
        $stmtCategoria->execute();
        $categoria = $stmtCategoria->get_result()->fetch_assoc();
        
        if (!$categoria) {
            throw new Exception("Categoría no encontrada");
        }
        $id_categoria = $categoria['id_categoria'];

        // 2. Obtener la tarjeta correspondiente según categoría y dificultad
        $stmtTarjeta = $conn->prepare("SELECT id_tarjeta FROM Tarjeta WHERE id_categoria = ? AND dificultad = ?");
        $stmtTarjeta->bind_param("is", $id_categoria, $data['dificultad']);
        $stmtTarjeta->execute();
        $tarjeta = $stmtTarjeta->get_result()->fetch_assoc();
        
        if (!$tarjeta) {
            throw new Exception("No existe tarjeta para esta categoría y dificultad");
        }
        $id_tarjeta = $tarjeta['id_tarjeta'];

        // 3. Actualizar la pregunta principal (se actualiza el campo "texto" en la tabla Pregunta)
        $stmtUpdatePregunta = $conn->prepare("UPDATE Pregunta SET texto = ?, id_tarjeta = ? WHERE id_pregunta = ?");
        $stmtUpdatePregunta->bind_param("sii", $data['pregunta'], $id_tarjeta, $data['id_pregunta']);
        $stmtUpdatePregunta->execute();

        // 4. Eliminar respuestas antiguas de la pregunta
        $stmtDeleteRespuestas = $conn->prepare("DELETE FROM Respuesta WHERE id_pregunta = ?");
        $stmtDeleteRespuestas->bind_param("i", $data['id_pregunta']);
        $stmtDeleteRespuestas->execute();

        // 5. Insertar las nuevas respuestas
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

?>
