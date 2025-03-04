<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require '../config/db.php'; // Reutilizamos la conexión existente

function importCSVCategorias() {
    global $conn; // Usamos la conexión ya definida en db.php

    $file = __DIR__ . '../../CSV/categorias.csv'; // Ruta del archivo CSV

    if (!file_exists($file)) {
        echo json_encode(['status' => 'error', 'mensaje' => 'El archivo CSV no existe en la ruta especificada.']);
        return;
    }

    $handle = fopen($file, "r");
    if ($handle === false) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Error al abrir el archivo CSV']);
        return;
    }

    // Omitimos la primera línea (encabezados)
    fgetcsv($handle, 1000, ";");

    $insertados = 0;
    while (($data = fgetcsv($handle, 1000, ";")) !== false) {
        $id = $data[0];
        $nombre = $data[1];

        $stmt = $conn->prepare("INSERT INTO Categoría (id_categoría, nombre) VALUES (?, ?) ON DUPLICATE KEY UPDATE nombre = VALUES(nombre)");
        $stmt->bind_param("is", $id, $nombre);

        if ($stmt->execute()) {
            $insertados++;
        }
    }

    fclose($handle);

    echo json_encode(['status' => 'success', 'mensaje' => "Se insertaron/actualizaron $insertados categorías."]);
}

?>
