<template>
  <footer class="footer">
    <div class="footer-container">
      <p>
        &copy; {{ year }} QuizMania.
        {{
          textosTraducidos["Todos los derechos reservados."] ||
          "Todos los derechos reservados."
        }}
      </p>
      <nav class="footer-nav">
        <a href="#">{{
          textosTraducidos["Política de Privacidad"] || "Política de Privacidad"
        }}</a>
        <a href="#">{{
          textosTraducidos["Términos y Condiciones"] || "Términos y Condiciones"
        }}</a>
      </nav>
    </div>
  </footer>
</template>

<script>
import axios from "axios";

export default {
  name: "Footer",
  data() {
    return {
      year: new Date().getFullYear(),
      textosTraducidos: {},
      traduccionesCargando: false,
      idiomaUsuario: "es",
    };
  },

  async mounted() {
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    if (this.idiomaUsuario !== "es") {
      await this.traducirContenido();
    }
  },

  methods: {
    async traducirTexto(texto) {
      if (/(^\d|:)/.test(texto) || this.idiomaUsuario === "es") return texto;
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

      const textosOriginales = {
        footer: [
          "Todos los derechos reservados.",
          "Política de Privacidad",
          "Términos y Condiciones",
        ],
      };

      const todosTextos = [...textosOriginales.footer];

      const traducciones = await Promise.all(
        todosTextos.map((texto) => this.traducirTexto(texto))
      );

      todosTextos.forEach((texto, index) => {
        this.textosTraducidos[texto] = traducciones[index];
      });

      this.traduccionesCargando = false;
    },
  },
};
</script>
<style scoped>
.footer {
  background-color: #5759cd;
  color: #fff;
  padding: 20px;
  text-align: center;
}

.footer-container {
  max-width: 1200px;
  margin: 0 auto;
}

.footer-nav {
  margin-top: 10px;
}

.footer-nav a {
  color: #fff;
  text-decoration: none;
  margin: 0 15px;
  font-weight: bold;
}

.footer-nav a:hover {
  text-decoration: underline;
}
</style>
