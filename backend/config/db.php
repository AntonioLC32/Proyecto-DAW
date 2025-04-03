<?php

$host = "localhost";
$usuario = "root"; 
$password = "";     
$db = "quizmania"; 

$conn = new mysqli($host, $usuario, $password, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}




?>