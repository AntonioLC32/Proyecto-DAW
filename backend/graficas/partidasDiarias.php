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

// Consulta para obtener las partidas jugadas por día
$sql = "
    SELECT 
        DAYOFWEEK(fecha) AS dia_semana, 
        COUNT(*) AS partidas_jugadas
    FROM Partida
    WHERE estado = 'finalizada'  -- Solo contar partidas finalizadas
    GROUP BY dia_semana
    ORDER BY dia_semana;
";

$result = $conn->query($sql);

$datos_partidas = array(
    'Lunes' => 0,
    'Martes' => 0,
    'Miércoles' => 0,
    'Jueves' => 0,
    'Viernes' => 0,
    'Sábado' => 0,
    'Domingo' => 0
);

if ($result->num_rows > 0) {
    // Obtener los resultados y asignarlos a los días de la semana
    while($row = $result->fetch_assoc()) {
        $dia = $row['dia_semana'];
        $partidas = $row['partidas_jugadas'];

        // Mapear el número del día de la semana a su nombre
        switch ($dia) {
            case 1: $datos_partidas['Domingo'] = $partidas; break;
            case 2: $datos_partidas['Lunes'] = $partidas; break;
            case 3: $datos_partidas['Martes'] = $partidas; break;
            case 4: $datos_partidas['Miércoles'] = $partidas; break;
            case 5: $datos_partidas['Jueves'] = $partidas; break;
            case 6: $datos_partidas['Viernes'] = $partidas; break;
            case 7: $datos_partidas['Sábado'] = $partidas; break;
        }
    }
}

// Cerrar la conexión
$conn->close();

// Devolver los datos en formato JSON
echo json_encode($datos_partidas);
?>
