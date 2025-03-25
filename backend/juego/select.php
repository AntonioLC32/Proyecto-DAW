<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';


function obtenerVidasPartida($data) {
    global $conn;

    $id_partida = $data['id_partida'] ?? null;
    
    try {
        // Validación del input
        if (!$id_partida || !is_numeric($id_partida)) {
            throw new Exception("ID de partida inválido");
        }

        $stmt = $conn->prepare("SELECT vidas, estado FROM Partida WHERE id_partida = ?");
        $stmt->bind_param("i", $id_partida);
        
        if (!$stmt->execute()) {
            throw new Exception("Error en la consulta: " . $stmt->error);
        }
        
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            throw new Exception("Partida no encontrada");
        }
        
        $data = $result->fetch_assoc();
        
        echo json_encode([
            "status" => "success",
            "vidas" => (int)$data['vidas'],
            "estado" => $data['estado']
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            "status" => "error",
            "mensaje" => $e->getMessage()
        ]);
    } finally {
        if (isset($stmt)) $stmt->close();
    }
}


?>