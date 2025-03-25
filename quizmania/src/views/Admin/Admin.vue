<template>
  <div class="body">
    <h1 class="admin-titulo">Datos generales</h1>
    <div class="general">
      <div class="datos">
        <h2>% Aciertos por Categoría</h2>
        <canvas ref="chartAciertos"></canvas>
      </div>
      <div class="datos">
        <h2>Participación Usuarios Semanal</h2>
        <canvas ref="chartUsuarios"></canvas>
      </div>
      <div class="datos">
        <h2>% Aciertos por Dificultad</h2>
        <canvas ref="chartDificultad"></canvas>
      </div>
      <div class="datos">
        <h2>Partidas Jugadas Diarias</h2>
        <canvas ref="chartPartidas"></canvas>
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
            type: "bar",
            data: {
              labels: ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"],
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
                  backgroundColor: "red",
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
            type: "bar",
            data: {
              labels: ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"],
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
                  backgroundColor: "green",
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
        const response = await fetch("/api/index.php?action=aciertosCategorias");
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        if (chartAciertos.value) {
          new Chart(chartAciertos.value, {
            type: "bar",
            data: {
              labels: data.map(item => item.categoria),
              datasets: [
                {
                  label: "Aciertos",
                  data: data.map(item => item.porcentaje),
                  backgroundColor: "blue",
                },
              ],
            },
          });
        }
      } catch (error) {
        console.error("Error al obtener datos de aciertos por categoría:", error);
      }
    };
    
    // Función para obtener los aciertos por dificultad
    const fetchAciertosDificultad = async () => {
      try {
        const response = await fetch("/api/index.php?action=aciertosDificultad");
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        if (chartDificultad.value) {
          new Chart(chartDificultad.value, {
            type: "bar",
            data: {
              labels: data.map(item => item.dificultad),
              datasets: [
                {
                  label: "Aciertos",
                  data: data.map(item => item.porcentaje),
                  backgroundColor: "orange",
                },
              ],
            },
          });
        }
      } catch (error) {
        console.error("Error al obtener datos de aciertos por dificultad:", error);
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
  padding-bottom: 50px;
}

@media (max-width: 900px) {
  .general {
    grid-template-columns: 1fr;
    gap: 20px; /* Opcional: ajusta el espacio entre elementos */
  }
}
</style>

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
