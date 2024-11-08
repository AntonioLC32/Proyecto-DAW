package abp.project.Controlador;

import abp.project.Clases.Usuario;
import abp.project.Conexion;
import abp.project.Constants;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.sql.ResultSet;

public class Controlador {

    private static List<Usuario> usuarios = new ArrayList<>();

    public static void registrarUsuario(String nombre, String pass) throws SQLException {

        Connection conn = new Conexion().getConnection();
        PreparedStatement ps = conn.prepareStatement(Constants.REGISTRARUSUARIO);

        ps.setString(1, nombre);
        ps.setString(2, pass);
        ps.executeUpdate();

    }

    public static void login(String nombre, String pass) throws SQLException {

        Connection conn = new Conexion().getConnection();
        PreparedStatement ps = conn.prepareStatement(Constants.LOGIN);
        ps.setString(1, nombre);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            String contrasenaDB = rs.getString("contrasena");
            if (contrasenaDB.equals(pass)) {
                System.out.println("Login correcto");
            } else {
                System.out.println("Contraseña incorrecta");
            }
        }



    }
}
