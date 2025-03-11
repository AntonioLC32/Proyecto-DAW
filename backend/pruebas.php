<?php
$data = [
    'id_categoria' => 1,
    'nombre' => 'Ciencia',
    'imagen' => '',
];

$input = json_encode($data);
$input = json_decode($input, true);
require 'categorias/update.php';actualizarCategoria($data)
?>