<?php
$data = [
    'id_usuario' => 16,
];

$input = json_encode($data);
$input = json_decode($input, true);
require 'juego/insert.php';crearPartidaSolitario($data)
?>