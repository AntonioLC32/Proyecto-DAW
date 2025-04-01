<template>
  <div class="categorias">
    <h1 class="titulo-categorias">
      {{ textosTraducidos["GESTIÓN DE CATEGORÍAS"] || "GESTIÓN DE CATEGORÍAS" }}
    </h1>
    <div class="mensajes">
      <div v-if="mensaje" :class="['mensaje', mensajeTipo]">
        {{ mensaje }}
        <span class="cerrar-mensaje" @click="mensaje = ''">×</span>
      </div>
    </div>
    <div class="content-wrapper">
      <div class="left-column">
        <section class="tabla">
          <Table :headers="headers" :rows="rows" @editar="abrirPopup" />
        </section>
      </div>
      <div v-if="popupVisible" class="popup-backdrop" @click.self="cerrarPopup">
        <div class="popup" @click.stop>
          <div class="popup-content">
            <span class="close" @click="cerrarPopup">×</span>
            <h2>{{ categoriaSeleccionada.nombre }}</h2>
            <img
              :src="
                nuevaImagenPreview || getImageUrl(categoriaSeleccionada.imagen)
              "
              :alt="categoriaSeleccionada.nombre"
            />
            <button
              @click="$refs.fileInput.click()"
              class="popup-btn cambiar-imagen-btn"
            >
              {{ textosTraducidos["CAMBIAR IMAGEN"] || "CAMBIAR IMAGEN" }}
            </button>
            <input
              type="file"
              ref="fileInput"
              hidden
              accept="image/*"
              @change="handleImageUpload"
            />
            <button @click="guardarCambios" class="popup-btn">
              {{ textosTraducidos["GUARDAR"] || "GUARDAR" }}
            </button>
          </div>
        </div>
      </div>
      <div class="right-column">
        <section class="grafico">
          <h3>
            {{
              textosTraducidos["Preguntas por categoría"] ||
              "Preguntas por categoría"
            }}
          </h3>
          <canvas ref="pieChart"></canvas>
        </section>
      </div>
    </div>
  </div>
</template>

<script>
import Table from "./Table.vue";
import Chart from "chart.js/auto";
import axios from "axios";

