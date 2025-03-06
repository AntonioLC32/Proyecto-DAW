<?php
$data = [
    'id_pregunta' => 1,
];

$input = json_encode($data);
$input = json_decode($input, true);

require 'usuarios/select.php';
usuariosTotales();
?>