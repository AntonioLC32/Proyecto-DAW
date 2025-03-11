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

/*------------------------- ZONA DE PRUEBAS -------------------------*/

    
    const fetchPartidasDiarias = async () => {
      // Simulando datos aleatorios para las partidas jugadas diarias
      const simulatedData = {
        Lunes: Math.floor(Math.random() * 100),  // Valores aleatorios entre 0 y 100
        Martes: Math.floor(Math.random() * 100),
        Miércoles: Math.floor(Math.random() * 100),
        Jueves: Math.floor(Math.random() * 100),
        Viernes: Math.floor(Math.random() * 100),
        Sábado: Math.floor(Math.random() * 100),
        Domingo: Math.floor(Math.random() * 100),
      };
      
      partidasData.value = simulatedData;
      
      // Llamada a la función para actualizar el gráfico de partidas jugadas
      PartidasDiarias();
    };

    const fetchUsuariosSemanal = async () => {
      // Simulando datos aleatorios para las partidas jugadas diarias
      const simulatedData = {
        Lunes: Math.floor(Math.random() * 100),  // Valores aleatorios entre 0 y 100
        Martes: Math.floor(Math.random() * 100),
        Miércoles: Math.floor(Math.random() * 100),
        Jueves: Math.floor(Math.random() * 100),
        Viernes: Math.floor(Math.random() * 100),
        Sábado: Math.floor(Math.random() * 100),
        Domingo: Math.floor(Math.random() * 100),
      };
      
      partidasData.value = simulatedData;
      
      // Llamada a la función para actualizar el gráfico de partidas jugadas
      UsuariosSemanal();
    };
    
    
  /*  const fetchPartidasDiarias = async () => {
      const response = await fetch("index.php?action=partidasDiarias", {
        method: "GET",
      });
      const data = await response.json();
      partidasData.value = data;
      PartidasDiarias();
    };
  */
  /*
    const fetchUsuariosSemanal = async () => {
      const response = await fetch("index.php?action=usuariosSemanal", {
        method: "GET",
      });
      const data = await response.json();
      partidasData.value = data;
      UsuariosSemanal();
    };
  */

    const fetchAciertos = async () => {
      const response = await fetch("index.php?action=aciertosCategoria", {
        method: "GET",
      });
      const data = await response.json();
      partidasData.value = data;
      AciertosCategoria();
    };
    
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
            labels: [
              "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"
            ],
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
      if (chartUsuarios.value) {
        new Chart(chartUsuarios.value, {
          type: "bar",
          data: {
            labels: [
              "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"
            ],
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
                backgroundColor: "green",
              },
            ],
          },
        });
      }
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
