<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

// Consulta para obtener las partidas jugadas por día (solo las finalizadas)
$sql = "
    SELECT 
        DAYOFWEEK(fecha) AS dia_semana, 
        COUNT(*) AS partidas_jugadas
    FROM Partida
    WHERE estado = 'finalizada'
    GROUP BY dia_semana
    ORDER BY dia_semana;
";

$result = $conn->query($sql);

$datos_partidas = array(
    'Lunes'     => 0,
    'Martes'    => 0,
    'Miércoles' => 0,
    'Jueves'    => 0,
    'Viernes'   => 0,
    'Sábado'    => 0,
    'Domingo'   => 0
);

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $dia = $row['dia_semana'];
        $partidas = $row['partidas_jugadas'];

        // Mapear número de día a su nombre (ajustado según el ejemplo)
        $dias_semana = [
            1 => 'Lunes',
            2 => 'Martes',
            3 => 'Miércoles',
            4 => 'Jueves',
            5 => 'Viernes',
            6 => 'Sábado',
            7 => 'Domingo'
        ];

        if (isset($dias_semana[$dia])) {
            $datos_partidas[$dias_semana[$dia]] = $partidas;
        }
    }
}

// Cerrar conexión
$conn->close();

// Devolver los datos en formato JSON
echo json_encode($datos_partidas);
?>
