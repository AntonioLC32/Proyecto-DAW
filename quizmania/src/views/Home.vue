<template>
  <section class="game-landing">
    <div class="hero">
      <div class="hero-content">
        <router-link v-if="userData" to="/quizmania" class="play-link">
          {{ textosTraducidos["¡A JUGAR!"] || "¡A JUGAR!" }}
        </router-link>
        <router-link v-else to="/login" class="play-link">
          {{ textosTraducidos["Inicia sesión"] || "Inicia sesión" }}
        </router-link>
      </div>
      <img
        src="../assets/background_inicio.png"
        alt="Fondo de inicio del juego"
        class="hero-image"
      />
    </div>

    <section class="game-modes">
      <div class="modes-container">
        <div class="mode-card">
          <h2 class="mode-title">
            {{ textosTraducidos["Modo solitario"] || "Modo solitario" }}
          </h2>
          <div class="mode-content">
            <p>
              {{
                textosTraducidos[
                  "Acierta tantas preguntas como puedas y supérate a ti mismo."
                ] ||
                "Acierta tantas preguntas como puedas y supérate a ti mismo."
              }}
            </p>
            <p>
              {{
                textosTraducidos[
                  "Tienes 3 vidas y pierdes una cada vez que fallas."
                ] || "Tienes 3 vidas y pierdes una cada vez que fallas."
              }}
            </p>
            <p>
              {{
                textosTraducidos[
                  "El juego termina cuando pierdas todas tus vidas."
                ] || "El juego termina cuando pierdas todas tus vidas."
              }}
            </p>
          </div>
        </div>

        <div class="mode-divider"></div>

        <div class="mode-card">
          <h2 class="mode-title">
            {{ textosTraducidos["Modo multijugador"] || "Modo multijugador" }}
          </h2>
          <div class="mode-content">
            <p>
              {{
                textosTraducidos["Responde preguntas de todo tipo."] ||
                "Responde preguntas de todo tipo."
              }}
            </p>
            <p>
              {{
                textosTraducidos[
                  "Cada 3 preguntas correctas, en la siguiente puedes ganar una corona."
                ] ||
                "Cada 3 preguntas correctas, en la siguiente puedes ganar una corona."
              }}
            </p>
            <p>
              {{
                textosTraducidos["Cada categoría tiene una corona propia."] ||
                "Cada categoría tiene una corona propia."
              }}
            </p>
            <p>
              {{
                textosTraducidos[
                  "Consigue las 10 coronas y gana la partida."
                ] || "Consigue las 10 coronas y gana la partida."
              }}
            </p>
          </div>
        </div>
      </div>

      <div class="powerups">
        <h2 class="powerups-title">
          {{ textosTraducidos["Comodines"] || "Comodines" }}
        </h2>
        <div class="powerups-content">
          <p>
            <strong>{{ textosTraducidos["50/50"] || "50/50:" }}</strong>
            {{
              textosTraducidos[
                "Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta."
              ] ||
              "Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta."
            }}
          </p>
          <p>
            <strong>{{ textosTraducidos["Pista"] || "Pista:" }}</strong>
            {{
              textosTraducidos[
                "Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta."
              ] ||
              "Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta."
            }}
          </p>
          <p>
            <strong>{{ textosTraducidos["Salto"] || "Salto:" }}</strong>
            {{
              textosTraducidos[
                "Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta)."
              ] ||
              "Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta)."
            }}
          </p>
        </div>
      </div>
    </section>

    <Footer />
  </section>
</template>
<script>
import axios from "axios";
import Footer from "./Footer.vue";

