package abp.project.Clases;

public class Ranking {

    private int id;
    private String nombreUsuario;
    private int rondas;

    public Ranking(int id, String nombreUsuario, int rondas) {
        this.id = id;
        this.nombreUsuario = nombreUsuario;
        this.rondas = rondas;
    }

    public Ranking() {

    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRondas() {
        return rondas;
    }

    public void setRondas(int rondas) {
        this.rondas = rondas;
    }
}
