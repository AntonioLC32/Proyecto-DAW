package abp.project;

public class Constants {

    // BBDD Conexión
    public static final String USER = "root";
    public static final String PASS = "root";
    public static final String SCHEMA = "quizmania";
    public static  final String BBDD = "jdbc:mysql://127.0.0.1:3307/QuizMania?user=root";

    // INSERTS

    public static final String REGISTRARUSUARIO = "INSERT INTO Usuario (nombre, contrasena) VALUES (?, ?)";
    public static final String LOGIN = "SELECT contrasena FROM Usuario WHERE nombre = ?";

}