export default {
  name: "Home",
  components: {
    Footer,
  },
  data() {
    return {
      userData: null,
      idiomaUsuario: "es",
      textosTraducidos: {},
      traduccionesCargando: false,
    };
  },

  async mounted() {
    this.userData = this.$cookies.get("user");
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
        solo: [
          "Modo solitario",
          "Acierta tantas preguntas como puedas y supérate a ti mismo.",
          "Tienes 3 vidas y pierdes una cada vez que fallas.",
          "El juego termina cuando pierdas todas tus vidas.",
        ],
        multi: [
          "Modo multijugador",
          "Responde preguntas de todo tipo.",
          "Cada 3 preguntas correctas, en la siguiente puedes ganar una corona.",
          "Cada categoría tiene una corona propia.",
          "Consigue las 10 coronas y gana la partida.",
        ],
        powerups: [
          "Comodines",
          "50/50",
          "Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta.",
          "Pista",
          "Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta.",
          "Salto",
          "Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta).",
          "¡A JUGAR!",
          "Inicia sesión",
        ],
      };

      const todosTextos = [
        ...textosOriginales.solo,
        ...textosOriginales.multi,
        ...textosOriginales.powerups,
      ];

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
.game-landing {
  min-height: 100vh;
  background-color: #f5f5f5;
}

.hero {
  position: relative;
  height: 80vh;
  overflow: hidden;
}

.hero-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: filter 0.3s ease;
}

.hero-content {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 2;
}

.play-link {
  color: white;
  text-decoration: none;
  font-size: 2.5rem;
  font-weight: 700;
  font-family: "Montserrat", sans-serif;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
  background: linear-gradient(135deg, #6366f1, #4f46e5);
  padding: 1.5rem 3rem;
  border: none;
  border-radius: 1rem;
  box-shadow: 0 4px 20px rgba(79, 70, 229, 0.3);
  transition: all 0.3s ease;
  cursor: pointer;
  white-space: nowrap;
}

.play-link:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(79, 70, 229, 0.4);
  background: linear-gradient(135deg, #4f46e5, #4338ca);
}

.game-modes {
  background: linear-gradient(135deg, #8d89f8, #6366f1);
  padding: 4rem 2rem;
  color: white;
}

.modes-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  gap: 3rem;
  justify-content: center;
  align-items: stretch;
}

.mode-card {
  flex: 1;
  max-width: 500px;
  padding: 2rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 1rem;
  backdrop-filter: blur(10px);
  transition: transform 0.3s ease;
}

.mode-card:hover {
  transform: translateY(-5px);
}

.mode-title {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  text-decoration: underline;
  text-underline-offset: 0.5rem;
}

.mode-content p {
  margin: 1rem 0;
  font-size: 1.1rem;
  line-height: 1.6;
}

.mode-divider {
  width: 3px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 3px;
}

.powerups:hover {
  transform: translateY(-5px);
}

.powerups {
  max-width: 1200px;
  margin: 4rem auto 0;
  padding: 2rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 1rem;
  backdrop-filter: blur(10px);
  transition: transform 0.3s ease;
}

.powerups-title {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  text-decoration: underline;
  text-underline-offset: 0.5rem;
}

.powerups-content p {
  margin: 1rem 0;
  font-size: 1.1rem;
  line-height: 1.6;
}

@media (max-width: 1024px) {
  .modes-container {
    flex-direction: column;
    gap: 2rem;
  }

  .mode-divider {
    height: 3px;
    width: 80%;
    margin: 0 auto;
  }

  .mode-card {
    max-width: 100%;
  }

  .play-link {
    font-size: 2rem;
    /* Puedes ajustar el padding aquí si es necesario */
  }

  .mode-title,
  .powerups-title {
    font-size: 1.8rem;
  }

  .mode-content p,
  .powerups-content p {
    font-size: 1rem;
  }
}

@media (max-width: 640px) {
  .hero {
    height: 60vh;
  }

  /* Ajuste para que el botón se vea completo en una sola línea */
  .play-link {
    font-size: 1.5rem;
    padding: 1rem 2rem;
    white-space: nowrap;
  }

  .game-modes {
    padding: 2rem 1rem;
  }
}
</style>
