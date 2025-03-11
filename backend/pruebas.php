<?php
$data = [
    'username' => 'Primer Usuario',
    'password' => 'qwe123'
];

$input = json_encode($data);
$input = json_decode($input, true);
require 'usuarios/auth.php';login($data)
?>