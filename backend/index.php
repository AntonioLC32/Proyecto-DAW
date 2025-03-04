<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$input = json_decode(file_get_contents("php://input"), true);
$action = $input['action'] ?? '';

switch ($action) {
    case 'importCsvCategorias':
        require 'categorias/insert.php';
        importCSVCategorias();
        break;

    case 'importCsvTarjetas':
        require 'tarjetas/insert.php';
        importCSVTarjetas();
        break;

    case 'importCsvPreguntas':
        require 'preguntas/insert.php';
        importCSVPreguntas();
        break;
    
    case 'importCsvRespuestas':
        require 'respuestas/insert.php';
        importCSVRespuestas();
        break;
    // Añadir casos para otras importaciones
    default:
        echo json_encode(['status' => 'error', 'mensaje' => 'Acción no válida']);
        exit;
}