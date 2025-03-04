<template>
  <div class="body">
    <h1 class="admin-titulo">Datos generales</h1>
    <div class="general">
      <div class="datos">
        <h2>Aciertos por Categoría</h2>
        <canvas id="chartAciertos"></canvas>
      </div>
      <div class="datos">
        <h2>Participación Usuarios Semanal</h2>
        <canvas id="chartUsuarios"></canvas>
      </div>
      <div class="datos">
        <h2>Aciertos por Dificultad</h2>
        <canvas id="chartDificultad"></canvas>
      </div>
      <div class="datos">
        <h2>Partidas Jugadas Diarias</h2>
        <canvas id="chartPartidas"></canvas>
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted } from "vue";
import Chart from "chart.js/auto";

export default {
  name: "Admin",
  setup() {
    onMounted(() => {
      new Chart(document.getElementById("chartAciertos"), {
        type: "bar",
        data: {
          labels: [
            "Ciencia",
            "Historia",
            "Geografía",
            "Deportes",
            "Arte",
            "Entretenimiento",
            "Tecnología",
            "Mates",
            "Cultura",
            "Música",
          ],
          datasets: [
            {
              label: "Aciertos",
              data: [40, 20, 50, 35, 45, 13, 27, 42, 31, 37],
              backgroundColor: "blue",
            },
          ],
        },
      });

      new Chart(document.getElementById("chartUsuarios"), {
        type: "bar",
        data: {
          labels: [
            "Lunes",
            "Martes",
            "Miércoles",
            "Jueves",
            "Viernes",
            "Sábado",
            "Domingo",
          ],
          datasets: [
            {
              label: "Usuarios activos",
              data: [30, 15, 40, 32, 25, 5, 35],
              backgroundColor: "green",
            },
          ],
        },
      });

      new Chart(document.getElementById("chartDificultad"), {
        type: "bar",
        data: {
          labels: ["Fácil", "Medio", "Difícil"],
          datasets: [
            {
              label: "Aciertos",
              data: [50, 70, 30],
              backgroundColor: "orange",
            },
          ],
        },
      });

      new Chart(document.getElementById("chartPartidas"), {
        type: "bar",
        data: {
          labels: [
            "Lunes",
            "Martes",
            "Miércoles",
            "Jueves",
            "Viernes",
            "Sábado",
            "Domingo",
          ],
          datasets: [
            {
              label: "Partidas",
              data: [10, 15, 8, 20, 18, 15, 20],
              backgroundColor: "red",
            },
          ],
        },
      });
    });
  },
};
</script>

<style scoped>
.body {
  font-family: "Montserrat", sans-serif;
  background: linear-gradient(to bottom, #7d7de6, #4d4d9d);
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.admin-titulo {
  margin-bottom: 20px;
  color: #fff;
  text-align: center;
  font-weight: bold;
}

.general {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 40px;
  width: 80%;
}

.datos {
  background: white;
  padding: 20px;
  border-radius: 15px;
  box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.2);
  font-weight: bold;
  font-size: 16px;
  height: 350px;
  padding-bottom:50px;
}

@media (max-width: 900px) {
  .general {
    grid-template-columns: 1fr;
    gap: 20px; /* Opcional: ajusta el espacio entre elementos */
  }
}
</style>
