<template>
  <div class="preguntas">
    <h1 class="titulo-preguntas">GESTIÓN DE PREGUNTAS</h1>

    <!-- Contenedor principal que agrupa ambas columnas -->
    <div class="content-wrapper">
      <!-- Columna izquierda: búsqueda, filtros y tabla -->
      <div class="left-column">
        <section class="gestion-preguntas">
          <div class="searchBar">
            <div class="input-container">
              <input
                type="text"
                v-model="input"
                class="search-input"
                placeholder="Buscar pregunta..."
              />
              <button @click="buscarPregunta" class="buscar-btn">
                <i class="fas fa-search"></i>
              </button>
            </div>
          </div>

          <div class="filtro-categorias">
            <label class="category-item" v-for="categoria in listaCategorias" :key="categoria">
              <input
                type="checkbox"
                :value="categoria"
                v-model="categoriasSeleccionadas"
              />
              <span>{{ categoria }}</span>
            </label>
          </div>
        </section>

        <section class="tabla">
          <!-- Se asume que el componente Table emite el evento "editar" pasando la fila -->
          <Table :headers="headers" :rows="rowsFiltradas" @editar="abrirPopup" />
        </section>
      </div>

      <!-- Popup de edición -->
      <div v-if="popupVisible" class="popup-backdrop" @click.self="cerrarPopup">
        <div class="popup" @click.stop>
          <div class="popup-content">
            <span class="close" @click="cerrarPopup">&times;</span>
            <h2>{{ preguntaSeleccionada.pregunta }}</h2>

            <div class="form-group">
              <label>Categoría</label>
              <select v-model="preguntaSeleccionada.categoria">
                <option value="Ciencia">Ciencia</option>
                <option value="Historia">Historia</option>
                <option value="Geografía">Geografía</option>
                <option value="Deportes">Deportes</option>
                <option value="Arte y Literatura">Arte y Literatura</option>
                <option value="Entretenimiento">Entretenimiento</option>
                <option value="Tecnología">Tecnología</option>
                <option value="Matemáticas">Matemáticas</option>
                <option value="Cultura General">Cultura General</option>
                <option value="Música">Música</option>
              </select>
            </div>

            <div class="form-group">
              <label>Dificultad</label>
              <select v-model="preguntaSeleccionada.dificultad">
                <option value="Fácil">Fácil</option>
                <option value="Media">Media</option>
                <option value="Difícil">Difícil</option>
              </select>
            </div>

            <div class="form-group">
              <label>Opciones</label>
              <textarea v-model="preguntaSeleccionada.opciones"></textarea>
            </div>

            <div class="form-group">
              <label>Respuesta correcta</label>
              <input v-model="preguntaSeleccionada.correcta" type="text" />
            </div>

            <button @click="guardarCambios" class="popup-btn">GUARDAR</button>
          </div>
        </div>
      </div>

      <!-- Columna derecha: formulario para añadir pregunta -->
      <div class="right-column">
        <section class="add-pregunta">
          <h1 class="titulo-form">AÑADIR PREGUNTA</h1>
          <form @submit.prevent="addPregunta">
            <div class="form-group">
              <label for="pregunta">Pregunta</label>
              <textarea
                id="pregunta"
                v-model="pregunta"
                placeholder="Escribe la pregunta"
              ></textarea>
            </div>
            <div class="form-group">
              <label for="categoria">Categoría</label>
              <select id="categoria" v-model="categoria" required>
                <option value="">Selecciona una categoría</option>
                <option value="Ciencia">Ciencia</option>
                <option value="Historia">Historia</option>
                <option value="Geografía">Geografía</option>
                <option value="Deportes">Deportes</option>
                <option value="Arte y Literatura">Arte y Literatura</option>
                <option value="Entretenimiento">Entretenimiento</option>
                <option value="Tecnología">Tecnología</option>
                <option value="Matemáticas">Matemáticas</option>
                <option value="Cultura General">Cultura General</option>
                <option value="Música">Música</option>
              </select>
            </div>

            <div class="form-group">
              <label for="dificultad">Dificultad</label>
              <select id="dificultad" v-model="dificultad" required>
                <option value="">Selecciona la dificultad</option>
                <option value="Fácil">Fácil</option>
                <option value="Media">Media</option>
                <option value="Difícil">Difícil</option>
              </select>
            </div>
            <div class="form-group">
              <label for="respuestas">Respuestas</label>
              <textarea
                id="respuestas"
                v-model="respuestas"
                placeholder="Escribe las respuestas (separadas por |)"
              ></textarea>
            </div>
            <div class="form-group">
              <label for="correcta">Respuesta correcta</label>
              <input
                id="correcta"
                type="text"
                v-model="correcta"
                placeholder="Escribe la respuesta correcta"
              />
            </div>
            <button type="submit">Añadir pregunta</button>
          </form>
        </section>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from "vue";
