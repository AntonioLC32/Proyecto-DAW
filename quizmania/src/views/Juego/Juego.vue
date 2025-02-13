<template>
  <section>
    <div class="division">
      <div class="left">
        <div class="encase">
          <div class="pregunta">
            <p>{{ preguntas[questionIndex].pregunta }}</p>
          </div>

          <button
            class="respuesta"
            v-for="opcion in preguntas[questionIndex].opciones"
            :key="opcion"
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
        </div>
      </div>
      <div class="right">
        <div class="encase gap-5">
          <img
            v-for="(corazon, index) in vidas"
            :key="index"
            src="../../assets/corazon.png"
            alt="Corazón"
            width="80px"
            height="80px"
          />
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: "PreguntaThriller",
  data() {
    return {
      preguntas: [
        {
          pregunta: "¿Quién hizo la canción Thriller?",
          opciones: [
            "Jason Derulo",
            "Bon Jovi",
            "Miley Cyrus",
            "Michael Jackson",
          ],
          respuestaCorrecta: "Michael Jackson",
        },
      ],
      questionIndex: 0, // Índice de la pregunta actual
      respuestaSeleccionada: null,
      seleccionado: false,
      pistaUsada: false,
      progreso: 50,
      vidas: 3,
    };
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
    seleccionarRespuesta(opcion) {
      if (!this.seleccionado) {
        this.respuestaSeleccionada = opcion;
        this.seleccionado = true;

        // Reducimos vidas si la respuesta es incorrecta
        if (opcion !== this.preguntas[this.questionIndex].respuestaCorrecta) {
          this.vidas = Math.max(0, this.vidas - 1); // Aseguramos que no baje de 0
        }
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
    siguientePregunta() {
      this.$router.push("/selecciontema");
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
  margin-top: 20px;
}

.left {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 60%;
}

.right {
  width: 20%;
  position: absolute;
  right: 10%;
  top: 15%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.right .encase {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
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
  align-items: center;
  justify-content: center;
  background-color: #5759cd;
  border-radius: 15px;
  width: 80%;
  padding: 150px;
  margin-bottom: 20px;
  text-align: center;
  filter: drop-shadow(0 10px 0px #5759cd35);
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
  padding: 15px;
  margin-bottom: 20px;
  filter: drop-shadow(0 10px 0px #5759cd35);
  border: 0px;
  transition: background-color 0.3s ease-in-out;
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
  align-items: center;
}

.misc img,
.right img {
  transition: all 0.3s ease-in-out;
}

.misc img:hover,
.right img:hover {
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

/* --- MEDIA QUERIES --- */
@media (max-width: 1024px) {
  .pregunta {
    width: 100%;
    padding: 120px;
  }
  .left {
    width: 70%;
  }

  .right .encase {
    padding-left: 200px;
  }
  .right img {
    width: 60px;
    height: 60px;
  }
}

@media (max-width: 768px) {
  .division {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .left,
  .right {
    width: 100%;
  }

  .right {
    flex-direction: row !important;
    justify-content: center;
    gap: 15px;
    margin-top: 20px;
  }

  .right .encase {
    display: flex;
    flex-direction: row;
    justify-content: center;
    width: 100%;
  }

  .right img {
    width: 60px;
    height: 60px;
  }

  .pregunta {
    width: 95%;
    padding: 40px;
    font-size: 22px;
    margin-top: 180px !important;
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
    font-size: 16px;
    padding: 60px;
    margin-top: 200px !important;
  }

  .respuesta {
    font-size: 14px;
    padding: 10px;
  }

  .right {
    display: flex;
    flex-direction: row !important;
    justify-content: center;
    gap: 15px;
    margin-top: 20px;
  }

  .right .encase img {
    width: 50px;
    height: 50px;
  }

  .right .encase {
    display: flex;
    flex-direction: row;
    justify-content: center;
    width: 100%;
  }

  .misc {
    gap: 15px;
  }

  .progreso {
    width: 50px;
    height: 50px;
    font-size: 16px;
  }

  .right img {
    width: 60px;
    height: 60px;
  }
}
</style>
