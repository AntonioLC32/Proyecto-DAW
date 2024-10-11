package abp.project.Clases;

public class Participante {

    private int idUsuario;
    private int idPartida;

    public Participante(int idUsuario, int idPartida) {
        this.idUsuario = idUsuario;
        this.idPartida = idPartida;
    }

    public Participante() {

    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public int getIdPartida() {
        return idPartida;
    }

    public void setIdPartida(int idPartida) {
        this.idPartida = idPartida;
    }
}
