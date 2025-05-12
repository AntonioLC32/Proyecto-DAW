# QuizMania

## Guía de instalación y ejecución

### Requisitos previos

- XAMPP instalado y configurado
- Node.js y npm instalados
- Git instalado

### Paso 1: Clonar el repositorio

En la carpeta htdocs de XAMPP, ejecuta:

```bash
git clone <URL-del-repositorio>
cd quizmania
```

### Paso 2: Configurar la base de datos

1. Inicia XAMPP y asegúrate que Apache y MySQL estén funcionando
2. Abre phpMyAdmin (http://localhost/phpmyadmin)
3. Crea una nueva base de datos llamada `quizmania`
4. Importa el script SQL ubicado en `Base de datos/quizmania.sql`

### Paso 3: Instalar dependencias y ejecutar la aplicación

Navega a la carpeta del proyecto quizmania:

```bash
cd quizmania
npm install
npm run dev
```

### Paso 4: Acceder a la aplicación

1. Abre tu navegador y accede a la URL proporcionada por Vite (http://localhost:5173)
2. Haz clic en el icono de usuario en el encabezado
3. Puedes crear una nueva cuenta o usar estas credenciales predefinidas:
   - **Usuario:** admin
   - **Contraseña:** QWE123

### Cambio de Idioma

Para cambiar el idioma de la aplicación:

1. Cambia el idioma de tu navegador
2. La aplicación detectará automáticamente el nuevo idioma
3. Si el idioma no está soportado, se usará el idioma predeterminado (generalmente inglés)