export default {
  name: "Categorias",
  components: { Table },
  data() {
    return {
      nuevaImagenPreview: null,
      popupVisible: false,
      categoriaSeleccionada: {},
      mensaje: "",
      mensajeTipo: "",
      headers: [
        { key: "id", label: "ID" },
        { key: "nombre", label: "NOMBRE" },
        { key: "imagen", label: "IMAGEN" },
        { key: "acciones", label: "ACCIONES" },
      ],
      rows: [],
      preguntas: [],
      chartData: {
        labels: [],
        datasets: [
          {
            data: [],
            backgroundColor: [
              "#6b8e23",
              "#8b5a2b",
              "#d2691e",
              "#b22222",
              "#9370db",
              "#f0e68c",
              "#c3b091",
              "#4682b4",
              "#5f9ea0",
              "#db7093",
            ],
            hoverBackgroundColor: [
              "#556b2f",
              "#8b4513",
              "#cd853f",
              "#a52a2a",
              "#6a5acd",
              "#e6e6fa",
              "#4169e1",
              "#d2b48c",
              "#20b2aa",
              "#ff69b4",
            ],
          },
        ],
      },
      textosTraducidos: {},
      idiomaUsuario: "es",
    };
  },
  async mounted() {
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    if (this.idiomaUsuario !== "es") {
      await this.traducirContenido();
    }
    await this.fetchCategorias();
    await this.fetchPreguntas();
  },
  methods: {
    async traducirTexto(texto) {
      if (/^[\d:]/.test(texto) || this.idiomaUsuario === "es") return texto;
      try {
        const response = await axios.post("/api/index.php?action=traducir", {
          texto: texto,
          idioma_origen: "es",
          idioma_destino: this.idiomaUsuario,
        });
        return response.data.status === "success"
          ? response.data.traduccion
          : texto;
      } catch (error) {
        console.error("Error en traducción:", error);
        return texto;
      }
    },
    async traducirContenido() {
      const textos = [
        "GESTIÓN DE CATEGORÍAS",
        "Preguntas por categoría",
        "ID",
        "NOMBRE",
        "IMAGEN",
        "ACCIONES",
        "CAMBIAR IMAGEN",
        "GUARDAR",
        "Categoría actualizada correctamente",
        "Error al actualizar categoría",
        "Error de conexión",
        "Por favor selecciona un archivo de imagen válido.",
      ];
      const traducciones = await Promise.all(textos.map(this.traducirTexto));
      textos.forEach((texto, index) => {
        this.textosTraducidos[texto] = traducciones[index];
      });

      this.headers = await Promise.all(
        this.headers.map(async (header) => ({
          ...header,
          label: await this.traducirTexto(header.label),
        }))
      );
    },
    async fetchCategorias() {
      try {
        const response = await axios.get(
          "/api/index.php?action=obtenerCategorias"
        );
        const data = response.data;
        if (data.status === "success") {
          this.rows = await Promise.all(
            data.data.map(async (categoria) => {
              const nombreTraducido =
                this.idiomaUsuario !== "es"
                  ? await this.traducirTexto(categoria.nombre)
                  : categoria.nombre;
              return {
                id: categoria.id,
                nombre: nombreTraducido,
                nombreOriginal: categoria.nombre,
                imagen: categoria.imagen,
                total_preguntas: 0,
                acciones: {
                  editar: true,
                  eliminar: false,
                  info: false,
                },
              };
            })
          );
        }
      } catch (error) {
        console.error("Error fetching categorias:", error);
      }
    },
    async fetchPreguntas() {
      try {
        const response = await axios.get(
          "/api/index.php?action=obtenerPreguntas"
        );
        const data = response.data;
        if (data.status === "success") {
          this.preguntas = data.data;
          this.contarPreguntasPorCategoria();
          this.actualizarGrafica();
        }
      } catch (error) {
        console.error("Error fetching preguntas:", error);
      }
    },
    contarPreguntasPorCategoria() {
      const conteoPorCategoria = {};
      this.preguntas.forEach((pregunta) => {
        const categoria = pregunta.categoria;
        conteoPorCategoria[categoria] =
          (conteoPorCategoria[categoria] || 0) + 1;
      });
      this.rows = this.rows.map((categoria) => ({
        ...categoria,
        total_preguntas: conteoPorCategoria[categoria.nombreOriginal] || 0,
      }));
    },
    actualizarGrafica() {
      this.chartData.labels = this.rows.map((categoria) => categoria.nombre);
      this.chartData.datasets[0].data = this.rows.map(
        (categoria) => categoria.total_preguntas
      );
      this.renderChart();
    },
    renderChart() {
      if (this.$refs.pieChart) {
        const ctx = this.$refs.pieChart.getContext("2d");
        if (this.chartInstance) {
          this.chartInstance.destroy();
        }
        this.chartInstance = new Chart(ctx, {
          type: "pie",
          data: this.chartData,
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: "bottom" } },
          },
        });
      }
    },
    abrirPopup(categoria) {
      this.categoriaSeleccionada = { ...categoria };
      this.popupVisible = true;
    },
    handleImageUpload(event) {
      const file = event.target.files[0];
      if (file && file.type.startsWith("image/")) {
        if (this.nuevaImagenPreview) {
          URL.revokeObjectURL(this.nuevaImagenPreview);
        }
        this.nuevaImagenPreview = URL.createObjectURL(file);
        this.categoriaSeleccionada.imagenFile = file;
      } else {
        alert(
          this.textosTraducidos[
            "Por favor selecciona un archivo de imagen válido."
          ] || "Por favor selecciona un archivo de imagen válido."
        );
      }
    },
    cerrarPopup() {
      this.popupVisible = false;
      this.nuevaImagenPreview = null;
    },
    convertFileToBase64(file) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = () => resolve(reader.result);
        reader.onerror = (error) => reject(error);
      });
    },
    async guardarCambios() {
      try {
        let base64Image = null;
        if (this.categoriaSeleccionada.imagenFile) {
          base64Image = await this.convertFileToBase64(
            this.categoriaSeleccionada.imagenFile
          );
        }

        const payload = {
          action: "actualizarCategorias",
          id_categoria: this.categoriaSeleccionada.id,
          nombre: this.categoriaSeleccionada.nombreOriginal,
          file: base64Image,
        };

        const response = await axios.post(
          "/api/index.php?action=actualizarCategorias",
          payload
        );
        const data = response.data;

        if (data.status === "success") {
          this.mensaje =
            this.textosTraducidos["Categoría actualizada correctamente"] ||
            "Categoría actualizada correctamente";
          this.mensajeTipo = "success";
          this.cerrarPopup();
          await this.fetchCategorias();
          await this.fetchPreguntas();
          this.nuevaImagenPreview = null;
        } else {
          this.mensaje =
            data.mensaje ||
            this.textosTraducidos["Error al actualizar categoría"] ||
            "Error al actualizar categoría";
          this.mensajeTipo = "error";
        }
      } catch (error) {
        this.mensaje = `${
          this.textosTraducidos["Error de conexión"] || "Error de conexión"
        }: ${error.message}`;
        this.mensajeTipo = "error";
      } finally {
        setTimeout(() => {
          this.mensaje = "";
          this.mensajeTipo = "";
          location.reload();
        }, 2000);
      }
    },
    getImageUrl(path) {
      const url = new URL("../../", import.meta.url);
      return `${url}/${path}`;
    },
  },
};
</script>

