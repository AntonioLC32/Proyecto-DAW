<template>
  <div class="preguntas">
    <h1 class="titulo-preguntas">
      {{ textosTraducidos["GESTIÓN DE PREGUNTAS"] || "GESTIÓN DE PREGUNTAS" }}
    </h1>

    <div class="mensajes">
      <div v-if="mensaje" :class="['mensaje', mensajeTipo]">
        {{ mensaje }}
        <span class="cerrar-mensaje" @click="mensaje = ''">×</span>
      </div>
    </div>

    <div class="content-wrapper">
      <div class="left-column">
        <section class="gestion-preguntas">
          <div class="searchBar">
            <div class="input-container">
              <input
                type="text"
                v-model="input"
                class="search-input"
                :placeholder="
                  textosTraducidos['Buscar pregunta...'] || 'Buscar pregunta...'
                "
              />
              <button @click="buscarPregunta" class="buscar-btn">
                <i class="fas fa-search"></i>
              </button>
            </div>
          </div>

          <div class="filtro-categorias">
            <label
              class="category-item"
              v-for="categoria in categoriasUnicasOriginales"
              :key="categoria"
            >
              <input
                type="checkbox"
                :value="categoria"
                v-model="categoriasSeleccionadas"
              />
              <span>{{ textosTraducidos[categoria] || categoria }}</span>
            </label>
          </div>
        </section>

        <section class="tabla">
          <Table
            :headers="headers"
            :rows="rowsFiltradas"
            @editar="abrirPopup"
            @eliminar="deshabilitarPregunta"
          />
        </section>
      </div>

      <div v-if="popupVisible" class="popup-backdrop" @click.self="cerrarPopup">
        <div class="popup" @click.stop>
          <div class="popup-content">
            <span class="close" @click="cerrarPopup">×</span>
            <h2>{{ preguntaSeleccionada.pregunta }}</h2>

            <div class="form-group">
              <label>{{ textosTraducidos["Categoría"] || "Categoría" }}</label>
              <select v-model="preguntaSeleccionada.categoria">
                <option
                  v-for="cat in categoriasOriginales"
                  :key="cat"
                  :value="cat"
                >
                  {{ textosTraducidos[cat] || cat }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label>{{
                textosTraducidos["Dificultad"] || "Dificultad"
              }}</label>
              <select v-model="preguntaSeleccionada.dificultad">
                <option
                  v-for="dif in dificultadesOriginales"
                  :key="dif"
                  :value="dif"
                >
                  {{ textosTraducidos[dif] || dif }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label>{{ textosTraducidos["Opciones"] || "Opciones" }}</label>
              <textarea v-model="preguntaSeleccionada.opciones"></textarea>
            </div>

            <div class="form-group">
              <label>{{
                textosTraducidos["Respuesta correcta"] || "Respuesta correcta"
              }}</label>
              <input
                v-model="preguntaSeleccionada.correcta"
                type="text"
                @keyup.enter="guardarCambios"
              />
            </div>

            <button @click="guardarCambios" class="popup-btn">
              {{ textosTraducidos["GUARDAR"] || "GUARDAR" }}
            </button>
          </div>
        </div>
      </div>

      <div class="right-column">
        <section class="add-pregunta">
          <h1 class="titulo-form">
            {{ textosTraducidos["AÑADIR PREGUNTA"] || "AÑADIR PREGUNTA" }}
          </h1>
          <form @submit.prevent="addPregunta">
            <div class="form-group">
              <label for="pregunta">{{
                textosTraducidos["Pregunta"] || "Pregunta"
              }}</label>
              <textarea
                id="pregunta"
                v-model="pregunta"
                :placeholder="
                  textosTraducidos['Escribe la pregunta en español'] ||
                  'Escribe la pregunta en español'
                "
              ></textarea>
            </div>
            <div class="form-group">
              <label for="categoria">{{
                textosTraducidos["Categoría"] || "Categoría"
              }}</label>
              <select id="categoria" v-model="categoria" required>
                <option value="">
                  {{
                    textosTraducidos["Selecciona una categoría"] ||
                    "Selecciona una categoría"
                  }}
                </option>
                <option
                  v-for="cat in categoriasOriginales"
                  :key="cat"
                  :value="cat"
                >
                  {{ textosTraducidos[cat] || cat }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label for="dificultad">{{
                textosTraducidos["Dificultad"] || "Dificultad"
              }}</label>
              <select id="dificultad" v-model="dificultad" required>
                <option value="">
                  {{
                    textosTraducidos["Selecciona la dificultad"] ||
                    "Selecciona la dificultad"
                  }}
                </option>
                <option
                  v-for="dif in dificultadesOriginales"
                  :key="dif"
                  :value="dif"
                >
                  {{ textosTraducidos[dif] || dif }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label for="respuestas">{{
                textosTraducidos["Respuestas"] || "Respuestas"
              }}</label>
              <textarea
                id="respuestas"
                v-model="respuestas"
                :placeholder="
                  textosTraducidos[
                    'Escribe las respuestas (separadas por |)'
                  ] || 'Escribe las respuestas (separadas por |)'
                "
              ></textarea>
            </div>
            <div class="form-group">
              <label for="correcta">{{
                textosTraducidos["Respuesta correcta"] || "Respuesta correcta"
              }}</label>
              <input
                id="correcta"
                type="text"
                v-model="correcta"
                :placeholder="
                  textosTraducidos['Escribe la respuesta correcta'] ||
                  'Escribe la respuesta correcta'
                "
              />
            </div>
            <button type="submit">
              {{ textosTraducidos["Añadir pregunta"] || "Añadir pregunta" }}
            </button>
          </form>
        </section>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from "vue";
import Table from "./Table.vue";
import axios from "axios";

export default {
  name: "Preguntas",
  components: {
    Table,
  },
  data() {
    return {
      input: "",
      pregunta: "",
      dificultad: "",
      categoria: "",
      respuestas: "",
      correcta: "",
      headers: [
        { key: "id", label: "ID" },
        { key: "pregunta", label: "PREGUNTA" },
        { key: "dificultad", label: "DIFICULTAD" },
        { key: "categoria", label: "CATEGORÍA" },
        { key: "acciones", label: "ACCIONES" },
      ],
      rows: [],
      categoriasSeleccionadas: [],
      popupVisible: false,
      preguntaSeleccionada: {},
      mensaje: "",
      mensajeTipo: "success",
      textosTraducidos: {},
      idiomaUsuario: "es",
      categoriasOriginales: [
        "Ciencia",
        "Historia",
        "Geografía",
        "Deportes",
        "Arte y Literatura",
        "Entretenimiento",
        "Tecnología",
        "Matemáticas",
        "Cultura General",
        "Música",
      ],
      dificultadesOriginales: ["Fácil", "Media", "Difícil"],
    };
  },
  computed: {
    rowsFiltradas() {
      return this.rows.filter((row) => {
        const textoBusqueda = this.input.toLowerCase().trim();
        const coincideTexto =
          textoBusqueda === "" ||
          row.pregunta.toLowerCase().includes(textoBusqueda);
        const coincideCategoria =
          this.categoriasSeleccionadas.length === 0 ||
          this.categoriasSeleccionadas.includes(row.categoria);
        return coincideTexto && coincideCategoria;
      });
    },
    categoriasUnicasOriginales() {
      return [...new Set(this.rows.map((item) => item.categoria))];
    },
    listaCategoriasTraducidas() {
      const categoriasUnicas = [
        ...new Set(this.rows.map((item) => item.categoria)),
      ];
      return categoriasUnicas.map((cat) =>
        this.idiomaUsuario !== "es" && this.textosTraducidos[cat]
          ? this.textosTraducidos[cat]
          : cat
      );
    },
  },
  async mounted() {
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    if (this.idiomaUsuario !== "es") {
      await this.traducirContenido();
    }
    this.fetchPreguntas();
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
        "GESTIÓN DE PREGUNTAS",
        "Buscar pregunta...",
        "ID",
        "PREGUNTA",
        "DIFICULTAD",
        "CATEGORÍA",
        "ACCIONES",
        "AÑADIR PREGUNTA",
        "Pregunta",
        "Categoría",
        "Dificultad",
        "Respuestas",
        "Respuesta correcta",
        "Añadir pregunta",
        "GUARDAR",
        "Opciones",
        "Respuesta correcta",
        "Pregunta deshabilitada correctamente",
        "Error al deshabilitar la pregunta",
        "Error de conexión",
        "¡Pregunta actualizada correctamente!",
        "Error al actualizar la pregunta",
        "¡Pregunta añadida exitosamente!",
        "Error al crear la pregunta",
        "Error: La respuesta correcta no está en las primeras 4 opciones",
        "Escribe la pregunta en español",
        "Selecciona una categoría",
        "Selecciona la dificultad",
        "Escribe las respuestas (separadas por |)",
        "Escribe la respuesta correcta",
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

      const categoriasTraducidas = await Promise.all(
        this.categoriasOriginales.map(this.traducirTexto)
      );
      const dificultadesTraducidas = await Promise.all(
        this.dificultadesOriginales.map(this.traducirTexto)
      );

      this.categoriasOriginales.forEach((cat, index) => {
        this.textosTraducidos[cat] = categoriasTraducidas[index];
      });
      this.dificultadesOriginales.forEach((dif, index) => {
        this.textosTraducidos[dif] = dificultadesTraducidas[index];
      });
    },
    async fetchPreguntas() {
      try {
        const response = await axios.get(
          "/api/index.php?action=obtenerPreguntas"
        );
        const data = response.data;
        if (data.status === "success") {
          this.rows = data.data.map((pregunta) => ({
            ...pregunta,
            acciones: {
              editar: true,
              eliminar: true,
              info: false,
            },
          }));
        }
      } catch (error) {
        console.error("Error fetching preguntas:", error);
      }
    },
    abrirPopup(pregunta) {
      this.preguntaSeleccionada = { ...pregunta };
      this.popupVisible = true;
    },
    cerrarPopup() {
      this.popupVisible = false;
    },
    async deshabilitarPregunta(pregunta) {
      try {
        const confirmar = confirm(
          `${
            this.textosTraducidos["¿Deshabilitar la pregunta"] ||
            "¿Deshabilitar la pregunta"
          } "${pregunta.pregunta}"?`
        );
        if (!confirmar) return;
        const response = await axios.post(
          "/api/index.php?action=deshabilitarPregunta",
          {
            id_pregunta: pregunta.id,
          }
        );
        const data = response.data;
        if (data.status === "success") {
          this.mensaje =
            this.textosTraducidos["Pregunta deshabilitada correctamente"] ||
            "Pregunta deshabilitada correctamente";
          this.mensajeTipo = "success";
          this.fetchPreguntas();
        } else {
          this.mensaje =
            data.mensaje ||
            this.textosTraducidos["Error al deshabilitar la pregunta"] ||
            "Error al deshabilitar la pregunta";
          this.mensajeTipo = "error";
        }
      } catch (error) {
        this.mensaje = `${
          this.textosTraducidos["Error de conexión"] || "Error de conexión"
        }: ${error.message}`;
        this.mensajeTipo = "error";
      } finally {
        setTimeout(() => (this.mensaje = ""), 5000);
      }
    },
    async guardarCambios() {
      try {
        let opcionesArray =
          typeof this.preguntaSeleccionada.opciones === "string"
            ? this.preguntaSeleccionada.opciones
                .split("|")
                .map((opcion) => opcion.trim())
            : this.preguntaSeleccionada.opciones.map((opcion) => opcion.trim());
        let opcionesLimitadas = opcionesArray.slice(0, 4);

        if (!opcionesLimitadas.includes(this.preguntaSeleccionada.correcta)) {
          this.mensaje =
            this.textosTraducidos[
              "Error: La respuesta correcta no está en las primeras 4 opciones"
            ] ||
            "Error: La respuesta correcta no está en las primeras 4 opciones";
          this.mensajeTipo = "error";
          return;
        }

        const dataToSend = {
          id_pregunta:
            this.preguntaSeleccionada.id ||
            this.preguntaSeleccionada.id_pregunta,
          pregunta: this.preguntaSeleccionada.pregunta,
          categoria: this.preguntaSeleccionada.categoria,
          dificultad: this.preguntaSeleccionada.dificultad,
          opciones: opcionesLimitadas,
          correcta: this.preguntaSeleccionada.correcta,
        };

        const response = await axios.post(
          "/api/index.php?action=updatePregunta",
          dataToSend
        );
        const data = response.data;

        if (data.status === "success") {
          this.mensaje =
            this.textosTraducidos["¡Pregunta actualizada correctamente!"] ||
            "¡Pregunta actualizada correctamente!";
          this.mensajeTipo = "success";
          this.fetchPreguntas();
          this.popupVisible = false;
        } else {
          this.mensaje =
            data.mensaje ||
            this.textosTraducidos["Error al actualizar la pregunta"] ||
            "Error al actualizar la pregunta";
          this.mensajeTipo = "error";
        }
      } catch (error) {
        this.mensaje = `${
          this.textosTraducidos["Error de conexión"] || "Error de conexión"
        }: ${error.message}`;
        this.mensajeTipo = "error";
        console.error("Error al guardar cambios:", error);
      } finally {
        setTimeout(() => (this.mensaje = ""), 5000);
      }
    },
    async addPregunta() {
      try {
        const response = await axios.post(
          "/api/index.php?action=insertPregunta",
          {
            texto: this.pregunta,
            dificultad: this.dificultad,
            categoria: this.categoria,
            respuestas: this.respuestas.split("|"),
            correcta: this.correcta,
          }
        );
        const data = response.data;
        if (data.status === "success") {
          this.mensaje =
            this.textosTraducidos["¡Pregunta añadida exitosamente!"] ||
            "¡Pregunta añadida exitosamente!";
          this.mensajeTipo = "success";
          this.fetchPreguntas();
          this.pregunta = "";
          this.dificultad = "";
          this.categoria = "";
          this.respuestas = "";
          this.correcta = "";
        } else {
          this.mensaje =
            data.mensaje ||
            this.textosTraducidos["Error al crear la pregunta"] ||
            "Error al crear la pregunta";
          this.mensajeTipo = "error";
        }
      } catch (error) {
        this.mensaje = `${
          this.textosTraducidos["Error de conexión"] || "Error de conexión"
        }: ${error.message}`;
        this.mensajeTipo = "error";
        console.error("Error al añadir pregunta:", error);
      } finally {
        setTimeout(() => (this.mensaje = ""), 5000);
      }
    },
    buscarPregunta() {},
  },
};
</script>

<style scoped>
.preguntas {
  margin-left: 60px;
  background: linear-gradient(to bottom, #8d89f8 0%, #8682eb 54%, #535192 100%);
  min-height: 100vh;
  padding: 20px;
  color: #333;
  font-family: Roboto, sans-serif;
  width: calc(100% - 60px);
}

.titulo-form {
  font-size: 24px;
  margin-bottom: 20px;
  color: #333;
  text-align: center;
  font-weight: bold;
}

.titulo-preguntas {
  margin-bottom: 20px;
  color: #fff;
  text-align: center;
  font-weight: bold;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  font-size: 2rem;
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

.content-wrapper {
  display: flex;
  gap: 20px;
  align-items: stretch;
  min-height: 83vh;
}

.left-column {
  flex: 2;
}

.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  flex-grow: 1;
}

.searchBar {
  display: flex;
  align-items: center;
  justify-content: center;
}

.input-container {
  position: relative;
  width: 100%;
}

.search-input {
  width: 100%;
  padding: 10px 40px 10px 12px;
  border: 1px solid #ddd;
  border-radius: 20px;
  background: #fff;
  font-size: 14px;
  transition: all 0.3s ease-in-out;
  outline: none;
}

.search-input:focus {
  border-color: #6c5ce7;
  box-shadow: 0 0 5px rgba(108, 92, 231, 0.5);
}

.buscar-btn {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  border: none;
  background: transparent;
  color: #6c5ce7;
  cursor: pointer;
  font-size: 16px;
}

.buscar-btn:hover {
  color: #5b4bc4;
}

.filtro-categorias {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  background: #fff;
  padding: 15px;
  border-radius: 8px;
  margin: 20px 0;
}

.category-item {
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
  font-size: 14px;
  cursor: pointer;
}

.category-item input[type="checkbox"] {
  margin: 0;
  width: 16px;
  height: 16px;
  cursor: pointer;
  accent-color: rgba(74, 77, 165, 0.87);
}

.tabla {
  margin-top: 20px;
}

.add-pregunta {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  flex: 1;
  display: flex;
  flex-direction: column;
}

.add-pregunta form {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 15px;
  justify-content: space-around;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  font-size: 14px;
  margin-bottom: 5px;
  color: #444;
}

.add-pregunta textarea,
.add-pregunta input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.3s, box-shadow 0.3s;
}

.add-pregunta textarea:focus,
.add-pregunta input:focus {
  border-color: #6c5ce7;
  outline: none;
  box-shadow: 0 0 0 2px rgba(108, 92, 231, 0.2);
}

.add-pregunta textarea {
  min-height: 80px;
  resize: vertical;
}

.add-pregunta button {
  background-color: #6c5ce7;
  color: white;
  padding: 12px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  text-transform: uppercase;
  transition: background-color 0.3s;
}

.add-pregunta button:hover {
  background-color: #5b4bc4;
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

.popup .form-group {
  margin-bottom: 15px;
}

.popup .form-group label {
  font-size: 14px;
  color: #555;
  margin-bottom: 5px;
  font-weight: 500;
}

.popup .form-group input,
.popup .form-group textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  transition: all 0.3s ease;
}

.popup .form-group input:focus,
.popup .form-group textarea:focus {
  border-color: #6c5ce7;
  outline: none;
  box-shadow: 0 0 0 2px rgba(108, 92, 231, 0.1);
}

.popup .form-group textarea {
  min-height: 100px;
  resize: vertical;
}

.add-pregunta select,
.popup select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  background-color: white;
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
  background-image: url("data:image/svg+xml;utf8,<svg fill='%236c5ce7' height='24' viewBox='0 0 24 24' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5z'/><path d='M0 0h24v24H0z' fill='none'/></svg>");
  background-repeat: no-repeat;
  background-position: right 10px center;
  transition: border-color 0.3s, box-shadow 0.3s;
  cursor: pointer;
}

.add-pregunta select:focus,
.popup select:focus {
  border-color: #6c5ce7;
  outline: none;
  box-shadow: 0 0 0 2px rgba(108, 92, 231, 0.2);
}

.add-pregunta select option,
.popup select option {
  background-color: white;
  color: #333;
  padding: 10px;
}

.add-pregunta select option:hover,
.popup select option:hover {
  background-color: #f0f0f0;
}

.add-pregunta select option[value=""] {
  color: #888;
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
