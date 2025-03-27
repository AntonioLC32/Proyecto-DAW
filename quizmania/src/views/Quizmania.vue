<template>
  <section class="inicio">
    <button class="instrucciones-btn" @click="showPopup = true">
      {{ textosTraducidos["INSTRUCCIONES"] || "INSTRUCCIONES" }}
    </button>

    <div v-if="showPopup" class="popup">
      <div class="popup-content">
        <button class="close-btn" @click="showPopup = false">✖</button>
        <section class="instrucciones">
          <div class="modos">
            <div class="modo">
              <h2>
                <u>{{
                  textosTraducidos["Modo solitario"] || "Modo solitario"
                }}</u>
              </h2>
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
            <div class="barra"></div>
            <div class="modo">
              <h2>
                <u>{{
                  textosTraducidos["Modo multijugador"] || "Modo multijugador"
                }}</u>
              </h2>
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
            <div class="barra2"></div>
          </div>
          <div class="comodines">
            <h2>
              <u>{{ textosTraducidos["Comodines"] || "Comodines" }}</u>
            </h2>
            <p>
              50/50:
              {{
                textosTraducidos[
                  "Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta."
                ] ||
                "Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta."
              }}
            </p>
            <p>
              {{ textosTraducidos["Pista"] || "Pista" }}:
              {{
                textosTraducidos[
                  "Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta."
                ] ||
                "Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta."
              }}
            </p>
            <p>
              {{ textosTraducidos["Salto"] || "Salto" }}:
              {{
                textosTraducidos[
                  "Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta)."
                ] ||
                "Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta)."
              }}
            </p>
          </div>
        </section>
      </div>
    </div>

    <div class="juegos">
      <button class="juego" @click="navegarA('solitario')">
        <span class="juego-link">{{
          textosTraducidos["Modo solitario"] || "Modo solitario"
        }}</span>
      </button>
      <button class="juego" @click="navegarA('multijugador')">
        <span class="juego-link">{{
          textosTraducidos["Modo multijugador"] || "Modo multijugador"
        }}</span>
      </button>
    </div>
  </section>
</template>

<script>
import axios from "axios";

