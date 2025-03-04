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
    
    // Añadir casos para otras importaciones
    default:
        echo json_encode(['status' => 'error', 'mensaje' => 'Acción no válida']);
        exit;
}