package abp.project.Clases;

public class Ronda {

    private int id;
    private int idPartida;
    private int tiempo;
    private int idCategoria;

    public Ronda(int id, int idPartida, int tiempo, int idCategoria) {
        this.id = id;
        this.idPartida = idPartida;
        this.tiempo = tiempo;
        this.idCategoria = idCategoria;
    }

    public Ronda() {
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

    public int getTiempo() {
        return tiempo;
    }

    public void setTiempo(int tiempo) {
        this.tiempo = tiempo;
    }

    public int getIdCategoria() {
        return idCategoria;
    }

    public void setIdCategoria(int idCategoria) {
        this.idCategoria = idCategoria;
    }
}
