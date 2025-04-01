<template>
  <div class="body">
    <h1 class="admin-titulo">
      {{ textosTraducidos["Datos generales"] || "Datos generales" }}
    </h1>
    <div class="general">
      <div class="datos">
        <h4>
          {{
            textosTraducidos["% Aciertos por Categoría"] ||
            "% Aciertos por Categoría"
          }}
        </h4>
        <div class="chart-container">
          <canvas ref="chartAciertos"></canvas>
        </div>
      </div>
      <div class="datos">
        <h4>
          {{
            textosTraducidos["Participación Usuarios Semanal"] ||
            "Participación Usuarios Semanal"
          }}
        </h4>
        <div class="chart-container">
          <canvas ref="chartUsuarios"></canvas>
        </div>
      </div>
      <div class="datos">
        <h4>
          {{
            textosTraducidos["% Aciertos por Dificultad"] ||
            "% Aciertos por Dificultad"
          }}
        </h4>
        <div class="chart-container">
          <canvas ref="chartDificultad"></canvas>
        </div>
      </div>
      <div class="datos">
        <h4>
          {{
            textosTraducidos["Partidas Jugadas Diarias"] ||
            "Partidas Jugadas Diarias"
          }}
        </h4>
        <div class="chart-container">
          <canvas ref="chartPartidas"></canvas>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted, ref, reactive } from "vue";
import Chart from "chart.js/auto";
import axios from "axios";

