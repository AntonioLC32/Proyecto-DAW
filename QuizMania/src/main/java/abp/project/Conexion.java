package abp.project;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {

    private static Connection conn = null;

    public Conexion() { }

    public Connection getConnection() {
        if (conn == null) {
            try {
                conn = DriverManager.getConnection(Constants.BBDD, Constants.USER, Constants.PASS);
                System.out.println("Conectado");
            } catch (SQLException e) {
                System.out.println("Error al establecer la conexión a la base de datos: " + e.getMessage());
                e.printStackTrace();
            }
        }
        return conn;
    }

}
