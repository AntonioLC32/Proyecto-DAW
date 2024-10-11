package abp.project.Clases;

public class Historial {

    private int id;
    private int idUsuario;
    private String fecha;
    private String resultado;

    public Historial(int id, int idUsuario, String resultado, String fecha) {
        this.id = id;
        this.idUsuario = idUsuario;
        this.resultado = resultado;
        this.fecha = fecha;
    }

    public Historial() {

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getFecha() {
        return fecha;
    }

    public void setFecha(String fecha) {
        this.fecha = fecha;
    }

    public String getResultado() {
        return resultado;
    }

    public void setResultado(String resultado) {
        this.resultado = resultado;
    }
}
