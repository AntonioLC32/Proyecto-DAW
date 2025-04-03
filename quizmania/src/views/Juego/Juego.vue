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
            <a v-if="!mitadUsada" href="#" @click.prevent="usarMitad">
              <div class="progreso">{{ progreso }}%</div>
            </a>
            <a v-if="!pistaUsada" href="#" @click.prevent="usarPista">
              <img
                src="../../assets/pista.png"
                alt="Pista"
                width="70px"
                height="70px"
              />
            </a>
            <a v-if="!skipUsada" href="#" @click.prevent="usarSkip">
              <img
                src="../../assets/siguiente.png"
                alt="Siguiente"
                width="70px"
                height="70px"
              />
            </a>
          </div>

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

    <div v-if="showGameOver" class="game-over-popup">
      <div class="popup-content">
        <h2>¡HAS PERDIDO!</h2>
        <p>Rondas completadas: {{ rondasTotales }}</p>
      </div>
    </div>

    <div v-if="traduccionesCargando" class="cargando-traduccion">
      Traduciendo pregunta...
    </div>
  </section>
</template>

<script>
import axios from "axios";
import { Howl } from 'howler';

export default {
  name: "Juego",
  data() {
    return {
      preguntas: [
        {
          pregunta: "",
          opciones: ["", "", "", ""],
          respuestaCorrecta: "",
          dificultad: "",
        },
      ],
      backgroundMusic: null,
      questionIndex: 0,
      respuestaSeleccionada: null,
      seleccionado: false,
      mitadUsada: false,
      pistaUsada: false,
      skipUsada: false,
      progreso: 50,
      vidas: 3,
      categoriaSeleccionada: null,
      userData: null,
      showGameOver: false,
      rondasTotales: 0,
      idiomaUsuario: "es",
      traduccionesCargando: false,
    };
  },

  mounted() {
    this.backgroundMusic = new Howl({
      src: '/src/assets/sounds/trivia.mp3',
      loop: false,
      volume: 0.5,
    });
    this.backgroundMusic.play();
    this.startTimer();

    if (sessionStorage.getItem("mitadUsada") === "true") {
      this.mitadUsada = true;
    }
    if (sessionStorage.getItem("pistaUsada") === "true") {
      this.pistaUsada = true;
    }
    if (sessionStorage.getItem("skipUsada") === "true") {
      this.skipUsada = true;
    }

    window.addEventListener("tiempoAgotado", this.tiempoAgotadoHandler);
    this.idiomaUsuario = navigator.language.split("-")[0] || "es";
    //this.idiomaUsuario = "en";

    this.categoriaSeleccionada = sessionStorage.getItem("categoria");
    this.userData = this.$cookies.get("user");

    const preguntaGuardada = sessionStorage.getItem("preguntaActual");
    if (preguntaGuardada) {
      this.preguntas[this.questionIndex] = JSON.parse(preguntaGuardada);
      this.progreso = sessionStorage.getItem("progreso") || 50;
    } else {
      this.cargarVidas();
      this.obtenerPregunta(this.categoriaSeleccionada);
    }
  },

  beforeDestroy() {
    window.removeEventListener("tiempoAgotado", this.tiempoAgotadoHandler);
    if (!this.showGameOver) {
      sessionStorage.removeItem("preguntaActual");
      sessionStorage.removeItem("preguntasUsadas");
    }
  },

  computed: {
    isRespuestaCorrecta() {
      return (opcion) =>
        this.seleccionado && opcion === this.preguntas[this.questionIndex].correcta;
    },
    isRespuestaIncorrecta() {
      return (opcion) =>
        this.seleccionado &&
        this.respuestaSeleccionada !== this.preguntas[this.questionIndex].correcta &&
        this.respuestaSeleccionada === opcion;
    },
  },


  methods: {
    usarSkip() {
      if (this.seleccionado) return;
      if (!this.skipUsada) {
        this.skipUsada = true;
        sessionStorage.setItem("skipUsada", "true");
        
        clearInterval(this.timerInterval);
        this.timer = 60;
        sessionStorage.setItem("tiempoRestante", "60");
        this.startTimer();

        this.obtenerPregunta(this.categoriaSeleccionada);
      }
    },


    startTimer() {
      const tiempoGuardado = sessionStorage.getItem("tiempoRestante");
      this.timer = tiempoGuardado ? parseInt(tiempoGuardado) : 60;

      this.timerInterval = setInterval(() => {
        if (this.timer > 0) {
          this.timer--;
          sessionStorage.setItem("tiempoRestante", this.timer.toString());

          const elapsed = 60 - this.timer;
          sessionStorage.setItem("tiempoTranscurrido", elapsed.toString());

          const minutes = Math.floor(elapsed / 60);
          const seconds = elapsed % 60;
          sessionStorage.setItem(
            "tiempoRonda",
            `${minutes.toString().padStart(2, "0")}:${seconds
              .toString()
              .padStart(2, "0")}`
          );
        } else {
          this.backgroundMusic.stop();
        }
      }, 1000);
    },

    async traducirTexto(texto) {
      if (
        /^\d+$/.test(texto) ||
        ["Fácil", "Media", "Difícil"].includes(texto)
      ) {
        return texto;
      }
      if (this.idiomaUsuario === "es") return texto;
      try {
        this.traduccionesCargando = true;
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
      } finally {
        this.traduccionesCargando = false;
      }
    },
    async obtenerPreguntaTraducida(preguntaOriginal) {
      try {
        const numOpciones = preguntaOriginal.opciones.length;
        const traducciones = await Promise.all([
          this.traducirTexto(preguntaOriginal.pregunta),
          ...preguntaOriginal.opciones.map((op) => this.traducirTexto(op)),
          this.traducirTexto(preguntaOriginal.dificultad),
          this.traducirTexto(preguntaOriginal.correcta || ""), // Asegurar que la traducción no sea undefined
        ]);

        return {
          ...preguntaOriginal,
          pregunta: traducciones[0],
          opciones: traducciones.slice(1, 1 + numOpciones),
          dificultad: traducciones[1 + numOpciones],
          respuestaCorrecta:
            traducciones[2 + numOpciones] || preguntaOriginal.correcta, // Fallback al original
        };
      } catch (error) {
        console.error("Error traduciendo pregunta:", error);
        return preguntaOriginal;
      }
    },

    async obtenerPregunta(categoriaSeleccionada) {
      try {
        const response = await axios.post(
          "/api/index.php?action=obtenerPreguntaJuego",
          {
            categoria: categoriaSeleccionada,
            exclude: JSON.parse(
              sessionStorage.getItem("preguntasUsadas") || "[]"
            ),
          }
        );

        if (response.data.status === "success") {
          const nuevaPregunta = response.data.data;
          console.log(nuevaPregunta);

          // Forzar traducción si el idioma es diferente
          if (this.idiomaUsuario !== "es") {
            //console.log("Iniciando traducción...");
            const preguntaTraducida = await this.obtenerPreguntaTraducida(
              nuevaPregunta
            );
            //console.log("Pregunta traducida:", preguntaTraducida);
            this.preguntas = [preguntaTraducida];
            sessionStorage.setItem(
              "preguntaActual",
              JSON.stringify(preguntaTraducida)
            );
          } else {
            this.preguntas = [nuevaPregunta];
            sessionStorage.setItem(
              "preguntaActual",
              JSON.stringify(nuevaPregunta)
            );
          }

          const preguntasUsadas = JSON.parse(
            sessionStorage.getItem("preguntasUsadas") || "[]"
          );
          preguntasUsadas.push(nuevaPregunta.id_pregunta);
          sessionStorage.setItem(
            "preguntasUsadas",
            JSON.stringify(preguntasUsadas)
          );
        }
      } catch (error) {
        console.error("Error al obtener pregunta:", error);
      }
    },

    tiempoAgotadoHandler() {
      if (!this.seleccionado) {
        clearInterval(this.timerInterval);
        this.seleccionado = true;
        this.procesarTiempoAgotado();
      }
    },

    async procesarTiempoAgotado() {
      try {
        const response = await axios.post(
          "/api/index.php?action=actualizarVidasPartida",
          {
            id_partida: sessionStorage.getItem("id_partida"),
            cambio: -1,
          }
        );

        if (response.data.status === "success") {
          this.vidas = response.data.vidas;
          if (response.data.estado === "finalizada") this.mostrarGameOver();
        }

        await this.guardarHistorialPregunta(false);
        this.redirigirASeleccionTema();
      } catch (error) {
        console.error("Error procesando tiempo agotado:", error);
      }
    },

    mostrarGameOver() {
      const ronda = parseInt(sessionStorage.getItem("ronda"), 10) || 0;
      this.rondasTotales = ronda;
      this.showGameOver = true;
      this.mitadUsada = false,
      this.pistaUsada = false,
      this.skipUsada = false,

      sessionStorage.removeItem("mitadUsada");
      sessionStorage.removeItem("pistaUsada");
      sessionStorage.removeItem("skipUsada");
      sessionStorage.removeItem("id_partida");
      sessionStorage.removeItem("preguntaActual");
      sessionStorage.removeItem("preguntasUsadas");
      sessionStorage.removeItem("tiempoRestante");

      setTimeout(() => {
        this.backgroundMusic.stop();
        this.$router.push("/").then(() => {
          location.reload();
          sessionStorage.removeItem("ronda");
        });
      }, 3000);
    },


    async redirigirASeleccionTema() {
      await axios.post("/api/index.php?action=insertarRonda", {
        id_partida: sessionStorage.getItem("id_partida"),
        tiempo: sessionStorage.getItem("tiempoTranscurrido") || 0,
        id_categoria: this.categoriaSeleccionada,
      });

      setTimeout(() => {
        this.seleccionado = false;
        this.$router.push("/selecciontema");
      }, 2000);
    },

    async seleccionarRespuesta(opcion) {
      if (!this.seleccionado) {
        clearInterval(this.timerInterval);

        this.respuestaSeleccionada = opcion;
        this.seleccionado = true;
        const esCorrecta = opcion === this.preguntas[this.questionIndex].correcta;


        try {
          if (!esCorrecta) {
            const soundWrong = new Howl({
                src: '/src/assets/sounds/wrong.wav',
                volume: 1,
              });
            soundWrong.play();
            const response = await axios.post(
              "/api/index.php?action=actualizarVidasPartida",
              {
                id_partida: sessionStorage.getItem("id_partida"),
                cambio: -1,
              }
            );
            this.vidas = response.data.vidas;
            if (response.data.estado === "finalizada") this.mostrarGameOver();
          }

          await this.guardarHistorialPregunta(esCorrecta);

          if (esCorrecta) {
            const soundCorrect = new Howl({
              src: '/src/assets/sounds/correct.wav',
              volume: 1,
            });
            soundCorrect.play();
            const puntos = { Fácil: 10, Media: 20, Difícil: 30 }[
              this.preguntas[this.questionIndex].dificultad
            ];
            if (puntos)
              await axios.post("/api/index.php?action=actualizarEstadisticas", {
                id_usuario: this.userData.id_usuario,
                nombre_categoria: this.categoriaSeleccionada,
                puntos: puntos,
              });
          }
        } finally {
          setTimeout(() => {
            this.siguientePregunta();
            this.seleccionado = false;
            this.respuestaSeleccionada = null;
          }, 2000);
        }
      }
    },

    async cargarVidas() {
      try {
        const response = await axios.post(
          "/api/index.php?action=obtenerVidasPartida",
          {
            id_partida: sessionStorage.getItem("id_partida"),
          }
        );
        this.vidas = response.data.vidas;
        if (response.data.estado === "finalizada") this.mostrarGameOver();
      } catch (error) {
        console.error("Error de conexión:", error);
      }
    },

    async siguientePregunta() {
      clearInterval(this.timerInterval);

      await axios.post("/api/index.php?action=insertarRonda", {
        id_partida: sessionStorage.getItem("id_partida"),
        tiempo: sessionStorage.getItem("tiempoTranscurrido") || 0,
        id_categoria: this.categoriaSeleccionada,
      });

      sessionStorage.removeItem("preguntaActual");
      sessionStorage.removeItem("tiempoRestante");

      if (this.vidas > 0) {
        this.backgroundMusic.stop();
        let ronda = parseInt(sessionStorage.getItem("ronda") || 1);
        sessionStorage.setItem("ronda", ++ronda);
        this.$router.push("/selecciontema");
      } else {
        this.mostrarGameOver();
      }
    },

    usarPista() {
      if (this.seleccionado) return;
      if (!this.pistaUsada) {
        const incorrectas = this.preguntas[this.questionIndex].opciones.filter(
          (opcion) =>
            opcion !== this.preguntas[this.questionIndex].respuestaCorrecta
        );

        if (incorrectas.length) {
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
        sessionStorage.setItem("pistaUsada", "true");
      }
    },

    usarMitad() {
      if (this.seleccionado) return;
      if (!this.mitadUsada) {
        const incorrectas = this.preguntas[this.questionIndex].opciones.filter(
          (opcion) =>
            opcion !== this.preguntas[this.questionIndex].respuestaCorrecta
        );

        if (incorrectas.length >= 2) {
          for (let i = 0; i < 2; i++) {
            const randomIndex = Math.floor(Math.random() * incorrectas.length);
            const opcionAEliminar = incorrectas[randomIndex];

            const eliminarIndex = this.preguntas[this.questionIndex].opciones.indexOf(opcionAEliminar);
            if (eliminarIndex !== -1) {
              this.preguntas[this.questionIndex].opciones.splice(eliminarIndex, 1);
            }

            incorrectas.splice(randomIndex, 1);
          }
        } else if (incorrectas.length === 1) {
          const eliminarIndex = this.preguntas[this.questionIndex].opciones.indexOf(incorrectas[0]);
          if (eliminarIndex !== -1) {
            this.preguntas[this.questionIndex].opciones.splice(eliminarIndex, 1);
          }
        }
        this.mitadUsada = true;
        sessionStorage.setItem("mitadUsada", "true");
      }
    },

    async guardarHistorialPregunta(acertada) {
      try {
        await axios.post("/api/index.php?action=guardarHistorialPregunta", {
          id_partida: sessionStorage.getItem("id_partida"),
          id_pregunta: this.preguntas[this.questionIndex].id_pregunta,
          acertada: acertada ? 1 : 0,
        });
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

.game-over-popup {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(225, 224, 255, 0.85);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.popup-content {
  background: #5759cd;
  padding: 2.5rem;
  border-radius: 15px;
  text-align: center;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 0 20px rgba(87, 89, 205, 0.4);
  border: 2px solid rgba(255, 255, 255, 0.3);
  animation: popIn 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.popup-content h2 {
  color: #fff;
  font-size: 2.5rem;
  margin: 0 0 1rem 0;
  text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.3);
}

.popup-content p {
  color: #fff;
  font-size: 1.5rem;
  margin: 0;
}

.popup-header {
  text-align: center;
  margin-bottom: 2rem;
}

.popup-header h2 {
  color: #fff;
  font-size: 2.8rem;
  margin: 1.5rem 0;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.popup-logo {
  width: 100px;
  height: auto;
  filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.2));
}

.stats-container {
  background: rgba(255, 255, 255, 0.08);
  border-radius: 15px;
  padding: 1.5rem;
  margin: 2rem 0;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  margin: 1rem 0;
  background: rgba(0, 0, 0, 0.15);
  border-radius: 10px;
}

.stat-label {
  color: #ffffffcc;
  font-size: 1.1rem;
  font-weight: 500;
}

.stat-value {
  color: #fff;
  font-size: 1.8rem;
  font-weight: 700;
}

.dificultad-final {
  color: #ff4757;
  text-shadow: 0 2px 4px rgba(255, 71, 87, 0.3);
}

.action-button {
  background: #26fb09;
  color: #1a1d28;
  border: none;
  padding: 1.2rem 3rem;
  font-size: 1.2rem;
  font-weight: 700;
  border-radius: 50px;
  cursor: pointer;
  transition: all 0.3s ease;
  width: 100%;
  max-width: 300px;
  margin-top: 1.5rem;
  box-shadow: 0 5px 15px rgba(38, 251, 9, 0.3);
}

.action-button:hover {
  background: #1fd600;
  transform: translateY(-2px);
  box-shadow: 0 7px 20px rgba(38, 251, 9, 0.4);
}

@keyframes popIn {
  0% {
    transform: scale(0.8) translateY(20px);
    opacity: 0;
  }
  100% {
    transform: scale(1) translateY(0);
    opacity: 1;
  }
}

@media (max-width: 768px) {
  .popup-content {
    padding: 1.8rem;
  }
  .popup-content h2 {
    font-size: 2rem;
  }
  .popup-content p {
    font-size: 1.3rem;
  }
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
  border: 0;
  transition: background-color 0.3s ease-in-out;
  min-height: 60px;
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

.progreso {
  transition: all 0.3s ease-in-out;
}

.progreso:hover {
  transform: scale(1.1);
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