import Table from "./Table.vue";

export default {
  name: "Preguntas",
  components: {
    Table,
  },
  data() {
    return {
      // Variables de búsqueda y filtros
      input: "",
      Ciencia: false,
      Historia: false,
      Geografia: false,
      Deportes: false,
      AyL: false,
      Entretenimiento: false,
      Tecnologia: false,
      Matematicas: false,
      CulturaGeneral: false,
      Musica: false,
      // Variables para el formulario
      pregunta: "",
      dificultad: "",
      categoria: "",
      respuestas: "",
      correcta: "",
      // Datos de la tabla
      headers: [
        { key: "id", label: "ID" },
        { key: "pregunta", label: "PREGUNTA" },
        { key: "dificultad", label: "DIFICULTAD" },
        { key: "categoria", label: "CATEGORÍA" },
        { key: "acciones", label: "ACCIONES" },
      ],
      categoriasSeleccionadas: [],
      rows: [
        {
          id: 1,
          pregunta: "¿Quién pintó la Mona Lisa?",
          dificultad: "Fácil",
          categoria: "Arte y Literatura",
          opciones: "Opción 1|Opción 2|Opción 3",
          correcta: "Opción 1",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 2,
          pregunta: "¿Cuál es la capital de Francia?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 3,
          pregunta: "¿En qué año llegó el hombre a la luna?",
          dificultad: "Media",
          categoria: "Historia",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 4,
          pregunta: "¿Cuál es la capital de Italia?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 5,
          pregunta: "¿Cuál es el planeta más cercano al Sol?",
          dificultad: "Difícil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 6,
          pregunta: "¿Cuál es la capital de Australia?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 7,
          pregunta: "¿Cuál es la capital de Japón?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 8,
          pregunta: "¿Cuál es la capital de Brasil?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 9,
          pregunta: "¿Cuál es la capital de España?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 10,
          pregunta: "¿Cuál es la capital de Argentina?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 11,
          pregunta: "¿Cuál es la capital de Colombia?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 12,
          pregunta: "¿Cuál es la capital de México?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 13,
          pregunta: "¿Cuál es la capital de Perú?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 14,
          pregunta: "¿Cuál es la capital de Chile?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 15,
          pregunta: "¿Cuál es la capital de Venezuela?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
        {
          id: 16,
          pregunta: "¿Cuál es la capital de Uruguay?",
          dificultad: "Fácil",
          categoria: "Geografía",
          opciones: "París|Londres|Berlín|Roma",
          correcta: "París",
          acciones: {
            editar: true,
            eliminar: true,
            info: false,
          },
        },
      ],
      listaCategorias: ["Arte y Literatura", "Geografía", "Ciencia", "Deportes", "Matemáticas", "Historia", "Música", "Tecnología", "Entretenimiento", "Cultura General"],
      popupVisible: false,
      preguntaSeleccionada: {},
    };
  },
  computed: {
    rowsFiltradas() {
      if (this.categoriasSeleccionadas.length === 0) {
        return this.rows; // Si no hay filtros, muestra todas las preguntas
      }
      return this.rows.filter(row => this.categoriasSeleccionadas.includes(row.categoria));
    },
  },
  methods: {
    abrirPopup(pregunta) {
      this.preguntaSeleccionada = { ...pregunta };
      this.popupVisible = true;
    },
    cerrarPopup() {
      this.popupVisible = false;
    },
    guardarCambios() {
      this.popupVisible = false;
    },
    buscarPregunta() {
      console.log("Buscando:", this.input);
      // Aquí podrías agregar lógica adicional para buscar preguntas por texto
    },
    filtrarCategorias() {
      // Actualiza el campo de búsqueda con las categorías seleccionadas

    },
    addPregunta() {},
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
  margin-top: 20px;
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
