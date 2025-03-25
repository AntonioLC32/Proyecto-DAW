<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require 'config/db.php';

function actualizarEstadoPartida($data) {
    global $conn;
    
    try {
        $stmt = $conn->prepare("UPDATE Partida SET estado = ? WHERE id_partida = ?");
        $stmt->bind_param("si", $data['estado'], $data['id_partida']);
        
        if (!$stmt->execute()) {
            throw new Exception("Error actualizando estado: " . $stmt->error);
        }
        
        echo json_encode(["status" => "success"]);
        
    } catch (Exception $e) {
        echo json_encode([
            "status" => "error",
            "mensaje" => $e->getMessage()
        ]);
    }
}





?>