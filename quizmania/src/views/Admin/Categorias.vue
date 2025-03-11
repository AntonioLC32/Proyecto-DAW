<template>
  <div class="categorias">
    <h1 class="titulo-categorias">GESTIÓN DE CATEGORÍAS</h1>
    <div class="mensajes">
      <div v-if="mensaje" :class="['mensaje', mensajeTipo]">
        {{ mensaje }}
        <span class="cerrar-mensaje" @click="mensaje = ''">&times;</span>
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
            <span class="close" @click="cerrarPopup">&times;</span>
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
              CAMBIAR IMAGEN
            </button>
            <input
              type="file"
              ref="fileInput"
              hidden
              accept="image/*"
              @change="handleImageUpload"
            />
            <button @click="guardarCambios" class="popup-btn">GUARDAR</button>
          </div>
        </div>
      </div>
      <div class="right-column">
        <section class="grafico">
          <h3>Preguntas por categoría</h3>
          <canvas ref="pieChart"></canvas>
        </section>
      </div>
    </div>
  </div>
</template>

<script>
import Table from "./Table.vue";
import Chart from "chart.js/auto";
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
              "#2E2E8B",
              "#7373E6",
              "#4C4C9D",
              "#C2C2E6",
              "#D3D3F5",
              "#FFD700",
              "#FF4500",
              "#32CD32",
              "#1E90FF",
              "#FF69B4",
            ],
          },
        ],
      },
    };
  },
  mounted() {
    this.fetchCategorias();
    this.fetchPreguntas();
  },
  methods: {
    async fetchCategorias() {
      try {
        const response = await fetch("/api/index.php?action=obtenerCategorias");
        const data = await response.json();
        if (data.status === "success") {
          this.rows = data.data.map((categoria) => ({
            id: categoria.id,
            nombre: categoria.nombre,
            imagen: categoria.imagen,
            total_preguntas: 0,
            acciones: {
              editar: true,
              eliminar: false,
              info: false,
            },
          }));

          if (this.rows.length > 0) {
            this.actualizarGrafica();
          }
        }
      } catch (error) {
        console.error("Error fetching categorias:", error);
      }
    },
    async fetchPreguntas() {
      try {
        const response = await fetch("/api/index.php?action=obtenerPreguntas");
        const data = await response.json();
        if (data.status === "success") {
          this.preguntas = data.data;
          this.contarPreguntasPorCategoria();
        }
      } catch (error) {
        console.error("Error fetching preguntas:", error);
      }
    },
    imageURL(imagen) {
      const path = new URL("../../", import.meta.url);
      return `${path}/${imagen}`;
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
        total_preguntas: conteoPorCategoria[categoria.nombre] || 0,
      }));
      this.actualizarGrafica();
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
        // Guardamos el archivo para enviarlo luego
        this.categoriaSeleccionada.imagenFile = file;
      } else {
        alert("Por favor selecciona un archivo de imagen válido.");
      }
    },
    cerrarPopup() {
      this.popupVisible = false;
      // No es necesario revocar el Base64
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
          nombre: this.categoriaSeleccionada.nombre,
          file: base64Image,
        };

        const response = await fetch(
          "/api/index.php?action=actualizarCategorias",
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
          }
        );

        const data = await response.json();

        if (data.status === "success") {
          this.mensaje = "Categoría actualizada correctamente";
          this.mensajeTipo = "success";
          this.cerrarPopup();

          // Forzar actualización completa
          await this.fetchCategorias();
          await this.fetchPreguntas();

          // Limpiar previsualización de imagen
          this.nuevaImagenPreview = null;
        } else {
          this.mensaje = data.mensaje || "Error al actualizar categoría";
          this.mensajeTipo = "error";
        }
      } catch (error) {
        this.mensaje = "Error de conexión: " + error.message;
        this.mensajeTipo = "error";
      } finally {
        setTimeout(() => {
          this.mensaje = "";
          this.mensajeTipo = "";
        }, 5000);
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
