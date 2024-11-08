package abp.project;

import abp.project.Controlador.Controlador;

import java.sql.Connection;
import java.sql.SQLException;

public class Main {
    public static void main(String[] args) throws SQLException {

        Conexion db = new Conexion();
        Controlador co = new Controlador();

        db.getConnection();



    }
}