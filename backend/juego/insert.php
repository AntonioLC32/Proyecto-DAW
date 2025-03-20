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

function insertarRonda($data) {
    global $conn;
    
    $id_partida = $data['id_partida'];
    $tiempo = $data['tiempo'];       
    $nombre_categoria = $data['id_categoria'];

    $conn->begin_transaction();

    try {
        $sqlCategoria = "SELECT id_categoria FROM Categoria WHERE nombre = ?";
        $stmtCategoria = $conn->prepare($sqlCategoria);
        if (!$stmtCategoria) {
            throw new Exception("Error al preparar la consulta para la categoría: " . $conn->error);
        }
        $stmtCategoria->bind_param("s", $nombre_categoria);
        if (!$stmtCategoria->execute()) {
            throw new Exception("Error al ejecutar la consulta para la categoría: " . $stmtCategoria->error);
        }
        $result = $stmtCategoria->get_result();
        if ($result->num_rows == 0) {
            throw new Exception("No se encontró la categoría con el nombre: " . $nombre_categoria);
        }
        $row = $result->fetch_assoc();
        $id_categoria = $row['id_categoria'];
        $stmtCategoria->close();

        $sql = "INSERT INTO Ronda (id_partida, tiempo, id_categoria) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            throw new Exception("Error al preparar la consulta: " . $conn->error);
        }
        $stmt->bind_param("isi", $id_partida, $tiempo, $id_categoria);
        if (!$stmt->execute()) {
            throw new Exception("Error al insertar la ronda: " . $stmt->error);
        }
        $stmt->close();
        $conn->commit();
        
        echo json_encode(['status' => 'success']);
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(['status' => 'error', 'mensaje' => $e->getMessage()]);
    }
}













?>