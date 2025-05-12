<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

function traducir($data) {
    global $conn;
    
    $texto = substr(trim($data['texto']), 0, 5000);
    $idioma_origen = in_array(strtoupper($data['idioma_origen']), ['ES', 'EN', 'FR', 'DE']) ? strtoupper($data['idioma_origen']) : 'ES';
    $idioma_destino = in_array(strtoupper($data['idioma_destino']), ['ES', 'EN', 'FR', 'DE']) ? strtoupper($data['idioma_destino']) : 'EN';
    
    if(empty($texto) || $idioma_origen === $idioma_destino) {
        echo json_encode(['status' => 'success', 'traduccion' => $texto]);
        return;
    }
    
    $stmt = $conn->prepare("SELECT texto_traducido FROM Traducciones WHERE texto_original = ? AND idioma_origen = ? AND idioma_destino = ?");
    if($stmt) {
        $stmt->bind_param("sss", $texto, $idioma_origen, $idioma_destino);
        $stmt->execute();
        $result = $stmt->get_result();
        if($result && $result->num_rows > 0) {
            $row = $result->fetch_assoc();
            echo json_encode(['status' => 'success', 'traduccion' => $row['texto_traducido']]);
            return;
        }
    }
    
    $auth_key = "84c24639-4030-4081-a698-2854561ba240:fx";
    $deeplUrl = "https://api-free.deepl.com/v2/translate";
    $postData = [
        'auth_key'    => $auth_key,
        'text'        => $texto,
        'target_lang' => $idioma_destino,
        'source_lang' => $idioma_origen
    ];
    
    $ch = curl_init($deeplUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($postData));
    $response = curl_exec($ch);
    curl_close($ch);
    
    $decodedResponse = json_decode($response, true);
    if (!isset($decodedResponse['translations'][0]['text'])) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Respuesta inesperada de la API.']);
        return;
    }
    
    $traduccion = $decodedResponse['translations'][0]['text'];
    
    $stmt = $conn->prepare("INSERT INTO Traducciones (texto_original, idioma_origen, idioma_destino, texto_traducido) VALUES (?, ?, ?, ?)");
    if($stmt) {
        $stmt->bind_param("ssss", $texto, $idioma_origen, $idioma_destino, $traduccion);
        $stmt->execute();
    }
    
    echo json_encode(['status' => 'success', 'traduccion' => $traduccion]);
}


?>