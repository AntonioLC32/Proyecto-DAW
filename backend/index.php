<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

$input = json_decode(file_get_contents("php://input"), true);
$action = $input['action'] ?? $_GET['action'] ?? '';

switch ($action) {
    case 'importCsvCategorias':
        require 'categorias/insert.php';
        importCSVCategorias();
        break;

    case 'importCsvTarjetas':
        require 'tarjetas/insert.php';
        importCSVTarjetas();
        break;

    case 'importCsvPreguntas':
        require 'preguntas/insert.php';
        importCSVPreguntas();
        break;
    
    case 'importCsvRespuestas':
        require 'respuestas/insert.php';
        importCSVRespuestas();
        break;

    case 'insertPregunta':
        require 'preguntas/insert.php';
        insertPregunta($input);
        break;

    case 'obtenerPreguntas':
        require 'preguntas/select.php';
        obtenerPreguntas();
        break;

    case 'obtenerCategorias':
        require_once 'categorias/select.php';
        obtenerCategorias();
        break;

    case 'actualizarCategorias':
        require 'categorias/update.php';
        actualizarCategoria($input);
        break;

    case 'actualizarUsuario':
        require_once 'perfil/updatePerfil.php';
        actualizarUsuario($input);
        break;

    case 'updatePregunta':
        require 'preguntas/update.php';
        updatePregunta($input);
        break;

    case 'deshabilitarPregunta':
        require 'preguntas/update.php';
        deshabilitarPregunta($input);
        break;

    case 'usuariosTotales':
        require 'usuarios/select.php';
        usuariosTotales();
        break;

    case 'usuariosConectados':
        require 'usuarios/select.php';
        usuariosConectados();
        break;

    case 'obtenerUsuarios':
        require 'usuarios/select.php';
        obtenerUsuarios();
        break;
    
    case 'deshabilitarUsuario':
        require 'usuarios/update.php';
        deshabilitarUsuario($input);
        break;

    case 'login':
        require 'usuarios/auth.php';
        login($input);
        break;

    case 'register':
        require 'usuarios/auth.php';
        register($input);
        break;
    case 'logout':
        require 'usuarios/logout.php';
        #logout();
        break;

    case 'partidasDiarias':
        require 'graficas/partidasDiarias.php';
        break;

    case 'usuariosSemanal':
        require 'graficas/usuariosSemanal.php';
        break;

    case 'aciertosDificultad':
        require 'graficas/aciertosDificultad.php';
        break;

    case 'aciertosCategorias':
        require 'graficas/aciertosCategorias.php';
        break;
    
    case 'obtenerPreguntaJuego':
        require 'preguntas/select.php';
        obtenerPreguntaJuego($input);
        break;

    case 'crearPartidaSolitario':
        require 'juego/insert.php';
        crearPartidaSolitario($input);
        break;
    
    case 'rendirsePartidaSolitario':
        require 'juego/insert.php';
        rendirsePartidaSolitario($input);
        break;

    case 'insertarRonda':
        require 'juego/insert.php';
        insertarRonda($input);
        break;
    case 'actualizarEstadisticas':
        require 'estadisticas/update.php';
        actualizarEstadisticas($input);
        break;
    
    case 'guardarHistorialPregunta':
        require 'juego/insert.php';
        guardarHistorialPregunta($input);
        break;

    case 'actualizarEstadoPartida':
        require 'juego/update.php';
        actualizarEstadoPartida($input);
        break;

    case 'actualizarVidasPartida':
        require 'juego/update.php';
        actualizarVidasPartida($input);
        break;

    case 'obtenerVidasPartida':
        require 'juego/select.php';
        obtenerVidasPartida($input);
        break;

    // Añadir casos para otras importaciones
    default:
        echo json_encode(['status' => 'error', 'mensaje' => 'Acción no válida']);
        exit;
}