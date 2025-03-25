<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'config/db.php'; 

function login($input) {
    global $conn;
    
    $username = isset($input['username']) ? trim($input['username']) : '';
    $password = isset($input['password']) ? $input['password'] : '';
    
    if (!$username || !$password) {
        echo json_encode([
            'status'  => 'error',
            'mensaje' => 'Faltan datos de usuario o contraseña'
        ]);
        exit;
    }
    
    try {
        $stmt = $conn->prepare("SELECT * FROM Usuario WHERE nombre = ? LIMIT 1");
        if (!$stmt) {
            throw new Exception("Error en la consulta: " . $conn->error);
        }
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            echo json_encode([
                'status'  => 'error',
                'mensaje' => 'Usuario no encontrado'
            ]);
            exit;
        }
        
        $userData = $result->fetch_assoc();
        
        if (password_verify($password, $userData['contraseña'])) {
            $updateStmt = $conn->prepare("UPDATE Usuario SET ult_conexion = NOW() WHERE id_usuario = ?");
            if ($updateStmt) {
                $updateStmt->bind_param("i", $userData['id_usuario']);
                $updateStmt->execute();
            }
            
            unset($userData['contraseña']); 
            
            echo json_encode([
                'status' => 'success',
                'user'   => [
                    'id_usuario' => $userData['id_usuario'],
                    'rol' => $userData['rol'],
            ]]);
        } else {
            echo json_encode([
                'status'  => 'error',
                'mensaje' => 'Contraseña incorrecta'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'status'  => 'error',
            'mensaje' => $e->getMessage()
        ]);
    }
}

function register($input) {
    global $conn;
    
    $username = isset($input['username']) ? trim($input['username']) : '';
    $password = isset($input['password']) ? $input['password'] : '';
    $email    = isset($input['email']) ? trim($input['email']) : '';
    $imageData = isset($input['image']) ? $input['image'] : '';
    
    if (!$username || !$password || !$email) {
        echo json_encode(['status' => 'error', 'mensaje' => 'Faltan datos requeridos']);
        exit;
    }

    try {
        $stmt = $conn->prepare("SELECT * FROM Usuario WHERE nombre = ? OR correo = ? LIMIT 1");
        if (!$stmt) throw new Exception("Error en la consulta: " . $conn->error);
        
        $stmt->bind_param("ss", $username, $email);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($result->num_rows > 0) {
            echo json_encode(['status' => 'error', 'mensaje' => 'El usuario o el correo ya están en uso']);
            exit;
        }
        
        $imagePath = '';
        if ($imageData) {
            $type = 'png';
            if (preg_match('/^data:image\/(\w+);base64,/', $imageData, $matches)) {
                $type = strtolower($matches[1]);
                $imageData = substr($imageData, strpos($imageData, ',') + 1);
                $imageData = base64_decode($imageData);
                if ($imageData === false) {
                    echo json_encode(['status' => 'error', 'mensaje' => 'Base64 de imagen inválido']);
                    exit;
                }
            } else {
                $decoded = base64_decode($imageData);
                if ($decoded !== false) {
                    $imageData = $decoded;
                }
            }
            
            $usernameFolder = strtolower(str_replace(' ', '_', $username));
            $uploadDir = '../quizmania/src/assets/users/' . $usernameFolder . '/';
            
            if (!file_exists($uploadDir) && !mkdir($uploadDir, 0777, true)) {
                echo json_encode(['status' => 'error', 'mensaje' => 'No se pudo crear la carpeta del usuario']);
                exit;
            }
            
            $fileName = $usernameFolder . '.png';
            $fullPath = $uploadDir . $fileName;
            
            if (!file_put_contents($fullPath, $imageData)) {
                echo json_encode(['status' => 'error', 'mensaje' => 'Error al guardar la imagen']);
                exit;
            }
            
            $imagePath = 'assets/users/' . $usernameFolder . '/' . $fileName;
        } else {
            $imagePath = 'assets/users/default/default.png';
        }
        
        $hashed_password = password_hash($password, PASSWORD_BCRYPT);
        
        $stmt_insert = $conn->prepare("INSERT INTO Usuario (nombre, contraseña, correo, imagen, ult_conexion) VALUES (?, ?, ?, ?, NOW())");
        if (!$stmt_insert) throw new Exception("Error en la consulta de inserción: " . $conn->error);
        
        $stmt_insert->bind_param("ssss", $username, $hashed_password, $email, $imagePath);
        if ($stmt_insert->execute()) {
            $new_id = $conn->insert_id;
            echo json_encode([
                'status'  => 'success',
                'mensaje' => 'Usuario registrado correctamente',
                'user'    => [
                    'id_usuario' => $new_id,
                    //'nombre'     => $username,
                    //'correo'     => $email,
                    //'num_derrotas' => 0,
                    //'num_victorias' => 0,
                    //'fecha_registro' => date("Y-m-d H:i:s"),
                    //'habilitado' => 1,
                    'rol' => 'jugador',
                    //'ult_conexion' => date("Y-m-d H:i:s"),
                    //'imagen'     => $imagePath
                ]
            ]);
        } else {
            echo json_encode(['status' => 'error', 'mensaje' => 'Error al registrar el usuario']);
        }
    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'mensaje' => $e->getMessage()]);
    }
}

?>
