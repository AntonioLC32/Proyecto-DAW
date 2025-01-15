<?php 
require_once("includes/head.php");
?>

<div class="navbar">
        <div class="navbar-links">
            <a href="#">INICIO</a>
            <a href="#">JUGAR!</a>
        </div>
    </div>
    <div class="container-fluid title">
        <h1><b>Ranking Global</b></h1>
    </div>
    <main>
        <section>
            <div class="container-fluid pantalla-ranking">
                <!-- Perfil Ranking -->
                <div class="perfil-ranking">
                    <img src="imgs/perfil.jpg" alt="Perfil Image" width="250px" height="275px" style="border-radius: 50%;">
                    <h3>PEPE_123ASD</h3>
                    <div>
                        <p><u>Estadísticas</u></p>
                        <p><u>Última posición:</u></p>
                        <div class="num"><u><b>1</b></u></div>
                    </div>
                </div>
                <!-- Tabla Ranking -->
                <div class="ranking">
                    <table>
                        <thead>
                            <tr>
                                <th>Jugador</th>
                                <th>Posición</th>
                                <th>Puntos</th>
                                <th>Categoría Destacada</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>PEPE_123ASD</td>
                                <td>1</td>
                                <td>15648</td>
                                <td>Ciencia</td>
                            </tr>
                            <tr>
                                <td>PEPE</td>
                                <td>2</td>
                                <td>15648</td>
                                <td>Cultura General</td>
                            </tr>
                            <tr>
                                <td>PEPE</td>
                                <td>3</td>
                                <td>15648</td>
                                <td>Historia</td>
                            </tr>
                            <!-- Agrega más filas según sea necesario -->
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

</main>
    
</body>
</html>