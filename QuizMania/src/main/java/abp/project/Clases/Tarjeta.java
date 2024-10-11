package abp.project.Clases;

public class Tarjeta {

    private int id;
    private String dificultad;
    private int idCategoria;

    public Tarjeta(int id, String dificultad, int idCategoria) {
        this.id = id;
        this.dificultad = dificultad;
        this.idCategoria = idCategoria;
    }

    public Tarjeta() {

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getDificultad() {
        return dificultad;
    }

    public void setDificultad(String dificultad) {
        this.dificultad = dificultad;
    }

    public int getIdCategoria() {
        return idCategoria;
    }

    public void setIdCategoria(int idCategoria) {
        this.idCategoria = idCategoria;
    }
}



