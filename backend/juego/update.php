<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require 'config/db.php';

function actualizarEstadoPartida($data) {
    global $conn;
    
    try {
        $stmt = $conn->prepare("CALL ActualizarEstadoPartidaSP(?, ?)");
        $stmt->bind_param("is", 
            $data['id_partida'],
            $data['estado']
        );
        
        if (!$stmt->execute()) {
            throw new Exception("Error ejecutando procedimiento: " . $stmt->error);
        }
        
        echo json_encode([
            "status" => "success",
            "mensaje" => "Estado actualizado correctamente"
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            "status" => "error",
            "mensaje" => $e->getMessage()
        ]);
    } finally {
        if (isset($stmt)) {
            $stmt->close();
        }
    }
}


function actualizarVidasPartida($data) {
    global $conn;
    
    try {
        $stmt = $conn->prepare("CALL ActualizarVidasPartida(?, ?)");
        $stmt->bind_param("ii", 
            $data['id_partida'],
            $data['cambio']
        );
        
        if (!$stmt->execute()) {
            throw new Exception("Error actualizando vidas: " . $stmt->error);
        }
        
        // Obtener nuevo estado
        $stmt = $conn->prepare("SELECT vidas, estado FROM Partida WHERE id_partida = ?");
        $stmt->bind_param("i", $data['id_partida']);
        $stmt->execute();
        $result = $stmt->get_result();
        $partida = $result->fetch_assoc();
        
        echo json_encode([
            "status" => "success",
            "vidas" => $partida['vidas'],
            "estado" => $partida['estado']
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