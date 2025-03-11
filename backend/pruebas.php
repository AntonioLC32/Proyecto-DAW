<?php
$data = [
    'id_categoria' => 1,
    'nombre' => 'Ciencia',
    'file' => 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M/wHwAF/wL+DzXwAAAAAElFTkSuQmCC'
];
require 'categorias/update.php';
actualizarCategoria($data);
?>
