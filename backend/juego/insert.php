<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function crearPartidaSolitario($data) {
    global $conn;
    
    $id_usuario = $data['id_usuario'];

    $conn->begin_transaction();

    try {

        $sqlPartida = "INSERT INTO Partida (modo) VALUES ('solitario')";
        if (!$conn->query($sqlPartida)) {
            throw new Exception("Error al crear partida: ". $conn->error);
        }

        $id_partida = $conn->insert_id;

        $sqlParticipante = "INSERT INTO Participante (id_usuario, id_partida) VALUES (?,?)";
        $stmt = $conn->prepare($sqlParticipante);
        if (!$stmt) {
            throw new Exception("Error al preparar la consulta: ". $conn->error);
        }
        $stmt->bind_param("ii", $id_usuario, $id_partida);
        if (!$stmt->execute()) {
            throw new Exception("Error al insertar participante: ". $stmt->error);
        }
        $stmt->close();
        $conn->commit();

        echo json_encode(['status' => 'success','id_partida' => $id_partida]);

    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(['status' => 'error', 'mensaje' => $e->getMessage()]);
    }
}


function rendirsePartidaSolitario($data) {

    global $conn;
    $id_partida = $data['id_partida'];
    
    $conn->begin_transaction();

    try {
        $sqlRendicion = "UPDATE Partida SET estado = 'finalizada' WHERE id_partida = ?";
        $stmt = $conn->prepare($sqlRendicion);
        if (!$stmt) {
            throw new Exception("Error al preparar la consulta: ". $conn->error);
        }
        $stmt->bind_param("i", $id_partida);
        if (!$stmt->execute()) {
            throw new Exception("Error al rendirse de la partida: ". $stmt->error);
        }
        $stmt->close();

        $conn->commit();

        echo json_encode(['status' => 'success']);
    } catch (PDOException $e) {
        $conn->rollback();
        http_response_code(400);
        echo json_encode(['status' => 'error','mensaje' => $e->getMessage()]);
        exit();
    }
}












?>