<template>
  <div class="body">
    <h1 class="admin-titulo">Datos generales</h1>
    <div class="general">
      <div class="datos">
        <h2>Aciertos por Categoría</h2>
        <canvas ref="chartAciertos"></canvas>
      </div>
      <div class="datos">
        <h2>Participación Usuarios Semanal</h2>
        <canvas ref="chartUsuarios"></canvas>
      </div>
      <div class="datos">
        <h2>Aciertos por Dificultad</h2>
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
        partidasData.value = data;
        PartidasDiarias();
      } catch (error) {
        console.error("Error al obtener partidas diarias:", error);
      }
    };

    // Función para obtener la participación de usuarios semanal desde la API
    const usuariosData = ref({});
    const fetchUsuariosSemanal = async () => {
      try {
        const response = await fetch("/api/index.php?action=usuariosSemanal");
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        const data = await response.json();
        usuariosData.value = Array.isArray(data) ? data[0] : data;
        UsuariosSemanal();
      } catch (error) {
        console.error("Error al obtener datos de usuariosSemanal:", error);
      }
    };
    
    // Función para obtener los aciertos por categoría (se asume que la API devuelve los datos correctos)
    const fetchAciertos = async () => {
      const response = await fetch("index.php?action=aciertosCategoria", {
        method: "GET",
      });
      const data = await response.json();
      partidasData.value = data;
      AciertosCategoria();
    };
    
    // Función para obtener los aciertos por dificultad
    const fetchDificultad = async () => {
      const response = await fetch("index.php?action=aciertosDificultad", {
        method: "GET",
      });
      const data = await response.json();
      partidasData.value = data;
      AciertosDificultad();
    };

    /*------------------------- Funciónes para actualizar los gráficos -------------------------*/
    
    const PartidasDiarias = () => {
      if (chartPartidas.value) {
        new Chart(chartPartidas.value, {
          type: "bar",
          data: {
            labels: ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"],
            datasets: [
              {
                label: "Partidas Jugadas",
                data: [
                  partidasData.value.Lunes,
                  partidasData.value.Martes,
                  partidasData.value.Miércoles,
                  partidasData.value.Jueves,
                  partidasData.value.Viernes,
                  partidasData.value.Sábado,
                  partidasData.value.Domingo,
                ],
                backgroundColor: "red",
              },
            ],
          },
        });
      }
    };

    // Inicialización de los otros gráficos
    const AciertosCategoria = () => {
      if (chartAciertos.value) {
        new Chart(chartAciertos.value, {
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
      }
    };

    const UsuariosSemanal = () => {
      if (!chartUsuarios.value || !usuariosData.value) {
        console.warn("UsuariosSemanal: No se encontró chartUsuarios o datos inválidos");
        return;
      }

      const dataArray = [
        usuariosData.value.Lunes || 0,
        usuariosData.value.Martes || 0,
        usuariosData.value.Miércoles || 0,
        usuariosData.value.Jueves || 0,
        usuariosData.value.Viernes || 0,
        usuariosData.value.Sábado || 0,
        usuariosData.value.Domingo || 0,
      ];

      new Chart(chartUsuarios.value, {
        type: "bar",
        data: {
          labels: ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"],
          datasets: [
            {
              label: "Usuarios Únicos",
              data: dataArray,
              backgroundColor: "green",
            },
          ],
        },
      });
    };

    const AciertosDificultad = () => {
      if (chartDificultad.value) {
        new Chart(chartDificultad.value, {
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
      }
    };

    onMounted(() => {
      fetchPartidasDiarias();
      fetchUsuariosSemanal();
      fetchAciertos();
      fetchDificultad();
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
