<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

$input = json_decode(file_get_contents("php://input"), true);
$action = isset($input['action']) ? $input['action'] : '';

switch ($action) {
    case 'importCsvCategorias':
        require 'categorias/insert.php';
        importCSVCategorias();
        break;
    
    default:
        echo json_encode(['status' => 'error', 'mensaje' => 'Acción no válida']);
        break;
}
?>
