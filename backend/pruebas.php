<?php
$data = [
    'categoria' => 'Historia',
];

$input = json_encode($data);
$input = json_decode($input, true);
require 'preguntas/select.php';obtenerPreguntaJuego($data)
?>