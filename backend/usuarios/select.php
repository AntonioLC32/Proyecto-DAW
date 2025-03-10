<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function obtenerUsuarios() {
    global $conn;

    try {
        $sql = "SELECT 
                    u.id_usuario,
                    u.nombre,
                    u.correo,
                    u.num_victorias,
                    u.num_derrotas,
                    u.imagen,
                    r.puntos,
                    r.posicion AS ranking
                FROM Usuario u
                LEFT JOIN Ranking r ON u.id_usuario = r.id_usuario
                WHERE habilitado = 1";
                
        $result = $conn->query($sql);

        if (!$result) {
            throw new Exception("Error en la consulta: " . $conn->error);
        }

        $usuarios = [];
        while ($row = $result->fetch_assoc()) {
            $usuarios[] = [
                'id' => $row['id_usuario'],
                'user' => $row['nombre'],
                'correo' => $row['correo'],
                'victorias' => $row['num_victorias'],
                'derrotas' => $row['num_derrotas'],
                'puntos' => $row['puntos'],
                'ranking' => $row['ranking']? (int)$row['ranking'] : null,
                'imagen' => $row['imagen'],
                'acciones' => [
                    'editar' => false,
                    'eliminar' => false,
                    'info' => true
                ]
            ];
        }
        
        $result->free();

        echo json_encode([
            'status' => 'success',
            'data' => $usuarios
        ]);

    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'error' => $e->getMessage()
        ]);
    }
}


function usuariosTotales() {
    global $conn;
    
    header("Content-Type: application/json");

    try {
        $sql = "SELECT COUNT(id_usuario) AS total FROM Usuario";
        $result = $conn->query($sql);

        if (!$result) {
            throw new Exception("Error en la consulta: " . $conn->error);
        }

        $row = $result->fetch_assoc();
        $total = $row ? (int)$row['total'] : 0;
        $result->free();

        echo json_encode([
            'status' => 'success',
            'data' => $total
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'error' => $e->getMessage()
        ]);
    }
}


function usuariosConectados() {
    global $conn;

    try {
        $sql = "SELECT COUNT(id_usuario) AS conectados FROM Usuario WHERE ult_conexion >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)";
        $result = $conn->query($sql);

        if (!$result) {
            throw new Exception("Error en la consulta: " . $conn->error);
        }

        $row = $result->fetch_assoc();
        echo json_encode([
            'status' => 'success',
            'data' => $row['conectados']
        ]);

    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'error' => $e->getMessage()
        ]);
    }
}









?>