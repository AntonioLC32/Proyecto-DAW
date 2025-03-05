<?php
$data = [
    'action' => 'insertPregunta',
    'texto' => '¿Cuál es la capital de Alemania?',
    'categoria' => 'Geografía',
    'dificultad' => 'Fácil',
    'respuestas' => ['Berlín', 'Munich', 'Hamburgo', 'Frankfurt'],
    'respuesta_correcta' => 'Berlín'
];

$input = json_encode($data);
require 'preguntas/insert.php';
insertPregunta($input);
?>