export default {
  name: "Admin",
  setup() {
    const partidasData = ref({});
    const chartAciertos = ref(null);
    const chartUsuarios = ref(null);
    const chartDificultad = ref(null);
    const chartPartidas = ref(null);
    const textosTraducidos = reactive({});
    const traduccionesCargando = ref(false);
    const idiomaUsuario = ref("es");
    const diasSemana = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo",
    ];

    const traducirTexto = async (texto) => {
      if (/^[\d:]/.test(texto)) return texto;
      try {
        const response = await axios.post("/api/index.php?action=traducir", {
          texto: texto,
          idioma_origen: "es",
          idioma_destino: idiomaUsuario.value,
        });
        return response.data.status === "success"
          ? response.data.traduccion
          : texto;
      } catch (error) {
        return texto;
      }
    };

    const traducirContenido = async () => {
      const textos = [
        "Datos generales",
        "% Aciertos por Categoría",
        "Participación Usuarios Semanal",
        "% Aciertos por Dificultad",
        "Partidas Jugadas Diarias",
        "Aciertos",
        "Usuarios Únicos",
        "Partidas Jugadas",
        ...diasSemana,
      ];
      const traducciones = await Promise.all(textos.map(traducirTexto));
      textos.forEach((texto, index) => {
        textosTraducidos[texto] = traducciones[index];
      });
      fetchPartidasDiarias();
      fetchUsuariosSemanal();
      fetchAciertosCategorias();
      fetchAciertosDificultad();
    };

    const chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: "top",
          labels: {
            color: "#2d3748",
            font: { size: 12, family: "Montserrat" },
            padding: 10,
          },
        },
        tooltip: {
          backgroundColor: "rgba(0,0,0,0.8)",
          titleFont: { family: "Montserrat", size: 14 },
          bodyFont: { family: "Montserrat", size: 12 },
          padding: 10,
          cornerRadius: 5,
        },
      },
      scales: {
        y: {
          beginAtZero: true,
          grid: { color: "rgba(0,0,0,0.05)" },
          ticks: { color: "#4a5568", padding: 5 },
        },
        x: {
          grid: { display: false },
          ticks: { color: "#4a5568", padding: 5 },
        },
      },
      animation: {
        duration: 1500,
        easing: "easeInOutQuart",
      },
      layout: {
        padding: {
          bottom: 10,
        },
      },
    };

    const colors = {
      blue: "#3B82F6",
      purple: "#8B5CF6",
      emerald: "#10B981",
      amber: "#F59E0B",
      indigo: "#6366F1",
    };

    const createGradient = (ctx, color1, color2) => {
      const gradient = ctx.createLinearGradient(0, 0, 0, 400);
      gradient.addColorStop(0, color1);
      gradient.addColorStop(1, color2);
      return gradient;
    };

    const fetchPartidasDiarias = async () => {
      try {
        const response = await axios.get(
          "/api/index.php?action=partidasDiarias"
        );
        const data = response.data;
        if (chartPartidas.value) {
          const ctx = chartPartidas.value.getContext("2d");
          const diasTraducidos = diasSemana.map(
            (dia) => textosTraducidos[dia] || dia
          );
          new Chart(ctx, {
            type: "line",
            data: {
              labels: diasTraducidos,
              datasets: [
                {
                  label:
                    textosTraducidos["Partidas Jugadas"] || "Partidas Jugadas",
                  data: [
                    data.Lunes || 0,
                    data.Martes || 0,
                    data.Miércoles || 0,
                    data.Jueves || 0,
                    data.Viernes || 0,
                    data.Sábado || 0,
                    data.Domingo || 0,
                  ],
                  borderColor: colors.indigo,
                  backgroundColor: createGradient(
                    ctx,
                    colors.blue + "80",
                    colors.blue + "20"
                  ),
                  borderWidth: 2,
                  pointRadius: 5,
                  pointHoverRadius: 7,
                  pointBackgroundColor: colors.indigo,
                  tension: 0.4,
                  fill: true,
                },
              ],
            },
            options: chartOptions,
          });
        }
      } catch (error) {
        console.error("Error al cargar partidas diarias:", error);
      }
    };

    const fetchUsuariosSemanal = async () => {
      try {
        const response = await axios.get(
          "/api/index.php?action=usuariosSemanal"
        );
        const data = response.data;
        if (chartUsuarios.value) {
          const ctx = chartUsuarios.value.getContext("2d");
          const diasTraducidos = diasSemana.map(
            (dia) => textosTraducidos[dia] || dia
          );
          new Chart(ctx, {
            type: "line",
            data: {
              labels: diasTraducidos,
              datasets: [
                {
                  label:
                    textosTraducidos["Usuarios Únicos"] || "Usuarios Únicos",
                  data: [
                    data.Lunes || 0,
                    data.Martes || 0,
                    data.Miércoles || 0,
                    data.Jueves || 0,
                    data.Viernes || 0,
                    data.Sábado || 0,
                    data.Domingo || 0,
                  ],
                  borderColor: colors.emerald,
                  backgroundColor: createGradient(
                    ctx,
                    colors.emerald + "80",
                    colors.emerald + "20"
                  ),
                  borderWidth: 2,
                  tension: 0.4,
                  fill: true,
                },
              ],
            },
            options: chartOptions,
          });
        }
      } catch (error) {
        console.error("Error al cargar usuarios semanal:", error);
      }
    };

    const fetchAciertosCategorias = async () => {
      try {
        const response = await axios.get(
          "/api/index.php?action=aciertosCategorias"
        );
        const data = response.data;
        if (chartAciertos.value) {
          const ctx = chartAciertos.value.getContext("2d");
          const categoriasTraducidas = await Promise.all(
            data.map((item) => traducirTexto(item.categoria))
          );
          new Chart(ctx, {
            type: "bar",
            data: {
              labels: data.map(
                (item, index) => categoriasTraducidas[index] || item.categoria
              ),
              datasets: [
                {
                  label: textosTraducidos["Aciertos"] || "Aciertos",
                  data: data.map((item) => item.porcentaje),
                  backgroundColor: [
                    createGradient(ctx, colors.blue, colors.blue + "80"),
                    createGradient(ctx, colors.purple, colors.purple + "80"),
                    createGradient(ctx, colors.emerald, colors.emerald + "80"),
                    createGradient(ctx, colors.amber, colors.amber + "80"),
                  ],
                  borderColor: "#fff",
                  borderWidth: 2,
                  borderRadius: 8,
                },
              ],
            },
            options: {
              ...chartOptions,
              scales: {
                y: {
                  ...chartOptions.scales.y,
                  max: 100,
                },
              },
            },
          });
        }
      } catch (error) {
        console.error("Error al cargar aciertos por categorías:", error);
      }
    };

    const fetchAciertosDificultad = async () => {
      try {
        const response = await axios.get(
          "/api/index.php?action=aciertosDificultad"
        );
        const data = response.data;
        if (chartDificultad.value) {
          const ctx = chartDificultad.value.getContext("2d");
          const dificultadesTraducidas = await Promise.all(
            data.map((item) => traducirTexto(item.dificultad))
          );

          // Configuración específica para gráfico de dona
          const doughnutOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: "right",
                labels: {
                  color: "#2d3748",
                  font: { size: 12, family: "Montserrat" },
                  padding: 10,
                },
              },
              tooltip: {
                backgroundColor: "rgba(0,0,0,0.8)",
                titleFont: { family: "Montserrat", size: 14 },
                bodyFont: { family: "Montserrat", size: 12 },
                padding: 10,
                cornerRadius: 5,
              },
            },
            // Eliminamos las escalas para el gráfico de dona
            scales: {},
            animation: {
              duration: 1500,
              easing: "easeInOutQuart",
            },
            cutout: "60%", // Ajusta el tamaño del hueco interior
            layout: {
              padding: 15,
            },
          };

          new Chart(ctx, {
            type: "doughnut",
            data: {
              labels: data.map(
                (item, index) =>
                  dificultadesTraducidas[index] || item.dificultad
              ),
              datasets: [
                {
                  data: data.map((item) => item.porcentaje),
                  backgroundColor: [
                    colors.blue + "80",
                    colors.purple + "80",
                    colors.emerald + "80",
                  ],
                  borderColor: "#fff",
                  borderWidth: 2,
                },
              ],
            },
            options: doughnutOptions,
          });
        }
      } catch (error) {
        console.error("Error al cargar aciertos por dificultad:", error);
      }
    };

    onMounted(async () => {
      idiomaUsuario.value = navigator.language.split("-")[0] || "es";
      if (idiomaUsuario.value !== "es") {
        await traducirContenido();
      } else {
        fetchPartidasDiarias();
        fetchUsuariosSemanal();
        fetchAciertosCategorias();
        fetchAciertosDificultad();
      }
    });

    return {
      chartAciertos,
      chartUsuarios,
      chartDificultad,
      chartPartidas,
      textosTraducidos,
    };
  },
};
</script>

