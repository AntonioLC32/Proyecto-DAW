<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

$conn = new mysqli($servername, $username, $password, $dbname);

// Comprobar la conexión
if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}

// Consulta para obtener la cantidad de usuarios únicos por día
$sql = "
    SELECT 
        DAYOFWEEK(fecha) AS dia_semana, 
        COUNT(DISTINCT id_usuario) AS usuarios_unicos
    FROM Partida
    WHERE estado = 'finalizada'  -- Solo contar partidas finalizadas
    GROUP BY dia_semana
    ORDER BY dia_semana;
";

$result = $conn->query($sql);

$datos_usuarios = array(
    'Lunes' => 0,
    'Martes' => 0,
    'Miércoles' => 0,
    'Jueves' => 0,
    'Viernes' => 0,
    'Sábado' => 0,
    'Domingo' => 0
);

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $dia = $row['dia_semana'];
        $usuarios = $row['usuarios_unicos'];

        // Mapear el número del día de la semana a su nombre
        switch ($dia) {
            case 1: $datos_usuarios['Domingo'] = $usuarios; break;
            case 2: $datos_usuarios['Lunes'] = $usuarios; break;
            case 3: $datos_usuarios['Martes'] = $usuarios; break;
            case 4: $datos_usuarios['Miércoles'] = $usuarios; break;
            case 5: $datos_usuarios['Jueves'] = $usuarios; break;
            case 6: $datos_usuarios['Viernes'] = $usuarios; break;
            case 7: $datos_usuarios['Sábado'] = $usuarios; break;
        }
    }
}

// Cerrar la conexión
$conn->close();

// Devolver los datos en formato JSON
echo json_encode($datos_usuarios);
?>
