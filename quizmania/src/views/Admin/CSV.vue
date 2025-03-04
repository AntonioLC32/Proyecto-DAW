<template>
  <div class="csv-importer">
    <h1 class="titulo-csv">IMPORTAR CSV</h1>

    <!-- Mensaje de error -->
    <div v-if="errorMessage" class="error-message">
      {{ errorMessage }}
      <button @click="dismissError">x</button>
    </div>

    <div>
      <button @click="testConnection">Probar conexión</button>
      <p v-if="serverMessage">{{ serverMessage }}</p>
    </div>

    <div class="csv-cards">
      <div
        v-for="(csv, index) in csvFiles"
        :key="index"
        class="csv-card"
        @click="importCsv(csv)"
      >
        <div class="csv-card-content">
          <h2>{{ csv.name }}</h2>
          <p>{{ csv.description }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "CsvImporter",
  data() {
    return {
      csvFiles: [
        { name: "Categorías", description: "Importa datos de categorías" },
        { name: "Tarjetas", description: "Importa datos de tarjetas" },
        { name: "Preguntas", description: "Importa datos de preguntas" },
        { name: "Respuestas", description: "Importa datos de respuestas" },
      ],
      errorMessage: "", // Aquí se almacenará el mensaje de error
      serverMessage: "", // Aquí se almacenará el mensaje del servidor
    };
  },
  methods: {
    importCsv(csv) {
      // Simulación: Si el CSV es "Tarjetas", se muestra un mensaje de error.
      if (csv.name === "Tarjetas") {
        this.errorMessage = `Error: No se pudo importar ${csv.name}.`;
      } else {
        this.errorMessage = "";
        console.log(`Simulando la importación de ${csv.name}`);
      }
    },
    dismissError() {
      this.errorMessage = "";
    },

    testConnection() {
      fetch("/api/index.php") // En vez de "http://localhost/Proyecto-DAW/backend/index.php"
        .then((response) => response.json())
        .then((data) => {
          this.serverMessage = data.mensaje; // Muestra el mensaje desde el backend
        })
        .catch((error) => {
          console.error("Error:", error);
          this.serverMessage = "Hubo un error al conectar con el servidor.";
        });
    },
  },
};
</script>

<style scoped>
.csv-importer {
  margin-left: 60px;
  background: linear-gradient(to bottom, #8d89f8 0%, #8682eb 54%, #535192 100%);
  min-height: 100vh;
  padding: 20px;
  color: #333;
  font-family: Roboto, sans-serif;
  width: calc(100% - 60px);
}

.titulo-csv {
  margin-bottom: 20px;
  color: #fff;
  text-align: center;
  font-weight: bold;
}

.error-message {
  max-width: 800px;
  background-color: #ffcccc;
  color: #a94442;
  padding: 10px;
  border: 1px solid #a94442;
  border-radius: 5px;
  margin: 0 auto;
  margin-bottom: 20px;
  text-align: center;
  position: relative;
}

.error-message button {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  background: transparent;
  border: none;
  font-size: 16px;
  cursor: pointer;
  color: #a94442;
}

/* Contenedor para las tarjetas */
.csv-cards {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  justify-content: center;
}

/* Estilos para cada tarjeta */
.csv-card {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  flex: 1 1 250px;
  max-width: 300px;
  min-width: 200px;
  height: 150px;
  cursor: pointer;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.csv-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
}

.csv-card-content {
  text-align: center;
  padding: 10px;
}

.csv-card-content h2 {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.csv-card-content p {
  margin: 5px 0 0;
  font-size: 14px;
  color: #666;
}

/* Responsividad */
@media (max-width: 768px) {
  .csv-card {
    flex: 1 1 45%;
  }
}

@media (max-width: 480px) {
  .csv-card {
    flex: 1 1 100%;
  }
}
</style>
