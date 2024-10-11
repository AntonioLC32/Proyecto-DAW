package abp.project.Clases;

public class Partida {

    private int id;
    private String modo;
    private int vidas;
    private String estado;
    private String ganador;

    public Partida(int id, String modo, int vidas, String estado, String ganador) {
        this.id = id;
        this.modo = modo;
        this.vidas = vidas;
        this.estado = estado;
        this.ganador = ganador;
    }

    public Partida() {

    }

    public int getVidas() {
        return vidas;
    }

    public void setVidas(int vidas) {
        this.vidas = vidas;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getGanador() {
        return ganador;
    }

    public void setGanador(String ganador) {
        this.ganador = ganador;
    }

    public String getModo() {
        return modo;
    }

    public void setModo(String modo) {
        this.modo = modo;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }
}
