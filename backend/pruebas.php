<?php
$data = [
    'id_pregunta' => 1,
    'pregunta'    => '¿Cuál es el planeta más cercano al sol?',
    'categoria'   => 'Geografía',
    'dificultad'  => 'Media',
    'opciones'    => ['Venus', 'Marte', 'Mercurio', 'La Tierra'],
    'correcta'    => 'Mercurio'
];

$input = json_encode($data);
$input = json_decode($input, true);
require 'preguntas/update.php';
updatePregunta($input);
?>