<style scoped>
.body {
  font-family: "Montserrat", sans-serif;
  background: linear-gradient(to bottom, #7d7de6, #4d4d9d);
  min-height: 100vh;
  padding: 20px;
  margin-left: 60px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.admin-titulo {
  margin-bottom: 20px;
  color: #fff;
  text-align: center;
  font-weight: bold;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  font-size: 2rem;
}

.general {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 2rem;
  max-width: 1600px;
  margin: 0 auto;
  width: 100%;
}

.datos {
  background: white;
  padding: 1.5rem;
  border-radius: 1rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  height: 400px;
}

.datos:hover {
  transform: translateY(-5px);
}

.datos h4 {
  color: #1e293b;
  font-size: 1.25rem;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #e2e8f0;
  font-weight: 500;
  word-wrap: break-word;
  flex-shrink: 0;
}

.chart-container {
  position: relative;
  flex-grow: 1;
  width: 100%;
  height: calc(100% - 45px); /* Altura restante después del título */
  min-height: 250px;
}

/* Estilo para canvas que se adapta automáticamente */
canvas {
  width: 100% !important;
  height: 100% !important;
}

/* Media query para dispositivos más pequeños: 1 columna (4 filas) */
@media (max-width: 992px) {
  .general {
    grid-template-columns: 1fr;
  }
  .body {
    padding: 1rem;
    margin-left: 0;
  }

  .datos {
    height: 350px;
  }
}

/* Para dispositivos muy pequeños ajustamos aún más la altura */
@media (max-width: 576px) {
  .datos {
    height: 300px;
  }
}
</style>
