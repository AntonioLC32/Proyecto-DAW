<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php';

// Consulta corregida con JOIN
$sql = "
    SELECT 
        DAYOFWEEK(p.fecha) AS dia_semana, 
        COUNT(DISTINCT pt.id_usuario) AS usuarios_unicos
    FROM Partida p
    JOIN Participante pt ON p.id_partida = pt.id_partida
    WHERE p.estado = 'finalizada'
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

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $dia = $row['dia_semana'];
        $usuarios = $row['usuarios_unicos'];

        // Mapear número de día a su nombre
        $dias_semana = [
            1 => 'Lunes', 2 => 'Martes', 3 => 'Miércoles',
            4 => 'Jueves', 5 => 'Viernes', 6 => 'Sábado', 7 => 'Domingo'
        ];

        if (isset($dias_semana[$dia])) {
            $datos_usuarios[$dias_semana[$dia]] = $usuarios;
        }
    }
}

// Cerrar conexión
$conn->close();

// Devolver datos en formato JSON
echo json_encode($datos_usuarios);

?>
