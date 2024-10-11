package abp.project.Clases;

public class Usuario {

    private int id;
    private String nombre;
    private String contrasena;
    private int numDerrotas;
    private int numVictorias;
    private int idRanking;

    public Usuario(int id, String contrasena, String nombre, int numDerrotas, int numVictorias, int idRanking) {
        this.id = id;
        this.contrasena = contrasena;
        this.nombre = nombre;
        this.numDerrotas = numDerrotas;
        this.numVictorias = numVictorias;
        this.idRanking = idRanking;
    }

    public Usuario() {

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getNumDerrotas() {
        return numDerrotas;
    }

    public void setNumDerrotas(int numDerrotas) {
        this.numDerrotas = numDerrotas;
    }

    public String getContrasena() {
        return contrasena;
    }

    public void setContrasena(String contrasena) {
        this.contrasena = contrasena;
    }

    public int getNumVictorias() {
        return numVictorias;
    }

    public void setNumVictorias(int numVictorias) {
        this.numVictorias = numVictorias;
    }

    public int getIdRanking() {
        return idRanking;
    }

    public void setIdRanking(int idRanking) {
        this.idRanking = idRanking;
    }
}
