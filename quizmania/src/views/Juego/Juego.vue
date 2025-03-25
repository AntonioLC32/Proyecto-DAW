<template>
  <section>
    <div class="division">
      <div class="left">
        <div class="encase">
          <div class="pregunta slide-in">
            <span
              v-if="preguntas[questionIndex].dificultad"
              class="dificultad"
              :class="{
                'dificultad-facil':
                  preguntas[questionIndex].dificultad === 'Fácil',
                'dificultad-media':
                  preguntas[questionIndex].dificultad === 'Media',
                'dificultad-dificil':
                  preguntas[questionIndex].dificultad === 'Difícil',
              }"
            >
              {{ preguntas[questionIndex].dificultad.toUpperCase() }}
            </span>
            <p>{{ preguntas[questionIndex].pregunta }}</p>
          </div>

          <button
            class="respuesta slide-in-hidden"
            v-for="(opcion, index) in preguntas[questionIndex].opciones"
            :key="opcion"
            :style="{ animationDelay: index * 0.4 + 0.8 + 's' }"
            :class="{
              correcta: isRespuestaCorrecta(opcion),
              incorrecta: isRespuestaIncorrecta(opcion),
            }"
            @click="seleccionarRespuesta(opcion)"
          >
            <p>{{ opcion }}</p>
          </button>

          <div class="misc">
            <div class="progreso">{{ progreso }}%</div>
            <a href="#" @click.prevent="usarPista">
              <img
                src="../../assets/pista.png"
                alt="Pista"
                width="70px"
                height="70px"
              />
            </a>
            <a href="#" @click.prevent="siguientePregunta">
              <img
                src="../../assets/siguiente.png"
                alt="Siguiente"
                width="70px"
                height="70px"
              />
            </a>
          </div>

          <!-- Corazones reposicionados debajo de los comodines -->
          <div class="vidas-container">
            <img
              v-for="(corazon, index) in vidas"
              :key="index"
              src="../../assets/corazon.png"
              alt="Corazón"
              width="60px"
              height="60px"
              class="corazon"
            />
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: "Juego",
  data() {
    return {
      preguntas: [
        {
          pregunta: "",
          opciones: ["", "", "", ""],
          respuestaCorrecta: "",
        },
      ],
      questionIndex: 0,
      respuestaSeleccionada: null,
      seleccionado: false,
      pistaUsada: false,
      progreso: 50,
      vidas: 3,
      categoriaSeleccionada: null,
      userData: null,
    };
  },

  mounted() {
    this.categoriaSeleccionada = sessionStorage.getItem("categoria");
    //console.log(this.categoriaSeleccionada);
    this.userData = this.$cookies.get("user");
    this.obtenerPregunta(this.categoriaSeleccionada);
  },
  computed: {
    isRespuestaCorrecta() {
      return (opcion) =>
        this.seleccionado &&
        this.respuestaSeleccionada ===
          this.preguntas[this.questionIndex].respuestaCorrecta &&
        opcion === this.preguntas[this.questionIndex].respuestaCorrecta;
    },
    isRespuestaIncorrecta() {
      return (opcion) =>
        this.seleccionado &&
        this.respuestaSeleccionada !==
          this.preguntas[this.questionIndex].respuestaCorrecta &&
        this.respuestaSeleccionada === opcion;
    },
  },
  methods: {
    async obtenerPregunta(categoriaSeleccionada) {
      try {
        const response = await fetch(
          "/api/index.php?action=obtenerPreguntaJuego",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({ categoria: categoriaSeleccionada }),
          }
        );
        const data = await response.json();
        if (data.status === "success") {
          const preguntaObtenida = {
            id_pregunta: data.data.id_pregunta,
            pregunta: data.data.pregunta,
            opciones: data.data.opciones,
            respuestaCorrecta: data.data.correcta,
            dificultad: data.data.dificultad,
          };
          this.preguntas = [preguntaObtenida];
        } else {
          console.error("Error al obtener la pregunta:", data.mensaje);
        }
      } catch (error) {
        console.error("Error al obtener pregunta:", error);
      }
    },
    async seleccionarRespuesta(opcion) {
      if (!this.seleccionado) {
        this.respuestaSeleccionada = opcion;
        this.seleccionado = true;
        const esCorrecta =
          opcion === this.preguntas[this.questionIndex].respuestaCorrecta;

        if (esCorrecta) {
          const dificultad = this.preguntas[this.questionIndex].dificultad;
          let puntos = 0;

          switch (dificultad) {
            case "Fácil":
              puntos = 10;
              break;
            case "Media":
              puntos = 20;
              break;
            case "Difícil":
              puntos = 30;
              break;
            default:
              console.warn("Dificultad no reconocida:", dificultad);
              puntos = 0;
          }

          if (puntos > 0) {
            await this.actualizarEstadisticas(puntos);
            await this.guardarHistorialPregunta(esCorrecta);
          }
        } else {
          this.vidas = Math.max(0, this.vidas - 1);
          await this.guardarHistorialPregunta(esCorrecta);
        }

        setTimeout(() => {
          this.siguientePregunta();
          this.seleccionado = false;
          this.respuestaSeleccionada = null;
        }, 2000);
      }
    },

    async guardarHistorialPregunta(acertada) {
      try {
        const response = await fetch(
          "/api/index.php?action=guardarHistorialPregunta",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              id_partida: sessionStorage.getItem("id_partida"),
              id_pregunta: this.preguntas[this.questionIndex].id_pregunta,
              acertada: acertada ? 1 : 0,
            }),
          }
        );

        const data = await response.json();
        if (data.status !== "success") {
          console.error("Error guardando historial:", data.mensaje);
        }
      } catch (error) {
        console.error("Error:", error);
      }
    },

    usarPista() {
      if (!this.pistaUsada) {
        const incorrectas = this.preguntas[this.questionIndex].opciones.filter(
          (opcion) =>
            opcion !== this.preguntas[this.questionIndex].respuestaCorrecta
        );

        if (incorrectas.length > 0) {
          const eliminarIndex = this.preguntas[
            this.questionIndex
          ].opciones.indexOf(
            incorrectas[Math.floor(Math.random() * incorrectas.length)]
          );
          if (eliminarIndex !== -1) {
            this.preguntas[this.questionIndex].opciones.splice(
              eliminarIndex,
              1
            );
          }
        }

        this.pistaUsada = true;
      }
    },
    async siguientePregunta() {
      try {
        const response = await fetch("/api/index.php?action=insertarRonda", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            id_partida: sessionStorage.getItem("id_partida"),
            tiempo: "00:01:00",
            id_categoria: sessionStorage.getItem("categoria"),
          }),
        });

        const data = await response.json();

        if (data.status === "success") {
          await fetch("/api/index.php?action=actualizarEstadoPartida", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              id_partida: sessionStorage.getItem("id_partida"),
              estado: this.vidas > 0 ? "activa" : "finalizada",
            }),
          });

          if (this.vidas > 0) {
            let rondaActual = parseInt(
              sessionStorage.getItem("ronda") || "1",
              10
            );
            rondaActual++;
            sessionStorage.setItem("ronda", rondaActual.toString());
            this.$router.push("/selecciontema");
          } else {
            this.$router.push("/resultado");
          }
        } else {
          console.error("Error insertando ronda:", data.mensaje);
        }
      } catch (error) {
        console.error("Error en la solicitud:", error);
      }
    },
    async actualizarEstadisticas(puntos) {
      try {
        const response = await fetch(
          "/api/index.php?action=actualizarEstadisticas",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              id_usuario: this.userData.id_usuario,
              nombre_categoria: sessionStorage.getItem("categoria"),
              puntos: puntos,
            }),
          }
        );
        const data = await response.json();
        if (data.status !== "success") {
          console.error("Error actualizando estadísticas:", data.mensaje);
        }
      } catch (error) {
        console.error("Error:", error);
      }
    },
  },
};
</script>