export default {
  name: "Quizmania",
  data() {
    return {
      showPopup: false,
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
    navegarA(modo) {
      sessionStorage.setItem("modo-juego", modo);
      this.$router.push("/selecciontema");
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

      const textosOriginales = [
        "INSTRUCCIONES",
        "Modo solitario",
        "Acierta tantas preguntas como puedas y supérate a ti mismo.",
        "Tienes 3 vidas y pierdes una cada vez que fallas.",
        "El juego termina cuando pierdas todas tus vidas.",
        "Modo multijugador",
        "Responde preguntas de todo tipo.",
        "Cada 3 preguntas correctas, en la siguiente puedes ganar una corona.",
        "Cada categoría tiene una corona propia.",
        "Consigue las 10 coronas y gana la partida.",
        "Comodines",
        "Se eliminarán 2 opciones incorrectas de las opciones a elegir de la pregunta.",
        "Se eliminará 1 opción incorrecta de las opciones a elegir de la pregunta.",
        "Se salta la pregunta actual y se continúa con otra pregunta (no cuenta como correcta).",
        "Pista",
        "Salto",
      ];

      const traducciones = await Promise.all(
        textosOriginales.map((texto) => this.traducirTexto(texto))
      );

      textosOriginales.forEach((texto, index) => {
        this.textosTraducidos[texto] = traducciones[index];
      });

      this.traduccionesCargando = false;
    },
  },
};
</script>

<style scoped>
.inicio {
  background: url("../assets/background_inicio.png") no-repeat center center
    fixed;
  background-size: cover;
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding-top: 80px; /* Espacio para el header */
}

.instrucciones-btn {
  position: fixed; /* Cambiado a fixed para mejor control */
  top: 120px; /* Ajustado para dar espacio al header */
  left: 30px;
  background: linear-gradient(135deg, #5759cd, #4a4da5);
  color: #fff;
  font-family: "Montserrat", sans-serif;
  font-weight: bold;
  width: 300px;
  height: 80px;
  font-size: 26px;
  border-radius: 25px;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(87, 89, 205, 0.3);
  z-index: 10; /* Asegura que esté por encima del contenido pero debajo del popup */
}

.instrucciones-btn:hover {
  background: linear-gradient(135deg, #4a4da5, #3f418a);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(87, 89, 205, 0.4);
}

.popup {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.8);
  display: flex;
  justify-content: center;
  align-items: flex-start; /* Cambiado para mejor control del scroll */
  backdrop-filter: blur(5px);
  z-index: 1000; /* Asegura que esté por encima de todo */
  padding-top: 80px; /* Espacio para el header */
  overflow-y: auto;
}

.popup-content {
  color: #fff;
  padding: 30px;
  width: 100%;
  position: relative;
  max-height: calc(100vh - 100px); /* Ajustado para considerar el header */
  overflow-y: auto;
}

.close-btn {
  position: absolute;
  top: 55px;
  right: 20px;
  background: none;
  border: none;
  font-size: 30px;
  color: #fff;
  cursor: pointer;
  transition: all 0.3s ease;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background-color: rgba(255, 255, 255, 0.1);
  transform: rotate(90deg);
}

.instrucciones h2 {
  font-size: 50px;
  font-weight: bold;
}

.instrucciones p {
  margin-top: 20px;
  font-size: 24px;
  font-weight: bold;
}

.modos {
  display: flex;
  justify-content: center;
  gap: 50px;
}

.modo {
  width: 40%;
  margin-top: 70px;
  margin-left: 10px;
}

.barra {
  background-color: #fff;
  width: 5px;
  height: auto;
  margin-top: 70px;
}

.barra2 {
  background-color: #fff;
  width: 0px;
  height: auto;
  margin-top: 70px;
}

.comodines {
  width: 90%;
  margin-top: 20px;
  padding-left: 5%;
  margin-left: 5%;
  padding-bottom: 5%;
}

.juegos {
  display: flex;
  justify-content: center;
  flex-direction: row;
  margin: 0 10%;
  height: 30%;
  gap: 20%;
}

.juego {
  background: linear-gradient(135deg, #5759cd, #4a4da5);
  border: none;
  border-radius: 25px;
  width: 100%;
  height: 100%;
  margin-top: 50px;
  font-size: 50px;
  color: white;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(87, 89, 205, 0.3);
  padding: 0;
}

.juego:hover {
  background: linear-gradient(135deg, #4a4da5, #3f418a);
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(87, 89, 205, 0.5);
}

.juego-link {
  text-decoration: none;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  border-radius: 25px;
}

@media (max-width: 1200px) {
  .popup {
    align-items: flex-start;
    overflow-y: auto;
  }

  .popup-content {
    margin-top: 10%;
    max-height: none;
    height: auto;
    overflow-y: visible;
    padding-bottom: 50px;
  }

  .instrucciones-btn {
    width: 250px;
    height: 70px;
    font-size: 22px;
  }

  .instrucciones h2 {
    font-size: 3vw;
    font-weight: bold;
  }

  .instrucciones p {
    font-size: 2vw;
    font-weight: bold;
  }

  .juegos {
    flex-direction: column;
    gap: 30px;
    align-items: center;
  }

  .juego {
    width: 90%;
    min-height: 200px;
    font-size: 40px;
  }

  .modos {
    padding-top: 40px;
    flex-direction: column;
    align-items: center;
  }

  .modo {
    width: 80%;
    margin-top: 10px;
  }

  .barra {
    width: 80%;
    height: 3px;
    margin-top: 5px;
  }

  .barra2 {
    width: 80%;
    height: 3px;
    margin-top: 5px;
  }

  .comodines {
    margin-top: 50px;
  }
}

@media (max-width: 768px) {
  .instrucciones-btn {
    top: 100px; /* Ajustado para móvil */
    left: 15px;
    width: 200px;
    height: 60px;
    font-size: 20px;
  }

  .popup {
    padding-top: 50px; /* Ajustado para móvil */
  }

  .popup-content {
    padding: 20px;
    margin-top: 10px;
  }

  .close-btn {
    top: 25px; /* Ajustado para móvil */
    right: 15px;
  }

  .instrucciones h2 {
    font-size: 24px; /* Tamaño más pequeño en móvil */
  }

  .instrucciones p {
    font-size: 16px; /* Tamaño más pequeño en móvil */
  }

  .juego {
    min-height: 150px;
    font-size: 32px;
  }
}

/* Para pantallas muy pequeñas */
@media (max-width: 480px) {
  .instrucciones-btn {
    width: 180px;
    height: 50px;
    font-size: 18px;
    top: 70px;
  }

  .popup {
    padding-top: 40px;
  }

  .instrucciones h2 {
    font-size: 20px;
  }

  .instrucciones p {
    font-size: 14px;
    margin-top: 15px;
  }
}
</style>
