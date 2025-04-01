<template>
  <div class="csv-importer">
    <h1 class="titulo-csv">
      {{ textosTraducidos["IMPORTAR CSV"] || "IMPORTAR CSV" }}
    </h1>

    <!-- Mensaje de error -->
    <div v-if="errorMessage" class="error-message">
      {{ errorMessage }}
      <button @click="dismissError">x</button>
    </div>

    <!-- Mensaje de éxito -->
    <div v-if="successMessage" class="success-message">
      {{ successMessage }}
      <button @click="dismissSuccess">x</button>
    </div>

    <div class="csv-cards">
      <div
        v-for="(csv, index) in csvFiles"
        :key="index"
        class="csv-card"
        @click="importCsv(csv)"
      >
        <div class="csv-card-content">
          <h2>
            {{
              getTranslation(csv.name)[0].toUpperCase() +
              getTranslation(csv.name).slice(1).toLowerCase()
            }}
          </h2>
          <p>{{ getTranslation(csv.description) }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "CsvImporter",
  data() {
    return {
      csvFiles: [
        {
          name: "Categorías",
          action: "importCsvCategorias",
          description: "Importa datos de categorías",
        },
        {
          name: "Tarjetas",
          action: "importCsvTarjetas",
          description: "Importa datos de tarjetas",
        },
        {
          name: "Preguntas",
          action: "importCsvPreguntas",
          description: "Importa datos de preguntas",
        },
        {
          name: "Respuestas",
          action: "importCsvRespuestas",
          description: "Importa datos de respuestas",
        },
      ],
      errorMessage: "",
      successMessage: "",
      textosTraducidos: {},
      traduccionesCargando: false,
      idiomaUsuario: "es",
    };
  },
  async mounted() {
    // Detectar el idioma del navegador
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    if (this.idiomaUsuario !== "es") {
      await this.traducirContenido();
    }
  },
  methods: {
    async importCsv(csv) {
      try {
        const response = await axios.post("/api/index.php", {
          action: csv.action,
        });

        if (response.data.status === "success") {
          this.successMessage = this.getTranslation(response.data.mensaje);
          this.errorMessage = "";
        } else {
          this.errorMessage = this.getTranslation(response.data.mensaje);
          this.successMessage = "";
        }
      } catch (error) {
        this.errorMessage = this.getTranslation(
          "Error al importar el archivo CSV."
        );
        this.successMessage = "";
        console.error("Error en la solicitud:", error);
      }
    },

    dismissError() {
      this.errorMessage = "";
    },

    dismissSuccess() {
      this.successMessage = "";
    },

    getTranslation(texto) {
      return this.textosTraducidos[texto] || texto;
    },

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
      this.traduccionesCargando = true;

      // Lista de textos a traducir
      const textos = [
        "IMPORTAR CSV",
        "Categorías",
        "Tarjetas",
        "Preguntas",
        "Respuestas",
        "Importa datos de categorías",
        "Importa datos de tarjetas",
        "Importa datos de preguntas",
        "Importa datos de respuestas",
        "Error al importar el archivo CSV.",
        "Hubo un error en la respuesta del servidor.",
        // Agregar aquí los mensajes de error y éxito comunes que puedan venir del servidor
      ];

      // Traducir todos los textos
      const traducciones = await Promise.all(textos.map(this.traducirTexto));

      // Guardar las traducciones en el objeto
      textos.forEach((texto, index) => {
        this.textosTraducidos[texto] = traducciones[index];
      });

      // También traducir los nombres y descripciones de los archivos CSV
      this.csvFiles.forEach(async (csv) => {
        const nameTranslation = await this.traducirTexto(csv.name);
        const descTranslation = await this.traducirTexto(csv.description);

        this.textosTraducidos[csv.name] = nameTranslation;
        this.textosTraducidos[csv.description] = descTranslation;
      });

      this.traduccionesCargando = false;
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
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  font-size: 2rem;
}

.error-message,
.success-message {
  max-width: 800px;
  padding: 10px;
  border-radius: 5px;
  margin: 0 auto 20px;
  text-align: center;
  position: relative;
}

.error-message {
  background-color: #ffcccc;
  color: #a94442;
  border: 1px solid #a94442;
}

.success-message {
  background-color: #ccffcc;
  color: #155724;
  border: 1px solid #155724;
}

.error-message button,
.success-message button {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  background: transparent;
  border: none;
  font-size: 16px;
  cursor: pointer;
}

.csv-cards {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  justify-content: center;
}

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
</style>