<style scoped>
.categorias {
  margin-left: 60px;
  background: linear-gradient(to bottom, #8d89f8 0%, #8682eb 54%, #535192 100%);
  min-height: 100vh;
  padding: 20px;
  color: #333;
  font-family: Roboto, sans-serif;
  width: calc(100% - 60px);
}
.titulo-categorias {
  margin-bottom: 20px;
  color: #fff;
  text-align: center;
  font-weight: bold;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  font-size: 2rem;
}
.content-wrapper {
  display: flex;
  gap: 20px;
  align-items: stretch;
}
.left-column {
  flex: 2;
}
.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.grafico {
  background: white;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 600px;
  box-sizing: border-box;
}
.grafico canvas {
  display: block;
  width: 100% !important;
  height: calc(100% - 40px) !important;
}
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translate(-50%, -50%) scale(0.7);
  }
  to {
    opacity: 1;
    transform: translate(-50%, -50%) scale(1);
  }
}
.popup-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 999;
  display: flex;
  justify-content: center;
  align-items: center;
  animation: backdropFadeIn 0.3s ease-out;
}
@keyframes backdropFadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}
.popup {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  width: 500px;
  max-width: 90%;
  z-index: 1000;
  animation: fadeIn 0.3s cubic-bezier(0.25, 0.1, 0.25, 1);
  border: 1px solid rgba(108, 92, 231, 0.2);
}
.popup-content {
  display: flex;
  flex-direction: column;
  position: relative;
  gap: 15px;
}
.popup-content img {
  max-width: 200px;
  max-height: 200px;
  object-fit: contain;
  display: block;
  margin: 0 auto;
  border-radius: 8px;
}
.popup-content h2 {
  color: #4a4aa6;
  font-size: 20px;
  margin-bottom: 20px;
  border-bottom: 2px solid rgba(108, 92, 231, 0.1);
  padding-bottom: 10px;
  text-align: center;
}
.close {
  position: absolute;
  right: 0;
  top: -10px;
  cursor: pointer;
  font-size: 24px;
  color: #888;
  transition: color 0.3s ease;
}
.close:hover {
  color: #6c5ce7;
}
.popup-btn {
  background-color: #6c5ce7;
  color: white;
  padding: 12px 20px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  text-transform: uppercase;
  transition: all 0.3s ease;
  margin-top: 10px;
  align-self: center;
  width: 100%;
}
.popup-btn:hover {
  background-color: #5b4bc4;
  transform: translateY(-2px);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}
.popup-btn.cambiar-imagen-btn {
  background-color: #4a4aa6;
  margin-top: 15px;
}
.popup-btn.cambiar-imagen-btn:hover {
  background-color: #3a3a86;
}
.popup-content {
  gap: 20px;
}

.mensajes {
  position: fixed;
  top: 80px;
  right: 20px;
  z-index: 1000;
  max-width: 300px;
}

.mensaje {
  padding: 15px 35px 15px 20px;
  border-radius: 8px;
  margin-bottom: 10px;
  position: relative;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  animation: slideIn 0.3s ease-out;
  font-size: 14px;
  font-weight: 500;
}

.mensaje.success {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.mensaje.error {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.cerrar-mensaje {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  cursor: pointer;
  font-size: 20px;
  line-height: 1;
  opacity: 0.7;
  transition: opacity 0.2s;
}

.cerrar-mensaje:hover {
  opacity: 1;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@media (max-width: 1400px) {
  .content-wrapper {
    flex-direction: column;
    align-items: initial;
  }
  .left-column,
  .right-column {
    flex: initial;
  }
}
</style>
