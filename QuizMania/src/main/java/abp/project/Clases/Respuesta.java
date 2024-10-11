package abp.project.Clases;

public class Respuesta {

    private int id;
    private String texto;
    private boolean esCorrecta;
    private int idTarjeta;

    public Respuesta(int id, String texto, boolean esCorrecta, int idTarjeta) {
        this.id = id;
        this.texto = texto;
        this.esCorrecta = esCorrecta;
        this.idTarjeta = idTarjeta;
    }

    public Respuesta() {

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

    public boolean isEsCorrecta() {
        return esCorrecta;
    }

    public void setEsCorrecta(boolean esCorrecta) {
        this.esCorrecta = esCorrecta;
    }

    public int getIdTarjeta() {
        return idTarjeta;
    }

    public void setIdTarjeta(int idTarjeta) {
        this.idTarjeta = idTarjeta;
    }
}
