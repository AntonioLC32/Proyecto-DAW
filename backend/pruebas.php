<?php
$data = [
    'texto' => '¿Cuál es el planeta más cercano al sol?',
    'idioma_origen' => 'es',
    'idioma_destino' => 'en'
];

$input = json_encode($data);
$input = json_decode($input, true);
require 'traducciones/translate.php';traducir($data)
?>