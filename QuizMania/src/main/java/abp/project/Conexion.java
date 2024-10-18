package abp.project;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {

    public Conexion() {

    }

    Connection conn = null;

    public Connection getConnection() {
        try {
            conn = DriverManager.getConnection(Constants.BBDD, Constants.USER, Constants.PASS);
            System.out.println("Conectado");
        } catch (SQLException e) {
            System.out.println("Error al establecer la conexión a la base de datos: " + e.getMessage());
            // e.printStackTrace(); // Para ver el stack trace completo en caso de depuración
        }
        return conn;
    }
}
