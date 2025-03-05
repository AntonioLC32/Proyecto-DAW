<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function updatePregunta($data) {
    global $conn;

    $texto = $data['texto'] ?? '';
    $categoriaNombre = $data['categoria'] ?? '';
    $dificultad = $data['dificultad'] ?? '';
    $respuestas = $data['respuestas'] ?? [];
    $respuesta_correcta = $data['respuesta_correcta'] ?? '';

    try {
        $conn->begin_transaction();

        $stmtCategoria = $conn->prepare("SELECT id_categoria FROM Categoria WHERE nombre = ?");
        $stmtCategoria->bind_param("s", $categoriaNombre);
        $stmtCategoria->execute();
        $categoria = $stmtCategoria->get_result()->fetch_assoc();
        
        if (!$categoria) {
            throw new Exception("Categoría no encontrada");
        }
        $id_categoria = $categoria['id_categoria'];
    
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(['status' => 'error', 'mensaje' => $e->getMessage()]);
    }


}

?>