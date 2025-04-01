<template>
  <div class="body">
    <h1 class="admin-titulo">Datos generales</h1>
    <div class="general">
      <div class="datos">
        <h4>% Aciertos por Categoría</h4>
        <canvas ref="chartAciertos" style="width: 100%; height: 100%"></canvas>
      </div>
      <div class="datos">
        <h4>Participación Usuarios Semanal</h4>
        <canvas ref="chartUsuarios" style="width: 100%; height: 100%"></canvas>
      </div>
      <div class="datos">
        <h4>% Aciertos por Dificultad</h4>
        <canvas
          ref="chartDificultad"
          style="width: 100%; height: 100%"
        ></canvas>
      </div>
      <div class="datos">
        <h4>Partidas Jugadas Diarias</h4>
        <canvas ref="chartPartidas" style="width: 100%; height: 100%"></canvas>
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted, ref } from "vue";
import Chart from "chart.js/auto";

export default {
  name: "Admin",
  setup() {
    const partidasData = ref({});

    const chartAciertos = ref(null);
    const chartUsuarios = ref(null);
    const chartDificultad = ref(null);
    const chartPartidas = ref(null);

    // Función para obtener las partidas jugadas diarias desde la API
    const fetchPartidasDiarias = async () => {
      try {
        const response = await fetch("/api/index.php?action=partidasDiarias");
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        if (chartPartidas.value) {
          new Chart(chartPartidas.value, {
            type: "line",
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
                  label: "Partidas Jugadas",
                  data: [
                    data.Lunes || 0,
                    data.Martes || 0,
                    data.Miércoles || 0,
                    data.Jueves || 0,
                    data.Viernes || 0,
                    data.Sábado || 0,
                    data.Domingo || 0,
                  ],
                  backgroundColor: "teal",
                  fill: false,
                  tension: 0.5,
                },
              ],
            },
          });
        }
      } catch (error) {
        console.error("Error al obtener partidas diarias:", error);
      }
    };

    // Función para obtener la participación de usuarios semanal desde la API
    const fetchUsuariosSemanal = async () => {
      try {
        const response = await fetch("/api/index.php?action=usuariosSemanal");
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        if (chartUsuarios.value) {
          new Chart(chartUsuarios.value, {
            type: "line",
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
                  label: "Usuarios Únicos",
                  data: [
                    data.Lunes || 0,
                    data.Martes || 0,
                    data.Miércoles || 0,
                    data.Jueves || 0,
                    data.Viernes || 0,
                    data.Sábado || 0,
                    data.Domingo || 0,
                  ],

                  backgroundColor: "rgba(56, 255, 45, 0.2)",
                  borderColor: "#066060",
                  borderWidth: 1,
                  fill: true,
                },
              ],
            },
          });
        }
      } catch (error) {
        console.error("Error al obtener datos de usuariosSemanal:", error);
      }
    };

    // Función para obtener los aciertos por categoría (se asume que la API devuelve los datos correctos)
    const fetchAciertosCategorias = async () => {
      try {
        const response = await fetch(
          "/api/index.php?action=aciertosCategorias"
        );
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        if (chartAciertos.value) {
          new Chart(chartAciertos.value, {
            type: "bar",
            data: {
              labels: data.map((item) => item.categoria),
              datasets: [
                {
                  label: "Aciertos",
                  data: data.map((item) => item.porcentaje),
                  backgroundColor: "rgba(0, 128, 0, 0.2)",
                  borderColor: "green",
                  borderWidth: 1,
                  pointBackgroundColor: "green",
                  /*backgroundColor: ["green", "brown", "orange", "red", "purple", "yellow", "blue", "khaki", "teal"],*/
                },
              ],
            },
          });
        }
      } catch (error) {
        console.error(
          "Error al obtener datos de aciertos por categoría:",
          error
        );
      }
    };

    // Función para obtener los aciertos por dificultad
    const fetchAciertosDificultad = async () => {
      try {
        const response = await fetch(
          "/api/index.php?action=aciertosDificultad"
        );
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        if (chartDificultad.value) {
          new Chart(chartDificultad.value, {
            type: "bar",
            data: {
              labels: data.map((item) => item.dificultad),
              datasets: [
                {
                  label: "Aciertos",
                  data: data.map((item) => item.porcentaje),
                  backgroundColor: "lightgreen",
                  borderColor: "green",
                  borderWidth: 1,
                },
              ],
            },
          });
        }
      } catch (error) {
        console.error(
          "Error al obtener datos de aciertos por dificultad:",
          error
        );
      }
    };

    onMounted(() => {
      fetchPartidasDiarias();
      fetchUsuariosSemanal();
      fetchAciertosCategorias();
      fetchAciertosDificultad();
    });

    return {
      chartAciertos,
      chartUsuarios,
      chartDificultad,
      chartPartidas,
    };
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
  margin-left: 60px;
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
  padding: 20px;
}

.general h4 {
  text-align: center;
  margin-bottom: 10px;
}

.canvas {
  width: 100%;
  height: 100%;
}

.datos {
  background: white;
  padding: 20px;
  border-radius: 15px;
  box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.2);
  font-weight: bold;
  font-size: 16px;
  min-height: 350px;
  max-height: 380px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  overflow: hidden;
}

@media (max-width: 900px) {
  .general {
    grid-template-columns: 1fr;
    gap: 20px; /* Opcional: ajusta el espacio entre elementos */
  }

  .datos {
    min-height: 350px;
    height: auto;
  }
}
</style>