<style scoped>
* {
  box-sizing: border-box;
  font-family: "Montserrat", sans-serif;
}

.division {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  min-height: 100vh;
  position: relative;
  margin-top: 60px;
}

.left {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 70vw;
}

.encase {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
}

section {
  background-color: #e1e0ff;
  min-height: 100vh;
  overflow-y: hidden;
}

.pregunta {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: #5759cd;
  border-radius: 15px;
  width: 80%;
  padding: 20px 30px;
  margin-bottom: 20px;
  text-align: center;
  filter: drop-shadow(0 10px 0px #5759cd35);
  min-height: 120px;
  max-width: 800px;
}

.dificultad {
  font-size: 24px;
  font-weight: bold;
  padding: 5px 10px;
  border-radius: 5px;
  margin-bottom: 10px;
  display: inline-block;
}

.dificultad-facil {
  color: #36ec5f;
}

.dificultad-media {
  color: #ffc107;
}

.dificultad-dificil {
  color: #dc3545;
}

.pregunta p {
  font-size: 24px;
  font-weight: bold;
  color: white;
  margin: 0;
}

.pregunta p {
  font-size: 24px;
  font-weight: bold;
  color: white;
  margin: 0;
}

.respuesta {
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #5759cd;
  border-radius: 10px;
  width: 80%;
  max-width: 800px;
  padding: 15px;
  margin-bottom: 20px;
  filter: drop-shadow(0 10px 0px #5759cd35);
  border: 0px;
  transition: background-color 0.3s ease-in-out;
  min-height: 60px; /* Altura mínima para mantener proporción */
}

.respuesta:hover {
  background-color: #8e8fcd;
}

.respuesta p {
  font-size: 20px;
  font-weight: bold;
  color: white;
  margin: 0;
}

/* Colores de respuestas */
.correcta {
  background-color: #26fb09 !important;
  filter: drop-shadow(0 10px 0px #26fb0935);
}

.incorrecta {
  background-color: #ff0707 !important;
  filter: drop-shadow(0 10px 0px #ff070735);
}

.misc {
  display: flex;
  flex-direction: row;
  gap: 30px;
  max-height: 70px;
  margin-top: 20px;
  margin-bottom: 20px;
  align-items: center;
}

.misc img {
  transition: all 0.3s ease-in-out;
}

.misc img:hover {
  transform: scale(1.1);
}

.progreso {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  border-radius: 50%;
  width: 70px;
  height: 70px;
  background-color: #5759cd;
  border: 5px solid #4a4da5;
  font-size: 24px;
}

.vidas-container {
  display: flex;
  justify-content: center;
  gap: 10px;
  margin-top: 10px;
}

.corazon {
  animation: pulseHeart 1.5s infinite alternate;
}

@keyframes pulseHeart {
  from {
    transform: scale(1);
  }
  to {
    transform: scale(1.1);
  }
}

@keyframes scaleIn {
  0% {
    opacity: 0;
    transform: scale(0.5);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

.slide-in {
  animation: scaleIn 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

@keyframes scaleInWithDelay {
  0% {
    opacity: 0;
    transform: scale(0.5);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

.slide-in-hidden {
  opacity: 0;
  animation: scaleInWithDelay 1s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
}

@media (max-width: 1024px) {
  .pregunta {
    width: 90%;
  }

  .left {
    width: 80vw;
  }
}

@media (max-width: 768px) {
  .division {
    flex-direction: column;
    margin-top: 80px;
  }

  .left {
    width: 100%;
  }

  .pregunta {
    width: 95%;
    font-size: 22px;
  }

  .respuesta {
    width: 95%;
    font-size: 18px;
    padding: 12px;
  }

  .progreso {
    width: 60px;
    height: 60px;
    font-size: 20px;
  }
}

@media (max-width: 480px) {
  .pregunta {
    padding: 15px;
    min-height: 100px;
  }

  .pregunta p {
    font-size: 18px;
  }

  .respuesta {
    font-size: 16px;
    padding: 10px;
    min-height: 50px;
  }

  .misc {
    gap: 15px;
  }

  .progreso {
    width: 50px;
    height: 50px;
    font-size: 16px;
  }

  .corazon {
    width: 40px;
    height: 40px;
  }
}

@media (max-height: 680px) {
  .pregunta {
    margin-top: 20px;
  }
}
</style>
