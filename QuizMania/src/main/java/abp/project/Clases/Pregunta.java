package abp.project.Clases;

public class Pregunta {

    private int id;
    private String texto;
    private int idTarjeta;

    public Pregunta(int id, String texto, int idTarjeta) {
        this.id = id;
        this.texto = texto;
        this.idTarjeta = idTarjeta;
    }

    public Pregunta() {

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTexto() {
        return texto;
    }

    public void setTexto(String texto) {
        this.texto = texto;
    }

    public int getIdTarjeta() {
        return idTarjeta;
    }

    public void setIdTarjeta(int idTarjeta) {
        this.idTarjeta = idTarjeta;
    }
}
