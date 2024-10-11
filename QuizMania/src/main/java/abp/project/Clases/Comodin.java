package abp.project.Clases;

public class Comodin {

    private int id;
    private int idPartida;
    private String nombre;
    private int cantidadMaxima;

    public Comodin(int id, int idPartida, String nombre, int cantidadMaxima) {
        this.id = id;
        this.idPartida = idPartida;
        this.nombre = nombre;
        this.cantidadMaxima = cantidadMaxima;
    }

    public Comodin() {

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdPartida() {
        return idPartida;
    }

    public void setIdPartida(int idPartida) {
        this.idPartida = idPartida;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getCantidadMaxima() {
        return cantidadMaxima;
    }

    public void setCantidadMaxima(int cantidadMaxima) {
        this.cantidadMaxima = cantidadMaxima;
    }
}
